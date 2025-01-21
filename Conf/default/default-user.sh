#! /bin/bash

#Create variables to count number of users to add.
X=$(($# - 1))
Y=$(($X / 3))
Z=$(($Y - 2))
a=-1

#Do it while have a User.
for i in $(seq -1 $Z);
do
    #User.
    a=$(($i + 3))
    #User Password.
    b=$(($a + 1))
    #User Samba Password.
    c=$(($b + 1))

    #Add user.
    sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/$a --gecos "User" "$a"
    echo "$a:$b" | sudo chpasswd

    #Add Samba password.
    (echo '$c'; echo '$c') | sudo smbpasswd -a -s $a

    #Put user in the default group.
    sudo gpasswd -M $a $1_Cloud

    #Go to Users folder and create default folders to the user.
    cd /mnt/Cloud/Users
    sudo mkdir $a $a/Docs $a/Midias

    #Set default permissions to user folder.
    sudo chown -R $a:$1_Cloud $a
    sudo chmod -R 775 $a
    sudo setfacl -R -d -m u::rwx $a
    sudo setfacl -R -d -m g::rwx $a
    sudo setfacl -R -d -m o::r-x $a

    #Set default permissions to user Docs folder.
    cd $a
    sudo chown -R $a:$a Docs
    sudo chmod -R 750 Docs
    sudo setfacl -R -d -m u::rwx Docs
    sudo setfacl -R -d -m g::r-x Docs
    sudo setfacl -R -d -m o::--- Docs

    #Go to Midias, create default folders and set default permissions.
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

    #Add Samba share folders to the user.
    sudo cat /etc/samba/smb.conf >> smb.conf
    sudo echo -e "#User $a\n\n[Mídias]\n	comment = User $a\n	path = /mnt/Cloud/Users/$a/Docs\n	valid users = $a\n\n[Docs]\n	comment = User $a\n	path = /mnt/Cloud/Users/$a/Docs\n	valid users = $a" >> smb.conf
    sudo chown root:root smb.conf
    sudo chmod 644 smb.conf
    sudo mv smb.conf /etc/samba/smb.conf

    #Add user folders to immich.
    cd /mnt/Cloud/Data/Docker/immich-app
    sudo echo -e "      - /mnt/Cloud/Users/$a/Midia/Midias-Anuais:/mnt/Cloud/Users/$a/Midia/Midias-Anuais:ro" >> docker-compose.yml
    sudo docker compose restart

    #Create a crontab to sync Immich with user folder.
    echo -e "#! /bin/bash\n\nmv /mnt/Cloud/Data/Docker/immich-app/immich_files/library/$a/*  /mnt/Cloud/Users/$a/Midias/Midias-Anuais/immich\n\nchown -R $a:$a /mnt/Cloud/Users/$a/Midias/Midias-Anuais/immich" >> immich_cron_$a.sh
    mv immich_cron_$a.sh /etc/cron.daily
    chmod 750 /etc/cron.daily/immich_cron.sh

done
