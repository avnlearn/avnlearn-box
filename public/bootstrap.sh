#!/usr/bin/env bash

# shellcheck source=/dev/null
source /vagrant/public/START.sh

function Install() {
    echo -e "${AVN_YELLOW}==========START Install Setup==========${AVN_NC}"
    PACKAGES=(
        build-essential
        bash-completion
        apache2
        php
        libapache2-mod-php
        vsftpd
        git
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
        php-json
        php-imagick
        php-xdebug
        php-http
        php-raphf
        php-dev
        php-pear
        composer
        unzip
        ghostscript
        openssl
        # mysql-server
        mariadb-server
        mkcert
        sendmail
    )
    echo "Install Apache2 :" "${PACKAGES[@]}"
    apt update && apt upgrade
    apt install -y software-properties-common
    add-apt-repository ppa:ondrej/php
    apt update
    apt install -y "${PACKAGES[@]}"
    apt autoremove && apt autoclean
    sudo systemctl start sendmail
    sudo systemctl enable sendmail
    composer update
    echo -e "${AVN_YELLOW}==========END Install Setup==========${AVN_NC}"
}
function setup_composer() {
    echo -e "${AVN_YELLOW}==========START Composer Setup==========${AVN_NC}"
    if ! command -v composer &>/dev/null; then
        EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

        if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
            echo >&2 'ERROR: Invalid installer checksum'
            rm composer-setup.php
            exit 1
        fi

        php composer-setup.php --quiet
        chmod +x composer-setup.php
        mv composer-setup.php /usr/bin/composer
    fi
    composer completion >/etc/bash_completion.d/composer
    chmod +x /etc/bash_completion.d/composer
    echo -e "${AVN_YELLOW}==========END Composer Setup==========${AVN_NC}"
}
function apache2_Setup() {
    echo -e "${AVN_YELLOW}==========START Apache2 Setup==========${AVN_NC}"
    a2enmod rewrite
    a2enmod ssl
    a2enmod headers
    systemctl restart apache2
    if [ -f "/etc/apache2/apache2.conf" ]; then
        # ${HTTP2_HOST_IP}
        echo "ServerName 127.0.0.1" >>/etc/apache2/apache2.conf
    fi
    sudo apachectl configtest
    systemctl reload apache2
    echo -e "${AVN_YELLOW}==========END Apache2 Setup==========${AVN_NC}"
}

function openssl_setup() {
    echo -e "${AVN_YELLOW}==========START OpenSSL Setup==========${AVN_NC}"
    if [ ! -f "${AVNLEARN_SSL_CRT}" ]; then
        echo "Setting up SSL..."
        mkdir -p /etc/ssl/certs /etc/ssl/private
        # openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "${AVNLEARN_SSL_KEY}" -out "${AVNLEARN_SSL_CRT}" -config /vagrant/public/openssl.cnf
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "${AVNLEARN_SSL_KEY}" -out "${AVNLEARN_SSL_CRT}" -subj "/C=IN/ST=State/L=City/O=AvNLearn/OU=Unit/CN=*.local"
        chmod 600 "${AVNLEARN_SSL_KEY}"
        chmod 644 "${AVNLEARN_SSL_CRT}"
        cp "${AVNLEARN_SSL_CRT}" /usr/local/share/ca-certificates/
        update-ca-certificates
    else
        echo "SSL certificate already exists."
    fi
    echo -e "${AVN_YELLOW}==========END OpenSSL Setup==========${AVN_NC}"
}

function database_setup() {
    echo -e "${AVN_YELLOW}==========START Database Setup==========${AVN_NC}"
    local COMMAND
    for cmd in mysql mariadb; do
        if command -v $cmd &>/dev/null; then
            COMMAND=$cmd
            break
        fi
    done

    if [ -z "$COMMAND" ]; then
        echo "MySQL/MariaDB command not found. Please install the MySQL client."
        return 1
    fi

    echo "Creating user: ${WEB_USERNAME}@${WEB_HOSTNAME}"
    if ! $COMMAND -u root -e "CREATE USER IF NOT EXISTS '${WEB_USERNAME}'@'${WEB_HOSTNAME}' IDENTIFIED BY '${WEB_PASSWD}';"; then
        echo "Failed to create user."
        return 1
    fi

    echo "Granting privileges to user: ${WEB_USERNAME}@${WEB_HOSTNAME}"
    if ! $COMMAND -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${WEB_USERNAME}'@'${WEB_HOSTNAME}' WITH GRANT OPTION;"; then
        echo "Failed to grant privileges."
        return 1
    fi

    echo "Flushing privileges..."
    if ! $COMMAND -u root -e "FLUSH PRIVILEGES;"; then
        echo "Failed to flush privileges."
        return 1
    fi

    echo "$COMMAND databases and user setup completed successfully."
    echo -e "${AVN_YELLOW}==========END Database Setup==========${AVN_NC}"
}

function ftp_server_setup() {
    systemctl start vsftpd
    systemctl enable vsftpd
    {
        echo "local_enable=YES"
        echo "write_enable=YES"
        echo "chroot_local_user=YES"
    } >>/etc/vsftpd.conf
    systemctl restart vsftpd
}

function setup_bashrc() {
    set_bashrc <<EOF
if command -v composer >/dev/null 2>&1; then
    echo ""
    echo -e "${AVN_GREEN}${AVN_BOLD}[✓]${AVN_NC} : composer = $(composer global config bin-dir --absolute 2>/dev/null)"
    export PATH="\$PATH:\$(composer global config bin-dir --absolute 2>/dev/null)"
fi
echo -e "${AVN_GREEN}${AVN_BOLD}TODO : SERVER Complete${AVN_NC}"
echo -e "${AVN_BOLD}${AVN_BLUE}======================${AVN_NC}"
echo -e "${AVN_BOLD}${YELLOW}Administrator${AVN_NC}"
echo -e "${AVN_BOLD}${AVN_BLUE}User Information:${AVN_NC}"
echo -e "\t${AVN_BOLD}1. ${AVN_YELLOW}Username : ${AVN_GREEN}$WEB_USERNAME${AVN_NC}"
echo -e "\t${AVN_BOLD}2. ${AVN_RED}Password : ${AVN_GREEN}$WEB_PASSWD${AVN_NC}"
echo -e "\t${AVN_BOLD}3. ${AVN_RED}Wiki Password : ${AVN_GREEN}$WIKI_PASSWD${AVN_NC}"
echo -e "\t${AVN_BOLD}3. ${AVN_RED}Moodle Password : ${AVN_GREEN}$MOODLE_PASSWD${AVN_NC}"
echo -e "${AVN_BOLD}${AVN_BLUE}======================${AVN_NC}"
EOF
}

Install
setup_composer
openssl_setup
apache2_Setup
database_setup
ftp_server_setup
setup_bashrc
echo "Setup completed successfully."
