# Widget Parameter Types

| xsi:type | Usage | Notes |
|----------|-------|-------|
| `text` | Simple text input | |
| `select` | Dropdown | Needs `<options>` child |
| `multiselect` | Multi-choice | Needs `<options>` child |
| `block` | Block/Page chooser | Needs `<block>` child |
| `conditions` | Catalog/Sales rule conditions | Complex widget |
| `label` | Display-only label | |

## Block Chooser Classes

| Class | Purpose |
|-------|---------|
| `Magento\Cms\Block\Adminhtml\Block\Widget\Chooser` | CMS Block chooser |
| `Magento\Cms\Block\Adminhtml\Page\Widget\Chooser` | CMS Page chooser |
| `Magento\Catalog\Block\Adminhtml\Product\Widget\Chooser` | Product chooser |
| `Magento\Catalog\Block\Adminhtml\Category\Widget\Chooser` | Category chooser |

## Example: Block Chooser Parameter

```xml
<parameter name="block_id" xsi:type="block" visible="true" sort_order="30">
    <label translate="true">CMS Block</label>
    <block class="Magento\Cms\Block\Adminhtml\Block\Widget\Chooser">
        <data>
            <item name="button" xsi:type="array">
                <item name="open" xsi:type="string">Select Block...</item>
            </item>
        </data>
    </block>
</parameter>
```

## Example: Select Parameter with Options

```xml
<parameter name="layout" xsi:type="select" visible="true" sort_order="10">
    <label translate="true">Layout</label>
    <options>
        <option name="grid" value="grid">
            <label translate="true">Grid</label>
        </option>
        <option name="list" value="list">
            <label translate="true">List</label>
        </option>
    </options>
</parameter>
```
