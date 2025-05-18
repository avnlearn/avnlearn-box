#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/START.sh
# Define the target directory
SITE_NAME="drupal"
TARGET_DIR="/var/www/${SITE_NAME}"

function Drush_Install() {
    if ! command -v drush &>/dev/null; then
        # sudo git clone https://github.com/drush-ops/drush.git /usr/local/src/drush
        # cd /usr/local/src/drush || exit
        Web_Download_File "https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar" "drush.phar"
        chmod +x drush.phar
        mv drush.phar /usr/local/bin/drush
        # Composer_Install "drush/drush"
        drush status
        drush self-update

    fi
}

function Install() {
    local OutFile
    local URI="https://www.drupal.org/download-latest/tar.gz"

    # Ensure TARGET_DIR is set
    if [ -z "$TARGET_DIR" ]; then
        echo "Error: TARGET_DIR is not set. Exiting."
        return 1
    fi

    OutFile="$SITE_NAME.tar.gz"
    echo "Starting $OutFile installation..."

    # Download the file
    if ! Web_Download_File "$URI" "$OutFile"; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi

    # Extract the downloaded package
    echo "Extracting $OutFile..."
    if ! tar -xf "$OutFile"; then
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
    Global_Permission "${TARGET_DIR}" "user"
    # Set permissions for the sites/default/files directory
    echo "Setting permissions for the files directory..."
    if [ ! -d "${TARGET_DIR}/sites/default/files" ]; then
        mkdir -p "${TARGET_DIR}/sites/default/files"
    fi
    Global_Permission "${TARGET_DIR}/sites/default/files"
}

function ConfigureSettings() {
    echo "Configuring Drupal settings..."
    cd "${TARGET_DIR}" || {
        echo "Error: Failed to change directory to ${TARGET_DIR}. Exiting."
        return 1
    }
    COMPOSER_DISABLE_NETWORK=1 composer update --dry-run --profile
    composer require drush/drush
    # Create settings.php file
    SETTING_FILE="${TARGET_DIR}/sites/default/settings.php"
    cp "${TARGET_DIR}/sites/default/default.settings.php" "${SETTING_FILE}"
    Global_Permission "${SETTING_FILE}"
    ./vendor/bin/drush config:set system.site clean_url 1
    ./vendor/bin/drush config:set system.site trusted_host_patterns '["^www\\.drupal\\.local$", "^drupal\\.local$"]'
    # Install Drupal using Drush
    ./vendor/bin/drush site-install standard --db-url="mysql://${WEB_USERNAME}:${WEB_PASSWD}@${WEB_HOSTNAME}/${SITE_NAME}" \
        --site-name="AvN Learn" \
        --account-name="${WEB_USERNAME}" \
        --account-pass="${WEB_PASSWD}" \
        --account-mail="${WEB_EMAIL_ID}" \
        --site-mail="${WEB_EMAIL_ID}" \
        --yes

}

# Run the installation function
# Drush_Install
Install
SetPermissions
Database_Create "$SITE_NAME"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
unset TARGET_DIR
