#! /bin/bash

passwd(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;}

ARS=( "$@" )

#Do it while have a User.
for (( i=1; i<=$#; i++));
do

    #User.
    echo -e "#User $1.\n" >> PASSWD_$1.txt
    USER=${ARS[i]}
    echo -e "USER=$USER" >> PASSWD_$1.txt
    USERPW=$(passwd)
    echo -e "$(echo "$USERPW")" >> PASSWD_$1.txt
    USERSMBPW=$(passwd)
    echo -e "$(echo "$USERSMBPW")" >> PASSWD_$1.txt
    mv PASSWD_$1.txt /mnt/Cloud/Public

    #Add user.
    sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/$USER --gecos "User" "$USER"
    echo "$USER:"$(echo "$USERPW")"" | sudo chpasswd

    #Add Samba password.
    (echo "$(echo "$USERSMBPW")"; echo "$(echo "$USERSMBPW")") | sudo smbpasswd -a -s $USER

    #Put user in the default group.
    sudo gpasswd -M $USER $1_Cloud

    #Go to Users folder and create default folders to the user.
    cd /mnt/Cloud/Users
    sudo mkdir $USER $USER/Docs $USER/Midias

    #Set default permissions to user folder.
    sudo chown -R $USER:$1_Cloud $USER
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
    sudo chown -R radarr:$1_Cloud Filmes
    sudo chown -R sonarr:$1_Cloud TV-Shows
    sudo chown -R readarr:$1_Cloud Livros
    sudo setfacl -R -m user:bazarr:rwx Filmes
    sudo setfacl -R -m user:bazarr:rwx TV-Shows

    #Add Samba share folders to the user.
    sudo cat /etc/samba/smb.conf >> smb.conf
    sudo echo -e "\n\n#User $USER\n\n[$USER]\n	comment = $USER\n	path = /mnt/Cloud/Users/$USER\n	valid users = $USER" >> smb.conf
    sudo chown root:root smb.conf
    sudo chmod 644 smb.conf
    sudo mv smb.conf /etc/samba/smb.conf

    #Add user folders to immich.
    cd /mnt/Cloud/Data/Docker/immich-app
    sudo echo -e "      - /mnt/Cloud/Users/$USER/Midia/Midias-Anuais:/mnt/Cloud/Users/$USER/Midia/Midias-Anuais:ro\n" >> docker-compose.yml
    sudo docker compose restart

    #Create a crontab to sync Immich with user folder.
    echo -e "#! /bin/bash\n\nmv /mnt/Cloud/Data/Docker/immich-app/immich_files/library/$USER/*  /mnt/Cloud/Users/$USER/Midias/Midias-Anuais/immich\n\nchown -R $USER:$USER /mnt/Cloud/Users/$USER/Midias/Midias-Anuais/immich" >> immich_cron_$USER.sh
    mv immich_cron_$USER.sh /etc/cron.daily
    chmod 750 /etc/cron.daily/immich_cron_$USER.sh

done
