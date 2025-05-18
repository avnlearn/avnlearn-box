#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/START.sh
# Define the target directory
SITE_NAME="opencart"
TARGET_DIR="/var/www/${SITE_NAME}"

git_clone "https://github.com/opencart/opencart.git"
Global_Permission "${TARGET_DIR}"
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
unset TARGET_DIR
