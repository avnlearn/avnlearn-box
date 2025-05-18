#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/START.sh

function SetPremission() {
    chown -R www-data:www-data /var/www
    chmod -R 755 /var/www
}
function Apache_Setup() {
    echo "TODO : Enable Apache mod_rewrite"
    a2dissite 000-default
    systemctl reload apache2
}
function Helper() {

    # Append custom messages to the .bashrc file for the vagrant user

    bash /home/vagrant/.bashrc
}
SetPremission
Apache_Setup
Helper
