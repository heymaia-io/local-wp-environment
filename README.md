# HeyMaia WordPress Development Environment

This is a Docker-based WordPress development environment specifically configured for developing the HeyMaia WordPress plugin.

## Features

- WordPress 6.8.1 with PHP 8.4
- MariaDB 11.4.7 (matching your hosting server)
- PHPMyAdmin for database management
- WP-CLI for command-line WordPress management
- Xdebug for debugging
- Live mounting of the heymaia-wp-config plugin
- Custom WordPress configuration matching your requirements

## Quick Start

1. **Start the environment:**

   ```bash
   ./manage.sh start
   ```

2. **Access your sites:**

   - WordPress: http://localhost:8080
   - PHPMyAdmin: http://localhost:8081

3. **Login credentials:**
   - Username: `support@heymaia.io`
   - Password: `jzFd$78ZE&j5ar@!Lx7C8!73&qaHK*6q!&44S#84`

## Management Commands

The `manage.sh` script provides easy management of your development environment:

```bash
./manage.sh start     # Start the environment
./manage.sh stop      # Stop the environment
./manage.sh restart   # Restart the environment
./manage.sh status    # Show status
./manage.sh logs      # Show container logs
./manage.sh clean     # Clean environment (removes all data)
./manage.sh wpcli     # Run WP-CLI commands
```

## Plugin Development

Your `heymaia-wp-config` plugin is automatically mounted into the WordPress instance at:

- Host path: `../heymaia-wp-config/`
- Container path: `/var/www/html/wp-content/plugins/heymaia-wp-config/`

Any changes you make to the plugin files will be immediately reflected in WordPress.

To activate your plugin:

```bash
./manage.sh wpcli plugin activate heymaia-wp-config
```

## Custom WordPress Configuration

The following custom settings are automatically applied:

```php
define('UPLOADS', 'wp-content/media-files');
define('WP_AUTO_UPDATE_CORE', false);
define('DISALLOW_FILE_EDIT', true);
```

Plus development-friendly settings like WP_DEBUG enabled.

## Database Access

- **PHPMyAdmin:** http://localhost:8081
- **Database:** wordpress
- **Username:** wordpress
- **Password:** wordpress_password
- **Root password:** root_password

## WP-CLI Examples

```bash
# List all plugins
./manage.sh wpcli plugin list

# Install a plugin
./manage.sh wpcli plugin install contact-form-7

# Create a new user
./manage.sh wpcli user create developer dev@example.com --role=administrator

# Export/Import database
./manage.sh wpcli db export backup.sql
./manage.sh wpcli db import backup.sql
```

## Debugging

Xdebug is pre-configured and ready to use:

- **Port:** 9003
- **IDE Key:** VSCODE
- **Client Host:** host.docker.internal

Configure your IDE to listen on port 9003 for Xdebug connections.

## Troubleshooting

1. **Docker not running:** Make sure Docker Desktop is running
2. **Port conflicts:** If ports 8080 or 8081 are in use, modify the docker-compose.yml
3. **Permission issues:** The containers run as user 33 (www-data)
4. **Plugin not visible:** Ensure the heymaia-wp-config folder exists in the parent directory

## Clean Start

To completely reset the environment:

```bash
./manage.sh clean
./manage.sh start
```

This will remove all WordPress data and database, giving you a fresh installation.
