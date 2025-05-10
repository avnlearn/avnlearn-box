#!/usr/bin/env bash

# Function to apply common PHP INI configurations
Common_PHP_INI_CONFIG() {
    local PHP_INI_PATH="$1"
    sed -i -e 's/^memory_limit = .*/memory_limit = 256M/' \
        -e 's/^display_errors = .*/display_errors = On/' \
        -e 's/^error_reporting = .*/error_reporting = E_ALL/' \
        -e 's/^file_uploads = .*/file_uploads = On/' \
        -e 's/^upload_max_filesize = .*/upload_max_filesize = 64M/' \
        -e 's/^post_max_size = .*/post_max_size = 64M/' \
        -e 's/^max_execution_time = .*/max_execution_time = 300/' \
        -e 's/^max_input_time = .*/max_input_time = 300/' \
        -e 's|^session.save_path = .*|session.save_path = "/tmp"|' \
        -e 's/^session.gc_maxlifetime = .*/session.gc_maxlifetime = 1440/' \
        -e 's/^output_buffering = .*/output_buffering = On/' \
        -e 's|^date.timezone = .*|date.timezone = "Asia/Kolkata"|' \
        -e 's/^allow_url_fopen = .*/allow_url_fopen = On/' \
        -e 's/^disable_functions = .*/disable_functions = "exec,passthru,shell_exec,system"/' \
        "$PHP_INI_PATH"
}

# Function to install a PHP extension
install_extension() {
    local extension=$1
    echo "Installing $extension..."
    if ! pecl install "$extension"; then
        echo "Failed to install $extension. Please check your PHP configuration."
        exit 1
    fi
}

# Get the current PHP version
CURRENT_PHP_VERSION=$(php -r "echo PHP_VERSION;")

# Extract the major and minor version (e.g., 8.1)
PHP_VERSION_MAJOR_MINOR=$(echo "$CURRENT_PHP_VERSION" | cut -d '.' -f 1-2)

# Check if the PHP version is installed
if [[ -d "/etc/php/$PHP_VERSION_MAJOR_MINOR" ]]; then
    echo "Current PHP version: $CURRENT_PHP_VERSION"
    echo "Applying configuration for PHP version $PHP_VERSION_MAJOR_MINOR..."

    for WEB_SERVER in "apache2" "cli"; do
        PHP_INI_CONFIG="/etc/php/$PHP_VERSION_MAJOR_MINOR/$WEB_SERVER/php.ini"
        if [[ -f "$PHP_INI_CONFIG" ]]; then
            cp -f "$PHP_INI_CONFIG" "$PHP_INI_CONFIG.bak"
            Common_PHP_INI_CONFIG "$PHP_INI_CONFIG"
            if [[ "$WEB_SERVER" == "apache2" ]]; then
                systemctl restart apache2
            fi
            echo "Updated configuration for $WEB_SERVER."
        else
            echo "PHP INI config not found for $WEB_SERVER at $PHP_INI_CONFIG"
        fi
    done

    # # Install required PHP extensions
    # for EXTENSION in "raphf" "pecl_http"; do
    #     if ! php -m | grep -q "$EXTENSION"; then
    #         install_extension "$EXTENSION"
    #         # Enable the extension in php.ini
    #         echo "extension=${EXTENSION}.so" | sudo tee -a "$PHP_INI_CONFIG"
    #     else
    #         echo "$EXTENSION is already installed."
    #     fi
    # done

else
    echo "PHP version $PHP_VERSION_MAJOR_MINOR is not installed."
fi
