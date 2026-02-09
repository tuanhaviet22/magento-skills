{
    "name": "{vendor}/{module}",
    "description": "{description}",
    "type": "magento2-module",
    "version": "{version}",
    "require": {
        "magento/framework": ">=103.0.0"
    },
    "autoload": {
        "files": ["registration.php"],
        "psr-4": {
            "{Vendor}\\{Module}\\": ""
        }
    }
}
