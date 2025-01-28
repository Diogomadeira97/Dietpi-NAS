#! /bin/bash

passwd(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;}

#Default variables.
echo -e "#Default variables." >> PASSWD_$1.txt
SERVERNAME=$1
echo -e "SERVERNAME=$SERVERNAME" >> PASSWD_$1.txt
DIETPIPW=$(passwd)
echo -e "DIETPIPW=$DIETPIPW" >> PASSWD_$1.txt
DBIMMICHPW=$(passwd)
echo -e "DBIMMICHPW=$DBIMMICHPW" >> PASSWD_$1.txt

#Default Users.
echo -e "#Default Users." >> PASSWD_$1.txt
ADMIN=$2
echo -e "ADMIN=$ADMIN" >> PASSWD_$1.txt
ADMINPW=$(passwd)
echo -e "ADMINPW=$ADMINPW" >> PASSWD_$1.txt
ADMINSMBPW=$(passwd)
echo -e "ADMINSMBPW=$ADMINSMBPW" >> PASSWD_$1.txt
GUEST=$3
echo -e "GUEST=$GUEST" >> PASSWD_$1.txt
GUESTPW=$(passwd)
echo -e "GUESTPW=$GUESTPW" >> PASSWD_$1.txt
GUESTSMBPW=$(passwd)
echo -e "GUESTSMBPW=$GUESTSMBPW" >> PASSWD_$1.txt

#Default Server.
echo -e "#Default Server." >> PASSWD_$1.txt
DOMAIN=$4
echo -e "DOMAIN=$DOMAIN" >> PASSWD_$1.txt
TPDOMAIN=$5
echo -e "TPDOMAIN=$TPDOMAIN" >> PASSWD_$1.txt
IP=$6
echo -e "IP=$IP" >> PASSWD_$1.txt
CLOUDFLARETOKEN=$7
echo -e "CLOUDFLARETOKEN=$CLOUDFLARETOKEN" >> PASSWD_$1.txt
EMAIL=$8
echo -e "EMAIL=$EMAIL" >> PASSWD_$1.txt

mv PASSWD_$1.txt /mnt/Cloud/Public

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