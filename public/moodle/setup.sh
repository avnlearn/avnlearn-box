#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
# Define the target directory
TARGET_DIR="/var/www/moodle"

function Install() {
    local URI="https://download.moodle.org/download.php/direct/stable500/moodle-latest-500.zip"
    OutFile="$(basename "$TARGET_DIR").zip"
    echo "Starting $OutFile installation..."
    if ! Web_Download_File "$URI" "$OutFile"; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi
    # Extract the downloaded package
    echo "Extracting Moodle..."
    if ! unzip -q "$OutFile" -d "$TARGET_DIR"; then
        echo "Error: Failed to extract Moodle. Exiting."
        return 1
    fi
    # Remove the downloaded zip file
    rm -f "$OutFile"

}

function SetPermissions() {
    # Set ownership and permissions for the Moodle directory
    Global_Permission "${TARGET_DIR}"
    Global_Permission "${TARGET_DIR}/moodledata"
}
function ConfigureSettings() {
    echo "Configuring Moodle settings..."
    # Check if the target directory exists
    if [ ! -d "${TARGET_DIR}" ]; then
        echo "Error: ${TARGET_DIR} does not exist. Exiting."
        return 1
    fi
    cd "${TARGET_DIR}" || {
        echo "Error: Failed to change directory to ${TARGET_DIR}. Exiting."
        return 1
    }

    # Create the config.php file
    cat <<PHP >config.php
<?php
// Moodle configuration file
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();
\$CFG->dbtype    = 'mysqli'; // Database type
\$CFG->dblibrary = 'native'; // Database library
\$CFG->dbhost    = '${WEB_HOSTNAME}'; // Database host
\$CFG->dbname    = '${MOODLE_DB}'; // Database name
\$CFG->dbuser    = '${WEB_USERNAME}'; // Database user
\$CFG->dbpass    = '${WEB_PASSWD}'; // Database password
\$CFG->prefix    = 'mdl_'; // Database table prefix
\$CFG->wwwroot   = 'http://localhost/moodle'; // Moodle URL
\$CFG->dataroot  = '${TARGET_DIR}/moodledata'; // Moodle data directory
\$CFG->admin     = '${WEB_USERNAME}'; // Admin user
\$CFG->directorypermissions = 02775; // Directory permissions
\$CFG->passwordsaltmain = '$(openssl rand -hex 12)'; // Password salt
require_once(__DIR__ . '/lib/setup.php');
PHP
}

Install
SetPermissions
Database_Create "$TARGET_DIR"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" # "ssl"
unset TARGET_DIR
