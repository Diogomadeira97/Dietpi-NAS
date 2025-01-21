#! /bin/bash

adduser --quiet --disabled-password --shell /bin/bash --home /home/guest-nas --gecos "User" "$1"
echo "'$1':$3" | chpasswd

(echo '$4'; echo '$4') | smbpasswd -a -s $1

sudo gpasswd -M $1 $2_Cloud

cd /mnt/Cloud/Users

sudo mkdir $1 $1/Docs $1/Midias

sudo chown -R $1:$2_Cloud $1
sudo chmod -R 775 $1
sudo setfacl -R -d -m u::rwx $1
sudo setfacl -R -d -m g::rwx $1
sudo setfacl -R -d -m o::r-x $1

cd $1

sudo chown -R $1:$1 Docs
sudo chmod -R 750 Docs
sudo setfacl -R -d -m u::rwx Docs
sudo setfacl -R -d -m g::r-x Docs
sudo setfacl -R -d -m o::--- Docs

cd Midias

mkdir Midias-Anuais Filmes TV-Shows Downloads Livros

sudo chmod -R 750 Midias-Anuais
sudo setfacl -R -d -m u::rwx Midias-Anuais
sudo setfacl -R -d -m g::r-x Midias-Anuais
sudo setfacl -R -d -m o::--- Midias-Anuais

sudo chown -R radarr:$2_Cloud Filmes
sudo chown -R sonarr:$2_Cloud TV-Shows
sudo chown -R readarr:$2_Cloud Livros

sudo setfacl -R -m user:bazarr:rwx Filmes
sudo setfacl -R -m user:bazarr:rwx TV-Shows

sudo cat /etc/samba/smb.conf >> smb.conf
sudo echo -e "#User $1\n\n[Mídias]\n	comment = User $1\n	path = /mnt/Cloud/Users/$1/Docs\n	valid users = $1\n\n[Docs]\n	comment = User $1\n	path = /mnt/Cloud/Users/$1/Docs\n	valid users = $1" >> smb.conf
sudo chown root:root smb.conf
sudo chmod 644 smb.conf
sudo mv smb.conf /etc/samba/smb.conf

cd /mnt/Cloud/Data/Docker/immich-app
sudo echo -e "      - /mnt/Cloud/Users/$1/Midia/Midias-Anuais:/mnt/Cloud/Users/$1/Midia/Midias-Anuais:ro" >> docker-compose.yml
sudo docker compose restart
