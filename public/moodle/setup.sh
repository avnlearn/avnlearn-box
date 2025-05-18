#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/START.sh
SITE_NAME="moodle"
TARGET_DIR="/var/www/${SITE_NAME}"
MOODLEDATA="/var/www/moodledata"
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
    if ! unzip -q "$OutFile" -d "/var/www/"; then
        echo "Error: Failed to extract Moodle. Exiting."
        return 1
    fi
    # Remove the downloaded zip file
    rm -f "$OutFile"

}

function SetPermissions() {
    # Set ownership and permissions for the Moodle directory
    Global_Permission "${TARGET_DIR}" "user"
    [[ ! -d "${MOODLEDATA}" ]] && mkdir -p "${MOODLEDATA}"
    Global_Permission "${MOODLEDATA}"
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
<?php  // Moodle configuration file
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();
\$CFG->dbtype    = 'mariadb';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = 'localhost';
\$CFG->dbname    = 'moodle';
\$CFG->dbuser    = 'admin';
\$CFG->dbpass    = 'admin@123';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
  'dbcollation' => 'utf8mb4_general_ci',
);
\$CFG->wwwroot   = 'http://moodle.local';
\$CFG->dataroot  = "${MOODLEDATA}";
\$CFG->admin     = 'admin';
\$CFG->directorypermissions = 0777;
require_once(__DIR__ . '/lib/setup.php');
PHP
}

Install
Database_Create "$SITE_NAME"
ConfigureSettings
SetPermissions
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
unset TARGET_DIR
