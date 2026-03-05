---
name: magento2-db-performance
description: >
  Database query optimization patterns for Magento 2 — bulk operations, EAV
  manipulation, CSV multiselect replacement, and custom loggers.
  Use when writing migration scripts, Console Commands with DB loops, bulk
  update operations, or any code where a loop contains DB queries.
  DO NOT use for frontend, caching, indexing, or search performance topics.
metadata:
  author: tuanhaviet22
  version: 1.0.0
  tags: [magento2, performance, database, migration, eav, bulk]
  compatibility: Magento 2.4+, PHP 8.1+, MySQL/MariaDB
---

# Magento 2 DB Performance Patterns

## Query Reduction Summary

| Operation | Before | After |
|---|---|---|
| DELETE in loop | N queries | 1 query |
| UPDATE same value in loop | N queries | 1 per group |
| CSV multiselect UPDATE | N SELECTs + N UPDATEs | 1 UPDATE per duplicate ID |

---

## Pattern 1 — Bulk DELETE (IN clause)

**Anti-pattern:** `$connection->delete()` called inside a foreach loop.

```php
// BAD — N queries
foreach ($rows as $row) {
    $connection->delete($table, ['id = ?' => $row['id']]);
}
```

**Fix:** Collect IDs first, then delete once after the loop.

```php
// GOOD — 1 query
$ids = [];
foreach ($rows as $row) {
    // ... process ...
    $ids[] = $row['id'];
}
if (!empty($ids)) {
    $connection->delete($table, ['id IN (?)' => $ids]);
}
```

**When to apply:** Any loop that deletes rows by a scalar ID or key value.

---

## Pattern 2 — Bulk UPDATE same value (IN clause)

**Anti-pattern:** Calling `$connection->update()` per row when all rows get the same new value (e.g. merging duplicates to a canonical value).

```php
// BAD — N queries
foreach ($duplicates as $dupId) {
    $connection->update($table, ['value' => $canonical], ['value = ?' => $dupId]);
}
```

**Fix:** Collect all duplicate values and update in one shot.

```php
// GOOD — 1 query per group
$connection->update(
    $table,
    ['value' => $canonical],
    ['value IN (?)' => $duplicates]
);
```

**When to apply:** Multiple rows need to be set to the same new value (e.g. merging EAV option IDs, normalising foreign keys after deduplication).

---

## Pattern 3 — SQL-side CSV replacement (`FIND_IN_SET` + `REPLACE`)

Magento stores multiselect EAV values as comma-separated IDs in `catalog_product_entity_varchar` (e.g. `"12,45,78"`). Replacing one ID requires touching every row that contains it.

**Anti-pattern:** PHP fetch-loop-update.

```php
// BAD — N SELECTs + N UPDATEs
$rows = $connection->fetchAll("SELECT value_id, value FROM $table WHERE FIND_IN_SET($dupId, value)");
foreach ($rows as $row) {
    $parts = array_map('intval', explode(',', $row['value']));
    $parts = array_map(fn($v) => $v === $dupId ? $canonicalId : $v, $parts);
    $parts = array_unique($parts);
    $connection->update($table, ['value' => implode(',', $parts)], ['value_id = ?' => $row['value_id']]);
}
```

**Fix:** Single `UPDATE` with `FIND_IN_SET` condition and `Zend_Db_Expr` REPLACE/TRIM expression.

```php
// GOOD — 1 query
$affected = $connection->update(
    $table,
    [
        'value' => new \Zend_Db_Expr(
            "TRIM(',' FROM REPLACE(
                REPLACE(
                    CONCAT(',', value, ','),
                    ',$duplicateId,',
                    ',$canonicalId,'
                ),
                ',$canonicalId,$canonicalId,',
                ',$canonicalId,'
            ))"
        )
    ],
    ["FIND_IN_SET($duplicateId, value) > 0"]
);
```

**How it works:**
1. `CONCAT(',', value, ',')` — wrap value in commas so every element (including first and last) has a delimiter on both sides.
2. First `REPLACE` — swap `,{duplicate},` → `,{canonical},`.
3. Second `REPLACE` — collapse accidental double canonical `,$canonical,$canonical,` → `,$canonical,` (handles the case where canonical was already present in the row).
4. `TRIM(',')` — strip the leading/trailing commas added in step 1.

**When to apply:** Multiselect EAV values stored as comma-separated IDs in `catalog_product_entity_varchar` (or any CSV-in-varchar column). Also applicable to `catalog_product_entity_text` if the same storage pattern is used.

**Edge case:** If `$canonicalId` was already in the value before the replacement, step 3 prevents storing the canonical twice.

---

## General Rules

- Always collect IDs/values into an array **before** any DB call; never query inside a tight loop.
- Use `$connection->delete($table, ['col IN (?)' => $array])` — the `?` placeholder handles array binding automatically in Magento's `Zend_Db_Adapter`.
- Use `new \Zend_Db_Expr(...)` for raw SQL expressions in update `$bind` arrays.
- Use `FIND_IN_SET(needle, column)` in WHERE conditions — it is index-unfriendly but acceptable for batch migration scripts run once.
- Always check `!empty($ids)` before issuing a bulk DELETE or UPDATE to avoid accidental full-table operations.
- Log both to `$output->writeln()` (CLI) and `$this->logger->info()` (file) for auditability.
