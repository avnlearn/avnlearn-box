#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
# Define the target directory
TARGET_DIR="/var/www/wordpress"

function WP_CLI_Install() {
    if ! command -v wp &>/dev/null; then
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        php wp-cli.phar --info
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
        wp --info
        wp cli update
        curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.11.0/utils/wp-completion.bash
        chmod +x wp-completion.bash
        mv wp-completion.bash /etc/bash_completion.d/
    fi
}

function Install() {
    local OutFile
    local URI="https://wordpress.org/latest.tar.gz"
    OutFile="$(basename "$TARGET_DIR").tar.gz"
    echo "Starting $OutFile installation..."
    if ! Web_Download_File "$URI" "$OutFile"; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi

    # Extract the downloaded package
    echo "Extracting $(dirname "$TARGET_DIR")..."
    if ! tar -xvzf "$OutFile" -C "$(dirname "$TARGET_DIR")"; then
        echo "Error: Failed to extract $OutFile. Exiting."
        return 1
    fi
    # Remove the downloaded tar file
    rm -f "$OutFile"

}

function SetPermissions() {
    Global_Permission "${TARGET_DIR}"
    Global_Permission "${TARGET_DIR}/wp-content/uploads"
}
function ConfigureSettings() {
    echo "TODO : WordPress Setup"
    # Check if the target directory exists
    if [ ! -d "${TARGET_DIR}" ]; then
        echo "Error: ${TARGET_DIR} does not exist. Exiting."
        return 1
    fi
    cd "${TARGET_DIR}" || {
        echo "Error: Failed to change directory to ${TARGET_DIR}. Exiting."
        return 1
    }
    sudo wp config create --dbname="${WP_DB}" --dbuser="${WEB_USERNAME}" --dbpass="${WEB_PASSWD}" --dbhost="${WEB_HOSTNAME}" --allow-root --extra-php <<PHP
define('WP_DEBUG', true); // Enable WP_DEBUG mode
define('WP_DEBUG_LOG', true); // Enable error logging to wp-content/debug.log
define('WP_DEBUG_DISPLAY', false); // Disable display of errors and warnings
define('SCRIPT_DEBUG', true); // Use unminified versions of CSS and JS files
define('WP_MEMORY_LIMIT', '256M'); // Increase memory limit
define('AUTOMATIC_UPDATER_DISABLED', true); // Disable automatic updates
define('WP_DEBUG_LOG', '$TARGET_DIR/debug.log');
PHP
    sudo wp core install --url="wordpress.local" --title="AvN Learn" --admin_user="${WEB_USERNAME}" --admin_password="${WEB_PASSWD}" --admin_email="${WEB_EMAIL_ID}" --allow-root
}

WP_CLI_Install
Install
Database_Create "$TARGET_DIR"
SetPermissions
ApacheConfigure "$TARGET_DIR" # "ssl"
ConfigureSettings

unset TARGET_DIR
