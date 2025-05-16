#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
SITE_NAME="processwire"
TARGET_DIR="/var/www/${SITE_NAME}"

function Install() {
    echo "Starting ProcessWire installation..."

    # Check if the target directory exists
    if [ ! -d "/var/www" ]; then
        echo "Error: /var/www/html does not exist. Exiting."
        return 1
    fi
    cd /var/www || {
        echo "Error: Failed to change directory to /var/www/html. Exiting."
        return 1
    }
    # Download the latest ProcessWire package
    echo "Downloading ProcessWire..."
    sudo git clone https://github.com/processwire/processwire.git

}

function SetPermissions() {
    Global_Permission "${TARGET_DIR}" "user"
    [[ ! -d "${TARGET_DIR}/assets" ]] && mkdir -p "${TARGET_DIR}/assets"
    Global_Permission "${TARGET_DIR}/assets" "user"
}

function ConfigureSettings() {
    echo "Configuring ProcessWire settings..."
    # Check if the target directory exists
    if [ ! -d "${TARGET_DIR}" ]; then
        echo "Error: ${TARGET_DIR} does not exist. Exiting."
        return 1
    fi
    cd "${TARGET_DIR}" || {
        echo "Error: Failed to change directory to ${TARGET_DIR}. Exiting."
        return 1
    }

    # Create a configuration file for ProcessWire
    cat <<EOL >"${TARGET_DIR}/site-blank/config.php"
<?php
\$config->dbHost = '${WEB_HOSTNAME}';
\$config->dbName = '${SITE_NAME}';
\$config->dbUser = '${WEB_USERNAME}';
\$config->dbPass = '${WEB_PASSWD}';
\$config->httpHosts = array('http://${SITE_NAME}.local', "http://www.${SITE_NAME}.local");
\$config->debug = true; // Enable debug mode
EOL

    echo "ProcessWire configuration file created successfully."
}

Install
SetPermissions
Database_Create "$SITE_NAME"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
unset TARGET_DIR
