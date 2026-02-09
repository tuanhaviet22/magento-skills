<?xml version="1.0"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="urn:magento:framework:Event/etc/events.xsd">
    <event name="{event_name}">
        <observer name="{vendor}_{module}_{observer_name}"
                  instance="{Vendor}\{Module}\Observer\{ObserverName}"/>
    </event>
</config>
