<?php

declare(strict_types=1);

namespace {Vendor}\{Module}\Helper;

use Magento\Framework\App\Helper\AbstractHelper;
use Magento\Framework\App\Helper\Context;
use Magento\Framework\Mail\Template\TransportBuilder;
use Magento\Framework\Translate\Inline\StateInterface;
use Magento\Store\Model\StoreManagerInterface;
use Psr\Log\LoggerInterface;

class Email extends AbstractHelper
{
    private const TEMPLATE_ID = '{vendor}_{module}_{template_id}';

    public function __construct(
        Context $context,
        private readonly TransportBuilder $transportBuilder,
        private readonly StateInterface $inlineTranslation,
        private readonly StoreManagerInterface $storeManager,
        private readonly LoggerInterface $logger
    ) {
        parent::__construct($context);
    }

    public function send(
        string $recipientEmail,
        string $recipientName,
        array $templateVars = []
    ): void {
        try {
            $this->inlineTranslation->suspend();

            $store = $this->storeManager->getStore();

            $transport = $this->transportBuilder
                ->setTemplateIdentifier(self::TEMPLATE_ID)
                ->setTemplateOptions([
                    'area'  => \Magento\Framework\App\Area::AREA_FRONTEND,
                    'store' => $store->getId(),
                ])
                ->setTemplateVars($templateVars)
                ->setFromByScope('general')
                ->addTo($recipientEmail, $recipientName)
                ->getTransport();

            $transport->sendMessage();
        } catch (\Exception $e) {
            $this->logger->error('Email send failed: ' . $e->getMessage());
        } finally {
            $this->inlineTranslation->resume();
        }
    }
}
