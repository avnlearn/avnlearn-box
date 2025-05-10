#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/.env
# Define the target directory
TARGET_DIR="/var/www/magento"

function Install() {
    local OutFile
    local URI="https://github.com/magento/magento2/archive/refs/heads/2.4-develop.zip"
    OutFile="$(basename "$TARGET_DIR").zip"
    echo "Starting $OutFile installation..."
    if ! Web_Download_File "$URI" "$OutFile"; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi

    # Extract the downloaded package
    echo "Extracting Magento..."
    if ! unzip -q "$OutFile" -d "${TARGET_DIR}"; then
        echo "Error: Failed to extract Magento. Exiting."
        return 1
    fi
    rm -f "$OutFile"
}

function SetPermissions() {
    Global_Permission "${TARGET_DIR}"
    echo "Setting permissions for var, pub, and generated directories..."
    mkdir -p ${TARGET_DIR}/{var,pub,generated}
    chmod -R 777 "${TARGET_DIR}/var" "${TARGET_DIR}/pub" "${TARGET_DIR}/generated"
    echo "Magento installation completed successfully."
}

function InstallComposer() {
    echo "Installing Composer..."
    if ! command -v composer &>/dev/null; then
        apt install -y composer
    fi
}

function ConfigureSettings() {
    echo "Configuring Magento settings..."
    cd "${TARGET_DIR}" || {
        echo "Error: Failed to change directory to ${TARGET_DIR}. Exiting."
        return 1
    }
    # Install Magento using Composer
    export COMPOSER_ALLOW_SUPERUSER=1
    composer install
    php bin/magento setup:install --base-url="magento.local" \
        --db-host="${WEB_HOSTNAME}" \
        --db-name="${MAGENTO_DB}" \
        --db-user="${WEB_USERNAME}" \
        --db-password="${WEB_PASSWD}" \
        --admin-firstname="Admin" \
        --admin-lastname="User" \
        --admin-email="${WEB_EMAIL_ID}" \
        --admin-user="${WEB_USERNAME}" \
        --admin-password="${WEB_PASSWD}" \
        --language="en_US" \
        --currency="USD" \
        --timezone="Asia/Kolkata" \
        --use-rewrites="1"
}

Install
SetPermissions
InstallComposer
Database_Create "$TARGET_DIR"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" "ssl"

unset TARGET_DIR
