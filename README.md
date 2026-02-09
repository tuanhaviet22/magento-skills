# magento-skills

A collection of [Claude Code](https://claude.ai/code) skills for Magento 2 backend development.

## Available Skills

### magento2-backend-toolkit

Scaffolds Magento 2 backend components with code generation for:

- **Module Scaffold** — `registration.php`, `module.xml`, `composer.json`
- **System.xml Generator** — Admin config fields with source models
- **Widget Generator** — Widget XML, block class, and phtml template
- **Plugin / Event Generator** — Before/after/around plugins and event observers
- **Email Function Generator** — Transactional email with trigger setup
- **Hyva Template + ViewModel** — Hyva-compatible phtml with Alpine.js and TailwindCSS

**Compatibility:** Magento 2.4.6+, PHP 8.1+, Hyva Theme 1.3+

## Installation

```bash
npx skills add tuanhaviet22/magento-skills
```

To fetch the latest version:

```bash
npx skills add tuanhaviet22/magento-skills@latest
```

## Usage

Once installed, Claude Code will automatically detect requests like:

- "Create a new Magento module"
- "Add system config fields"
- "Generate a widget"
- "Create a plugin for Product::getName"
- "Set up a transactional email"
- "Create a Hyva template with ViewModel"

The skill will ask for required inputs (module name, dependencies, etc.) before generating files with proper Magento 2 conventions.

## Structure

```
skills/
└── magento2-backend-toolkit/
    ├── SKILL.md              # Skill definition and rules
    ├── assets/templates/     # 20 code generation templates (.tpl)
    └── references/           # Field types, widget params, Hyva patterns
```
