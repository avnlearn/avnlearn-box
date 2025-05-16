#!/usr/bin/env bash

# Function to apply common PHP INI configurations
Common_PHP_INI_CONFIG() {
    sed -i.bak -e "s/^memory_limit.*/memory_limit = 256M/" \
        -e "s/^display_errors.*/display_errors = On/" \
        -e "s/^error_reporting.*/error_reporting = E_ALL/" \
        -e "s/^file_uploads.*/file_uploads = On/" \
        -e "s/^upload_max_filesize.*/upload_max_filesize = 64M/" \
        -e "s/^post_max_size.*/post_max_size = 64M/" \
        -e "s/^max_execution_time.*/max_execution_time = 300/" \
        -e "s/^max_input_time.*/max_input_time = 300/" \
        -e "s/^session.save_path.*/session.save_path = \/tmp/" \
        -e "s/^session.gc_maxlifetime.*/session.gc_maxlifetime = 1440/" \
        -e "s/^output_buffering.*/output_buffering = On/" \
        -e "s/^date.timezone.*/date.timezone = Asia/Kolkata/" \
        -e "s/^allow_url_fopen.*/allow_url_fopen = On/" \
        -e "s/^disable_functions.*/disable_functions = exec,passthru,shell_exec,system/" \
        -e "s/^;max_input_vars.*/max_input_vars = 5000/" "$1"
}

for PHP_DIR in /etc/php/*; do
    [[ -d "$PHP_DIR" ]] || continue
    for WEB_SERVER in "apache2" "cli"; do
        PHP_INI_CONFIG="$PHP_DIR/$WEB_SERVER/php.ini"
        [[ -f "$PHP_INI_CONFIG" ]] || continue
        Common_PHP_INI_CONFIG "$PHP_INI_CONFIG"
        [[ "$WEB_SERVER" == "apache2" ]] && systemctl restart apache2
        echo "Updated configuration for $WEB_SERVER in $PHP_DIR."
    done
done
