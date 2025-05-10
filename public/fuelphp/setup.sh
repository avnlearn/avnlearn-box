#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/.env
# Define the target directory
TARGET_DIR="/var/www/fuelphp"

function Install() {
    echo "Starting FuelPHP installation..."
    curl -L https://get.fuelphp.com/oil | sh
}
Install
Generate_Index_File "${TARGET_DIR}"
Global_Permission "${TARGET_DIR}"
Database_Create "$TARGET_DIR"
ApacheConfigure "$TARGET_DIR" "ssl"
unset TARGET_DIR
