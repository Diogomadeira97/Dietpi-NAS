#! /bin/bash

dietpi-software install 

umask 0022

adduser --quiet --disabled-password --shell /bin/bash --home /home/guest-nas --gecos "User" "admin-nas"
adduser --quiet --disabled-password --shell /bin/bash --home /home/guest-nas --gecos "User" "guest-nas"
echo "admin-nas:$3" | chpasswd
echo "guest-nas:$4" | chpasswd

(echo '$5'; echo '$5') | smbpasswd -a -s admin-nas
(echo '$6'; echo '$6') | smbpasswd -a -s admin-nas

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
chmod 755 /mnt/Cloud/Data/default.sh

mv default/default-user.sh /mnt/Cloud/Data
chmod 755 /mnt/Cloud/Data/default-user.sh

mv default/default-keys.sh /mnt/Cloud/Data
chmod 755 /mnt/Cloud/Data/default-keys.sh

hash=$(echo -n "$2" | sha512sum | mawk '{print $1}')
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
