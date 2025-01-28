#! /bin/bash

#Default variables.
SERVERNAME=
DIETPIPW="$(echo '')"
DBIMMICHPW="$(echo '')"

#Default Users.
ADMIN=
ADMINPW="$(echo '')"
ADMINSMBPW="$(echo '')"
GUEST=
GUESTPW="$(echo '')"
GUESTSMBPW="$(echo '')"

#Users variables.
USER=
USERPW="$(echo '')"
USERSMBPW="$(echo '')"
#Put the Number of Users.
#        .
#        .
#        .
#USERx=
#USERPWx=
#USERSMBPWx=

#Device variables.
DEVICE=
#Put the Number of Devices.
#        .
#        .
#        .
#DEVICEx=

#Domain name.
DOMAIN=
#Examples: .com .pt .com.br
TPDOMAIN=
#IPv4 static IP.
IP=
#Create this token once you have a domain pointing to Clouflare.
CLOUDFLARETOKEN=''
#E-mail to certbot expiration.
EMAIL=''


#Add Default configs.
bash default-root.sh $SERVERNAME $ADMIN $ADMINPW $ADMINSMBPW $GUEST $GUESTPW $GUESTSMBPW $DIETPIPW $DBIMMICHPW

#Add users with default configs.
#EDIT!!!
bash /mnt/Cloud/Data/Commands/default-user.sh $SERVERNAME $USER $USERPW $USERSMBPW ... $USERx $USERPWx $USERSMBPWx

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