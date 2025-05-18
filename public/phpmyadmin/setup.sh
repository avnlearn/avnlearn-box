#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/START.sh

SITE_NAME="phpmyadmin"
TARGET_DIR="/var/www/${SITE_NAME}"

function Install() {
    if [ ! -d "$(dirname $TARGET_DIR)" ]; then
        echo "$(dirname $TARGET_DIR) is not exist"
        return 1
    fi
    cd "$(dirname $TARGET_DIR)" || exit
    composer create-project phpmyadmin/phpmyadmin --no-dev -q
    cat <<EOL >config.inc.php
<?php
\$i=0;
\$i++;
\$cfg['Servers'][\$i]['user']          = '$WEB_USERNAME';
\$cfg['Servers'][\$i]['password']      = '$WEB_PASSWD'; // use here your password
\$cfg['Servers'][\$i]['auth_type']     = 'config';
EOL
    # git clone https://github.com/phpmyadmin/phpmyadmin.git
    # echo "Install : phpMyAdmin"
    # export DEBIAN_FRONTEND="noninteractive"
    # # Set the MySQL administrative user's password
    # echo "Setting up debconf selections for phpMyAdmin..."
    # sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/dbconfig-install boolean true"
    # sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/mysql/admin-user string $WEB_USERNAME"
    # sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/mysql/admin-pass password $WEB_PASSWD"
    # sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/mysql/app-pass password $WEB_PASSWD"
    # sudo debconf-set-selections <<<"phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"

    # # Install phpMyAdmin
    # apt install -yq phpmyadmin
}

function Apache2_conf() {
    echo "Including phpMyAdmin configuration in Apache..."
    echo "Include /etc/phpmyadmin/apache.conf" | sudo tee -a /etc/apache2/apache2.conf
}

Install
Global_Permission "${TARGET_DIR}"
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
