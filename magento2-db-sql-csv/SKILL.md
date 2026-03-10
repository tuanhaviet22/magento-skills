---
name: magento2-db-sql-csv
description: Magento 2 best practices for database queries and CSV exports. Use when writing SQL queries, fetching data from DB, or exporting data to CSV files. Triggers on tasks involving raw SQL, SELECT queries, JOIN operations, CSV generation, or file export adapters. DO NOT use for frontend, caching, or search topics.
license: MIT
metadata:
  author: community
  version: "1.0.0"
---

# Magento 2 — DB Query & CSV Export Best Practices

Two mandatory rules for Magento 2 projects.

## Rules

| # | Rule | Severity |
|---|------|----------|
| 1 | Never write raw SQL — always use the Magento query builder | CRITICAL |
| 2 | Always use/create a CSV adapter class for file exports | REQUIRED |

---

## Rule 1 — No Raw SQL, Use Query Builder

Read: `rules/no-raw-sql.md`

## Rule 2 — CSV Export via Adapter

Read: `rules/csv-adapter.md`
