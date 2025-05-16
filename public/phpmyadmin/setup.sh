#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
SITE_NAME="phpmyadmin"
TARGET_DIR="/usr/share/phpmyadmin"
function Install() {
    echo "Install : phpMyAdmin"
    export DEBIAN_FRONTEND="noninteractive"

    # Set the MySQL administrative user's password
    echo "Setting up debconf selections for phpMyAdmin..."
    sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/dbconfig-install boolean true"
    sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/mysql/admin-user string $WEB_USERNAME"
    sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/mysql/admin-pass password $WEB_PASSWD"
    sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/mysql/app-pass password $WEB_PASSWD"
    sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"

    # Install phpMyAdmin
    apt install -yq phpmyadmin
}

function apache2_conf() {
    echo "Including phpMyAdmin configuration in Apache..."
    echo "Include /etc/phpmyadmin/apache.conf" | sudo tee -a /etc/apache2/apache2.conf
}

Install
# apache2_conf
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
