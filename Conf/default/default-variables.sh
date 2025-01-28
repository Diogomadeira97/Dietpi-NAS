#! /bin/bash

#Default variables.
SERVERNAME=$1
echo -e "SERVERNAME=$1" >> PASSWD.txt
DIETPIPW="$(echo '')"
echo -e "" >> PASSWD.txt
DBIMMICHPW="$(echo '')"
echo -e "" >> PASSWD.txt

#Default Users.
ADMIN=$2
echo -e "$2" >> PASSWD.txt
ADMINPW="$(echo '')"
echo -e "" >> PASSWD.txt
ADMINSMBPW="$(echo '')"
echo -e "" >> PASSWD.txt
GUEST=$3
echo -e "$3" >> PASSWD.txt
GUESTPW="$(echo '')"
echo -e "" >> PASSWD.txt
GUESTSMBPW="$(echo '')"
echo -e "" >> PASSWD.txt

#Domain name.
DOMAIN=$4
echo -e "" >> PASSWD.txt
#Examples: .com .pt .com.br
TPDOMAIN=$5
echo -e "" >> PASSWD.txt
#IPv4 static IP.
IP=$6
echo -e "" >> PASSWD.txt
#Create this token once you have a domain pointing to Clouflare.
CLOUDFLARETOKEN="$(echo "$7")"
echo -e "" >> PASSWD.txt
#E-mail to certbot expiration.
EMAIL=$8
echo -e "" >> PASSWD.txt

#Device variables.
DEVICE=
echo -e "" >> PASSWD.txt
#Put the Number of Devices.
#        .
#        .
#        .
#DEVICEx=


#Add Default configs.
bash default-root.sh $SERVERNAME $ADMIN $ADMINPW $ADMINSMBPW $GUEST $GUESTPW $GUESTSMBPW $DIETPIPW $DBIMMICHPW

#Add Domain to known_hosts.
ssh-keyscan -H $DOMAIN$TPDOMAIN >> ~/.ssh/known_hosts

#Add SSH_Keys and VPN_Keys to Devices.
#Can easily export with Dietpi-Dashboard or Samba.
#EDIT!!!
bash /mnt/Cloud/Data/Commands/default-keys.sh $DOMAIN $TPDOMAIN $ADMIN $ADMINPW $DEVICE ... $DEVICEx

#Add Nginx, Certbot and Homer default configs.
bash /mnt/Cloud/Data/Dietpi-NAS/Conf/default/default-server.sh $DOMAIN $TPDOMAIN $IP $CLOUDFLARETOKEN $SERVERNAME $EMAIL

#Delete the installation folder.
rm -rf /mnt/Cloud/Data/Dietpi-NAS

#Reboot the system and use SSH key to login with admin.
reboot