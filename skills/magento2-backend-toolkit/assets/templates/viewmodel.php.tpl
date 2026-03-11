<?php

declare(strict_types=1);

namespace {Vendor}\{Module}\ViewModel;

use Magento\Framework\View\Element\Block\ArgumentInterface;

class {ViewModelName} implements ArgumentInterface
{
    // /**
    //  * @var \Some\Dependency
    //  */
    // private SomeDependency $dependency;

    /**
     * @param \Some\Dependency $dependency
     */
    public function __construct(
        // inject dependencies here
    ) {
        // $this->dependency = $dependency;
    }

    /**
     * Get items
     *
     * @return array
     */
    public function getItems(): array
    {
        // Your data logic here
        return [];
    }
}
