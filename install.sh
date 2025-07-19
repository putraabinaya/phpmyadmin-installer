#!/bin/bash

# Warna
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Banner
clear
echo -e "${CYAN}"
echo "=================================================="
echo "          🚀 AUTO INSTALL PHPMYADMIN v5.2.2       "
echo "           by SkyNest Cloud - Bash Script          "
echo "=================================================="
echo -e "${NC}"

# Prompt Input
read -p "👤 Masukkan username database MySQL: " DBUSER
read -p "🔑 Masukkan password untuk user MySQL [$DBUSER]: " DBPASS

echo -e "\n${YELLOW}========================================"
echo "🔧 Mulai Proses Instalasi phpMyAdmin..."
echo "👤 DB User    : $DBUSER"
echo "🔐 DB Password: $DBPASS"
echo "========================================${NC}\n"
sleep 2

# Step 2: Unduh dan Ekstrak phpMyAdmin
echo -e "${CYAN}📥 Mengunduh phpMyAdmin...${NC}"
wget -q https://files.phpmyadmin.net/phpMyAdmin/5.2.2/phpMyAdmin-5.2.2-all-languages.zip
unzip -q phpMyAdmin-5.2.2-all-languages.zip
sudo mkdir -p /var/www/pterodactyl/public/pma
sudo mv phpMyAdmin-5.2.2-all-languages/* /var/www/pterodactyl/public/pma
rm -rf phpMyAdmin-5.2.2-all-languages*

# Step 3: Konfigurasi phpMyAdmin
echo -e "${CYAN}⚙️  Konfigurasi phpMyAdmin...${NC}"
cd /var/www/pterodactyl/public/pma
cp config.sample.inc.php config.inc.php

BLOWFISH=$(openssl rand -base64 32)
sed -i "s|\['blowfish_secret'\] = ''|['blowfish_secret'] = '$BLOWFISH'|g" config.inc.php
echo "\$cfg['TempDir'] = '/tmp';" >> config.inc.php

# Step 6: Setup Database
echo -e "${CYAN}🗄️  Konfigurasi MySQL...${NC}"
sudo mysql -u root <<MYSQL_SCRIPT
CREATE USER IF NOT EXISTS '$DBUSER'@'%' IDENTIFIED BY '$DBPASS';
GRANT ALL PRIVILEGES ON *.* TO '$DBUSER'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Step 7: Remote Access MySQL
echo -e "${CYAN}🔓 Membuka akses remote MySQL...${NC}"
sudo sed -i "s/^bind-address\s*=.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mysql

# DONE
echo -e "\n${GREEN}✅ Instalasi Selesai!${NC}"
echo -e "👤 Username MySQL  : ${YELLOW}$DBUSER${NC}"
echo -e "🔐 Password MySQL  : ${YELLOW}$DBPASS${NC}"
echo ""
