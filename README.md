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
- Local data storage (not tracked in Git)

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

## Environment Configuration

You can customize the environment by creating a `.env` file:

```bash
cp .env.example .env
```

Then edit `.env` to customize:

```bash
# Port Configuration
WORDPRESS_PORT=8080
PHPMYADMIN_PORT=8081

# WordPress Site Configuration
WORDPRESS_URL=http://localhost:8080
WORDPRESS_TITLE=My Development Site

# Admin User Configuration
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_PASSWORD=admin_password123
WORDPRESS_ADMIN_EMAIL=admin@localhost.dev
```

All changes in `.env` are automatically applied when you run `./manage.sh start`!

## Development Customizations

Need to mount custom plugins or themes? Create a development override file:

```bash
# Copy the main compose file to create a development version
cp docker-compose.yml docker-compose.dev.yml

# Edit docker-compose.dev.yml to add your plugin/theme mounts
# Example: Add volumes under the wordpress and wpcli services:
# services:
#   wordpress:
#     volumes:
#       - ./data/wordpress:/var/www/html
#       - ../my-plugin:/var/www/html/wp-content/plugins/my-plugin
#       - ../my-theme:/var/www/html/wp-content/themes/my-theme
#       # ... other existing volumes
#   wpcli:
#     volumes:
#       - ./data/wordpress:/var/www/html
#       - ../my-plugin:/var/www/html/wp-content/plugins/my-plugin
#       - ../my-theme:/var/www/html/wp-content/themes/my-theme
#       # ... other existing volumes
```

**Benefits:**

- ✅ `docker-compose.dev.yml` is ignored by Git (safe to customize)
- ✅ `manage.sh` automatically detects and uses the dev file when present
- ✅ No risk of accidentally committing your local plugin mounts
- ✅ Keep the original `docker-compose.yml` clean for the public repo

## Running Multiple Instances

Need to test plugins with multiple WordPress sites (e.g., master/client setup)? Simply clone the repository multiple times and configure different ports:

```bash
# Clone for master instance
git clone https://github.com/heymaia-io/wordpress-docker-dev.git wordpress-master
cd wordpress-master
cp .env.example .env
# Keep default ports (8080, 8081)
./manage.sh start
# Master: http://localhost:8080, PHPMyAdmin: http://localhost:8081

# Clone for client instance
git clone https://github.com/heymaia-io/wordpress-docker-dev.git wordpress-client
cd wordpress-client
cp .env.example .env
```

**Configure different ports for client instance** by editing `.env`:

```bash
# Edit .env file
WORDPRESS_PORT=8090
PHPMYADMIN_PORT=8091
WORDPRESS_URL=http://localhost:8090
```

Then start the client:

```bash
./manage.sh start
# Client: http://localhost:8090, PHPMyAdmin: http://localhost:8091
```

**Benefits of this approach:**

- ✅ No need to edit docker-compose.yml manually
- ✅ All configuration in one place (.env file)
- ✅ Easy to manage multiple instances
- ✅ Each instance completely isolated

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
  - ./data/wordpress:/var/www/html
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
  - ./data/wordpress:/var/www/html
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

## Local Data Storage

This environment stores all data locally in the `data/` folder:

- **WordPress files:** `data/wordpress/` - Contains all WordPress core files, plugins, themes, and uploads
- **Database files:** `data/mysql/` - Contains the MariaDB database files

**Benefits:**

- Faster performance compared to Docker volumes
- Easy to backup - just copy the `data/` folder
- Persistent data that survives container recreation
- Easy to inspect and debug files

**Git Integration:**

- The `data/` folder structure is tracked in Git
- The actual content is ignored via `.gitignore`
- Fresh clones will have empty data folders ready for use

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
