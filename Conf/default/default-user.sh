#! /bin/bash

#Do it while have a User.
for (( i=2; i<=$#; i++)); 
do

    #User.
    USER=${!i}
    echo -e "USER="${!i} >> PASSWD_$1.txt
    USERPW=
    echo -e "$(echo "$USERPW")" >> PASSWD_$1.txt
    USERSMBPW=
    echo -e "$(echo "$USERSMBPW")" >> PASSWD_$1.txt

    #User.
    a=${!i}
    #User Password.
    b=${!x}
    #User Samba Password.
    c=${!y}

    #Add user.
    sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/$a --gecos "User" "$a"
    echo "$a:"$(echo "$b")"" | sudo chpasswd

    #Add Samba password.
    (echo "$(echo "$c")"; echo "$(echo "$c")") | sudo smbpasswd -a -s $a

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
    sudo echo -e "\n\n#User $a\n\n[$a]\n	comment = $a\n	path = /mnt/Cloud/Users/$a\n	valid users = $a" >> smb.conf
    sudo chown root:root smb.conf
    sudo chmod 644 smb.conf
    sudo mv smb.conf /etc/samba/smb.conf

    #Add user folders to immich.
    cd /mnt/Cloud/Data/Docker/immich-app
    sudo echo -e "      - /mnt/Cloud/Users/$a/Midia/Midias-Anuais:/mnt/Cloud/Users/$a/Midia/Midias-Anuais:ro\n" >> docker-compose.yml
    sudo docker compose restart

    #Create a crontab to sync Immich with user folder.
    echo -e "#! /bin/bash\n\nmv /mnt/Cloud/Data/Docker/immich-app/immich_files/library/$a/*  /mnt/Cloud/Users/$a/Midias/Midias-Anuais/immich\n\nchown -R $a:$a /mnt/Cloud/Users/$a/Midias/Midias-Anuais/immich" >> immich_cron_$a.sh
    mv immich_cron_$a.sh /etc/cron.daily
    chmod 750 /etc/cron.daily/immich_cron_$a.sh

done
