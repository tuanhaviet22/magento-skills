<?xml version="1.0"?>
<widgets xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="urn:magento:module:Magento_Widget:etc/widget.xsd">
    <widget id="{vendor}_{module}_{widget_id}"
            class="{Vendor}\{Module}\Block\Widget\{WidgetName}">
        <label translate="true">{Widget Label}</label>
        <description translate="true">{Widget Description}</description>
        <parameters>
            <parameter name="title" xsi:type="text" visible="true" sort_order="10">
                <label translate="true">Title</label>
            </parameter>
            <parameter name="template" xsi:type="select" visible="true" sort_order="20">
                <label translate="true">Template</label>
                <options>
                    <option name="default" value="{Vendor}_{Module}::widget/{widget_name}.phtml">
                        <label translate="true">Default</label>
                    </option>
                </options>
            </parameter>
        </parameters>
    </widget>
</widgets>
