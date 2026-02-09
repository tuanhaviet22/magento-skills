<?php

declare(strict_types=1);

namespace {Vendor}\{Module}\Block\Widget;

use Magento\Framework\View\Element\Template;
use Magento\Widget\Block\BlockInterface;

class {WidgetName} extends Template implements BlockInterface
{
    protected $_template = '{Vendor}_{Module}::widget/{widget_name}.phtml';

    public function getTitle(): string
    {
        return (string) $this->getData('title');
    }
}
