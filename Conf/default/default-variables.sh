#! /bin/bash

passwd(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;}

#Default variables.
echo -e "#Default variables." >> PASSWD.txt
SERVERNAME=$1
echo -e "SERVERNAME=$SERVERNAME" >> PASSWD.txt
DIETPIPW=$(passwd)
echo -e "DIETPIPW=$DIETPIPW" >> PASSWD.txt
DBIMMICHPW=$(passwd)
echo -e "DBIMMICHPW=$DBIMMICHPW" >> PASSWD.txt

#Default Users.
echo -e "#Default Users." >> PASSWD.txt
ADMIN=$2
echo -e "ADMIN=$ADMIN" >> PASSWD.txt
ADMINPW=$(passwd)
echo -e "ADMINPW=$ADMINPW" >> PASSWD.txt
ADMINSMBPW=$(passwd)
echo -e "ADMINSMBPW=$ADMINSMBPW" >> PASSWD.txt
GUEST=$3
echo -e "GUEST=$GUEST" >> PASSWD.txt
GUESTPW=$(passwd)
echo -e "GUESTPW=$GUESTPW" >> PASSWD.txt
GUESTSMBPW=$(passwd)
echo -e "GUESTSMBPW=$GUESTSMBPW" >> PASSWD.txt

#Default Server.
echo -e "#Default Server." >> PASSWD.txt
DOMAIN=$4
echo -e "DOMAIN=$DOMAIN" >> PASSWD.txt
TPDOMAIN=$5
echo -e "TPDOMAIN=$TPDOMAIN" >> PASSWD.txt
IP=$6
echo -e "IP=$IP" >> PASSWD.txt
CLOUDFLARETOKEN=$7
echo -e "CLOUDFLARETOKEN=$CLOUDFLARETOKEN" >> PASSWD.txt
EMAIL=$8
echo -e "EMAIL=$EMAIL" >> PASSWD.txt

#Add Default configs.
bash default-root.sh $SERVERNAME $ADMIN $ADMINPW $ADMINSMBPW $GUEST $GUESTPW $GUESTSMBPW $DIETPIPW $DBIMMICHPW

#Add Domain to known_hosts.
ssh-keyscan -H $DOMAIN$TPDOMAIN >> ~/.ssh/known_hosts

#Add Nginx, Certbot and Homer default configs.
bash /mnt/Cloud/Data/Dietpi-NAS/Conf/default/default-server.sh $DOMAIN $TPDOMAIN $IP $CLOUDFLARETOKEN $SERVERNAME $EMAIL

#Delete the installation folder.
rm -rf /mnt/Cloud/Data/Dietpi-NAS

#Reboot the system and use SSH key to login with admin.
reboot