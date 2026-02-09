# Hyva ViewModel Best Practices

## Rules
1. Always implement `ArgumentInterface`
2. Inject dependencies via constructor
3. Keep ViewModels thin — delegate to services/repositories
4. Return typed data (arrays, collections, DTOs)
5. Use `$viewModels->require()` to load ViewModels in templates

## Available Hyva ViewModels

| ViewModel | Purpose |
|-----------|---------|
| `Hyva\Theme\ViewModel\HeroiconsOutline` | Outline icons |
| `Hyva\Theme\ViewModel\HeroiconsSolid` | Solid icons |
| `Hyva\Theme\ViewModel\SvgIcons` | Custom SVG icons |
| `Hyva\Theme\ViewModel\CurrentProduct` | Current product context |
| `Hyva\Theme\ViewModel\CurrentCategory` | Current category context |
| `Hyva\Theme\ViewModel\Cart` | Cart data |
| `Hyva\Theme\ViewModel\StoreConfig` | Store configuration values |
| `Hyva\Theme\ViewModel\Modal` | Modal dialog helper |
| `Hyva\Theme\ViewModel\Customer` | Customer session data |

## Template Pattern

```php
<?php
declare(strict_types=1);

use Vendor\Module\ViewModel\MyViewModel;
use Hyva\Theme\Model\ViewModelRegistry;
use Hyva\Theme\ViewModel\HeroiconsOutline;
use Magento\Framework\Escaper;
use Magento\Framework\View\Element\Template;

/** @var Template $block */
/** @var Escaper $escaper */
/** @var ViewModelRegistry $viewModels */

/** @var MyViewModel $myViewModel */
$myViewModel = $viewModels->require(MyViewModel::class);

/** @var HeroiconsOutline $heroicons */
$heroicons = $viewModels->require(HeroiconsOutline::class);
```

## Escaper Methods

| Method | Use For |
|--------|---------|
| `$escaper->escapeHtml()` | Text output |
| `$escaper->escapeHtmlAttr()` | HTML attribute values |
| `$escaper->escapeUrl()` | URL output |
| `$escaper->escapeJs()` | JavaScript strings |
| `$escaper->escapeCss()` | CSS values |

## Alpine.js Patterns in Hyva

```html
<div x-data="initComponent()"
     x-init="init()"
     class="my-4">
    <div x-show="isVisible" x-cloak>
        <!-- content -->
    </div>
</div>

<script>
    function initComponent() {
        return {
            isVisible: false,
            init() {
                // initialization logic
            }
        }
    }
</script>
```

## Icon Usage

```php
<?= $heroicons->chevronRightHtml('w-5 h-5 text-gray-500') ?>
<?= $heroicons->searchHtml('w-6 h-6') ?>
<?= $heroicons->shoppingCartHtml('w-5 h-5', 24, 24, ['aria-label' => 'Cart']) ?>
```
