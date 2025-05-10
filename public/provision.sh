#!/usr/bin/env bash

# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh

function Install() {
    PACKAGES=(
        build-essential
        apache2
        php
        composer
        mysql-server
        git
        libapache2-mod-php
        php-common
        php-http
        php-oauth
        php-sqlite3
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
        php-http
        php-raphf
        unzip
        openssl
        sendmail
        php-pear
        php-dev
        zlib1g-dev
        libcurl4-openssl-dev
        libevent-dev
        libicu-dev
        libidn2-0-dev
    )
    echo "Install Apache2 :" "${PACKAGES[@]}"
    apt update && apt upgrade
    apt install -y software-properties-common
    add-apt-repository ppa:ondrej/php
    apt update
    apt install -y "${PACKAGES[@]}"
    apt autoremove && apt autoclean
    a2enmod rewrite
    a2enmod ssl
    systemctl restart apache2
    systemctl restart sendmail
    # systemctl enable sendmail
}

function SetPermissions() {
    chown -R www-data:www-data /var/www
    chmod -R 755 /var/www
}

function ssl_setup() {
    if [ ! -f "/etc/ssl/certs/${PRIVATE_SSL}.crt" ]; then
        echo "Setting up SSL..."
        mkdir -p /etc/ssl/certs /etc/ssl/private
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "/etc/ssl/private/${PRIVATE_SSL}.key" -out "/etc/ssl/certs/${PRIVATE_SSL}.crt" -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=*.local"
    else
        echo "SSL certificate already exists."
    fi
}

function mysql_db() {
    echo "Creating user: ${WEB_USERNAME}@${WEB_HOSTNAME}"
    mysql -u root -e "CREATE USER IF NOT EXISTS '${WEB_USERNAME}'@'${WEB_HOSTNAME}' IDENTIFIED BY '${WEB_PASSWD}';" 2>&1 || {
        echo "Failed to create user: $?"
        exit 1
    }

    echo "Granting privileges to user: ${WEB_USERNAME}@${WEB_HOSTNAME}"
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${WEB_USERNAME}'@'${WEB_HOSTNAME}' WITH GRANT OPTION;" 2>&1 || {
        echo "Failed to grant privileges: $?"
        exit 1
    }

    echo "Flushing privileges..."
    mysql -u root -e "FLUSH PRIVILEGES;" 2>&1 || {
        echo "Failed to flush privileges: $?"
        exit 1
    }

    echo "MySQL databases and user setup completed successfully."
}

Install
SetPermissions
ssl_setup
mysql_db
echo "Setup completed successfully."
