#! /bin/bash

dietpi-software install 73 200 96 134 162 44 144 145 151 180 203 178 212 126 182 117 205 85 92

umask 0022

adduser --quiet --disabled-password --shell /bin/bash --home /home/guest-nas --gecos "User" "admin-nas"
adduser --quiet --disabled-password --shell /bin/bash --home /home/guest-nas --gecos "User" "guest-nas"
echo "admin-nas:$2" | chpasswd
echo "guest-nas:$3" | chpasswd

(echo '$4'; echo '$4') | smbpasswd -a -s admin-nas
(echo '$5'; echo '$5') | smbpasswd -a -s admin-nas

pdbedit -x dietpi

groupadd $1_Cloud
groupadd $1_BAK

gpasswd -M admin-nas,guest-nas $1_Cloud
gpasswd -M admin-nas $1_BAK

mkdir /mnt/Cloud/Keys_SSH

cd /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf

mv sudoers /etc
chmod 600 /etc/sudoers

mv dietpi.conf /etc/ssh/sshd_config.d
chmod 644 /etc/ssh/sshd_config.d/dietpi.conf

mv config.toml /opt/dietpi-dashboard/
chmod 644 /opt/dietpi-dashboard/config.toml

mv Samba/smb.conf /etc/samba/smb.conf
chmod 644 /etc/samba/smb.conf

mv default/default.sh /mnt/Cloud/Data
chown admin-nas:root /mnt/Cloud/Data/default.sh
chmod 750 /mnt/Cloud/Data/default.sh

mv default/default-user.sh /mnt/Cloud/Data
chown admin-nas:root /mnt/Cloud/Data/default-user.sh
chmod 750 /mnt/Cloud/Data/default-user.sh

mv default/default-keys.sh /mnt/Cloud/Data
chown admin-nas:root /mnt/Cloud/Data/default-Keys.sh
chmod 750 /mnt/Cloud/Data/default-keys.sh

hash=$(echo -n "$6" | sha512sum | mawk '{print $1}')
secret=$(openssl rand -hex 32)
G_CONFIG_INJECT 'pass[[:blank:]]' 'pass = true' /opt/dietpi-dashboard/config.toml
GCI_PASSWORD=1 G_CONFIG_INJECT 'hash[[:blank:]]' "hash = \"$hash\"" /opt/dietpi-dashboard/config.toml
GCI_PASSWORD=1 G_CONFIG_INJECT 'secret[[:blank:]]' "secret = \"$secret\"" /opt/dietpi-dashboard/config.toml
unset -v hash secret

systemctl restart dietpi-dashboard

apt install acl -y

systemctl unmask systemd-logind
apt install dbus -y
systemctl start dbus systemd-logind

cd /mnt

rm -rf ftp_client nfs_client samba

mkdir Cloud/Data/Docker Cloud/Data/Docker/flaresolver Cloud/Data/Docker/immich-app Cloud/Data/Jellyfin Cloud/Public Cloud/Public/Downloads Cloud/Users

setfacl -R -b Cloud
chmod -R 775 Cloud
chown -R admin-nas:$1_Cloud Cloud
setfacl -R -d -m u::rwx Cloud
setfacl -R -d -m g::rwx Cloud
setfacl -R -d -m o::r-x Cloud
chmod -R g+s Cloud

chmod 750 BAK_Cloud
chown admin-nas:$1_BAK BAK_Cloud
setfacl -d -m u::rwx BAK_Cloud
setfacl -d -m g::r-x BAK_Cloud
setfacl -d -m o::--- BAK_Cloud
chmod g+s Cloud BAK_Cloud

cd Cloud

chmod -R 750 Data
setfacl -R -d -m u::rwx Data
setfacl -R -d -m g::r-x Data
setfacl -R -d -m o::--- Data

chown -R jellyfin:$1_Cloud Data/Jellyfin

chown -R debian-transmission:$1_Cloud Public/Downloads

service samba restart

cd Data/Docker/flaresolver

docker run -d --name=flaresolverr   -p 8191:8191   -e LOG_LEVEL=info   --restart unless-stopped   ghcr.io/flaresolverr/flaresolverr:latest

cd ../immich-app

mv /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/Immich/* /mnt/Cloud/Data/Docker/immich-app

echo -e "DB_PASSWORD=$7" >> .env

echo -e "#! /bin/bash\n\nmv /mnt/Cloud/Data/Docker/immich-app/immich_files/library/$1/*  /mnt/Cloud/Users/$1/Midias/Midias-Anuais/immich\n\nchown -R $1:$1 /mnt/Cloud/Users/$1/Midias/Midias-Anuais/immich" >> immich_cron.sh

mv immich_cron.sh /etc/cron.daily

chmod 750 /etc/cron.daily/immich_cron.sh

docker compose up -d

rm -rf /mnt/Cloud/Data/Dietpi/0-Dietpi
