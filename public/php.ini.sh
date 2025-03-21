#!/usr/bin/env bash
PHP_VERSION="8.1"

Commmon_PHP_INI_CONFIG() {
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

WEB_SERVER="apache2"
PHP_INI_CONFIG="/etc/php/$PHP_VERSION/$WEB_SERVER/php.ini"
if ! [[ -d "$PHP_INI_CONFIG" ]]; then
    cp -f "$PHP_INI_CONFIG" "$PHP_INI_CONFIG.bak"
    Commmon_PHP_INI_CONFIG "$PHP_INI_CONFIG"
    systemctl restart apache2
fi

WEB_SERVER="cli"
PHP_INI_CONFIG="/etc/php/$PHP_VERSION/$WEB_SERVER/php.ini"
if ! [[ -d "$PHP_INI_CONFIG" ]]; then
    cp -f "$PHP_INI_CONFIG" "$PHP_INI_CONFIG.bak"
    Commmon_PHP_INI_CONFIG "$PHP_INI_CONFIG"
    systemctl restart apache2
fi
