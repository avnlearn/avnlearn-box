#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/START.sh
SITE_NAME="magento"
TARGET_DIR="/var/www/${SITE_NAME}"

function Install() {
    local OutFile
    local URI="https://github.com/magento/magento2/archive/refs/tags/2.4.8.zip"
    OutFile="$(basename "$TARGET_DIR").zip"
    echo "Starting $OutFile installation..."
    if ! Web_Download_File "$URI" "$OutFile"; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi

    # Extract the downloaded package
    echo "Extracting Magento..."
    if ! unzip -q "$OutFile" -d "magento"; then
        echo "Error: Failed to extract Magento. Exiting."
        return 1
    fi
    echo "Moving files to ${TARGET_DIR}..."
    pushd "magento" || exit
    [ ! -d "${TARGET_DIR}/" ] && mkdir -p "${TARGET_DIR}/"
    if mv magento2-*/* "${TARGET_DIR}/"; then
        echo "Files moved successfully to ${TARGET_DIR}."
    else
        echo "Error: Failed to move files to ${TARGET_DIR}. Exiting."
        return 1
    fi
    rm -f "$OutFile"
    rm -rf magento
    echo "Installation completed successfully."
    popd || exit
}

function SetPermissions() {
    Global_Permission "${TARGET_DIR}"
    echo "Setting permissions for var, pub, and generated directories..."
    # mkdir -p ${TARGET_DIR}/{var,pub,generated}
    # chmod -R 777 "${TARGET_DIR}/var" "${TARGET_DIR}/pub" "${TARGET_DIR}/generated"
    Global_Permission "${TARGET_DIR}/var"
    Global_Permission "${TARGET_DIR}/pub"
    Global_Permission "${TARGET_DIR}/generated"
    echo "Magento installation completed successfully."
}

function ConfigureSettings() {
    echo "Configuring Magento settings..."
    cd "${TARGET_DIR}" || {
        echo "Error: Failed to change directory to ${TARGET_DIR}. Exiting."
        return 1
    }
    # Install Magento using Composer
    composer install
    # USD
    # Magento_OpenSearch
    # Magento_Elasticsearch
    # Magento_Elasticsearch8
    php bin/magento setup:install --disable-modules=Magento_Elasticsearch8,Magento_Elasticsearch,Magento_OpenSearch \
        --base-url="http://${SITE_NAME}.local" \
        --db-host="${WEB_HOSTNAME}" \
        --db-name="${SITE_NAME}" \
        --db-user="${WEB_USERNAME}" \
        --db-password="${WEB_PASSWD}" \
        --admin-firstname="Admin" \
        --admin-lastname="User" \
        --admin-email="${WEB_EMAIL_ID}" \
        --admin-user="${WEB_USERNAME}" \
        --admin-password="${WEB_PASSWD}" \
        --language="en_US" \
        --currency="INR" \
        --timezone="Asia/Kolkata" \
        --use-rewrites="1" \
        --search-engine=opensearch \
        --opensearch-host=os-host.example.com \
        --opensearch-port=9200 \
        --opensearch-index-prefix=magento2 \
        --opensearch-timeout=15
}
Install
SetPermissions
InstallComposer
Database_Create "$SITE_NAME"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"

unset TARGET_DIR
