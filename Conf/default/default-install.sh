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

#Default variables.

SERVERNAME=${VARIABLES[1]}
echo -e "#Default variables.\n" >> PASSWD_$SERVERNAME.txt
echo -e "       • SERVERNAME: $SERVERNAME\n" >> PASSWD_$SERVERNAME.txt
DIETPIPW=$(passwd)
echo -e "       • DIETPIPW: $DIETPIPW\n" >> PASSWD_$SERVERNAME.txt
DBIMMICHPW=$(passwd)
echo -e "       • DBIMMICHPW: $DBIMMICHPW\n" >> PASSWD_$SERVERNAME.txt
DBOFFICEPW=$(passwd)
echo -e "       • DBOFFICEPW: $DBOFFICEPW\n" >> PASSWD_$SERVERNAME.txt
DBPASSBOLTPW=$(passwd)
echo -e "       • DBPASSBOLTPW: $DBPASSBOLTPW\n" >> PASSWD_$SERVERNAME.txt

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

#Go to Cloud and create default folders.
cd /mnt/Cloud
mkdir Data/Commands Data/Docker Data/Docker/flaresolver Data/Docker/immich-app Data/Docker/vscodium Data/Docker/gimp Data/Docker/stirling Data/Docker/passbolt Public Public/Downloads Public/Docs Public/Midias Public/Passwords Users $SERVERNAME $SERVERNAME/Midias $SERVERNAME/Docs

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

#Install Fail2Ban, Dietpi-Dashboard, PiVPN(Wireguard), Unbound, AdGuard_Home, Samba_server, Transmission, Sonarr, Radarr, Prowlarr, Readarr, Bazarr, Jellyfin, Kavita, Nginx, LEMP, Docker, Docker_Compose and Portainer.
/boot/dietpi/dietpi-software install 73 200 117 182 126 96 44 144 145 151 180 203 178 212 85 79 134 162 185 

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
groupadd $SERVERNAME

#Add default users to default groups.
usermod -a -G $CLOUD "$ADMIN"
usermod -a -G $CLOUD "$GUEST"
usermod -a -G $SERVERNAME "$ADMIN"
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

#Use /mnt/Cloud/Data/subdomain.sh to add some subdomain.
mv subdomain-docker.sh /mnt/Cloud/Data/Commands

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
chmod g+s BAK_Cloud

#Set Data default permissions.
cd Cloud
chmod -R 750 Data
setfacl -R -d -m g::r-x Data
setfacl -R -d -m o::--- Data
setfacl -m user:www-data:rwx Data

#Set Server default permissions.
chown -R admin-acaci:$SERVERNAME $SERVERNAME
cd $SERVERNAME
sudo chmod -R 770 Docs
sudo setfacl -R -d -m o::--- Docs
chown -R admin-acaci:$SERVERNAME Midias
cd Midias
mkdir Midias-Anuais Filmes TV-Shows Downloads Livros
sudo chmod -R 770 Midias-Anuais
sudo setfacl -R -d -m o::--- Midias-Anuais
sudo setfacl -R -m user:radarr:rwx Filmes
sudo setfacl -R -m user:sonarr:rwx TV-Shows
sudo setfacl -R -m user:readarr:rwx Livros
sudo setfacl -R -m user:debian-transmission:rwx Downloads
sudo setfacl -R -m user:bazarr:rwx Filmes
sudo setfacl -R -m user:bazarr:rwx TV-Shows

#Turn admin the owner of Folder.
chown -R $ADMIN:$CLOUD Data/Commands

#Turn dietpi the owner of Folder.
chown -R dietpi:$CLOUD Public/Docs

#Turn debian-transmission the owner of Public Downloads Folder.
chown -R debian-transmission:$CLOUD Public/Downloads

#Install tools.
bash /mnt/Cloud/Data/Dietpi-NAS/Conf/default/default-tools.sh $DBIMMICHPW $DBOFFICEPW $DBPASSBOLTPW $DOMAIN $TPDOMAIN $EMAIL

#Install Certbot and Homer to set server default configs.
bash /mnt/Cloud/Data/Dietpi-NAS/Conf/default/default-server.sh $DOMAIN $TPDOMAIN $IP $CLOUDFLARETOKEN $SERVERNAME $EMAIL

#Add Users.
bash /mnt/Cloud/Data/Commands/default-user.sh $SERVERNAME ${USERS[@]}

#Add Domain to known_hosts.
ssh-keyscan -H $DOMAIN$TPDOMAIN >> ~/.ssh/known_hosts

#Add Devices (SSH).
bash /mnt/Cloud/Data/Commands/default-keys-ssh.sh $DOMAIN $TPDOMAIN $ADMIN $ADMINPW ${DEVICES[@]}

#Add Devices (VPN).
bash /mnt/Cloud/Data/Commands/default-keys-vpn.sh $ADMIN ${DEVICES[@]}

#Delete the installation folder.
rm -rf /mnt/Cloud/Data/Dietpi-NAS

#Reboot the system and use SSH key to login with admin.
reboot