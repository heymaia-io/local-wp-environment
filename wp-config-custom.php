<?php
/**
 * Custom WordPress configuration additions for development
 * This file will be included in wp-config.php
 */

// Custom uploads directory
define('UPLOADS', 'wp-content/media-files');

// Deactivate auto-upgrade WordPress
define('WP_AUTO_UPDATE_CORE', false);

// Deactivate file edition in WP panel
define('DISALLOW_FILE_EDIT', true);

// Development settings
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);
define('SCRIPT_DEBUG', true);

// Memory limit
ini_set('memory_limit', '256M');
