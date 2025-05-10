#!/usr/bin/env bash
export WEB_HOSTNAME="localhost"
export WEB_HOST_IP="192.168.56.10"
export WEB_EMAIL_ID="mr.raj3010@gmail.com"
export WEB_USERNAME="admin"
export WEB_PASSWD="admin@123"
export WIKI_PASSWD="adminwiki@123"
export PRIVATE_SSL="avnlearn"
export WP_DB="wordpress"
export DRUPAL_DB="drupal"
export JOOMLA_DB="joomla"
export MAGENTO_DB="magento"
export PROCESSWIRE_DB="processwire"
export PYROCMS_DB="pyrocms"
export BLUDIT_DB="bludit"
export MOODLE_DB="moodle"
export WIKI_DB="mediawiki"
export LARAVEL_DB="laravel"
export CAKEPHP_DB="cakephp"
export FUELPHP_DB="fuelphp"
export SYMFONY_DB="symfony"
export CODEIGNITER_DB="codeigniter"
export AVNLEARN_DB="avnlearn"
export PHP_DB="php"

export COMPOSER_ALLOW_SUPERUSER=1

function Composer_Install() {
    local Install_Package=("$@")
    echo "==========START Composer=========="
    echo "Install " "${Install_Package[@]}"
    composer global require "${Install_Package[@]}"
    echo "==========END Composer=========="
}

