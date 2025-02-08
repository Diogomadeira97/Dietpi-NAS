#Install Docker, Docker_Compose, Portainer, Nginx, LEMP and nextcloud.
/boot/dietpi/dietpi-software install 134 162 185 85 79 114

#Go to Cloud and create default folders.
cd /mnt/Cloud
mkdir Data/Docker Data/Docker/flaresolver Data/Docker/immich-app Data/Docker/vscodium Data/Docker/gimp Data/Docker/stirling Data/Docker/passbolt

#Go to Flaresolver Docker directory.
cd /mnt/Cloud/Data/Docker/flaresolver
#Run Flaresolver on Docker.
docker run -d --name=flaresolverr   -p 8191:8191   -e LOG_LEVEL=info   --restart unless-stopped   ghcr.io/flaresolverr/flaresolverr:latest

#Go to Immich Docker directory.
cd /mnt/Cloud/Data/Docker/immich-app
#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Docker/Immich/docker-compose.yml .
#Change Data Base password.
echo -e "UPLOAD_LOCATION=/mnt/Cloud/Data/Docker/immich-app/immich-files\nDB_DATA_LOCATION=/mnt/Cloud/Data/Docker/immich-app/postgres\nIMMICH_VERSION=release\nDB_USERNAME=postgres\nDB_DATABASE_NAME=immich\nDB_PASSWORD=$1" >> .env
#Run Immich on Docker.
docker compose up -d

#Go to Vscodium Docker directory.
cd /mnt/Cloud/Data/Docker/vscodium
#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Docker/Vscodium/docker-compose.yml .
#Run Vscodium on Docker.
docker compose up -d

#Go to Gimp Docker directory.
cd /mnt/Cloud/Data/Docker/gimp
#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Docker/Gimp/docker-compose.yml .
#Run Vscodium on Docker.
docker compose up -d

#Go to Stirling Docker directory.
cd /mnt/Cloud/Data/Docker/stirling
#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Docker/Stirling/docker-compose.yml .
#Run Vscodium on Docker.
docker compose up -d

#Go to Passbolt Docker directory.
cd /mnt/Cloud/Data/Docker/passbolt
#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Docker/Passbolt/docker-compose-ce.yaml .
curl -LO https://github.com/passbolt/passbolt_docker/releases/latest/download/docker-compose-ce-SHA512SUM.txt
#Run Vscodium on Docker.
docker compose -f docker-compose-ce.yaml up -d
docker compose -f docker-compose-ce.yaml exec passbolt su -m -c "/usr/share/php/passbolt/bin/cake passbolt register_user -u $4 -f $3 -l Server -r admin" -s /bin/sh www-data

#Change Nextcloud configs.
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set maintenance_window_start --type=integer --value=1
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set opcache.interned_strings_buffer --type=integer --value=9
sudo -u www-data php8.2 /var/www/nextcloud/occ maintenance:repair --include-expensive
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set default_phone_region --value="BR"
sudo -u www-data php8.2 /var/www/nextcloud/occ config:system:set datadirectory --value="/mnt/Cloud/Data/nextcloud_data"
mv /mnt/dietpi_userdata/nextcloud_data /mnt/Cloud/Data
sudo apt-get install php-bcmath php-gmp php-imagick libmagickcore-6.q16-6-extra -y

#Remove default files.
cd /etc/nginx/sites-dietpi
sudo rm -rf dietpi-dav_redirect.conf dietpi-nextcloud.conf

#Install postgresql.
sudo apt-get install postgresql -y
#Create user and database.
sudo -i -u postgres psql -c "CREATE USER onlyoffice WITH PASSWORD '$(echo "$2")';"
sudo -i -u postgres psql -c 'CREATE DATABASE onlyoffice WITH OWNER onlyoffice;'
#Install rabbitmq-server.
sudo apt-get install rabbitmq-server -y
#Change port to 8090
echo onlyoffice-documentserver onlyoffice/ds-port select 8090 | sudo debconf-set-selections
#Go to Data.
cd /mnt/Cloud/Data
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
sudo apt-get install onlyoffice-documentserver -y
#Change /etc/nginx/nginx.conf with "variables_hash_max_size 2048;".
sed '$ d' /etc/nginx/nginx.conf > nginx.conf
echo -e '\n        variables_hash_max_size 2048;\n}' >> nginx.conf
mv nginx.conf /etc/nginx