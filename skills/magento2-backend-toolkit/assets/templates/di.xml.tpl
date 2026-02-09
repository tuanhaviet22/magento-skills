<?xml version="1.0"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="urn:magento:framework:ObjectManager/etc/config.xsd">
    <type name="{Target\Class\Full\Path}">
        <plugin name="{vendor}_{module}_{plugin_name}"
                type="{Vendor}\{Module}\Plugin\{PluginName}"
                sortOrder="10"/>
    </type>
</config>
