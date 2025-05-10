#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/.env
# Define the target directory
TARGET_DIR="/var/www/cakephp"

Generate_Index_File "${TARGET_DIR}"
Global_Permission "${TARGET_DIR}"
Database_Create "$TARGET_DIR"
ApacheConfigure "$TARGET_DIR" "ssl"
unset TARGET_DIR
