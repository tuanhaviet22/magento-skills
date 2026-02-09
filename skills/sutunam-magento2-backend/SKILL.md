---
name: sutunam-magento2-backend
description: >
  Scaffold Magento 2 backend modules, system.xml admin configs, widgets,
  plugins/events/observers, transactional email, and Hyva-compatible templates
  with ViewModels — following Sutunam team conventions with Warden environment.
  Use when user asks to "create module", "scaffold module", "generate plugin",
  "add system config", "create widget", "setup email template", "create hyva
  template", or any Magento 2 backend code generation.
  Do NOT use for frontend-only tasks, CSS/JS theming, or Magento 1.x.
metadata:
  author: tuanhaviet22
  version: 1.0.0
  tags: [magento2, hyva, backend, scaffold, plugin, widget, email, sutunam, warden]
  compatibility: Magento 2.4.6+, PHP 8.1+, Hyva Theme 1.3+, Warden
---

# Sutunam Magento 2 Backend Toolkit

## CRITICAL: Sutunam-Specific Rules

### Warden Environment
- ALL Magento CLI commands MUST use Warden:
  `warden env exec php-fpm bin/magento <command>`
- NEVER run `bin/magento` directly
- NEVER run `rm -rf var/cache`, `rm -rf generated`, or any manual cache folder deletion
- To clear cache: `warden env exec php-fpm bin/magento cache:flush`

### Copyright Header — MANDATORY
- ALL new `.php`, `.xml`, and `.phtml` files MUST include the Sutunam copyright header
- Do NOT add copyright to `.js` or `.css` files
- Replace `{CURRENT_YEAR}` with the actual current year (e.g. 2025, 2026...)

**PHP files** (add before `declare(strict_types=1);`):
```php
/**
 *  @author    Sutunam
 *  @copyright Copyright (c) {CURRENT_YEAR} Sutunam <https://www.sutunam.com/>
 */
```

**XML files** (add as comment after `<?xml version="1.0"?>`):
```xml
<!--
 *  @author    Sutunam
 *  @copyright Copyright (c) {CURRENT_YEAR} Sutunam <https://www.sutunam.com/>
-->
```

**PHTML files** (add at the very top):
```php
<?php
/**
 *  @author    Sutunam
 *  @copyright Copyright (c) {CURRENT_YEAR} Sutunam <https://www.sutunam.com/>
 */
```

### Code Quality — PHPCS
- After writing or modifying any backend PHP file (Block, Model, Plugin, Observer,
  Helper, ViewModel, Controller), run:
  `make gitsniff`
- Fix any reported violations before considering the task complete

### Internationalization (i18n) — MANDATORY
- All user-facing text in code MUST be in English using `__('English text')`
- When developing a module in `app/code/`, ALWAYS create `i18n/en_US.csv`
  with all translatable strings
- French translations go in the theme folder:
  `app/design/frontend/{Vendor}/{Theme}/i18n/fr_FR.csv`
- The `fr_FR.csv` translates from en_US: `"English text","Texte en francais"`

### i18n File Formats

**Module-level** `app/code/{Vendor}/{Module}/i18n/en_US.csv`:
```csv
"Add to Cart","Add to Cart"
"Brand Name","Brand Name"
```

**Theme-level** `app/design/frontend/{Vendor}/{Theme}/i18n/fr_FR.csv` (append new lines):
```csv
"Add to Cart","Ajouter au panier"
"Brand Name","Nom de la marque"
```

---

## General Rules

- All generated code MUST follow PSR-12 coding standard
- All PHP files MUST have `declare(strict_types=1);`
- Use strict type hints on all method parameters and return types
- Namespace follows: `Vendor\Module\Path` convention
- XML files must include proper XSD schema references
- Default Vendor name: ask user, suggest `Sutunam` if not specified
- NEVER use ObjectManager directly — only use DI
- Always create `composer.json` with new modules

## CRITICAL: Input Validation Gate

NEVER generate files without confirming required inputs. If user gives a vague
request, ask ALL missing fields in ONE message. Do not ask one by one.

---

## Feature 1: Module Scaffold

### Required Questions (ask if not provided)
1. **Module name?** (e.g. `Sutunam_Brand`)
2. **Dependencies?** (e.g. `Magento_Catalog`, or "none")
3. **Short description?** (for composer.json)
4. **Version?** (default: `1.0.0`)

### Generated Files
```
app/code/{Vendor}/{Module}/
├── registration.php
├── composer.json
├── etc/
│   └── module.xml
└── i18n/
    └── en_US.csv
```

