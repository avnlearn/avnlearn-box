#!/usr/bin/env bash

# Function to apply common PHP INI configurations
Common_PHP_INI_CONFIG() {
    awk -v OFS='=' '
    BEGIN { 
        memory_limit = "256M"; display_errors = "On"; error_reporting = "E_ALL"; 
        file_uploads = "On"; upload_max_filesize = "64M"; post_max_size = "64M"; 
        max_execution_time = "300"; max_input_time = "300"; 
        session_save_path = "/tmp"; session_gc_maxlifetime = "1440"; 
        output_buffering = "On"; date_timezone = "Asia/Kolkata"; 
        allow_url_fopen = "On"; disable_functions = "exec,passthru,shell_exec,system"; 
        max_input_vars = "5000"; 
    }
    /^memory_limit/ { print $1, memory_limit; next }
    /^display_errors/ { print $1, display_errors; next }
    /^error_reporting/ { print $1, error_reporting; next }
    /^file_uploads/ { print $1, file_uploads; next }
    /^upload_max_filesize/ { print $1, upload_max_filesize; next }
    /^post_max_size/ { print $1, post_max_size; next }
    /^max_execution_time/ { print $1, max_execution_time; next }
    /^max_input_time/ { print $1, max_input_time; next }
    /^session.save_path/ { print $1, session_save_path; next }
    /^session.gc_maxlifetime/ { print $1, session_gc_maxlifetime; next }
    /^output_buffering/ { print $1, output_buffering; next }
    /^date.timezone/ { print $1, date_timezone; next }
    /^allow_url_fopen/ { print $1, allow_url_fopen; next }
    /^disable_functions/ { print $1, disable_functions; next }
    /^max_input_vars/ { print $1, max_input_vars; next }
    { print }
    ' "$1" >"$1.tmp" && mv "$1.tmp" "$1"
}

# Iterate through all installed PHP versions
for PHP_DIR in /etc/php/*; do
    [[ -d "$PHP_DIR" ]] || continue
    for WEB_SERVER in "apache2" "cli"; do
        PHP_INI_CONFIG="$PHP_DIR/$WEB_SERVER/php.ini"
        [[ -f "$PHP_INI_CONFIG" ]] || continue
        cp -f "$PHP_INI_CONFIG" "$PHP_INI_CONFIG.bak"
        Common_PHP_INI_CONFIG "$PHP_INI_CONFIG"
        [[ "$WEB_SERVER" == "apache2" ]] && systemctl restart apache2
        echo "Updated configuration for $WEB_SERVER in $PHP_DIR."
    done
done
