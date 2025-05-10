#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
TARGET_DIR="/var/www/mediawiki"

function Install() {
    local OutFile
    local URI="https://releases.wikimedia.org/mediawiki/1.39/mediawiki-1.39.0.tar.gz"
    OutFile="$(basename "$TARGET_DIR").tar.gz"
    echo "Starting $OutFile installation..."
    if ! Web_Download_File "$URI" "$OutFile"; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi

    # Extract the downloaded package
    echo "Extracting $OutFile..."
    if ! tar -xvzf "$OutFile"; then
        echo "Error: Failed to extract $OutFile. Exiting."
        return 1
    fi
    # Move the extracted files to the target directory
    [ ! -d "${TARGET_DIR}" ] && mkdir -p "${TARGET_DIR}"
    mv mediawiki-*/* "${TARGET_DIR}/"
    rm -rf mediawiki-*
    # Remove the downloaded tar file
    rm -f "$OutFile"
}

function SetPermissions() {
    Global_Permission "${TARGET_DIR}"
    Global_Permission "${TARGET_DIR}/images"
}

function ConfigureSettings() {
    echo "Configuring MediaWiki settings..."

    # Check if the MediaWiki maintenance script is available
    if [ ! -f "${TARGET_DIR}/maintenance/install.php" ]; then
        echo "Error: MediaWiki install script not found. Exiting."
        return 1
    fi

    # Run the MediaWiki installation script
    php "${TARGET_DIR}/maintenance/install.php" \
        --dbname="${WIKI_DB}" \
        --dbuser="${WEB_USERNAME}" \
        --dbpass="${WEB_PASSWD}" \
        --dbserver="${WEB_HOSTNAME}" \
        --installdbuser="${WEB_USERNAME}" \
        --installdbpass="${WEB_PASSWD}" \
        --scriptpath="" \
        --pass="${WIKI_PASSWD}" \
        "AvNLearn" \
        "Admin" \
        "${WEB_EMAIL_ID}"

    # Move the generated LocalSettings.php to the target directory
    mv "${TARGET_DIR}/LocalSettings.php" "${TARGET_DIR}/LocalSettings.php"

    echo "MediaWiki has been installed. You can now access it at your web server's URL."
}

Install
SetPermissions
Database_Create "$TARGET_DIR"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" # "ssl"
unset TARGET_DIR
