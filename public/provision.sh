#!/usr/bin/env bash

# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh

function Install() {
    PACKAGES=(
        build-essential
        apache2
        ghostscript
        php
        composer
        mysql-server
        git
        libapache2-mod-php
        php-bcmath
        php-intl
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
        php-dev
        unzip
        openssl
        sendmail
        php-pear
        zlib1g-dev
        libcurl4-openssl-dev
        libevent-dev
        libicu-dev
        libidn2-0-dev
        irqbalance
        vsftpd
        libnss3-tools
    )
    echo "Install Apache2 :" "${PACKAGES[@]}"
    apt update && apt upgrade
    apt install -y software-properties-common
    add-apt-repository ppa:ondrej/php
    apt update
    apt install -y "${PACKAGES[@]}"
    apt autoremove && apt autoclean
    # systemctl enable sendmail
}

function Apache2_Setup() {
    a2enmod rewrite
    systemctl restart apache2
    if [ -f "/etc/apache2/apache2.conf" ]; then
        # ${HTTP2_HOST_IP}
        echo "ServerName 127.0.0.1" >>/etc/apache2/apache2.conf
    fi
    sudo apachectl configtest
    systemctl reload apache2
}

function mkcert_setup() {
    # Extension : cert-file and key-file => *.pem
    curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
    chmod +x mkcert-v*-linux-amd64
    cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert
    mkcert -install
    a2enmod ssl
    a2enmod headers
    systemctl restart apache2
}

function openssl_setup() {
    # Extension : cert-file => *.cert
    # Extension : key-file => *.key
    a2enmod ssl
    # systemctl restart apache2
    # systemctl reload apache2
    if [ ! -f "${AVNLEARN_SSL_CRT}" ]; then
        echo "Setting up SSL..."
        mkdir -p /etc/ssl/certs /etc/ssl/private
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "${AVNLEARN_SSL_KEY}" -out "${AVNLEARN_SSL_CRT}" -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=*.local"
        # openssl req -new -newkey rsa:2048 -nodes -out "/etc/ssl/certs/${PRIVATE_SSL}.csr" -keyout "/etc/ssl/private/${PRIVATE_SSL}.key" -subj "/C=IN/ST=example/L=example/O=Development/OU=developer/CN=Example"
        # openssl req -new -newkey rsa:2048 -nodes -out "${AVNLEARN_SSL_CRT}" -keyout "${AVNLEARN_SSL_KEY}" -subj "/C=IN/ST=example/L=example/O=Development/OU=developer/CN=*.local"
        chmod 600 "${AVNLEARN_SSL_KEY}"
        chmod 644 "${AVNLEARN_SSL_CRT}"
        cp "${AVNLEARN_SSL_CRT}" /usr/local/share/ca-certificates/
        update-ca-certificates
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

function ftp_server() {
    systemctl start vsftpd
    systemctl enable vsftpd
    {
        echo "local_enable=YES"
        echo "write_enable=YES"
        echo "chroot_local_user=YES"
    } >>/etc/vsftpd.conf
    systemctl restart vsftpd
}

Install
mkcert_setup
Apache2_Setup
mysql_db
ftp_server
echo "Setup completed successfully."
