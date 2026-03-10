# Magento 2 — DB Query & CSV Export Best Practices

Two mandatory rules for Magento 2 projects.

---

## Rule 1 — No Raw SQL: Always Use the Query Builder

### Why

Writing raw SQL strings bypasses Magento's query builder protections:
- **SQL injection risk** — user or config values are not automatically quoted
- **Table prefix ignored** — raw SQL hardcodes table names; Magento installations may use a prefix
- **Not auditable** — raw strings cannot be inspected or modified by plugins/observers

Always use `$connection->select()` from `\Magento\Framework\App\ResourceConnection`.

### Bad — Never Do This

```php
$sql = <<<SQL
    SELECT cpe.sku, cpe.entity_id AS product_id
    FROM catalog_product_entity cpe
    JOIN cataloginventory_stock_item csi
        ON csi.product_id = cpe.entity_id AND csi.stock_id = 1
    WHERE ea.attribute_code = 'status'
SQL;
return $connection->fetchAll($sql);
```

```php
// Inline string with variable — SQL injection
$sql = "SELECT * FROM catalog_product_entity WHERE sku = '" . $sku . "'";
$connection->query($sql);
```

### Good — Always Do This

```php
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
```

### Key Methods Reference

| Need | Method |
|------|--------|
| Start query | `$connection->select()` |
| Main table | `->from(['alias' => getTableName('table')], ['col', 'alias' => 'col'])` |
| INNER JOIN | `->join(['alias' => getTableName('table')], 'condition', ['cols'])` |
| LEFT JOIN | `->joinLeft(...)` |
| Safe value | `$connection->quoteInto('col = ?', $value)` |
| Raw expression | `new \Zend_Db_Expr('ROUND(col)')` |
| WHERE | `->where('col = ?', $value)` |
| ORDER | `->order('col ASC')` |
| LIMIT | `->limit(100)` |
| Fetch all rows | `$connection->fetchAll($select)` |
| Fetch single value | `$connection->fetchOne($select)` |
| Fetch key=>value pairs | `$connection->fetchPairs($select)` |

### Required Injection

```php
use Magento\Framework\App\ResourceConnection;

/** @var \Magento\Framework\App\ResourceConnection */
private ResourceConnection $resourceConnection;

public function __construct(ResourceConnection $resourceConnection)
{
    $this->resourceConnection = $resourceConnection;
}
```

---

## Rule 2 — CSV Export via Adapter Class

### Why

Inlining CSV logic (file open/write/close + line formatting) inside a service or console command mixes responsibilities. It cannot be reused, is hard to test, and any format change requires hunting through business logic.

Magento's `AbstractAdapter` (`\Magento\ImportExport\Model\Export\Adapter\AbstractAdapter`) is **not suitable** for custom exports — it is locked to `var/import_export/` and carries admin-download API surface (`getContents`, `getContentType`).

Create a **standalone adapter** in `Model/Export/Adapter/`.

### Bad — Never Do This

```php
// File logic inlined in service — mixes responsibilities
private function writeCsv(array $rows): void
{
    $handle = $this->fileDriver->fileOpen($filePath, 'w');
    $this->fileDriver->fileWrite($handle, '"sku"|"qty"' . "\n");
    foreach ($rows as $row) {
        $this->fileDriver->fileWrite($handle, '"' . implode('"|"', [$row['sku'], $row['qty']]) . '"' . "\n");
    }
    $this->fileDriver->fileClose($handle);
}
```

### Good — Create an Adapter

**`app/code/Vendor/Module/Model/Export/Adapter/Csv.php`**

```php
<?php
declare(strict_types=1);

namespace Vendor\Module\Model\Export\Adapter;

use Magento\Framework\Filesystem\Driver\File as FileDriver;

class Csv
{
    private const DELIMITER = '|';
    private const ENCLOSURE = '"';

    /** @var \Magento\Framework\Filesystem\Driver\File */
    private FileDriver $fileDriver;

    /** @var array */
    private array $headerCols = [];

    /** @var resource|null */
    private $fileHandle = null;

    public function __construct(FileDriver $fileDriver)
    {
        $this->fileDriver = $fileDriver;
    }

    public function open(string $filePath): void
    {
        $dir = $this->fileDriver->getParentDirectory($filePath);
        if (!$this->fileDriver->isExists($dir)) {
            $this->fileDriver->createDirectory($dir, 0755);
        }
        $this->fileHandle = $this->fileDriver->fileOpen($filePath, 'w');
        $this->headerCols = [];
    }

    public function setHeaderCols(array $cols): void
    {
        $this->headerCols = $cols;
        $this->fileDriver->fileWrite($this->fileHandle, $this->formatRow($cols));
    }

    public function writeRow(array $rowData): void
    {
        $row = [];
        foreach ($this->headerCols as $col) {
            $row[] = $rowData[$col] ?? '';
        }
        $this->fileDriver->fileWrite($this->fileHandle, $this->formatRow($row));
    }

    public function close(): void
    {
        if ($this->fileHandle !== null) {
            $this->fileDriver->fileClose($this->fileHandle);
            $this->fileHandle = null;
        }
    }

    private function formatRow(array $fields): string
    {
        return self::ENCLOSURE
            . implode(self::ENCLOSURE . self::DELIMITER . self::ENCLOSURE, $fields)
            . self::ENCLOSURE . "\n";
    }
}
```

**Usage in service:**

```php
use Vendor\Module\Model\Export\Adapter\Csv as CsvAdapter;

private const HEADER = ['sku', 'product_id', 'qty', 'status'];

/** @var \Vendor\Module\Model\Export\Adapter\Csv */
private CsvAdapter $csvAdapter;

private function writeCsv(array $rows): void
{
    $this->csvAdapter->open($this->getExportFilePath());
    $this->csvAdapter->setHeaderCols(self::HEADER);

    foreach ($rows as $row) {
        $this->csvAdapter->writeRow([
            'sku'        => $row['sku'],
            'product_id' => (string) $row['product_id'],
            'qty'        => (string) (int) $row['qty'],
            'status'     => $row['status_value'] == 1 ? 'Enabled' : 'Disabled',
        ]);
    }

    $this->csvAdapter->close();
}
```

### Why Not Extend AbstractAdapter?

| | `AbstractAdapter` | Custom `Adapter\Csv` |
|---|---|---|
| Output path | Fixed `var/import_export/` | Any absolute path |
| API surface | Admin download methods | Only open/write/close |
| Coupling | `Filesystem` + `DirectoryList` | Only `FileDriver` |
| Use case | Admin catalog export | CLI / scheduled export |

### Conventions

- No constructor property promotion — explicit `@var` docblocks + `$this->x = $x` assignments.
- Adapter in `Model/Export/Adapter/` of the module that owns the export.
- One adapter class per format (pipe-CSV, comma-CSV) — no `$delimiter` generic param.
