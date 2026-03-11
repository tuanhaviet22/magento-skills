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

    /**
     * @var \Magento\Framework\Mail\Template\TransportBuilder
     */
    private TransportBuilder $transportBuilder;

    /**
     * @var \Magento\Framework\Translate\Inline\StateInterface
     */
    private StateInterface $inlineTranslation;

    /**
     * @var \Magento\Store\Model\StoreManagerInterface
     */
    private StoreManagerInterface $storeManager;

    /**
     * @var \Psr\Log\LoggerInterface
     */
    private LoggerInterface $logger;

    /**
     * @param \Magento\Framework\App\Helper\Context $context
     * @param \Magento\Framework\Mail\Template\TransportBuilder $transportBuilder
     * @param \Magento\Framework\Translate\Inline\StateInterface $inlineTranslation
     * @param \Magento\Store\Model\StoreManagerInterface $storeManager
     * @param \Psr\Log\LoggerInterface $logger
     */
    public function __construct(
        Context $context,
        TransportBuilder $transportBuilder,
        StateInterface $inlineTranslation,
        StoreManagerInterface $storeManager,
        LoggerInterface $logger
    ) {
        parent::__construct($context);
        $this->transportBuilder = $transportBuilder;
        $this->inlineTranslation = $inlineTranslation;
        $this->storeManager = $storeManager;
        $this->logger = $logger;
    }

    /**
     * Send transactional email
     *
     * @param string $recipientEmail
     * @param string $recipientName
     * @param array $templateVars
     * @return void
     */
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
