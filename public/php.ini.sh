#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/START.sh
echo -e "${AVN_YELLOW}==========START PHP Configuration==========${AVN_NC}"
# Function to apply common PHP INI configurations
Common_PHP_INI_CONFIG() {

    [ ! -d "/var/www/tmp" ] && mkdir -p /var/www/tmp
    sudo chown -R www-data:www-data "/var/www/tmp"
    sudo chmod -R 755 "/var/www/tmp"
    sed -i.bak -e "s|^memory_limit.*|memory_limit = 256M|" \
        -e "s|^display_errors.*|display_errors = On|" \
        -e "s|^error_reporting.*|error_reporting = E_ALL|" \
        -e "s|^file_uploads.*|file_uploads = On|" \
        -e "s|^upload_max_filesize.*|upload_max_filesize = 512M|" \
        -e "s|^post_max_size.*|post_max_size = 512M|" \
        -e "s|^max_file_uploads.*|max_file_uploads = 100|" \
        -e "s|^max_execution_time.*|max_execution_time = 300|" \
        -e "s|^max_input_time.*|max_input_time = 300|" \
        -e "s|^session.save_path.*|session.save_path = /tmp|" \
        -e "s|^session.gc_maxlifetime.*|session.gc_maxlifetime = 1440|" \
        -e "s|^output_buffering.*|output_buffering = On|" \
        -e "s|^date.timezone.*|date.timezone = Asia/Kolkata|" \
        -e "s|^allow_url_fopen.*|allow_url_fopen = On|" \
        -e "s|^disable_functions.*|disable_functions = exec,passthru,shell_exec,system|" \
        -e "s|^;max_input_vars.*|max_input_vars = 5000|" \
        -e "s|^;upload_tmp_dir.*|upload_tmp_dir = /var/www/tmp|" "$1"
    # -e "s|^;extension=openssl|extension=openssl|" \
    # -e "s|^;extension=sqlite3|extension=sqlite3|" \
    # -e "s|^;extension=curl|extension=curl|" \
    # -e "s|^;extension=zip|extension=zip|" \
    # "$1"
}

# Loop through PHP versions and apply configurations
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
echo -e "${AVN_YELLOW}==========END PHP Configuration==========${AVN_NC}"
