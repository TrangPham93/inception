#!/bin/sh

echo "==> Setting up WordPress..."
echo "memory_limit = 512M" >> /etc/php83/php.ini

cd /var/www/html

echo "Downloading WordPress client (WP-CLI)..."
wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp || { echo "Failed to download wp-cli.phar"; exit 1; }
chmod +x /usr/local/bin/wp

echo "Waiting for MariaDB to be ready..."
mariadb-admin ping --protocol=tcp --host=mariadb --port=${DB_PORT} \
    -u $WORDPRESS_DATABASE_USER \
    --password=$WORDPRESS_DATABASE_USER_PASSWORD \
    --wait=300

if [ ! -f /var/www/html/wp-settings.php ]; then
    echo "Downloading WordPress core files..."
    wp core download --allow-root
fi

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname=$WORDPRESS_DATABASE_NAME \
        --dbuser=$WORDPRESS_DATABASE_USER \
        --dbpass=$WORDPRESS_DATABASE_USER_PASSWORD \
        --dbhost=mariadb:${DB_PORT} \
        --allow-root \
        --force

    echo "Installing WordPress..."
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root \
        --skip-email \
        --path=/var/www/html

    echo "Creating a WordPress user..."
    wp user create \
        $WORDPRESS_USER \
        $WORDPRESS_USER_EMAIL \
        --role=author \
        --user_pass=$WORDPRESS_USER_PASSWORD \
        --allow-root
else
    echo "==> WordPress already configured. Syncing site URL..."
fi

# Always force the URL to match .env — this makes port changes work without wiping volumes
wp config set WP_HOME    "https://$DOMAIN_NAME" --allow-root
wp config set WP_SITEURL "https://$DOMAIN_NAME" --allow-root
wp option update siteurl "https://$DOMAIN_NAME" --allow-root
wp option update home    "https://$DOMAIN_NAME" --allow-root

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html/

echo "Running PHP-FPM in the foreground..."
exec php-fpm83 -F