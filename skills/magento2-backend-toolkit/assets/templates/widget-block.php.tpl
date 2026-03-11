<?php

declare(strict_types=1);

namespace {Vendor}\{Module}\Block\Widget;

use Magento\Framework\View\Element\Template;
use Magento\Widget\Block\BlockInterface;

class {WidgetName} extends Template implements BlockInterface
{
    /**
     * @var string
     */
    protected $_template = '{Vendor}_{Module}::widget/{widget_name}.phtml';

    /**
     * Get widget title
     *
     * @return string
     */
    public function getTitle(): string
    {
        return (string) $this->getData('title');
    }
}
