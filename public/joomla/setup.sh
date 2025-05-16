#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh
# Define the target directory

SITE_NAME="joomla"
TARGET_DIR="/var/www/${SITE_NAME}"

function Install() {
    echo "Starting Joomla installation..."
    local OutFile
    local URI="https://downloads.joomla.org/cms/joomla5/5-3-0/Joomla_5-3-0-Stable-Full_Package.zip?format=zip"
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
    rm -rf Joomla_5.*
}

function SetPermissions() {
    Global_Permission "${TARGET_DIR}" "user"
    mkdir -p ${TARGET_DIR}/{logs,tmp}
    Global_Permission "${TARGET_DIR}/logs" "user"
    Global_Permission "${TARGET_DIR}/tmp" "user"
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
class JConfig {
	public \$offline = false;
	public \$offline_message = 'This site is down for maintenance.<br>Please check back again soon.';
	public \$display_offline_message = 1;
	public \$offline_image = '';
	public \$sitename = 'AvN Learn';
	public \$editor = 'tinymce';
	public \$captcha = '0';
	public \$list_limit = 20;
	public \$access = 1;
	public \$frontediting = 1;
	public \$debug = true;
	public \$debug_lang = true;
	public \$debug_lang_const = true;
	public \$dbtype = 'mysqli';
	public \$host = '${WEB_HOSTNAME}';
	public \$user = '${WEB_USERNAME}';
	public \$password = '${WEB_PASSWD}';
	public \$db = '${SITE_NAME}';
	public \$dbprefix = 'fp9k2_';
	public \$dbencryption = 0;
	public \$dbsslverifyservercert = false;
	public \$dbsslkey = '';
	public \$dbsslcert = '';
	public \$dbsslca = '';
	public \$dbsslcipher = '';
	public \$force_ssl = 0;
	public \$live_site = '';
	public \$secret = 'RU8cOO4rEqJhkLjM';
	public \$gzip = false;
	public \$error_reporting = 'default';
	public \$helpurl = 'https://help.joomla.org/proxy?keyref=Help{major}{minor}:{keyref}&lang={langcode}';
	public \$offset = 'UTC';
	public \$cors = false;
	public \$cors_allow_origin = '*';
	public \$cors_allow_methods = '';
	public \$cors_allow_headers = 'Content-Type,X-Joomla-Token';
	public \$mailonline = true;
	public \$mailer = 'mail';
	public \$mailfrom = '${WEB_EMAIL_ID}';
	public \$fromname = 'AvN Learn';
	public \$sendmail = '/usr/sbin/sendmail';
	public \$smtpauth = false;
	public \$smtpuser = '';
	public \$smtppass = '';
	public \$smtphost = '${WEB_HOSTNAME}';
	public \$smtpsecure = 'none';
	public \$smtpport = 25;
	public \$caching = 0;
	public \$cache_handler = 'file';
	public \$cachetime = 15;
	public \$cache_platformprefix = false;
	public \$MetaDesc = '';
	public \$MetaAuthor = true;
	public \$MetaVersion = false;
	public \$robots = '';
	public \$sef = true;
	public \$sef_rewrite = false;
	public \$sef_suffix = false;
	public \$unicodeslugs = false;
	public \$feed_limit = 10;
	public \$feed_email = 'none';
	public \$log_path = '/var/www/joomla/administrator/logs';
	public \$tmp_path = '/var/www/joomla/tmp';
	public \$lifetime = 15;
	public \$session_handler = 'database';
	public \$shared_session = false;
	public \$session_metadata = true;
EOL

    # Set permissions for configuration.php
    Global_Permission "${TARGET_DIR}/configuration.php"

    echo "Joomla configuration completed successfully."
}

Install
SetPermissions
Database_Create "$SITE_NAME"
ConfigureSettings
ApacheConfigure "$TARGET_DIR" "$SITE_NAME" # "ssl"
unset TARGET_DIR
