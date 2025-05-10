#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
# Define the target directory
TARGET_DIR="/var/www/symfony"

function Install() {
    echo "Starting Symfony installation..."
    curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
    sudo apt install symfony-cli

}
# Install
Generate_Index_File "${TARGET_DIR}"
Global_Permission "${TARGET_DIR}"
Database_Create "$TARGET_DIR"
ApacheConfigure "$TARGET_DIR" # "ssl"
unset TARGET_DIR