#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh

function SetPremission(){
    sudo chmod -R 755 /var/www
}
function Apache_Setup() {
    echo "TODO : Enable Apache mod_rewrite"
    # a2enmod ssl
    a2dissite 000-default.conf
    systemctl restart apache2
    systemctl reload apache2
}
function Helper() {
    echo "TODO : SERVER Complete"
    echo "======================"
    echo "http://localhost:8080"
    echo "Administrator"
    echo -e "\tUsername : $WEB_USERNAME"
    echo -e "\tPassword : $WEB_PASSWD"
    echo "======================"
}
SetPremission
Apache_Setup
Helper
