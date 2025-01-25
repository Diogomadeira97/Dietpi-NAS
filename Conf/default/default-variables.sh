#! /bin/bash

#Default variables.
SERVERNAME=
ADMINPW="$(echo '')"
GUESTPW="$(echo '')"
ADMINSMBPW="$(echo '')"
GUESTSMBPW="$(echo '')"
DIETPIPW="$(echo '')"
DBIMMICHPW="$(echo '')"

#User variables.
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
#Create this token once you have a domain pointing to Clouflare
CLOUDFLARETOKEN=''

#Add Default configs.
bash default-root.sh $SERVERNAME $ADMINPW $GUESTPW $ADMINSMBPW $GUESTSMBPW $DIETPIPW

#Add users with default configs.
#EDIT!!!
bash /mnt/Cloud/Data/Dietpi-NAS/Conf/default/default-user.sh $SERVERNAME $USER $USERPW $USERSMBPW ... $USERx $USERPWx $USERSMBPWx

#Add SSH_Keys and VPN_Keys to Devices.
#Can easily export with Dietpi-Dashboard or Samba.
#EDIT!!!
bash /mnt/Cloud/Data/Dietpi-NAS/Conf/default/default-keys.sh $SERVERNAME $DEVICE ... $DEVICEx

#Add Nginx, Certbot and Homer default configs.
bash /mnt/Cloud/Data/Dietpi-NAS/Conf/default/default-server.sh $DOMAIN $TPDOMAIN $IP $CLOUDFLARETOKEN

#Delete the installation folder.
rm -rf /mnt/Cloud/Data/Dietpi-NAS

#Reboot the system and use SSH key to login with admin-nas.
reboot