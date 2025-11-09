#!/bin/bash
set -e

cd /var/www/pterodactyl

# Wait for database if configured
if [ -n "$DB_HOST" ]; then
    echo "Waiting for database at $DB_HOST..."
    until nc -z "$DB_HOST" "${DB_PORT:-3306}"; do
        sleep 2
    done
fi

# Run migrations and seeds
echo "Running migrations..."
php artisan migrate --seed --force

# Fix permissions for web server
chown -R www-data:www-data /var/www/pterodactyl/*

# Create first user
USER_COUNT=$(php artisan tinker --execute="echo \Pterodactyl\Models\User::count();")

if [ "$USER_COUNT" -eq 0 ]; then
    echo "No users found. Creating first admin user..."

    # Generate a random password (12 chars)
    ADMIN_PASSWORD=$(openssl rand -base64 12)
    ADMIN_EMAIL="${ADMIN_EMAIL:-admin@localhost}"
    ADMIN_USERNAME="${ADMIN_USERNAME:-admin}"
    ADMIN_NAME="${ADMIN_NAME:-Administrator}"

    echo "First admin credentials:"
    echo "  Email:    $ADMIN_EMAIL"
    echo "  Username: $ADMIN_USERNAME"
    echo "  Password: $ADMIN_PASSWORD"

    # Run p:user:make non-interactive
    php artisan p:user:make \
        --email="$ADMIN_EMAIL" \
        --username="$ADMIN_USERNAME" \
        --password="$ADMIN_PASSWORD" \
	--name-first="$ADMIN_USERNAME" \
	--name-last="$ADMIN_USERNAME" \
        --admin=1
else
    echo "Users already exist. Skipping admin creation."
fi

# Start PHP-FPM and Nginx
echo "Starting PHP-FPM and Nginx..."
service php8.3-fpm start
nginx -g "daemon off;"
