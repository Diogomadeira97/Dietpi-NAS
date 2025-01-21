#! /bin/bash

umask 0022

adduser admin-nas
adduser guest-nas

smbpasswd -a admin-nas
smbpasswd -a guest-nas

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

systemctl restart dietpi-dashboard

apt install acl -y

systemctl unmask systemd-logind
apt install dbus -y
systemctl start dbus systemd-logind
