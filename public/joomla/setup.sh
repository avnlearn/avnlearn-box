#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/.env
# Define the target directory
TARGET_DIR="/var/www/joomla"

function Install() {
    echo "Starting Joomla installation..."
    local OutFile
    local URI="https://downloads.joomla.org/cms/joomla3/3-10-11/Joomla_3.10.11-Stable-Full_Package.zip"
    OutFile="$(basename "$TARGET_DIR").zip"
    echo "Starting $OutFile installation..."
    if ! Web_Download_File "$URI" "$OutFile"; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi

    # Extract the downloaded package
    echo "Extracting Joomla..."
    if ! unzip -q joomla.zip -d "${TARGET_DIR}"; then
        echo "Error: Failed to extract Joomla. Exiting."
        return 1
    fi

    # Move the extracted files to the target directory
    # mv Joomla_3.*/* "${TARGET_DIR}/"
    # Remove the downloaded zip file
    rm -f "$OutFile"
    # Remove the extracted directory
    rm -rf Joomla_3.*
}

function SetPermissions() {
    Global_Permission "${TARGET_DIR}"
    mkdir -p ${TARGET_DIR}/{logs,tmp}
    Global_Permission "${TARGET_DIR}/logs"
    Global_Permission "${TARGET_DIR}/tmp"
}

function ConfigureSettings() {
    echo "Configuring Joomla settings..."
    cd "${TARGET_DIR}" || {
        echo "Error: Failed to change directory to ${TARGET_DIR}. Exiting."
        return 1
    }

    # Create configuration.php file
    cat <<EOL >configuration.php
<?php
public \$dbtype = 'mysqli';
public \$host = '${WEB_HOSTNAME}';
public \$user = '${WEB_USERNAME}';
public \$password = '${WEB_PASSWD}';
public \$db = '${JOOMLA_DB}';
public \$dbprefix = 'jos_';
public \$log_path = '${TARGET_DIR}/logs';
public \$tmp_path = '${TARGET_DIR}/tmp';
public \$live_site = '';
public \$secret = 'your_secret_key';
public \$gzip = '0';
public \$error_reporting = 'default';
public \$debug = '0';
public \$debug_lang = '0';
public \$cache_handler = 'file';
public \$cache_time = '15';
public \$cache = '0';
public \$caching = '0';
public \$session_handler = 'database';
public \$session_name = 'JSESSIONID';
public \$session_lifetime = '1440';
public \$session_path = '';
public \$session_save_path = '';
public \$session_cookie = '';
public \$session_cookie_lifetime = '0';
public \$session_cookie_path = '/';
public \$session_cookie_domain = '';
public \$session_cookie_secure = '0';
public \$session_cookie_httponly = '0';
public \$session_cookie_samesite = 'Lax';
EOL

    # Set permissions for configuration.php
    Global_Permission "${TARGET_DIR}/configuration.php"

    echo "Joomla configuration completed successfully."
}


Install
SetPermissions
Database_Create "$TARGET_DIR"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" "ssl"
unset TARGET_DIR
