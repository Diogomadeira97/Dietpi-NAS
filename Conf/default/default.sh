#! /bin/bash

cd /mnt

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