Use templates from `magento2-backend-toolkit/assets/templates/registration.php.tpl`,
`magento2-backend-toolkit/assets/templates/module.xml.tpl`, and `magento2-backend-toolkit/assets/templates/composer.json.tpl`.

If no dependencies, omit the `<sequence>` block entirely in module.xml.

ALWAYS create `i18n/en_US.csv` (even if empty initially) for every new module.

### Post-Generation Steps
```bash
warden env exec php-fpm bin/magento module:enable {Vendor}_{Module}
warden env exec php-fpm bin/magento setup:upgrade
warden env exec php-fpm bin/magento cache:flush
```

### Example Interaction
**User:** "Create a module to manage brands"
**Claude responds:**
> To create the module, I need to confirm:
> 1. Module name? Suggest: `Sutunam_Brand`
> 2. Dependencies? (e.g. `Magento_Catalog`, `Magento_Eav`... or none)
> 3. Short description? Suggest: "Brand management for Magento 2"
> 4. Version? (default: 1.0.0)

---

## Feature 2: System.xml Generator

### Required Questions
1. **Module name?** (existing or new)
2. **Tab name?** (admin menu tab label)
3. **Section/Group/Fields?** Describe what config fields are needed

### Supported Field Types
Refer to `magento2-backend-toolkit/references/system-xml-field-types.md` for the complete list.
Common types: `text`, `textarea`, `select`, `multiselect`, `obscure`, `image`, `editor`.

### Generated Files
```
etc/
├── adminhtml/
│   └── system.xml
└── config.xml
```

Use templates from `magento2-backend-toolkit/assets/templates/system.xml.tpl` and `magento2-backend-toolkit/assets/templates/config.xml.tpl`.

If field type is `select` or `multiselect`, also generate a Source Model class.
See template: `magento2-backend-toolkit/assets/templates/source-model.php.tpl`.

### ACL Resource
Always generate `{Vendor}_{Module}::config` as the resource identifier.

### Post-Generation
Run `make gitsniff` to validate code style.

---

## Feature 3: Widget Generator

### Required Questions
1. **Module name?**
2. **Widget name/label?** (e.g. "Brand Slider")
3. **Parameters?** (text inputs, dropdowns, template chooser, block chooser...)
4. **Where to use?** CMS Page / CMS Block / Layout XML

### Generated Files
```
etc/
└── widget.xml
Block/
└── Widget/
    └── {WidgetName}.php
view/
└── frontend/
    └── templates/
        └── widget/
            └── {widget_name}.phtml
```

Use templates from `magento2-backend-toolkit/assets/templates/widget.xml.tpl` and `magento2-backend-toolkit/assets/templates/widget-block.php.tpl`.

Refer to `magento2-backend-toolkit/references/widget-param-types.md` for parameter type details and
block chooser classes.

### CMS Usage Snippet
Always provide the CMS widget insertion code after generating files:
```
{{widget type="{Vendor}\{Module}\Block\Widget\{WidgetName}" title="My Title" template="{Vendor}_{Module}::widget/{widget_name}.phtml"}}
```

### Post-Generation
1. Run `make gitsniff` to validate Block PHP code
2. Add translatable strings to `i18n/en_US.csv`
3. Add FR translations to `app/design/frontend/{Vendor}/{Theme}/i18n/fr_FR.csv`

---

## Feature 4: Plugin / Event Generator

### Required Questions
1. **Module name?**
2. **Type?** `plugin` (before/after/around) or `observer` (event)
3. **Target?**
   - Plugin: target class + method (e.g. `Magento\Catalog\Model\Product::getName`)
   - Observer: event name (e.g. `checkout_cart_add_product_complete`)
4. **What to do?** Brief description of logic
5. **Scope?** global / frontend / adminhtml (determines XML file location)

### Plugin — Generated Files
```
etc/
└── {scope}/di.xml       (or etc/di.xml for global)
Plugin/
└── {PluginName}.php
```

Use templates from `magento2-backend-toolkit/assets/templates/di.xml.tpl` and `magento2-backend-toolkit/assets/templates/plugin.php.tpl`.

### Observer — Generated Files
```
etc/
└── {scope}/events.xml   (or etc/events.xml for global)
Observer/
└── {ObserverName}.php
```

Use templates from `magento2-backend-toolkit/assets/templates/events.xml.tpl` and `magento2-backend-toolkit/assets/templates/observer.php.tpl`.

### Common Events
Suggest these when user is unsure. For the full list, refer to:
https://developer.adobe.com/commerce/php/development/components/events-and-observers/event-list/

### Post-Generation
Run `make gitsniff` to validate PHP code.

---

## Feature 5: Email Function Generator

