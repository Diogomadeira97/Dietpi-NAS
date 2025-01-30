#! /bin/bash

passwd(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;}

ARS=( "$@" )

VARIABLES=()
USERS=()
DEVICES=()

i=-1

until [ ${ARS[i]} = "." ]
do

        if [ ${ARS[i]} != "." ]; then
                VARIABLES+=(${ARS[i]})
                ((i++))
        fi

done

((i++))

until [ ${ARS[i]} = "." ]
do

        if [ ${ARS[i]} != "." ]; then
                USERS+=(${ARS[i]})
                ((i++))
        fi

done

((i++))

for (( $i; i<=$#; i++));
do

    DEVICES+=(${ARS[i]})

done

#Default variables.
echo -e "#Default variables." >> PASSWD_${VARIABLES[1]}.txt
SERVERNAME=${VARIABLES[1]}
echo -e "SERVERNAME=$SERVERNAME" >> PASSWD_$SERVERNAME.txt
DIETPIPW=$(passwd)
echo -e "DIETPIPW=$DIETPIPW" >> PASSWD_$SERVERNAME.txt
DBIMMICHPW=$(passwd)
echo -e "DBIMMICHPW=$DBIMMICHPW" >> PASSWD_$SERVERNAME.txt

#Default Users.
echo -e "#Default Users." >> PASSWD_$SERVERNAME.txt
ADMIN=${VARIABLES[2]}
echo -e "ADMIN=$ADMIN" >> PASSWD_$SERVERNAME.txt
ADMINPW=$(passwd)
echo -e "ADMINPW=$ADMINPW" >> PASSWD_$SERVERNAME.txt
ADMINSMBPW=$(passwd)
echo -e "ADMINSMBPW=$ADMINSMBPW" >> PASSWD_$SERVERNAME.txt
GUEST=${VARIABLES[3]}
echo -e "GUEST=$GUEST" >> PASSWD_$SERVERNAME.txt
GUESTPW=$(passwd)
echo -e "GUESTPW=$GUESTPW" >> PASSWD_$SERVERNAME.txt
GUESTSMBPW=$(passwd)
echo -e "GUESTSMBPW=$GUESTSMBPW" >> PASSWD_$SERVERNAME.txt

#Default Server.
echo -e "#Default Server." >> PASSWD_$SERVERNAME.txt
DOMAIN=${VARIABLES[4]}
echo -e "DOMAIN=$DOMAIN" >> PASSWD_$SERVERNAME.txt
TPDOMAIN=${VARIABLES[5]}
echo -e "TPDOMAIN=$TPDOMAIN" >> PASSWD_$SERVERNAME.txt
IP=${VARIABLES[6]}
echo -e "IP=$IP" >> PASSWD_$SERVERNAME.txt
CLOUDFLARETOKEN=${VARIABLES[7]}
echo -e "CLOUDFLARETOKEN=$CLOUDFLARETOKEN" >> PASSWD_$SERVERNAME.txt
EMAIL=${VARIABLES[8]}
echo -e "EMAIL=$EMAIL" >> PASSWD_$SERVERNAME.txt

#Create directory and move Dietpi-NAS folder.
mkdir /mnt/Cloud/Data
cd ../../../
mv Dietpi-NAS /mnt/Cloud/Data

#Go to Cloud and create default folders.
cd /mnt/Cloud
mkdir Data/Commands Data/Keys_SSH Data/Keys_VPN Data/Docker Data/Docker/flaresolver Data/Docker/immich-app Data/Jellyfin Public Public/Downloads Users

mv PASSWD_$SERVERNAME.txt /mnt/Cloud/Public

#dietpi-config
/boot/dietpi/dietpi-config

#dietpi-drive_manager
/boot/dietpi/dietpi-drive_manager

#dietpi-sync
/boot/dietpi/dietpi-sync

#dietpi-backup
/boot/dietpi/dietpi-backup

#Define Umask.
umask 0022

#Add default users.
adduser --quiet --disabled-password --shell /bin/bash --home /home/"$ADMIN" --gecos "User" "$ADMIN"
adduser --quiet --disabled-password --shell /bin/bash --home /home/"$GUEST" --gecos "User" "$GUEST"
echo "$ADMIN:"$(echo "$ADMINPW")"" | chpasswd
echo "$GUEST:"$(echo "$GUESTPW")"" | chpasswd

#Install Fail2Ban Dietpi-Dashboard PiVPN(Wireguard) Unbound AdGuard_Home Samba_server Docker Docker_Compose Home_Assistant 157 Transmission Sonarr Radarr Prowlarr Readarr Bazarr Jellyfin Kavita.
/boot/dietpi/dietpi-software install 73 200 117 182 126 96 134 162 44 144 145 151 180 203 178 212

#Add default users Samba password.
(echo "$(echo "$ADMINSMBPW")"; echo "$(echo "$ADMINSMBPW")") | smbpasswd -a -s $ADMIN
(echo "$(echo "$GUESTSMBPW")"; echo "$(echo "$GUESTSMBPW")") | smbpasswd -a -s $GUEST

#Exclude dietpi user from Samba.
pdbedit -x dietpi

#Create group names.
CLOUD="$(echo $SERVERNAME'_Cloud' )"
BAK="$(echo $SERVERNAME'_BAK' )"

#Add default groups.
groupadd $CLOUD
groupadd $BAK

#Add default users to default groups.
gpasswd -M "$ADMIN","$GUEST" $CLOUD
gpasswd -M "$ADMIN" $BAK

#Turn admin in SU without password.
echo -e "$ADMIN ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#Change terminal user of Dietpi-Dashboard to admin.
cd /opt/dietpi-dashboard/
rm config.toml
echo -e 'terminal_user = "'$ADMIN'"' >> config.toml
chmod 644 config.toml

#Go to Samba folder.
cd /mnt/Cloud/Data/Dietpi-NAS/Conf/Samba

#Create default Samba share folders.
echo -e "        guest account = $GUEST" >> smb.conf
cat smb_temp.conf >> smb.conf
echo -e "        valid users = $ADMIN" >> smb.conf

mv smb.conf /etc/samba/smb.conf
chmod 644 /etc/samba/smb.conf
service samba restart

#Change Dietpi-Dashboard password.
hash=$(echo -n "$(echo "teste")" | sha512sum | mawk '{print $SERVERNAME}')
secret=$(openssl rand -hex 32)
echo -e "pass = true" >> /opt/dietpi-dashboard/config.toml
echo -e 'hash="'$hash'"' >> /opt/dietpi-dashboard/config.toml
echo -e 'secret="'$secret'"' >> /opt/dietpi-dashboard/config.toml
unset -v hash secret

#Restart Dietpi-Dashboard.
systemctl restart dietpi-dashboard

#Go to default folder.
cd /mnt/Cloud/Data/Dietpi-NAS/Conf/default

#Use /mnt/Cloud/Data/Commands/default.sh and reconfig folders permissions to default.
mv default.sh /mnt/Cloud/Data/Commands

#Use /mnt/Cloud/Data/Commands/default-user.sh to add some users.
mv default-user.sh /mnt/Cloud/Data/Commands

#Use /mnt/Cloud/Data/Commands/default-keys.sh to add some ssh keys.
mv default-keys.sh /mnt/Cloud/Data/Commands

#Use /mnt/Cloud/Data/subdomain.sh to add some subdomain.
mv subdomain.sh /mnt/Cloud/Data/Commands

#Use /mnt/Cloud/Data/subdomain.sh to add some subpath.
mv subpath.sh /mnt/Cloud/Data/Commands

#Create iptables_custom.sh.
echo -e "#! /bin/bash" >> iptables_custom.sh

#Use /mnt/Cloud/Data/iptables_custom.sh to add iptables.
mv iptables_custom.sh /mnt/Cloud/Data/Commands

#Create crontab to custom iptables.
echo -e "@reboot sleep 10 && /mnt/Cloud/Data/Commands/iptables_custom.sh" >> crontab
crontab crontab
rm crontab

#Install Access Control List.
apt install acl sshpass -y

#This code is to fix the reboot error message.
systemctl unmask systemd-logind
apt install dbus -y
systemctl start dbus systemd-logind

#Go to mount drives and delete unnecessary files.
cd /mnt
rm -rf ftp_client nfs_client samba

#Set Cloud default permissions.
setfacl -R -b Cloud
chmod -R 775 Cloud
chown -R $ADMIN:$CLOUD Cloud
setfacl -R -d -m u::rwx Cloud
setfacl -R -d -m g::rwx Cloud
setfacl -R -d -m o::r-x Cloud
chmod -R g+s Cloud

#Set BAK_Cloud default permissions.
chmod 750 BAK_Cloud
chown $ADMIN:$BAK BAK_Cloud
setfacl -d -m u::rwx BAK_Cloud
setfacl -d -m g::r-x BAK_Cloud
setfacl -d -m o::--- BAK_Cloud
chmod g+s Cloud BAK_Cloud

#Set Data default permissions.
cd Cloud
chmod -R 750 Data
setfacl -R -d -m u::rwx Data
setfacl -R -d -m g::r-x Data
setfacl -R -d -m o::--- Data

#Turn admin the owner of Folder.
chown -R $ADMIN:$CLOUD Data/Commands

#Turn jellyfin the owner of Folder.
chown -R jellyfin:$CLOUD Data/Jellyfin

#Turn debian-transmission the owner of Public Downloads Folder.
chown -R debian-transmission:$CLOUD Public/Downloads

#Create Flaresolver Docker directory.
cd /mnt/Cloud/Data/Docker/flaresolver

#Run Flaresolver on Docker.
docker run -d --name=flaresolverr   -p 8191:8191   -e LOG_LEVEL=info   --restart unless-stopped   ghcr.io/flaresolverr/flaresolverr:latest

#Go to Immich Docker directory.
cd /mnt/Cloud/Data/Docker/immich-app

#Import default files.
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Immich/docker-compose.yml /mnt/Cloud/Data/Docker/immich-app

#Change Data Base password.
echo -e "UPLOAD_LOCATION=/mnt/Cloud/Data/Docker/immich-app/immich-files\nDB_DATA_LOCATION=/mnt/Cloud/Data/Docker/immich-app/postgres\nIMMICH_VERSION=release\nDB_USERNAME=postgres\nDB_DATABASE_NAME=immich\nDB_PASSWORD=$DBIMMICHPW" >> .env

#Run Immich on Docker.
docker compose up -d

#Add Nginx, Certbot and Homer default configs.
bash /mnt/Cloud/Data/Dietpi-NAS/Conf/default/default-server.sh $DOMAIN $TPDOMAIN $IP $CLOUDFLARETOKEN $SERVERNAME $EMAIL

#Add Users.
bash /mnt/Cloud/Data/Commands/default-user.sh $SERVERNAME ${USERS[@]}

#Add Domain to known_hosts.
ssh-keyscan -H $DOMAIN$TPDOMAIN >> ~/.ssh/known_hosts

#Add Devices.
bash /mnt/Cloud/Data/Commands/default-keys.sh $DOMAIN $TPDOMAIN $ADMIN $ADMINPW ${DEVICES[@]}

#Delete the installation folder.
rm -rf /mnt/Cloud/Data/Dietpi-NAS

#Reboot the system and use SSH key to login with admin.
reboot