#Install nextcloud.
/boot/dietpi/dietpi-software install 114

#Change Nextcloud configs. 
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set maintenance_window_start --type=integer --value=1
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set opcache.interned_strings_buffer --type=integer --value=9
sudo -u www-data php8.2 /var/www/nextcloud/occ maintenance:repair --include-expensive

#Remove default files.
cd /etc/nginx/sites-dietpi
sudo rm -rf dietpi-dav_redirect.conf dietpi-nextcloud.conf

#Install postgresql.
sudo apt-get install postgresql -y

#Create user and database.
sudo -i -u postgres psql -c 'CREATE USER onlyoffice WITH PASSWORD '"$(echo "$1")"';'
sudo -i -u postgres psql -c 'CREATE DATABASE onlyoffice WITH OWNER onlyoffice;'

#Install rabbitmq-server.
sudo apt-get install rabbitmq-server -y

#Change port to 8090
echo onlyoffice-documentserver onlyoffice/ds-port select 8090 | sudo debconf-set-selections

#Add GPG key.
mkdir -p -m 700 ~/.gnupg
curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --import
chmod 644 /tmp/onlyoffice.gpg
sudo chown root:root /tmp/onlyoffice.gpg
sudo mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg

#Add ONLYOFFICE Docs repository.
echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main" | sudo tee /etc/apt/sources.list.d/onlyoffice.list

#Update
sudo apt-get update -y

#Install ttf-mscorefonts-installer.
sudo apt-get install ttf-mscorefonts-installer -y

#Install Onlyoffice.
(echo "$(echo "$1")") | sudo apt-get install onlyoffice-documentserver -y