### Required Questions
1. **Module name?**
2. **Email purpose?** (e.g. "welcome email", "order status notification")
3. **Trigger method?** Choose one:
   - After Plugin (on existing method)
   - Event Observer
   - Controller action
4. **Email variables?** (e.g. customer name, order ID)
5. **Recipient?** (customer email, admin email, custom)

### Generated Files
```
etc/
└── email_templates.xml
Helper/
└── Email.php
view/
└── frontend/
    └── email/
        └── {template_id}.html
```

Use templates from `magento2-backend-toolkit/assets/templates/email_templates.xml.tpl`,
`magento2-backend-toolkit/assets/templates/email_helper.php.tpl`, and `magento2-backend-toolkit/assets/templates/email_template.html.tpl`.

Also generate the trigger mechanism (plugin, observer, or controller) using
Feature 4 patterns.

### Post-Generation
1. Run `make gitsniff` to validate Helper PHP code
2. Add email subject/body strings to `i18n/en_US.csv`
3. Add FR translations to `app/design/frontend/{Vendor}/{Theme}/i18n/fr_FR.csv`

---

## Feature 6: Hyva Template with ViewModel

### Required Questions
1. **Module name?**
2. **Template purpose?** (e.g. "brand list", "customer widget")
3. **Data needed?** (what ViewModel should provide)
4. **Interactive?** (need Alpine.js? e.g. slider, toggle, modal)
5. **Need Hyva icons?** (heroicons integration)

### Generated Files
```
ViewModel/
└── {ViewModelName}.php
view/
└── frontend/
    ├── layout/
    │   └── {layout_handle}.xml
    └── templates/
        └── {template_name}.phtml
```

Use templates from `magento2-backend-toolkit/assets/templates/viewmodel.php.tpl`,
`magento2-backend-toolkit/assets/templates/layout.xml.tpl`, and `magento2-backend-toolkit/assets/templates/hyva_template.phtml.tpl`.

### Key Hyva Patterns
Refer to `magento2-backend-toolkit/references/hyva-viewmodel-pattern.md` for full details:
- Always use `$escaper->escapeHtml()` for output
- Always use `$escaper->escapeHtmlAttr()` inside HTML attributes
- Use `$escaper->escapeUrl()` for URLs
- Alpine.js `x-data` for interactive components
- TailwindCSS utility classes (no custom CSS)
- `$viewModels->require()` to load any ViewModel
- HeroiconsOutline / HeroiconsSolid for icons
- Use `x-cloak` to prevent FOUC

### Post-Generation
1. Run `make gitsniff` to validate ViewModel PHP code
2. Add translatable strings to `i18n/en_US.csv`
3. Add FR translations to `app/design/frontend/{Vendor}/{Theme}/i18n/fr_FR.csv`

---

## Workflow

```
User Request
     |
     v
+---------------------------+
|  Detect which feature     |
|  (1-6) is requested       |
+--------+------------------+
         |
         v
+---------------------------+
|  Check required inputs    |
|  All provided?            |
+---- NO -------------------+
|  Ask ALL missing fields   |  <-- ONE message, not multiple
|  in ONE message           |
+---- YES ------------------+
|                           |
|  1. Generate files        |
|  2. Create i18n/en_US.csv |
|  3. Update fr_FR.csv      |
|  4. Run make gitsniff     |
|  5. Show file locations   |
+---------------------------+
```

## Post-Generation Checklist

After EVERY code generation task, verify:
- [ ] All PHP files pass `make gitsniff`
- [ ] `i18n/en_US.csv` created/updated in the module
- [ ] FR translations appended to `app/design/frontend/{Vendor}/{Theme}/i18n/fr_FR.csv`
- [ ] Magento commands use `warden env exec php-fpm bin/magento`
- [ ] No manual cache folder deletion (`rm -rf var/cache` etc.)

## Troubleshooting

### Module not recognized after creation
```bash
warden env exec php-fpm bin/magento module:enable {Vendor}_{Module}
warden env exec php-fpm bin/magento setup:upgrade
warden env exec php-fpm bin/magento cache:flush
```

### PHPCS violations
Run `make gitsniff` and fix reported issues. Common fixes:
- Missing `declare(strict_types=1);`
- Missing type hints on parameters/return types
- Line length exceeding 120 characters
- Missing PHPDoc blocks on public methods

### XML schema validation error
- Verify XSD reference matches Magento version
- Check for typos in attribute names
- Ensure proper XML nesting

### Plugin not firing
- Check scope (global/frontend/adminhtml) matches where code runs
- Verify method name matches exactly (case-sensitive)
- Check sortOrder if multiple plugins exist
