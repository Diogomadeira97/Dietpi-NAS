#! /bin/bash

#Go to .ssh folder to create SSH Keys.
cd ~/.ssh

#Do it while have a Device.
for (( i=2; i<=$#; i++)); 
do

    #Device.
    a=${!i}

    #Generate a Device SSH key.
    sudo ssh-keygen -f $a

    #Create a Device Wireguard Key.
    sudo pivpn add -n $a

    #Copy Device SSH Key to default user.
    sudo ssh-copy-id -i $a.pub admin-nas@$1

    #Change Device SSH key permissions.
    sudo chmod 777 $a

    #Move Device SSH Key to /mnt/Cloud/Keys_SSH and easily export with Dietpi-Dashboard or Samba.
    sudo mv $a /mnt/Cloud/Data/Keys_SSH

done

#Move Device Wireguard Key to /mnt/Cloud/Keys_VPN and easily export with Dietpi-Dashboard or Samba.
sudo mv configs/* /mnt/Cloud/Data/Keys_VPN
sudo rm -rf configs