function Database_Create() {
    echo "==========START Database=========="
    local DIR_NAME
    local DATABASE_NAME
    DIR_NAME="$1"
    DATABASE_NAME="$(basename "$DIR_NAME")"

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
    if mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${DATABASE_NAME}\`;" 2>/dev/null; then
        echo "Database '${DATABASE_NAME}' created successfully."
    else
        echo "Error: Failed to create database '${DATABASE_NAME}'."
        return 1
    fi
    echo "==========END Database=========="
}

function ApacheConfigure() {
    local DIR_NAME
    local CONFIG_NAME
    local CONFIG_TYPE="$2" # Default to 'http' if not provided
    DIR_NAME="$1"
    CONFIG_NAME="$(basename "$DIR_NAME")"
    echo "==========START Apache2=========="
    # Check if DIR_NAME is provided
    if [[ -z "$DIR_NAME" ]]; then
        echo "Error: Directory name is required."
        return 1
    fi

    # Validate DIR_NAME (only allow valid directory paths)
    if [[ ! -d "$DIR_NAME" ]]; then
        echo "Error: The provided path '$DIR_NAME' is not a valid directory."
        return 1
    fi

    # Define the configuration file path
    local CONFIG_FILE="/etc/apache2/sites-available/avn-${CONFIG_NAME}.conf"

    # Check if the configuration file already exists
    if [[ -f "$CONFIG_FILE" ]]; then
        echo "Error: Apache configuration file $CONFIG_FILE already exists."
        return 1
    fi

    # Create the Apache configuration file for HTTP
    bash -c "cat <<EOF > $CONFIG_FILE
<VirtualHost *:80>
    ServerAdmin ${CONFIG_NAME}@avnlearn.com
    ServerName ${CONFIG_NAME}.local
    DocumentRoot $DIR_NAME
    ServerAlias www.${CONFIG_NAME}.local

    ErrorLog \${APACHE_LOG_DIR}/${CONFIG_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${CONFIG_NAME}_access.log combined
</VirtualHost>
EOF" || {
        echo "Error: Failed to create Apache configuration file."
        return 1
    }

    # Enable the new site
    a2ensite "avn-${CONFIG_NAME}.conf" || {
        echo "Error: Failed to enable site avn-${CONFIG_NAME}.conf."
        return 1
    }

    # Add entries to /etc/hosts
    local HOSTS_FILE="/etc/hosts"
    if ! grep -q "${CONFIG_NAME}.local" "$HOSTS_FILE"; then
        echo "127.0.0.1 ${CONFIG_NAME}.local" >>"$HOSTS_FILE"
        echo "127.0.0.1 www.${CONFIG_NAME}.local" >>"$HOSTS_FILE"
        echo "Added ${CONFIG_NAME}.local to /etc/hosts."
    else
        echo "Entry for ${CONFIG_NAME}.local already exists in /etc/hosts."
    fi

    # Restart Apache to apply changes
    systemctl reload apache2 || {
        echo "Error: Failed to restart Apache."
        return 1
    }

    echo "Apache configuration for ${CONFIG_NAME} has been set up successfully."

    # Additional configuration setup based on CONFIG_TYPE
    if [[ "$CONFIG_TYPE" == "ssl" ]]; then
        echo ##########START ssl##########"
        # Create SSL configuration if CONFIG_TYPE is 'ssl'
        local SSL_CONFIG_FILE="/etc/apache2/sites-available/avn-${CONFIG_NAME}-ssl.conf"
        if [[ -f "$SSL_CONFIG_FILE" ]]; then
            echo "Error: SSL configuration file $SSL_CONFIG_FILE already exists."
            return 1
        fi

        bash -c "cat <<EOF > $SSL_CONFIG_FILE
<IfModule mod_ssl.c>
    <VirtualHost *:80>
        ServerAdmin ${CONFIG_NAME}@avnlearn.com
        ServerName ${CONFIG_NAME}.local
        ServerAlias www.${CONFIG_NAME}.local
        Redirect permanent / https://${CONFIG_NAME}.local/
    </VirtualHost>
    <VirtualHost *:443>
        ServerAdmin ${CONFIG_NAME}@avnlearn.com
        ServerName ${CONFIG_NAME}.local
        DocumentRoot $DIR_NAME
        ServerAlias www.${CONFIG_NAME}.local

        ErrorLog \${APACHE_LOG_DIR}/${CONFIG_NAME}_ssl_error.log
        CustomLog \${APACHE_LOG_DIR}/${CONFIG_NAME}_ssl_access.log combined

        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/${PRIVATE_SSL}.crt
        SSLCertificateKeyFile /etc/ssl/private/${PRIVATE_SSL}.key

        <FilesMatch \"\\.(cgi|shtml|phtml|php)\$\">
            SSLOptions +StdEnvVars
        </FilesMatch>
        <Directory /usr/lib/cgi-bin>
            SSLOptions +StdEnvVars
        </Directory>
    </VirtualHost>
</IfModule>
EOF" || {
            echo "Error: Failed to create SSL Apache configuration file."
            return 1
        }

        # Enable the SSL site
        a2ensite "avn-${CONFIG_NAME}-ssl.conf" || {
            echo "Error: Failed to enable SSL site avn-${CONFIG_NAME}-ssl.conf."
            return 1
        }

        # Restart Apache to apply changes
        systemctl reload apache2 || {
            echo "Error: Failed to reload Apache."
            return 1
        }
        # systemctl reload apache2
        echo "SSL configuration for ${CONFIG_NAME} has been set up successfully."
        echo ##########END ssl##########"
    fi
    echo "==========END Apache2=========="
}

function Generate_Index_File() {
    local DIR_NAME="$1"
    local INDEX_PATH="$DIR_NAME/index.html"
    local CONFIG_NAME
    CONFIG_NAME="$(basename "$DIR_NAME")"
    echo "==========START Index.html=========="
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
    Global_Permission "$DIR_NAME"
    echo "==========END Index.html=========="
}

function Web_Download_File() {
    local URI="$1"
    local OutFile="$2"
    local Outdir
    Outdir="$(dirname "${OutFile}")"
    echo "==========START Download=========="
    # Check if the target directory exists
    if [ ! -d "$Outdir" ]; then
        echo "Error: $Outdir does not exist. Exiting."
        return 1
    fi
    echo "Starting download of ${OutFile}..."
    # Download the file
    echo "Downloading ${OutFile} from ${URI}..."
    if ! wget -q --show-progress "${URI}" -O "${OutFile}"; then
        echo "Error: Failed to download ${OutFile}. Exiting."
        return 1
    fi

    echo "Download of ${OutFile} completed successfully."
    echo "==========END Download=========="
    return 0
}

function Global_Permission() {
    local DIR_NAME="$1"
    echo "==========START Permission=========="
    if [[ -d "$DIR_NAME" ]]; then
        chown -R www-data:www-data "$DIR_NAME" &&
            find "$DIR_NAME" -type d -exec chmod 755 {} \; &&
            find "$DIR_NAME" -type f -exec chmod 644 {} \; &&
            echo "Permissions set for directory."
    elif [[ -f "$DIR_NAME" ]]; then
        chown www-data:www-data "$DIR_NAME" && chmod 644 "$DIR_NAME" &&
            echo "Permissions set for file."
    else
        echo "$DIR_NAME does not exist." >&2
        return 1
    fi
    echo "==========END Permission=========="
}
