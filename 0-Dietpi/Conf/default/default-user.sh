#! /bin/bash

sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/$2 --gecos "User" "$2"
echo "$2:$3" | sudo chpasswd

(echo '$4'; echo '$4') | sudo smbpasswd -a -s $2

sudo gpasswd -M $2 $1_Cloud

cd /mnt/Cloud/Users

sudo mkdir $2 $2/Docs $2/Midias

sudo chown -R $2:$2_Cloud $2
sudo chmod -R 775 $2
sudo setfacl -R -d -m u::rwx $2
sudo setfacl -R -d -m g::rwx $2
sudo setfacl -R -d -m o::r-x $2

cd $2

sudo chown -R $2:$2 Docs
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

sudo chown -R radarr:$1_Cloud Filmes
sudo chown -R sonarr:$1_Cloud TV-Shows
sudo chown -R readarr:$1_Cloud Livros

sudo setfacl -R -m user:bazarr:rwx Filmes
sudo setfacl -R -m user:bazarr:rwx TV-Shows

sudo cat /etc/samba/smb.conf >> smb.conf
sudo echo -e "#User $2\n\n[Mídias]\n	comment = User $2\n	path = /mnt/Cloud/Users/$2/Docs\n	valid users = $2\n\n[Docs]\n	comment = User $2\n	path = /mnt/Cloud/Users/$2/Docs\n	valid users = $2" >> smb.conf
sudo chown root:root smb.conf
sudo chmod 644 smb.conf
sudo mv smb.conf /etc/samba/smb.conf

cd /mnt/Cloud/Data/Docker/immich-app
sudo echo -e "      - /mnt/Cloud/Users/$2/Midia/Midias-Anuais:/mnt/Cloud/Users/$2/Midia/Midias-Anuais:ro" >> docker-compose.yml
sudo docker compose restart
