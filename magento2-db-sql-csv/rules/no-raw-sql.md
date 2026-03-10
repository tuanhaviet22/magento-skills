# Rule: No Raw SQL — Use Magento Query Builder

## Why

Writing raw SQL strings (heredoc, inline strings, `$connection->query("SELECT ...")`) bypasses Magento's query builder protections and introduces SQL injection risk. Table names may also have a prefix that raw SQL ignores, causing errors in non-default installations.

Magento provides `\Magento\Framework\DB\Select` (via `$connection->select()`) which:
- Automatically quotes identifiers and values
- Handles table prefix via `getTableName()`
- Produces auditable, readable, testable query objects

## Bad — Never Do This

```php
// Raw heredoc SQL — SQL injection risk, ignores table prefix
$sql = <<<SQL
    SELECT
        cpe.sku,
        cpe.entity_id AS product_id,
        csi.is_in_stock,
        ROUND(csi.qty) AS qty
    FROM catalog_product_entity cpe
    JOIN cataloginventory_stock_item csi
        ON csi.product_id = cpe.entity_id AND csi.stock_id = 1
    WHERE ea.attribute_code = 'status'
    ORDER BY cpe.entity_id ASC
SQL;

return $connection->fetchAll($sql);
```

```php
// Inline string — same problem
$sql = "SELECT * FROM catalog_product_entity WHERE sku = '" . $sku . "'";
$connection->query($sql);
```

## Good — Always Do This

```php
private function fetchRows(): array
{
    $connection = $this->resourceConnection->getConnection();

    $select = $connection->select()
        ->from(
            ['cpe' => $this->resourceConnection->getTableName('catalog_product_entity')],
            ['sku', 'product_id' => 'entity_id']
        )
        ->join(
            ['csi' => $this->resourceConnection->getTableName('cataloginventory_stock_item')],
            'csi.product_id = cpe.entity_id AND csi.stock_id = 1',
            ['is_in_stock', 'qty' => new \Zend_Db_Expr('ROUND(csi.qty)'), 'backorders']
        )
        ->join(
            ['ea' => $this->resourceConnection->getTableName('eav_attribute')],
            $connection->quoteInto('ea.attribute_code = ? AND ea.entity_type_id = 4', 'status'),
            []
        )
        ->join(
            ['cpei' => $this->resourceConnection->getTableName('catalog_product_entity_int')],
            'cpei.entity_id = cpe.entity_id AND cpei.attribute_id = ea.attribute_id AND cpei.store_id = 0',
            ['status_value' => 'value']
        )
        ->order('cpe.entity_id ASC');

    return $connection->fetchAll($select);
}
```

## Key Methods

| Need | Method |
|------|--------|
| Start a query | `$connection->select()` |
| Main table | `->from(['alias' => $this->resourceConnection->getTableName('table_name')], ['col1', 'alias' => 'col2'])` |
| JOIN | `->join(['alias' => $this->resourceConnection->getTableName('table')], 'condition', ['cols'])` |
| LEFT JOIN | `->joinLeft(...)` |
| Safe value binding | `$connection->quoteInto('col = ?', $value)` |
| Raw SQL expression | `new \Zend_Db_Expr('ROUND(col)')` |
| WHERE | `->where('col = ?', $value)` |
| ORDER | `->order('col ASC')` |
| LIMIT | `->limit(100)` |
| Execute | `$connection->fetchAll($select)` / `fetchCol` / `fetchOne` / `fetchPairs` |

## Constructor Injection Required

```php
use Magento\Framework\App\ResourceConnection;

/** @var \Magento\Framework\App\ResourceConnection */
private ResourceConnection $resourceConnection;

public function __construct(ResourceConnection $resourceConnection)
{
    $this->resourceConnection = $resourceConnection;
}
```
