#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/START.sh
# Define the target directory
SITE_NAME="bludit"
TARGET_DIR="/var/www/${SITE_NAME}"

function Install() {
    local OutFile
    local URI="https://www.bludit.com/releases/bludit-3-16-2.zip"
    OutFile="$(basename "$TARGET_DIR").zip"
    echo "Starting $OutFile installation..."
    if ! Web_Download_File "$URI" "$OutFile"; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi
    
    # Extract the downloaded package
    echo "Extracting $OutFile..."
    if ! unzip -q "$OutFile" -d "$(dirname "$TARGET_DIR")"; then
        echo "Error: Failed to extract $OutFile. Exiting."
        return 1
    fi
    # Remove the downloaded zip file
    rm -f "$OutFile"
}

function ConfigureSettings() {
    echo "Configuring Bludit settings..."
    # Bludit does not require a database setup like WordPress, but you can create a config file if needed.
    # You can also set up the admin user through the web interface after installation.
    echo "Bludit is ready for setup. Please visit your site to complete the installation."
}

Install
Global_Permission "${TARGET_DIR}"
Database_Create "$SITE_NAME"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
unset TARGET_DIR
