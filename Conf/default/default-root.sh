#! /bin/bash

apt-get update && upgrade -y

#Install Fail2Ban Dietpi-Dashboard Unbound AdGuard_Home Samba_server Docker Docker_Compose Transmission Sonarr Radarr Prowlarr Readarr Bazarr Jellyfin Kavita.
/boot/dietpi/dietpi-software install 73 200 182 126 96 134 162 44 144 145 151 180 203 178 212

mkdir /mnt/Cloud /mnt/Cloud/Data /mnt/BAK_Cloud
mount /dev/sdb /mnt/Cloud
mount /dev/sda1 /mnt/BAK_Cloud
cd /mnt/Cloud
mv /root/Dietpi-NAS /mnt/Cloud/Data

umask 0022

#Add default users.
adduser --quiet --disabled-password --shell /bin/bash --home /home/admin-nas --gecos "User" "admin-nas"
adduser --quiet --disabled-password --shell /bin/bash --home /home/guest-nas --gecos "User" "guest-nas"
echo "admin-nas:"$(echo "$2")"" | chpasswd
echo "guest-nas:"$(echo "$3")"" | chpasswd

#Add default users Samba password.
(echo "$(echo "$4")"; echo "$(echo "$4")") | smbpasswd -a -s admin-nas
(echo "$(echo "$5")"; echo "$(echo "$5")") | smbpasswd -a -s guest-nas

#Exclude dietpi user from Samba.
pdbedit -x dietpi

#Install PiVPN(Wireguard) to admin-nas.
/boot/dietpi/dietpi-software install 117

#Add default groups.
groupadd $1_Cloud
groupadd $1_BAK

#Add default users to default groups.
gpasswd -M admin-nas,guest-nas $1_Cloud
gpasswd -M admin-nas $1_BAK

cd /mnt/Cloud/Data/Dietpi-NAS/Conf

#Turn admin-nas in SU without password.
mv sudoers /etc
chmod 600 /etc/sudoers

#Turn off root and password login.
mv dietpi.conf /etc/ssh/sshd_config.d
chmod 644 /etc/ssh/sshd_config.d/dietpi.conf

#Change terminal user of Dietpi-Dashboard to admin-nas.
mv config.toml /opt/dietpi-dashboard/
chmod 644 /opt/dietpi-dashboard/config.toml

#Create default Samba share folders.
mv Samba/smb.conf /etc/samba/smb.conf
chmod 644 /etc/samba/smb.conf

#Use /mnt/Cloud/Data/default.sh and reconfig folders permissions to default.
mv default/default.sh /mnt/Cloud/Data
chown admin-nas:root /mnt/Cloud/Data/default.sh
chmod 750 /mnt/Cloud/Data/default.sh

#Use /mnt/Cloud/Data/default-user.sh to add some users.
mv default/default-user.sh /mnt/Cloud/Data
chown admin-nas:root /mnt/Cloud/Data/default-user.sh
chmod 750 /mnt/Cloud/Data/default-user.sh

#Use /mnt/Cloud/Data/default-keys.sh to add some ssh keys.
mv default/default-keys.sh /mnt/Cloud/Data
chown admin-nas:root /mnt/Cloud/Data/default-Keys.sh
chmod 750 /mnt/Cloud/Data/default-keys.sh

#Change Dietpi-Dashboard password.
hash=$(echo -n "$(echo "$6")" | sha512sum | mawk '{print $1}')
secret=$(openssl rand -hex 32)
G_CONFIG_INJECT 'pass[[:blank:]]' 'pass = true' /opt/dietpi-dashboard/config.toml
GCI_PASSWORD=1 G_CONFIG_INJECT 'hash[[:blank:]]' "hash = \"$hash\"" /opt/dietpi-dashboard/config.toml
GCI_PASSWORD=1 G_CONFIG_INJECT 'secret[[:blank:]]' "secret = \"$secret\"" /opt/dietpi-dashboard/config.toml
unset -v hash secret

#Restart Dietpi-Dashboard.
systemctl restart dietpi-dashboard

#Install Access Control List.
apt install acl -y

#This code is to fix the reboot error message.
systemctl unmask systemd-logind
apt install dbus -y
systemctl start dbus systemd-logind

#Go to mount drives and delete unnecessary files.
cd /mnt
rm -rf ftp_client nfs_client samba

#Go to Cloud and create the default directories.
cd Cloud
mkdir Data/Keys_SSH Data/Keys_VPN Data/Docker Data/Docker/flaresolver Data/Docker/immich-app Data/Jellyfin Public Public/Downloads Users

#Set Cloud default permissions.
setfacl -R -b Cloud
chmod -R 775 Cloud
chown -R admin-nas:$1_Cloud Cloud
setfacl -R -d -m u::rwx Cloud
setfacl -R -d -m g::rwx Cloud
setfacl -R -d -m o::r-x Cloud
chmod -R g+s Cloud

#Set BAK_Cloud default permissions.
chmod 750 BAK_Cloud
chown admin-nas:$1_BAK BAK_Cloud
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

#Create Jellyfin directory.
chown -R jellyfin:$1_Cloud Data/Jellyfin

#Turn debian-transmission the owner of Public Downloads Folder.
chown -R debian-transmission:$1_Cloud Public/Downloads

#Restart Samba_server.
service samba restart

#Create Flaresolver Docker directory.
cd Data/Docker/flaresolver

#Run Flaresolver on Docker.
docker run -d --name=flaresolverr   -p 8191:8191   -e LOG_LEVEL=info   --restart unless-stopped   ghcr.io/flaresolverr/flaresolverr:latest

#Go to Immich Docker directory.
cd ../immich-app

#Import default files.
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Immich/* /mnt/Cloud/Data/Docker/immich-app

#Change Data Base password.
echo -e "DB_PASSWORD=$7" >> .env

#Run Immich on Docker.
docker compose up -d
