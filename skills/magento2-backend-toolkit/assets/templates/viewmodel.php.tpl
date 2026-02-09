<?php

declare(strict_types=1);

namespace {Vendor}\{Module}\ViewModel;

use Magento\Framework\View\Element\Block\ArgumentInterface;

class {ViewModelName} implements ArgumentInterface
{
    public function __construct(
        // inject dependencies here
    ) {
    }

    /**
     * @return array
     */
    public function getItems(): array
    {
        // Your data logic here
        return [];
    }
}
