#! /bin/bash

passwd(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;}

ARS=( "$@" )

#Do it while have a User.
for (( i=1; i<$#; i++));
do

    #User.
    USER=${ARS[i]}
    echo -e "#User $USER.\n" >> PASSWD_$USER.txt
    echo -e "USER=$USER\n" >> PASSWD_$USER.txt
    USERPW=$(passwd)
    echo -e "$(echo "USERPW=$USERPW\n")" >> PASSWD_$USER.txt
    USERSMBPW=$(passwd)
    echo -e "$(echo "USERSMBPW=$USERSMBPW")" >> PASSWD_$USER.txt
    
    #Move passwords with right permissions to Public.
    sudo chmod 777 PASSWD_$USER.txt
    mv PASSWD_$USER.txt /mnt/Cloud/Public/Passwords

    #Add user.
    sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/$USER --gecos "User" "$USER"
    sudo echo "$USER:"$(echo "$USERPW")"" | chpasswd

    #Add Samba password.
    (echo "$(echo "$USERSMBPW")"; echo "$(echo "$USERSMBPW")") | sudo smbpasswd -a -s $USER

    #Create group names.
    CLOUD="$(echo $1'_Cloud' )"

    #Put user in the default group.
    sudo gpasswd -M "$USER" $CLOUD

    #Go to Users folder and create default folders to the user.
    cd /mnt/Cloud/Users
    sudo mkdir $USER $USER/Docs $USER/Midias

    #Set default permissions to user folder.
    sudo chown -R $USER:$CLOUD $USER
    sudo chmod -R 775 $USER
    sudo setfacl -R -d -m u::rwx $USER
    sudo setfacl -R -d -m g::rwx $USER
    sudo setfacl -R -d -m o::r-x $USER

    #Set default permissions to user Docs folder.
    cd $USER
    sudo chown -R $USER:$USER Docs
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
    sudo chown -R radarr:$CLOUD Filmes
    sudo chown -R sonarr:$CLOUD TV-Shows
    sudo chown -R readarr:$CLOUD Livros
    sudo setfacl -R -m user:bazarr:rwx Filmes
    sudo setfacl -R -m user:bazarr:rwx TV-Shows

    #Add Samba share folders to the user.
    sudo cat /etc/samba/smb.conf >> smb.conf
    sudo echo -e "\n\n#User $USER\n\n[$USER]\n        comment = $USER\n        path = /mnt/Cloud/Users/$USER\n        valid users = $USER" >> smb.conf
    sudo chown root:root smb.conf
    sudo chmod 644 smb.conf
    sudo mv smb.conf /etc/samba/smb.conf
    service samba restart

    #Add user folders to immich.
    cd /mnt/Cloud/Data/Docker/immich-app
    sudo echo -e "      - /mnt/Cloud/Users/$USER/Midia/Midias-Anuais:/mnt/Cloud/Users/$USER/Midia/Midias-Anuais:ro\n" >> docker-compose.yml
    sudo docker compose restart

    #Create a crontab to sync Immich with user folder.
    echo -e "#! /bin/bash\n\nmv /mnt/Cloud/Data/Docker/immich-app/immich_files/library/$USER/*  /mnt/Cloud/Users/$USER/Midias/Midias-Anuais/immich\n\nchown -R $USER:$USER /mnt/Cloud/Users/$USER/Midias/Midias-Anuais/immich" >> immich_cron_$USER.sh
    mv immich_cron_$USER.sh /etc/cron.daily
    chmod 750 /etc/cron.daily/immich_cron_$USER.sh

done
