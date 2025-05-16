#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
# Define the target directory
SITE_NAME="avnlearn"
TARGET_DIR="/var/www/html"

Generate_Index_File "${TARGET_DIR}" "$SITE_NAME"
Database_Create "avnlearn"
ApacheConfigure "$TARGET_DIR" "avnlearn" # "ssl"
unset TARGET_DIR
