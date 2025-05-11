#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
# Define the target directory
SITE_NAME="symfony"
TARGET_DIR="/var/www/${SITE_NAME}.local/public_html"
function Install() {
    echo "Starting Symfony installation..."
    curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
    sudo apt install symfony-cli

}
Generate_Index_File "${TARGET_DIR}" "$SITE_NAME"
# Global_Permission "${TARGET_DIR}"
Database_Create "$SITE_NAME"
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"