# Rule: CSV Export via Adapter Class

## Why

Inlining CSV file-writing logic (open handle, format line, close) inside a service or command class mixes responsibilities and makes the formatting logic untestable and non-reusable.

Magento's built-in `\Magento\ImportExport\Model\Export\Adapter\AbstractAdapter` exists but is **not suitable** for custom exports because:
- It is hard-wired to `var/import_export/` via `DirectoryList::VAR_IMPORT_EXPORT`
- It only supports relative paths inside that directory
- It carries API surface (`getContents`, `getContentType`, `getFileExtension`) meant for the admin export-download pipeline

For custom CLI/scheduled exports writing to arbitrary paths (e.g. `pub/media/lengow/`), create a **standalone adapter**.

## Bad — Never Do This

```php
// All file logic inlined in the service
private function writeCsv(array $rows): void
{
    $dir = $this->fileDriver->getParentDirectory($filePath);
    if (!$this->fileDriver->isExists($dir)) {
        $this->fileDriver->createDirectory($dir, 0755);
    }
    $handle = $this->fileDriver->fileOpen($filePath, 'w');

    // Header
    $this->fileDriver->fileWrite($handle, '"sku"|"product_id"|"qty"' . "\n");

    foreach ($rows as $row) {
        // Formatting logic duplicated everywhere
        $this->fileDriver->fileWrite(
            $handle,
            '"' . implode('"|"', [$row['sku'], $row['product_id'], $row['qty']]) . '"' . "\n"
        );
    }

    $this->fileDriver->fileClose($handle);
}
```

## Good — Create a Dedicated Adapter

### Step 1 — Create `Model/Export/Adapter/Csv.php`

Place it in your module: `app/code/Vendor/Module/Model/Export/Adapter/Csv.php`

```php
<?php
declare(strict_types=1);

namespace Vendor\Module\Model\Export\Adapter;

use Magento\Framework\Filesystem\Driver\File as FileDriver;

class Csv
{
    private const DELIMITER = '|';
    private const ENCLOSURE = '"';

    /**
     * @var \Magento\Framework\Filesystem\Driver\File
     */
    private FileDriver $fileDriver;

    /**
     * @var array
     */
    private array $headerCols = [];

    /**
     * @var resource|null
     */
    private $fileHandle = null;

    /**
     * @param \Magento\Framework\Filesystem\Driver\File $fileDriver
     */
    public function __construct(FileDriver $fileDriver)
    {
        $this->fileDriver = $fileDriver;
    }

    /**
     * Open (or overwrite) the destination file, create directory if needed.
     *
     * @param string $filePath Absolute path.
     *
     * @return void
     * @throws \Magento\Framework\Exception\FileSystemException
     */
    public function open(string $filePath): void
    {
        $dir = $this->fileDriver->getParentDirectory($filePath);
        if (!$this->fileDriver->isExists($dir)) {
            $this->fileDriver->createDirectory($dir, 0755);
        }
        $this->fileHandle = $this->fileDriver->fileOpen($filePath, 'w');
        $this->headerCols = [];
    }

    /**
     * Write header row and store column order for subsequent writeRow() calls.
     *
     * @param array $cols
     *
     * @return void
     * @throws \Magento\Framework\Exception\FileSystemException
     */
    public function setHeaderCols(array $cols): void
    {
        $this->headerCols = $cols;
        $this->fileDriver->fileWrite($this->fileHandle, $this->formatRow($cols));
    }

    /**
     * Write one data row. Keys must match headers set via setHeaderCols().
     * Missing keys default to empty string.
     *
     * @param array $rowData
     *
     * @return void
     * @throws \Magento\Framework\Exception\FileSystemException
     */
    public function writeRow(array $rowData): void
    {
        $row = [];
        foreach ($this->headerCols as $col) {
            $row[] = $rowData[$col] ?? '';
        }
        $this->fileDriver->fileWrite($this->fileHandle, $this->formatRow($row));
    }

    /**
     * Close the file handle.
     *
     * @return void
     * @throws \Magento\Framework\Exception\FileSystemException
     */
    public function close(): void
    {
        if ($this->fileHandle !== null) {
            $this->fileDriver->fileClose($this->fileHandle);
            $this->fileHandle = null;
        }
    }

    /**
     * @param array $fields
     * @return string
     */
    private function formatRow(array $fields): string
    {
        return self::ENCLOSURE
            . implode(self::ENCLOSURE . self::DELIMITER . self::ENCLOSURE, $fields)
            . self::ENCLOSURE . "\n";
    }
}
```

### Step 2 — Inject and Use in Your Service

```php
use Vendor\Module\Model\Export\Adapter\Csv as CsvAdapter;

private const HEADER = ['sku', 'product_id', 'epuise', 'qty', 'status', 'backorders'];

/**
 * @var \Vendor\Module\Model\Export\Adapter\Csv
 */
private CsvAdapter $csvAdapter;

public function __construct(CsvAdapter $csvAdapter, ...)
{
    $this->csvAdapter = $csvAdapter;
    // ...
}

private function writeCsv(array $rows): void
{
    $filePath = $this->getExportFilePath();
    $this->csvAdapter->open($filePath);
    $this->csvAdapter->setHeaderCols(self::HEADER);

    foreach ($rows as $row) {
        $this->csvAdapter->writeRow([
            'sku'        => $row['sku'],
            'product_id' => (string) $row['product_id'],
            'epuise'     => $row['is_in_stock'] ? 'non' : 'oui',
            'qty'        => (string) (int) $row['qty'],
            'status'     => $row['status_value'] == 1 ? 'Enabled' : 'Disabled',
            'backorders' => (string) $row['backorders'],
        ]);
    }

    $this->csvAdapter->close();
}
```

## Adapter Public API

| Method | Purpose |
|--------|---------|
| `open(string $filePath)` | Create directory if needed, open file for writing, reset headers |
| `setHeaderCols(array $cols)` | Write header row, store column order |
| `writeRow(array $rowData)` | Write one row by key mapping; missing keys → empty string |
| `close()` | Flush and close the file handle |

## Why Not Extend AbstractAdapter?

| Concern | AbstractAdapter | Custom Adapter |
|---------|----------------|----------------|
| Output path | Fixed: `var/import_export/` (relative) | Any absolute path |
| API surface | `getContents`, `getContentType`, `getFileExtension` (admin download) | Only `open/setHeaderCols/writeRow/close` |
| Coupling | Requires `Magento\Framework\Filesystem` + `DirectoryList` | Only `FileDriver` |
| Use case | Admin catalog export download | CLI / scheduled export to custom path |

## Convention Notes

- No constructor property promotion — use explicit `@var` docblocks and `$this->x = $x` in constructor body.
- Adapter lives in `Model/Export/Adapter/` inside the relevant module.
- One adapter per delimiter/format (pipe CSV, comma CSV, etc.) — do not add a `$delimiter` constructor param to a single generic class.
