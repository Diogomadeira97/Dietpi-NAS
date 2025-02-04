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

#dietpi-config
/boot/dietpi/dietpi-config

#dietpi-drive_manager
/boot/dietpi/dietpi-drive_manager

#dietpi-sync
/boot/dietpi/dietpi-sync

#dietpi-backup
/boot/dietpi/dietpi-backup

#Create directory and move Dietpi-NAS folder.
cd ../../../
mkdir /mnt/Cloud/Data
mv Dietpi-NAS /mnt/Cloud/Data

#Go to Cloud and create default folders.
cd /mnt/Cloud
mkdir Data/Commands Data/Docker Data/Docker/flaresolver Data/Docker/immich-app Data/Docker/vscodium Data/Docker/gimp Public Public/Downloads Public/Docs Public/Midias Public/Passwords Users

#Default variables.

SERVERNAME=${VARIABLES[1]}
echo -e "#Default variables.\n" >> PASSWD_$SERVERNAME.txt
echo -e "       • SERVERNAME: $SERVERNAME\n" >> PASSWD_$SERVERNAME.txt
OFFICEPW=$(passwd)
echo -e "       • OFFICEPW: $OFFICEPW\n" >> PASSWD_$SERVERNAME.txt
DIETPIPW=$(passwd)
echo -e "       • DIETPIPW: $DIETPIPW\n" >> PASSWD_$SERVERNAME.txt
DBIMMICHPW=$(passwd)
echo -e "       • DBIMMICHPW: $DBIMMICHPW\n\n" >> PASSWD_$SERVERNAME.txt

#Default Users.
echo -e "#Default Users.\n" >> PASSWD_$SERVERNAME.txt
ADMIN=${VARIABLES[2]}
ADMINPW=$(passwd)
echo -e "       • $ADMIN: $ADMINPW\n" >> PASSWD_$SERVERNAME.txt
ADMINSMBPW=$(passwd)
echo -e "       • $ADMIN(smb): $ADMINSMBPW\n" >> PASSWD_$SERVERNAME.txt
GUEST=${VARIABLES[3]}
GUESTPW=$(passwd)
echo -e "       • $GUEST: $GUESTPW\n" >> PASSWD_$SERVERNAME.txt
GUESTSMBPW=$(passwd)
echo -e "       • $GUEST(smb): $GUESTSMBPW\n\n" >> PASSWD_$SERVERNAME.txt

#Default Server.
echo -e "#Default Server.\n" >> PASSWD_$SERVERNAME.txt
DOMAIN=${VARIABLES[4]}
echo -e "       • DOMAIN: $DOMAIN\n" >> PASSWD_$SERVERNAME.txt
TPDOMAIN=${VARIABLES[5]}
echo -e "       • TPDOMAIN: $TPDOMAIN\n" >> PASSWD_$SERVERNAME.txt
IP=${VARIABLES[6]}
echo -e "       • IP: $IP\n" >> PASSWD_$SERVERNAME.txt
CLOUDFLARETOKEN=${VARIABLES[7]}
echo -e "       • CLOUDFLARETOKEN: $CLOUDFLARETOKEN\n" >> PASSWD_$SERVERNAME.txt
EMAIL=${VARIABLES[8]}
echo -e "       • EMAIL: $EMAIL\n" >> PASSWD_$SERVERNAME.txt

#Move passwords with right permissions to Public.
sudo chmod 777 PASSWD_$SERVERNAME.txt
mv PASSWD_$SERVERNAME.txt /mnt/Cloud/Public/Passwords

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
usermod -a -G $CLOUD "$ADMIN"
usermod -a -G $CLOUD "$GUEST"
usermod -a -G  $BAK "$ADMIN"

#Turn admin in SU without password.
echo -e "$ADMIN ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#Go to Samba folder.
cd /mnt/Cloud/Data/Dietpi-NAS/Conf/Samba

#Create default Samba share folders.
echo -e "        guest account = $GUEST" >> smb.conf
cat smb_temp.conf >> smb.conf
echo -e "        valid users = $ADMIN" >> smb.conf
mv smb.conf /etc/samba/smb.conf
chmod 644 /etc/samba/smb.conf
service samba restart

#Change Dietpi-Dashboard password and terminal user to admin.
hash=$(echo -n "$(echo "$DIETPIPW")" | sha512sum | mawk '{print $1}')
secret=$(openssl rand -hex 32)
echo -e "pass = true" >> config.toml
echo -e 'hash="'$hash'"' >> config.toml
echo -e 'secret="'$secret'"' >> config.toml
echo -e 'terminal_user = "'$ADMIN'"' >> config.toml
mv config.toml /opt/dietpi-dashboard/
chmod 644 /opt/dietpi-dashboard/config.toml
unset -v hash secret

