# WordPress Development Environment

This is a Docker-based WordPress development environment for general WordPress development.

## Features

- WordPress 6.8.1 with PHP 8.4
- MariaDB 11.4.7 (matching your hosting server)
- PHPMyAdmin for database management
- WP-CLI for command-line WordPress management
- Xdebug for debugging
- Live mounting support for plugin development
- Custom WordPress configuration for development
- Easy plugin mounting and management

## Quick Start

1. **Start the environment:**

   ```bash
   ./manage.sh start
   ```

2. **Access your sites:**

   - WordPress: http://localhost:8080
   - PHPMyAdmin: http://localhost:8081

3. **Login credentials:**
   - Username: `admin`
   - Password: `admin_password123`

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

To develop plugins, you can mount them into the WordPress instance by adding volumes to the `docker-compose.yml` file:

```yaml
volumes:
  - wordpress_data:/var/www/html
  - ./your-plugin:/var/www/html/wp-content/plugins/your-plugin
```

Any changes you make to mounted plugin files will be immediately reflected in WordPress.

To activate your plugin:

```bash
./manage.sh wpcli plugin activate your-plugin-name
```

## Customizing for Your Project

### Mounting Your Plugins

To mount your own plugins for development, edit the `docker-compose.yml` file and add volume mounts under both the `wordpress` and `wpcli` services:

```yaml
volumes:
  - wordpress_data:/var/www/html
  - ./my-plugin:/var/www/html/wp-content/plugins/my-plugin
```

### Changing Admin Credentials

You can customize the WordPress admin credentials by editing the `manage.sh` file in the `setup_wordpress()` function. Look for these lines:

```bash
--admin_user="admin" \
--admin_password="admin_password123" \
--admin_email="admin@localhost.dev" \
```

### Port Configuration

If ports 8080 or 8081 are already in use on your system, you can change them in `docker-compose.yml`:

```yaml
ports:
  - '8090:80' # WordPress will be available on http://localhost:8090
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
4. **Plugin not visible:** Ensure your plugin folder is properly mounted in docker-compose.yml

## Clean Start

To completely reset the environment:

```bash
./manage.sh clean
./manage.sh start
```

This will remove all WordPress data and database, giving you a fresh installation.
