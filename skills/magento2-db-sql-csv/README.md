# magento2-db-sql-csv

A Claude Code skill enforcing two Magento 2 best practices for database queries and CSV exports.

## Rules

1. **No raw SQL** — always use `$connection->select()->from()->join()` (SQL injection prevention + table prefix support)
2. **CSV adapter** — always isolate file-writing logic in a dedicated `Model/Export/Adapter/Csv.php` class

## Install

```bash
claude skills install /path/to/magento2-db-sql-csv
```

## Triggers

Use this skill when:
- Writing or reviewing database queries in Magento 2 PHP code
- Building a service or console command that exports data to a CSV file
- Code review flags raw SQL or inline CSV logic
