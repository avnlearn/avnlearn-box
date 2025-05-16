#!/usr/bin/env bash
# shellcheck source=/dev/null
source /vagrant/public/bootstrap.sh

function SetPremission() {
    chown -R www-data:www-data /var/www
    chmod -R 755 /var/www
}
function Apache_Setup() {
    echo "TODO : Enable Apache mod_rewrite"
    a2dissite 000-default
    systemctl reload apache2
}
function Helper() {

    # Append custom messages to the .bashrc file for the vagrant user
    cat <<EOF >>/home/vagrant/.bashrc
echo -e "${AVN_BOLD}${AVN_GREEN}TODO : SERVER Complete${AVN_NC}"
echo -e "${AVN_BOLD}${AVN_BLUE}======================${AVN_NC}"
echo -e "${AVN_BOLD}${YELLOW}Administrator${AVN_NC}"
echo -e "${AVN_BOLD}${AVN_BLUE}User Information:${AVN_NC}"
echo -e "\t${AVN_BOLD}1. ${AVN_YELLOW}Username : ${AVN_GREEN}$WEB_USERNAME${AVN_NC}"
echo -e "\t${AVN_BOLD}2. ${AVN_RED}Password : ${AVN_GREEN}$WEB_PASSWD${AVN_NC}"
echo -e "\t${AVN_BOLD}3. ${AVN_RED}Wiki Password : ${AVN_GREEN}$WIKI_PASSWD${AVN_NC}"
echo -e "${AVN_BOLD}${AVN_BLUE}======================${AVN_NC}"
EOF
    bash /home/vagrant/.bashrc
}
SetPremission
Apache_Setup
Helper
