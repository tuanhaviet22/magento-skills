<?php

declare(strict_types=1);

use {Vendor}\{Module}\ViewModel\{ViewModelName};
use Hyva\Theme\Model\ViewModelRegistry;
use Hyva\Theme\ViewModel\HeroiconsOutline;
use Magento\Framework\Escaper;
use Magento\Framework\View\Element\Template;

/** @var Template $block */
/** @var Escaper $escaper */
/** @var ViewModelRegistry $viewModels */

/** @var {ViewModelName} $myViewModel */
$myViewModel = $viewModels->require({ViewModelName}::class);

/** @var HeroiconsOutline $heroicons */
$heroicons = $viewModels->require(HeroiconsOutline::class);

$items = $myViewModel->getItems();
?>

<?php if (!empty($items)): ?>
<div x-data="initMyComponent()"
     x-init="init()"
     class="my-4">

    <h2 class="text-2xl font-bold mb-4">
        <?= $escaper->escapeHtml(__('Section Title')) ?>
    </h2>

    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <?php foreach ($items as $item): ?>
            <div class="border rounded-lg p-4 hover:shadow-lg transition-shadow"
                 @click="selectItem('<?= $escaper->escapeHtmlAttr($item['id']) ?>')">

                <div class="flex items-center gap-2 mb-2">
                    <?= $heroicons->chevronRightHtml('w-5 h-5 text-gray-500') ?>
                    <span class="font-semibold">
                        <?= $escaper->escapeHtml($item['name']) ?>
                    </span>
                </div>

                <p class="text-sm text-gray-600">
                    <?= $escaper->escapeHtml($item['description']) ?>
                </p>
            </div>
        <?php endforeach; ?>
    </div>

    <div x-show="selectedItem" x-cloak class="mt-4 p-4 bg-blue-50 rounded">
        <p x-text="selectedItem"></p>
    </div>
</div>

<script>
    function initMyComponent() {
        return {
            selectedItem: null,
            init() {
                // Initialize component
            },
            selectItem(itemId) {
                this.selectedItem = itemId;
            }
        }
    }
</script>
<?php endif; ?>
