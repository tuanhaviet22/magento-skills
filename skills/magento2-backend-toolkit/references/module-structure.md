# Standard Magento 2 Module Directories

| Directory | Purpose |
|-----------|---------|
| `Api/` | Service contracts (interfaces) |
| `Api/Data/` | Data interfaces |
| `Block/` | View blocks |
| `Controller/` | Controllers (`Adminhtml/` for backend) |
| `Cron/` | Cron jobs |
| `etc/` | Configuration XML files |
| `Helper/` | Helper classes |
| `Model/` | Models, ResourceModels, Repositories |
| `Observer/` | Event observers |
| `Plugin/` | Interceptor plugins |
| `Setup/` | Install/Upgrade scripts (legacy) |
| `Ui/` | UI components (DataProvider, etc.) |
| `ViewModel/` | View models |
| `view/frontend/` | Frontend templates, layout, web assets |
| `view/adminhtml/` | Admin templates, layout, UI components |

## etc/ Subdirectories

| Path | Scope |
|------|-------|
| `etc/module.xml` | Module declaration |
| `etc/di.xml` | Global dependency injection |
| `etc/frontend/di.xml` | Frontend-only DI |
| `etc/adminhtml/di.xml` | Admin-only DI |
| `etc/frontend/routes.xml` | Frontend routes |
| `etc/adminhtml/routes.xml` | Admin routes |
| `etc/adminhtml/system.xml` | System configuration |
| `etc/config.xml` | Default config values |
| `etc/events.xml` | Global event observers |
| `etc/frontend/events.xml` | Frontend event observers |
| `etc/crontab.xml` | Cron job definitions |
| `etc/acl.xml` | ACL resources |
| `etc/widget.xml` | Widget definitions |
| `etc/email_templates.xml` | Email template definitions |
