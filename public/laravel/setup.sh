#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/START.sh
# Define the target directory
SITE_NAME="laravel"
TARGET_DIR="/var/www/${SITE_NAME}"

Generate_Index_File "${TARGET_DIR}" "$SITE_NAME"
# Global_Permission "${TARGET_DIR}"
Database_Create "$SITE_NAME"
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
