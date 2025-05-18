#!/usr/bin/env bash
export WEB_HOSTNAME="localhost"
export HTTP2_HOST_IP="$WEB_HOSTNAME"
export WEB_EMAIL_ID="mr.raj3010@gmail.com"
export WEB_USERNAME="admin"
export WEB_PASSWD="admin@123"
export WIKI_PASSWD="adminwiki@123"
export MOODLE_PASSWD="Admin@123"

export AVNLEARN_SSL_CRT="/etc/ssl/certs/avnlearn.cert"
export AVNLEARN_SSL_KEY="/etc/ssl/private/avnlearn.key"
export COMPOSER_ALLOW_SUPERUSER=1
export DEBIAN_FRONTEND="noninteractive"

# Define color codes
export AVN_RED='\033[0;31m'
export AVN_GREEN='\033[0;32m'
export AVN_YELLOW='\033[1;33m'
export AVN_BLUE='\033[0;34m'
export AVN_BOLD='\033[1m'
export AVN_NC='\033[0m' # No Color

function Composer_Install() {
    local Install_Package=("$@")
    echo "${AVN_YELLOW}==========START Composer==========${AVN_NC}"
    echo "Install " "${Install_Package[@]}"
    composer global require "${Install_Package[@]}"
    echo "${AVN_YELLOW}==========END Composer==========${AVN_NC}"
    composer global config bin-dir --absolute
}

