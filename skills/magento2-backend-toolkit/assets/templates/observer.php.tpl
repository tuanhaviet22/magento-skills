<?php

declare(strict_types=1);

namespace {Vendor}\{Module}\Observer;

use Magento\Framework\Event\Observer;
use Magento\Framework\Event\ObserverInterface;

class {ObserverName} implements ObserverInterface
{
    public function execute(Observer $observer): void
    {
        $event = $observer->getEvent();
        // Your logic here
    }
}
