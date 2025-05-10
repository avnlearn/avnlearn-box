#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
# Define the target directory
TARGET_DIR="/var/www/drupal"

function Install() {
    local OutFile
    local URI="https://www.drupal.org/download-latest/tar.gz"

    # Ensure TARGET_DIR is set
    if [ -z "$TARGET_DIR" ]; then
        echo "Error: TARGET_DIR is not set. Exiting."
        return 1
    fi

    OutFile="$(basename "$URI")"
    echo "Starting $OutFile installation..."

    # Download the file
    if ! Web_Download_File "$URI" "$OutFile"; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi

    # Extract the downloaded package
    echo "Extracting $OutFile..."
    if ! tar -xzf "$OutFile"; then
        echo "Error: Failed to extract $OutFile. Exiting."
        return 1
    fi

    # Create target directory if it doesn't exist
    [ ! -d "${TARGET_DIR}" ] && mkdir -p "${TARGET_DIR}"

    # Move files to the target directory
    echo "Moving files to ${TARGET_DIR}..."
    if mv drupal-*/* "${TARGET_DIR}/"; then
        echo "Files moved successfully to ${TARGET_DIR}."
    else
        echo "Error: Failed to move files to ${TARGET_DIR}. Exiting."
        return 1
    fi

    # Cleanup
    rm -f "$OutFile"
    rm -rf drupal-*
    echo "Installation completed successfully."
}

function SetPermissions() {
    Global_Permission "${TARGET_DIR}"
    # Set permissions for the sites/default/files directory
    echo "Setting permissions for the files directory..."
    if [ ! -d "${TARGET_DIR}/sites/default/files" ]; then
        mkdir -p "${TARGET_DIR}/sites/default/files"
    fi
    Global_Permission "${TARGET_DIR}/sites/default/files"
}

function InstallDrush() {
    if ! command -v drush &>/dev/null; then
        Composer_Install "drush/drush"
    fi
}

function ConfigureSettings() {
    echo "Configuring Drupal settings..."
    cd "${TARGET_DIR}" || {
        echo "Error: Failed to change directory to ${TARGET_DIR}. Exiting."
        return 1
    }
    # Create settings.php file
    SETTING_FILE="${TARGET_DIR}/sites/default/settings.php"
    cp "${TARGET_DIR}/sites/default/default.settings.php" "${SETTING_FILE}"
    Global_Permission "${SETTING_FILE}"

    # Install Drupal using Drush
    drush site-install standard --db-url="mysql://${WEB_USERNAME}:${WEB_PASSWD}@${WEB_HOSTNAME}/${DRUPAL_DB}" \
        --site-name="Drupal Site" \
        --account-name="${WEB_USERNAME}" \
        --account-pass="${WEB_PASSWD}" \
        --account-mail="${WEB_EMAIL_ID}" \
        --site-mail="${WEB_EMAIL_ID}" \
        --yes
}

# Run the installation function
Install
SetPermissions
InstallDrush
Database_Create "$TARGET_DIR"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" # "ssl"
unset TARGET_DIR
