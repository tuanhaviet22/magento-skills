---
name: magento2-custom-logger
description: >
  Custom per-class log files in Magento 2 using di.xml virtual types — no PHP
  class needed. Use when the user says "custom logger", "dedicated log file",
  "separate log file", "log to my own file", "virtual type logger", or wants
  a Console Command / Service to write to a specific var/log/ path.
  DO NOT use for general Magento logging via \Psr\Log\LoggerInterface already
  injected by the framework, or for frontend/JS logging.
metadata:
  author: tuanhaviet22
  version: 1.0.0
  tags: [magento2, logger, monolog, di.xml, virtual-type, console-command]
  compatibility: Magento 2.4+, PHP 8.1+
---

# Magento 2 Custom Logger via `di.xml` Virtual Types

Give any class its own dedicated log file without creating a real PHP Logger class — everything is wired through XML virtual types.

---

## How it works

Magento's DI container supports **virtual types**: named aliases for existing classes with different constructor arguments. Two virtual types are needed:

1. **Handler** — extends `Magento\Framework\Logger\Handler\Base`, sets `fileName`
2. **Logger** — extends `Magento\Framework\Logger\Monolog`, references the handler

---

## `etc/di.xml` snippet

```xml
<?xml version="1.0"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">

    <!-- 1. Handler: points to the log file -->
    <virtualType name="Vendor\Module\Logger\Handler\MyFeature"
                 type="Magento\Framework\Logger\Handler\Base">
        <arguments>
            <argument name="fileName" xsi:type="string">/var/log/my_feature.log</argument>
        </arguments>
    </virtualType>

    <!-- 2. Logger: named Monolog channel wrapping the handler -->
    <virtualType name="Vendor\Module\Logger\MyFeatureLogger"
                 type="Magento\Framework\Logger\Monolog">
        <arguments>
            <argument name="name" xsi:type="string">my_feature</argument>
            <argument name="handlers" xsi:type="array">
                <item name="debug" xsi:type="object">Vendor\Module\Logger\Handler\MyFeature</item>
            </argument>
        </arguments>
    </virtualType>

    <!-- 3. Inject into target class -->
    <type name="Vendor\Module\Console\Command\MyCommand">
        <arguments>
            <argument name="logger" xsi:type="object">Vendor\Module\Logger\MyFeatureLogger</argument>
        </arguments>
    </type>

</config>
```

---

## PHP class — constructor injection

Declare `LoggerInterface` in the constructor; DI injects the virtual logger automatically.

```php
use Psr\Log\LoggerInterface;
use Magento\Framework\App\ResourceConnection;

public function __construct(
    ResourceConnection $resource,
    LoggerInterface $logger,
    ?string $name = null         // only for Console Commands
) {
    $this->resource = $resource;
    $this->logger   = $logger;
    parent::__construct($name);  // only for Console Commands
}
```

No import of a concrete logger class — always type-hint against `Psr\Log\LoggerInterface`.

---

## Naming conventions

| Part | Convention | Example |
|---|---|---|
| Handler virtual type | `Vendor\Module\Logger\Handler\{Feature}` | `Distriartisan\Migration\Logger\Handler\FixData` |
| Logger virtual type | `Vendor\Module\Logger\{Feature}Logger` | `Distriartisan\Migration\Logger\FixDataLogger` |
| Monolog channel name | dot-separated, lowercase | `migrate.fix_data` |
| Log file path | `/var/log/{context}/{feature}.log` | `/var/log/migrate/fix_data.log` |

---

## Rules

- `fileName` is relative to `{MAGENTO_ROOT}` — the leading `/var/log/` maps to `{MAGENTO_ROOT}/var/log/`.
- The `handlers` array item key (`debug`) sets the **minimum log level** captured; `debug` captures everything. Use `info`, `warning`, or `error` to filter.
- One Handler + one Logger virtual type pair per log file destination.
- Virtual type names must be globally unique — namespace them under your module.
- Never inject a concrete logger class directly; always use `Psr\Log\LoggerInterface` in the PHP constructor.
- Works for any injectable class: Console Commands, Services, Observers, Plugins, etc.
- After adding or modifying `di.xml`, run `bin/magento setup:di:compile` (or `bin/magento cache:flush` in developer mode).
