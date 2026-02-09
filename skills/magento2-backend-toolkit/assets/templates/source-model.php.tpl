<?php

declare(strict_types=1);

namespace {Vendor}\{Module}\Model\Config\Source;

use Magento\Framework\Data\OptionSourceInterface;

class {SourceName} implements OptionSourceInterface
{
    public function toOptionArray(): array
    {
        return [
            ['value' => 'option1', 'label' => __('Option 1')],
            ['value' => 'option2', 'label' => __('Option 2')],
        ];
    }
}
