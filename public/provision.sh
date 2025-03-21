#!/usr/bin/env bash
export WP_DATABASE_NAME="wordpress"
export WP_DATABASE_USER="wpuser"
export WP_DATABASE_PASSWORD="password"
export WEB_HOSTNAME="localhost"
export WORDPRESS_USER="admin"
export WORDPRESS_PASSWORD="admin@123"

function Install() {
    APACHE2=(
        libapache2-mod-php
        php-mysql
        php-cli
        php-pcov
        php-curl
        php-xml
        php-mbstring
        php-zip
        php-gd
        php-intl
        php-soap
        php-bcmath
        php-json
        php-imagick
        php-xdebug
    )
    echo "Install Apache2 :" "${APACHE2[@]}"
    apt-get install -y "${APACHE2[@]}"
    systemctl restart apache2

    echo "TODO : Install Composer"
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer

    echo "TODO : Install WP-CLI"
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.11.0/utils/wp-completion.bash
    chmod +x wp-completion.bash
    mv wp-completion.bash /etc/bash_completion.d/
}

function phpmyadmin() {
    echo "Install : phpMyAdmin"
    export DEBIAN_FRONTEND="noninteractive"
    apt install -yq phpmyadmin
    echo "Set the MySQL administrative user's password"
    sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/dbconfig-install boolean true"
    sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/mysql/admin-user string $WP_DATABASE_USER"
    sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/mysql/admin-pass password $WP_DATABASE_PASSWORD"
    sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/mysql/app-pass password $WP_DATABASE_PASSWORD"
    sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
    sudo dpkg-reconfigure -f noninteractive phpmyadmin
    echo "Include /etc/phpmyadmin/apache.conf" >>/etc/apache2/apache2.conf
    echo "TODO : Enable Apache mod_rewrite"
    a2enmod rewrite && systemctl restart apache2
}

function wordpress_install() {
    echo "TODO : Download and install WordPress"
    cd /var/www/html || exit
    rm -r index.html
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv -f wordpress/* ./
    rm -rf wordpress latest.tar.gz
    echo "TODO : Let Apache be owner"
    chown www-data:www-data -R /var/www/html
    echo "TODO : Change Directory permissions rwxr-xr-x"
    find . -type d -exec chmod 755 {} \;
    echo "TODO : Change file permissions rw-r--r--"
    find . -type f -exec chmod 644 {} \; #
}

function mysql_db() {
    echo "TODO : Create a MySQL database for WordPress"
    # service mysql start
    systemctl start mysql
    mysql -e "CREATE DATABASE $WP_DATABASE_NAME;"
    mysql -e "CREATE USER '$WP_DATABASE_USER'@'$WEB_HOSTNAME' IDENTIFIED BY '$WP_DATABASE_PASSWORD';"
    mysql -e "GRANT ALL PRIVILEGES ON $WP_DATABASE_NAME.* TO '$WP_DATABASE_USER'@'$WEB_HOSTNAME';"
    mysql -e "FLUSH PRIVILEGES;"
}

function wordpress_apache() {
    echo "TODO : Create Apache virtual host configuration for WordPress"
    cp -f "/vagrant/public/config/wordpress.conf" "/etc/apache2/sites-available/wordpress.conf"
    echo "TODO : Enable the site with:"
    a2ensite wordpress
    echo "TODO : Enable URL rewriting with:"
    a2enmod rewrite
    echo "TODO : reload apache2 to apply all these changes"
    systemctl reload apache2

}

function wordpress_config() {
    echo "TODO : WordPress Setup"
    cd /var/www/html || exit
    sudo wp config create --dbname=$WP_DATABASE_NAME --dbuser=$WP_DATABASE_USER --dbpass=$WP_DATABASE_PASSWORD --dbhost=$WEB_HOSTNAME --allow-root --extra-php <<PHP
define('WP_DEBUG', true); // Enable WP_DEBUG mode
define('WP_DEBUG_LOG', true); // Enable error logging to wp-content/debug.log
define('WP_DEBUG_DISPLAY', false); // Disable display of errors and warnings
define('SCRIPT_DEBUG', true); // Use unminified versions of CSS and JS files
define('WP_MEMORY_LIMIT', '256M'); // Increase memory limit
define('AUTOMATIC_UPDATER_DISABLED', true); // Disable automatic updates
PHP
    sudo wp core install --url="localhost:8080" --title="WordPress" --admin_user="$WORDPRESS_USER" --admin_password="$WORDPRESS_PASSWORD" --admin_email="example@example.com" --allow-root

    # Upload media
    chmod -R 755 /var/www/html/wp-content/uploads
    chown -R www-data:www-data /var/www/html/wp-content/uploads
    sudo wp user import-csv /vagrant/public/users.csv --allow-root
}

function helper() {
    echo "TODO : WordPress Complete"
    echo "======================"
    echo "WordPress : http://localhost:8080"
    echo "Administrator"
    echo -e "\tUsername : $WORDPRESS_USER"
    echo -e "\tPassword : $WORDPRESS_PASSWORD"
    echo "======================"
    echo "phpMyAdmin : http://localhost:8080/phpmyadmin"
    echo -e "\tUsername : $WP_DATABASE_USER"
    echo -e "\tPassword : $WP_DATABASE_PASSWORD"
    echo "======================"
}

Install
mysql_db
wordpress_install
phpmyadmin
wordpress_config
wordpress_apache
helper
