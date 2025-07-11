#!/bin/bash

# WordPress Development Environment Manager
# This script helps you manage your local WordPress development environment

set -e

# Load environment variables
if [ -f .env ]; then
    set -o allexport
    source .env
    set +o allexport
fi

# Set default values if not provided in .env
export WORDPRESS_PORT=${WORDPRESS_PORT:-8080}
export PHPMYADMIN_PORT=${PHPMYADMIN_PORT:-8081}
export WORDPRESS_URL=${WORDPRESS_URL:-"http://localhost:$WORDPRESS_PORT"}
export WORDPRESS_TITLE=${WORDPRESS_TITLE:-"WordPress Development Site"}
export WORDPRESS_ADMIN_USER=${WORDPRESS_ADMIN_USER:-"admin"}
export WORDPRESS_ADMIN_PASSWORD=${WORDPRESS_ADMIN_PASSWORD:-"admin_password123"}
export WORDPRESS_ADMIN_EMAIL=${WORDPRESS_ADMIN_EMAIL:-"admin@localhost.dev"}

# Determine which docker-compose file to use
COMPOSE_FILE="docker-compose.yml"
if [ -f "docker-compose.dev.yml" ]; then
    COMPOSE_FILE="docker-compose.dev.yml"
    echo -e "\033[0;33m[DEV]\033[0m Using docker-compose.dev.yml (custom development setup)"
else
    echo -e "\033[0;32m[INFO]\033[0m Using docker-compose.yml (default setup)"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Start the environment
start() {
    print_status "Starting WordPress development environment..."
    check_docker
    
    docker compose -f $COMPOSE_FILE up -d
    
    print_status "Waiting for WordPress to be ready..."
    sleep 30
    
    # Setup WordPress if it's the first time
    setup_wordpress
    
    print_status "Environment is ready!"
    print_status "WordPress: http://localhost:$WORDPRESS_PORT"
    print_status "PHPMyAdmin: http://localhost:$PHPMYADMIN_PORT"
    print_status "Admin credentials: $WORDPRESS_ADMIN_USER / $WORDPRESS_ADMIN_PASSWORD"
}

# Stop the environment
stop() {
    print_status "Stopping WordPress development environment..."
    docker compose -f $COMPOSE_FILE down
    print_status "Environment stopped."
}

# Restart the environment
restart() {
    print_status "Restarting WordPress development environment..."
    stop
    start
}

# Setup WordPress (run once)
setup_wordpress() {
    print_status "Setting up WordPress..."
    print_status "Using title: '$WORDPRESS_TITLE'"
    
    # Wait for WordPress to be accessible
    until curl -f http://localhost:$WORDPRESS_PORT > /dev/null 2>&1; do
        print_status "Waiting for WordPress to be accessible..."
        sleep 5
    done
    
    # Check if WordPress is already installed
    if docker compose -f $COMPOSE_FILE exec -T wpcli wp core is-installed 2>/dev/null; then
        print_status "WordPress already installed. Updating site title..."
        docker compose -f $COMPOSE_FILE exec -T wpcli wp option update blogname "$WORDPRESS_TITLE"
        docker compose -f $COMPOSE_FILE exec -T wpcli wp option update home "$WORDPRESS_URL"
        docker compose -f $COMPOSE_FILE exec -T wpcli wp option update siteurl "$WORDPRESS_URL"
    else
        print_status "Installing WordPress..."
        # Install WordPress
        docker compose -f $COMPOSE_FILE exec -T wpcli wp core install \
            --url="$WORDPRESS_URL" \
            --title="$WORDPRESS_TITLE" \
            --admin_user="$WORDPRESS_ADMIN_USER" \
            --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
            --admin_email="$WORDPRESS_ADMIN_EMAIL" \
            --skip-email
    fi
    
    # Include custom wp-config settings
    docker compose -f $COMPOSE_FILE exec -T wpcli wp config set --raw UPLOADS "'wp-content/media-files'"
    docker compose -f $COMPOSE_FILE exec -T wpcli wp config set --raw WP_AUTO_UPDATE_CORE "false"
    docker compose -f $COMPOSE_FILE exec -T wpcli wp config set --raw DISALLOW_FILE_EDIT "true"
    docker compose -f $COMPOSE_FILE exec -T wpcli wp config set --raw WP_DEBUG "true"
    docker compose -f $COMPOSE_FILE exec -T wpcli wp config set --raw WP_DEBUG_LOG "true"
    docker compose -f $COMPOSE_FILE exec -T wpcli wp config set --raw WP_DEBUG_DISPLAY "false"
    docker compose -f $COMPOSE_FILE exec -T wpcli wp config set --raw SCRIPT_DEBUG "true"
    
    print_status "WordPress setup completed!"
}

# Clean environment (remove all data)
clean() {
    print_warning "This will remove all WordPress data and database. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Cleaning environment..."
        docker compose -f $COMPOSE_FILE down
        
        # Remove local data folders content but keep the folders
        print_status "Removing WordPress data..."
        rm -rf ./data/wordpress/* 2>/dev/null || true
        
        print_status "Removing MySQL data..."
        rm -rf ./data/mysql/* 2>/dev/null || true
        
        print_status "Environment cleaned."
    else
        print_status "Clean operation cancelled."
    fi
}

# Show logs
logs() {
    docker compose -f $COMPOSE_FILE logs -f
}

# Run WP-CLI commands
wpcli() {
    if [ $# -eq 0 ]; then
        print_error "Please provide a WP-CLI command. Example: ./manage.sh wpcli plugin list"
        exit 1
    fi
    docker compose -f $COMPOSE_FILE exec wpcli wp "$@"
}

# Show status
status() {
    print_status "Environment Status:"
    docker compose -f $COMPOSE_FILE ps
    echo ""
    print_status "WordPress: http://localhost:$WORDPRESS_PORT"
    print_status "PHPMyAdmin: http://localhost:$PHPMYADMIN_PORT"
}

# Show help
help() {
    echo "WordPress Development Environment Manager"
    echo ""
    echo "Usage: ./manage.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start     Start the development environment"
    echo "  stop      Stop the development environment"
    echo "  restart   Restart the development environment"
    echo "  status    Show environment status"
    echo "  logs      Show container logs"
    echo "  clean     Clean environment (removes all data)"
    echo "  wpcli     Run WP-CLI commands (e.g., ./manage.sh wpcli plugin list)"
    echo "  help      Show this help message"
    echo ""
    echo "Configuration:"
    echo "  .env                    Environment variables (copy from .env.example)"
    echo "  docker-compose.dev.yml  Development overrides (ignored by Git)"
    echo ""
    echo "Development Mode:"
    echo "  If docker-compose.dev.yml exists, it will be used instead of docker-compose.yml"
    echo "  This allows you to safely customize volumes and other settings locally"
    echo ""
    echo "Examples:"
    echo "  ./manage.sh start"
    echo "  ./manage.sh wpcli plugin install contact-form-7"
    echo "  ./manage.sh logs"
}

# Main script logic
case "${1:-help}" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    logs)
        logs
        ;;
    clean)
        clean
        ;;
    wpcli)
        shift
        wpcli "$@"
        ;;
    help|--help|-h)
        help
        ;;
    *)
        print_error "Unknown command: $1"
        help
        exit 1
        ;;
esac
