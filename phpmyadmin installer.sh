#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
clear
echo -e "${BLUE}=======================================${NC}"
echo -e "${YELLOW}     Gyu Installer Tools Panel       ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}1) Install PhpMyAdmin for Pterodactyl${NC}"
echo -e "${GREEN}2) Add Database User Admin${NC}"
echo -e "${RED}3) Exit${NC}"
echo -e "${BLUE}=======================================${NC}"
read -p "Choose an option: " option

generate_blowfish_secret() {
    echo $(tr -dc 'a-zA-Z0-9!@#$%^&*()-_=+{}[]<>?' </dev/urandom | head -c 32)
}

install_phpmyadmin() {
    echo -e "${YELLOW}Installing PhpMyAdmin...${NC}"
    cd /var/www/pterodactyl/public/
    mkdir -p pma
    cd pma
    wget https://files.phpmyadmin.net/phpMyAdmin/5.2.2/phpMyAdmin-5.2.2-all-languages.zip
    unzip phpMyAdmin-5.2.2-all-languages.zip
    mv phpMyAdmin-5.2.2-all-languages/* /var/www/pterodactyl/public/pma
    rm -rf phpM*
    mkdir -p /var/www/pterodactyl/public/pma/tmp
    chmod -R 777 /var/www/pterodactyl/public/pma/tmp
    
    blowfish_secret=$(generate_blowfish_secret)
    sed -i "s|\$cfg\['blowfish_secret'\] = '';|\$cfg\['blowfish_secret'\] = '$blowfish_secret';|" /var/www/pterodactyl/public/pma/config.sample.inc.php
    mv /var/www/pterodactyl/public/pma/config.sample.inc.php /var/www/pterodactyl/public/pma/config.inc.php
    
    echo -e "${GREEN}Installation Complete. PhpMyAdmin is now installed with a generated Blowfish Secret.${NC}"
}

add_database_admin() {
    read -p "Enter new MySQL admin username: " db_user
    read -s -p "Enter new MySQL admin password: " db_pass
    echo
    read -p "Enter MySQL root password: " root_pass

    mysql -u root -p"$root_pass" -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_pass';"
    mysql -u root -p"$root_pass" -e "GRANT ALL PRIVILEGES ON *.* TO '$db_user'@'localhost' WITH GRANT OPTION;"
    mysql -u root -p"$root_pass" -e "FLUSH PRIVILEGES;"
    echo -e "${GREEN}User $db_user added as MySQL Admin.${NC}"
}

case $option in
    1)
        install_phpmyadmin
        ;;
    2)
        add_database_admin
        ;;
    3)
        echo -e "${RED}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Exiting...${NC}"
        exit 1
        ;;
esac