#Restart Dietpi-Dashboard.
systemctl restart dietpi-dashboard

#Go to default folder.
cd /mnt/Cloud/Data/Dietpi-NAS/Conf/default

#Use /mnt/Cloud/Data/Commands/default.sh and reconfig folders permissions to default.
mv default.sh /mnt/Cloud/Data/Commands

#Use /mnt/Cloud/Data/Commands/default-user.sh to add some users.
mv default-user.sh /mnt/Cloud/Data/Commands

#Use /mnt/Cloud/Data/Commands/default-keys-ssh.sh to add some ssh keys.
mv default-keys-ssh.sh /mnt/Cloud/Data/Commands

#Use /mnt/Cloud/Data/Commands/default-keys-vpn.sh to add some vpn keys.
mv default-keys-vpn.sh /mnt/Cloud/Data/Commands

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
apt install acl sshpass postgresql rabbitmq-server -y

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

#Install Onlyoffice.
sudo -i -u postgres psql -c "CREATE USER onlyoffice WITH PASSWORD "$(echo "$OFFICEPW")";"
sudo -i -u postgres psql -c "CREATE DATABASE onlyoffice OWNER onlyoffice;"
echo onlyoffice-documentserver onlyoffice/ds-port select 8090 | sudo debconf-set-selections
mkdir -p -m 700 ~/.gnupg
curl -fsSL https://download.onlyoffice.com/GPG-KEY-ONLYOFFICE | gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --import
chmod 644 /tmp/onlyoffice.gpg
sudo chown root:root /tmp/onlyoffice.gpg
sudo mv /tmp/onlyoffice.gpg /usr/share/keyrings/onlyoffice.gpg
echo "deb [signed-by=/usr/share/keyrings/onlyoffice.gpg] https://download.onlyoffice.com/repo/debian squeeze main" | sudo tee /etc/apt/sources.list.d/onlyoffice.list
sudo apt-get install ttf-mscorefonts-installer onlyoffice-documentserver -y

#Create Flaresolver Docker directory.
cd /mnt/Cloud/Data/Docker/flaresolver

#Run Flaresolver on Docker.
docker run -d --name=flaresolverr   -p 8191:8191   -e LOG_LEVEL=info   --restart unless-stopped   ghcr.io/flaresolverr/flaresolverr:latest

#Go to Immich Docker directory.
cd /mnt/Cloud/Data/Docker/immich-app

#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Immich/docker-compose.yml .

#Change Data Base password.
echo -e "UPLOAD_LOCATION=/mnt/Cloud/Data/Docker/immich-app/immich-files\nDB_DATA_LOCATION=/mnt/Cloud/Data/Docker/immich-app/postgres\nIMMICH_VERSION=release\nDB_USERNAME=postgres\nDB_DATABASE_NAME=immich\nDB_PASSWORD=$DBIMMICHPW" >> .env

#Run Immich on Docker.
docker compose up -d

#Go to Vscodium Docker directory.
cd /mnt/Cloud/Data/Docker/vscodium

#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Vscodium/docker-compose.yml .

#Run Vscodium on Docker.
docker compose up -d

#Go to Gimp Docker directory.
cd /mnt/Cloud/Data/Docker/gimp

#Import default file.
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Gimp/docker-compose.yml .

#Run Vscodium on Docker.
docker compose up -d

#Add Nginx, Certbot and Homer default configs.
bash /mnt/Cloud/Data/Dietpi-NAS/Conf/default/default-server.sh $DOMAIN $TPDOMAIN $IP $CLOUDFLARETOKEN $SERVERNAME $EMAIL

#Add Users.
bash /mnt/Cloud/Data/Commands/default-user.sh $SERVERNAME ${USERS[@]}

#Add Domain to known_hosts.
ssh-keyscan -H $DOMAIN$TPDOMAIN >> ~/.ssh/known_hosts

#Add Devices.
bash /mnt/Cloud/Data/Commands/default-keys-ssh.sh $DOMAIN $TPDOMAIN $ADMIN $ADMINPW ${DEVICES[@]}

#Add Devices.
bash /mnt/Cloud/Data/Commands/default-keys-vpn.sh $ADMIN ${DEVICES[@]}

#Delete the installation folder.
rm -rf /mnt/Cloud/Data/Dietpi-NAS

#Reboot the system and use SSH key to login with admin.
reboot