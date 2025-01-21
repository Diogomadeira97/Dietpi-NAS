#! /bin/bash

cd /mnt

sudo rm -rf ftp_client nfs_client samba

sudo mkdir Cloud/Data/Docker Cloud/Data/Docker/flaresolver Cloud/Data/Docker/immich-app Cloud/Data/Jellyfin Cloud/Public Cloud/Public/Downloads Cloud/Users

sudo setfacl -R -b Cloud
sudo chmod -R 775 Cloud
sudo chown -R admin-nas:$1_Cloud Cloud
sudo setfacl -R -d -m u::rwx Cloud
sudo setfacl -R -d -m g::rwx Cloud
sudo setfacl -R -d -m o::r-x Cloud
sudo chmod -R g+s Cloud

sudo chmod 750 BAK_Cloud
sudo chown admin-nas:$1_BAK BAK_Cloud
sudo setfacl -d -m u::rwx BAK_Cloud
sudo setfacl -d -m g::r-x BAK_Cloud
sudo setfacl -d -m o::--- BAK_Cloud
sudo chmod g+s Cloud BAK_Cloud

cd Cloud

sudo chmod -R 750 Data
sudo setfacl -R -d -m u::rwx Data
sudo setfacl -R -d -m g::r-x Data
sudo setfacl -R -d -m o::--- Data

sudo chown -R jellyfin:$1_Cloud Data/Jellyfin

sudo chown -R debian-transmission:$1_Cloud Public/Downloads

sudo service samba restart

cd Data/Docker/flaresolver

sudo docker run -d --name=flaresolverr   -p 8191:8191   -e LOG_LEVEL=info   --restart unless-stopped   ghcr.io/flaresolverr/flaresolverr:latest

cd ../immich-app

sudo mv /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/Immich/* /mnt/Cloud/Data/Docker/immich-app

sudo echo -e "DB_PASSWORD=$2" >> .env

sudo docker compose up -d

sudo mv /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/default/immich_cron.sh /etc/cron.daily

sudo chmod 750 /etc/cron.daily/immich_cron.sh

sudo rm -rf /mnt/Cloud/Data/Dietpi/0-Dietpi