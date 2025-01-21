#! /bin/bash

#Default variables.
SERVER_NAME=
ADMIN-NAS_PASSWORD=
GUEST-NAS_PASSWORD=
ADMIN-NAS_SAMBA_PASSWORD=
GUEST-NAS_SAMBA_PASSWORD=
DIETPI_PASSWORD=
DB_IMMICH_PASSWORD=

#User variables.
USER=
USER_PASSWORD=
USER_SAMBA_PASSWORD=
#Put the Number of Users.      
#        .
#        .
#        .
#USERx=
#USER_PASSWORDx=
#USER_SAMBA_PASSWORDx=

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
GENERIC_AND_COUNTRY_TOP-LEVEL_DOMAIN=
#IPv4 static IP.
IP=
#Create this token once you have a domain pointing to Clouflare
CLOUDFLARE_TOKEN=

#Add Default configs.
bash default-root.sh $SERVER_NAME $ADMIN-NAS_PASSWORD $GUEST-NAS_PASSWORD $ADMIN-NAS_SAMBA_PASSWORD $GUEST-NAS_SAMBA_PASSWORD $DIETPI_PASSWORD $DB_IMMICH_PASSWORD

#Add users with default configs.
bash default-user.sh $SERVER_NAME $USER $USER_PASSWORD $USER_SAMBA_PASSWORD ... $USERx $USER_PASSWORDx $USER_SAMBA_PASSWORDx

#Add SSH Keys to Devices.
#Can easily export with Dietpi-Dashboard.
bash default-keys.sh $SERVER_NAME $DEVICE ... $DEVICEx

#Go to /mnt/Cloud/DataAdd and create Wireguard Key to Devices.
#Can easily export with Dietpi-Dashboard.
cd /mnt/Cloud/Data

pivpn add $DEVICE
#Put the Number of Devices.    
#        .
#        .
#        .
#pivpn add $DEVICEx

#To create a wireguard Qr code.
pivpn -qr $DEVICE

#Add Nginx, Certbot and Homer default configs.
bash /mnt/Cloud/Data/Dietpi-NAS/Conf/default/default-server.sh $DOMAIN $GENERIC_AND_COUNTRY_TOP-LEVEL_DOMAIN $IP $CLOUDFLARE_TOKEN

#Delete the installation folder.
rm -rf /mnt/Cloud/Data/Dietpi-NAS

#Reboot the system and use SSH key to login with admin-nas. 
reboot