function Database_Create() {
    echo "${AVN_YELLOW}==========START Database==========${AVN_NC}"
    local DIR_NAME
    local DATABASE_NAME
    DIR_NAME="$1"
    DATABASE_NAME="$(basename "$DIR_NAME")"
    local COMMAND
    for cmd in mysql mariadb; do
        if command -v $cmd &>/dev/null; then
            COMMAND=$cmd
            break
        fi
    done
    if [ -z "$COMMAND" ]; then
        echo "MySQL/MariaDB command not found. Please install the MySQL client."
        return 1
    fi
    # Check if the database name is provided
    if [[ -z "$DATABASE_NAME" ]]; then
        echo "Error: No database name provided."
        return 1
    fi

    # Validate the database name (optional: you can customize this regex)
    if ! [[ "$DATABASE_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Error: Invalid database name. Only alphanumeric characters and underscores are allowed."
        return 1
    fi

    echo "Creating database: ${DATABASE_NAME}"

    # Attempt to create the database and capture the output
    if $COMMAND -u root -e "CREATE DATABASE IF NOT EXISTS \`${DATABASE_NAME}\`;" 2>/dev/null; then
        echo "Database '${DATABASE_NAME}' created successfully."
    else
        echo "Error: Failed to create database '${DATABASE_NAME}'."
        return 1
    fi
    echo -e "${AVN_YELLOW}==========END Database==========${AVN_NC}"
}

function set_bashrc() {
    local STR
    # Read the heredoc into the string variable
    STR=$(cat)
    for user in root vagrant; do
        # Append the string to the user's .bashrc
        if [ -f "/home/$user/.bashrc" ]; then
            echo "$STR" >>"/home/$user/.bashrc"
        elif [ -f "/$user/.bashrc" ]; then
            echo "$STR" >>"/$user/.bashrc"
        fi
    done
}

function git_clone() {
    local REPO="$1"
    # Check if the target directory exists
    if [ ! -d "/var/www" ]; then
        echo "Error: /var/www/html does not exist. Exiting."
        return 1
    fi
    cd /var/www || {
        echo "Error: Failed to change directory to /var/www/html. Exiting."
        return 1
    }
    # Download the latest ProcessWire package
    echo "Downloading $(basename "$REPO")..."
    sudo git clone "$REPO"
}

function ApacheConfigure() {
    local DIR_NAME="$1"
    local SITE_NAME="$2"
    local APACHE_LOG_DIR="\${APACHE_LOG_DIR}"
    local DOMAIN_NAME="${SITE_NAME}.local"
    local SITE_CONFIG_FILE="/etc/apache2/sites-available/${DOMAIN_NAME}.conf"
    local SSL_CONFIG_FILE="/etc/apache2/sites-available/${DOMAIN_NAME}-ssl.conf"
    local SSL_KEY="/etc/ssl/private/${SITE_NAME}.pem"
    local SSL_CERTS="/etc/ssl/certs/${SITE_NAME}.pem"
    SSL_CERTS="${AVNLEARN_SSL_CRT}"
    SSL_KEY="${AVNLEARN_SSL_KEY}"

    echo -e "${AVN_YELLOW}==========END Apache2 Configuration ${SITE_NAME}==========${AVN_NC}"
    if [[ -z "$DIR_NAME" || -z "$SITE_NAME" || ! -d "$DIR_NAME" ]]; then
        echo "Error: Valid directory name and site name are required."
        return 1
    fi

    if [[ -f "$SITE_CONFIG_FILE" ]]; then
        echo "Error: Configuration file already exists."
        return 1
    fi
    echo "Create $SITE_CONFIG_FILE"
    if [ ! -f "/vagrant/public/${SITE_NAME}/apache2.conf" ]; then
        echo "Generator $SITE_CONFIG_FILE"
        cat <<EOF >"$SITE_CONFIG_FILE"
<VirtualHost *:80>
    ServerAdmin ${SITE_NAME}@avnlearn.com
    ServerName ${DOMAIN_NAME}
    DocumentRoot $DIR_NAME
    ServerAlias www.${DOMAIN_NAME}
    <Directory $DIR_NAME>
        AllowOverride All
        # Options Indexes FollowSymLinks
        Options -Indexes
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/${DOMAIN_NAME}_error.log
    CustomLog ${APACHE_LOG_DIR}/${DOMAIN_NAME}_access.log combined
</VirtualHost>
EOF
    else
        echo "Copying /vagrant/public/${SITE_NAME}/apache2.conf => $SITE_CONFIG_FILE"
        cp "/vagrant/public/${SITE_NAME}/apache2.conf" "$SITE_CONFIG_FILE"
    fi
    if [ -f "$SITE_CONFIG_FILE" ]; then
        a2ensite "${DOMAIN_NAME}"
        cat <<EOF >>/home/vagrant/.bashrc
echo -e "${AVN_BOLD}${AVN_RED}[✓] : ${AVN_YELLOW}http://${DOMAIN_NAME}${AVN_NC}"
EOF
        apachectl configtest
        systemctl reload apache2
        echo "Apache configuration for http://${DOMAIN_NAME} set up successfully."
    else
        echo "Appache configuration is not exists!"
    fi

    # SSL Configuration
    if [ ! -f "${SSL_CERTS}" ]; then
        mkcert -key-file "${SSL_KEY}" -cert-file "${SSL_CERTS}" "${DOMAIN_NAME}"
        sudo chown www-data:www-data "${SSL_KEY}"
        sudo chown www-data:www-data "${SSL_CERTS}"
        sudo chmod 644 "${SSL_CERTS}"
        sudo chmod 600 "${SSL_KEY}"
    fi
    if [[ -f "${SSL_KEY}" && -f "${SSL_CERTS}" ]]; then
        echo -e "${AVN_BOLD}${AVN_GREEN}##########START SSL##########${AVN_NC}"
        if [[ -f "$SSL_CONFIG_FILE" ]]; then
            echo "Error: SSL configuration file already exists."
            return 1
        fi
        echo "Create $SSL_CONFIG_FILE"
        if [ ! -f "/vagrant/public/${SITE_NAME}/apache2-ssl.conf" ]; then
            echo "Generator $SSL_CONFIG_FILE"
            cat <<EOF >"$SSL_CONFIG_FILE"
<IfModule mod_ssl.c>
    # <VirtualHost *:80>
    #     Redirect permanent / https://${DOMAIN_NAME}/
    # </VirtualHost>
    <VirtualHost *:443>
        ServerAdmin ${SITE_NAME}@avnlearn.com
        ServerName ${DOMAIN_NAME}
        DocumentRoot $DIR_NAME
        ServerAlias www.${DOMAIN_NAME}
        SSLEngine on
        SSLCertificateFile ${SSL_CERTS}
        SSLCertificateKeyFile ${SSL_KEY}
        <Directory $DIR_NAME>
            AllowOverride All
            # Options Indexes FollowSymLinks
            Options -Indexes
            Require all granted
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/${DOMAIN_NAME}_ssl_error.log
        CustomLog ${APACHE_LOG_DIR}/${DOMAIN_NAME}_ssl_access.log combined
        # Security Headers
        Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains" env=HTTPS
        Header always set X-Content-Type-Options "nosniff"
        Header always set X-XSS-Protection "1; mode=block"
        Header always set X-Frame-Options "DENY"
        Header always set Content-Security-Policy "default-src 'self';"
    </VirtualHost>
</IfModule>
EOF
        else
            echo "Copying /vagrant/public/${SITE_NAME}/apache2-ssl.conf => $SSL_CONFIG_FILE"
            cp -f "/vagrant/public/${SITE_NAME}/apache2-ssl.conf" "$SSL_CONFIG_FILE"

        fi
        if [ -f "$SSL_CONFIG_FILE" ]; then
            a2ensite "${DOMAIN_NAME}-ssl"
            cat <<EOF >>/home/vagrant/.bashrc
echo -e "${AVN_BOLD}${AVN_RED}[✓] : ${AVN_GREEN}https://${DOMAIN_NAME}${AVN_NC}"
EOF
            apachectl configtest
            systemctl reload apache2
            echo "SSL configuration for https://${DOMAIN_NAME} set up successfully."
        else
            echo "Appache configuration SSL is not exists!"
        fi
        echo -e "${AVN_BOLD}${AVN_GREEN}##########END SSL##########${AVN_NC}"
    fi
    echo -e "${AVN_YELLOW}==========END Apache2 Configuration ${SITE_NAME}==========${AVN_NC}"
}

function Generate_Index_File() {
    local DIR_NAME="$1"
    local INDEX_PATH="$DIR_NAME/index.html"
    local CONFIG_NAME="$2"
    # CONFIG_NAME="$(basename "$DIR_NAME")"
    echo -e "${AVN_YELLOW}==========START Index.html==========${AVN_NC}"
    mkdir -p "$DIR_NAME" || {
        echo "Error: Failed to create directory '$DIR_NAME'."
        return 1
    }

    cat <<EOF >"$INDEX_PATH"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${CONFIG_NAME}</title>
</head>
<body>
    <h1>Welcome to ${CONFIG_NAME}</h1>
    <p>A web framework or web application framework is a software framework that is designed to support the development of web applications including web services, web resources, and web APIs.</p>
    <p>Web frameworks provide a standard way to build and deploy web applications on the World Wide Web.</p>
    <p>Web frameworks aim to automate the overhead associated with common activities performed in web development.</p>
</body>
</html>
EOF

    echo "Index file created successfully at '$INDEX_PATH'."
    Global_Permission "$DIR_NAME" "user"
    echo -e "${AVN_YELLOW}==========END Index.html==========${AVN_NC}"
}

function Web_Download_File() {
    local URI="$1"
    local OutFile="$2"
    local Outdir
    Outdir="$(dirname "${OutFile}")"

    echo -e "${AVN_YELLOW}==========START Download==========${AVN_NC}"

    # Check if the target directory exists
    if [ ! -d "$Outdir" ]; then
        echo "Error: $Outdir does not exist. Exiting."
        return 1
    fi

    echo "Starting download of ${OutFile}..."
    echo "Downloading ${OutFile} from ${URI}..."

    # Download the file
    # if ! wget -q --show-progress "${URI}" -O "${OutFile}"; then

    if ! wget -q "${URI}" -O "${OutFile}"; then
        # if ! curl -v "${URI}" -o "${OutFile}" >"${LogFile}" 2>&1; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi

    echo "Download of ${OutFile} completed successfully."
    echo -e "${AVN_YELLOW}==========END Download==========${AVN_NC}"
    return 0
}

function Global_Permission() {
    local DIR_NAME="$1"
    local USER_PERMISSION="$2"
    echo -e "${AVN_YELLOW}==========START Permission==========${AVN_NC}"

    if [[ ! -e "$DIR_NAME" ]]; then
        echo "$DIR_NAME does not exist." >&2
        return 1
    fi

    if [[ "$USER_PERMISSION" == "user" ]]; then
        chown -R "vagrant:vagrant" "$DIR_NAME"
    else
        chown -R "www-data:www-data" "$DIR_NAME"
        find "$DIR_NAME" -type d -exec chmod 755 {} \; -o -type f -exec chmod 644 {} \;
    fi

    echo "Permissions set for $DIR_NAME."
    echo -e "${AVN_YELLOW}==========END Permission==========${AVN_NC}"
}
