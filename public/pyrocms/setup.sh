#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/.env
# Define the target directory
TARGET_DIR="/var/www/laravel"

function Install() {
    echo "Starting pyrocms installation..."

    # Check if the target directory exists
    if [ ! -d "/var/www" ]; then
        echo "Error: /var/www/html does not exist. Exiting."
        return 1
    fi
    cd /var/www || {
        echo "Error: Failed to change directory to /var/www/html. Exiting."
        return 1
    }
    # Remove the default index.html if it exists
    if [ -f "index.html" ]; then
        rm -f index.html
    fi
    mkdir -p "$TARGET_DIR"
}


Install
Global_Permission "${TARGET_DIR}"
Database_Create "$(basename "$TARGET_DIR")"
ApacheConfigure "$(basename "$TARGET_DIR")"
unset TARGET_DIR
