# System.xml Field Types

| Type | XML type value | Notes |
|------|---------------|-------|
| Text | `text` | Simple text input |
| Textarea | `textarea` | Multiline text |
| Select | `select` | Requires `source_model` |
| Multiselect | `multiselect` | Requires `source_model` |
| Password | `obscure` | Masked input |
| Image | `image` | File upload for images |
| File | `file` | General file upload |
| Color | `text` | Use `frontend_model` for color picker |
| Editor | `editor` | WYSIWYG editor |
| Time | `time` | Time picker |
| Note | `note` | Display-only text |

## Common Source Models

| Source Model | Purpose |
|-------------|---------|
| `Magento\Config\Model\Config\Source\Yesno` | Yes/No dropdown |
| `Magento\Config\Model\Config\Source\Enabledisable` | Enable/Disable dropdown |
| `Magento\Config\Model\Config\Source\Locale` | Locale list |
| `Magento\Store\Model\Config\Source\Store` | Store list |
| `Magento\Catalog\Model\Category\Attribute\Source\Page` | CMS pages |
| `Magento\Cms\Model\Config\Source\Block` | CMS blocks |

## Visibility Attributes

Each field, group, and section supports:
- `showInDefault="1"` — Show in Default Config scope
- `showInWebsite="1"` — Show in Website scope
- `showInStore="1"` — Show in Store View scope

## Example: Select Field with Source Model

```xml
<field id="display_mode" translate="label" type="select" sortOrder="20"
       showInDefault="1" showInWebsite="1" showInStore="1">
    <label>Display Mode</label>
    <source_model>Vendor\Module\Model\Config\Source\DisplayMode</source_model>
</field>
```
