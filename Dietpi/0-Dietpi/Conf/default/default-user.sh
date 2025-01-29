#! /bin/bash

sudo adduser $1

sudo smbpasswd -a $1

sudo gpasswd -M $1 Alga-NAS_Cloud

cd /mnt/Cloud/Users

sudo mkdir $1 $1/Docs $1/Midias

sudo chown -R $1:Alga-NAS_Cloud $1
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

sudo chown -R radarr:Alga-NAS_Cloud Filmes
sudo chown -R sonarr:Alga-NAS_Cloud TV-Shows
sudo chown -R readarr:Alga-NAS_Cloud Livros

sudo setfacl -R -m user:bazarr:rwx Filmes
sudo setfacl -R -m user:bazarr:rwx TV-Shows

LINE='#User $1\n\n[Mídias]\n	comment = User $1\n	path = /mnt/Cloud/Users/$1/Docs\n	valid users = $1\n\n[Docs]\n	comment = User $1\n	path = /mnt/Cloud/Users/$1/Docs\n	valid users = $1'	
FILE='/mnt/Cloud/Data/iptables_custom.sh'
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"