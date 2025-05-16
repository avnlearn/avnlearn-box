#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
# Define the target directory

SITE_NAME="fuelphp"
TARGET_DIR="/var/www/${SITE_NAME}.local/public_html"
function Install() {
    echo "Starting FuelPHP installation..."
    curl -L https://get.fuelphp.com/oil | sh
}


Install
Generate_Index_File "${TARGET_DIR}" "$SITE_NAME"

# Global_Permission "${TARGET_DIR}"
Database_Create "$SITE_NAME"
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
