#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/START.sh
SITE_NAME="processwire"
TARGET_DIR="/var/www/${SITE_NAME}"

function SetPermissions() {
    Global_Permission "${TARGET_DIR}"
    [[ ! -d "${TARGET_DIR}/assets" ]] && mkdir -p "${TARGET_DIR}/assets"
    Global_Permission "${TARGET_DIR}/assets"
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

git_clone "https://github.com/processwire/processwire.git"
SetPermissions
Database_Create "$SITE_NAME"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
unset TARGET_DIR
