<?xml version="1.0"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="urn:magento:module:Magento_Email:etc/email_templates.xsd">
    <template id="{vendor}_{module}_{template_id}"
              label="{Template Label}"
              file="{Vendor}_{Module}::email/{template_id}.html"
              type="html"
              module="{Vendor}_{Module}"
              area="frontend"/>
</config>
