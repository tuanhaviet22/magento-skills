# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a collection of Claude Code skills (agent prompts) for Magento 2 backend development. Each skill in `skills/` is a self-contained toolkit that Claude Code can use to scaffold Magento 2 modules, configurations, and components.

## Architecture

```
skills/
├── magento2-backend-toolkit/     # Generic Magento 2 scaffolding skill
│   ├── SKILL.md                  # Skill definition (features, rules, workflow)
│   ├── references/               # Reference docs for field types, patterns
│   └── assets/templates/         # .tpl code templates for all generators
└── sutunam-magento2-backend/     # Sutunam team variant (adds Warden, i18n, copyright)
    └── SKILL.md                  # Extends base toolkit with team conventions
```

### Skill Relationship

- **magento2-backend-toolkit**: Base skill with 6 generators (module scaffold, system.xml, widget, plugin/observer, email, Hyva template+ViewModel). Templates live in its `assets/templates/` directory.
- **sutunam-magento2-backend**: Team-specific overlay that reuses the base skill's templates (referenced as `magento2-backend-toolkit/assets/templates/...`) but adds Warden CLI wrapping, Sutunam copyright headers, `make gitsniff` PHPCS checks, and mandatory i18n (en_US.csv + fr_FR.csv).

### Skill Definition Format

Each `SKILL.md` follows a frontmatter + markdown pattern:
- YAML frontmatter with `name`, `description`, `metadata` (author, version, tags, compatibility)
- The `description` field controls when the skill is triggered (keyword matching)
- Body contains rules, feature definitions with required questions, generated file lists, and workflow

## Key Conventions

- Target: Magento 2.4.6+, PHP 8.1+, Hyva Theme 1.3+
- PSR-12 coding standard, `declare(strict_types=1)` in all PHP
- Never use ObjectManager directly — DI only
- XML files require proper XSD schema references
- Templates use `.tpl` extension and contain placeholder variables (e.g., `{Vendor}`, `{Module}`)

## Adding or Modifying Skills

- New code templates go in `skills/magento2-backend-toolkit/assets/templates/`
- Reference documentation goes in `skills/magento2-backend-toolkit/references/`
- Team-specific skill variants should reference base templates rather than duplicating them
- Each feature must define: required questions, generated file list, and template references
