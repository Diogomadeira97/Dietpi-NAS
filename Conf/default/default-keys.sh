#! /bin/bash

#Go to .ssh folder to create SSH Keys.
cd ~/.ssh

#Do it while have a Device.
for (( i=3; i<=$#; i++)); 
do

    #Device.
    a=${!i}

    #Generate a Device SSH key.
    sudo ssh-keygen -f $a -P ""

    #Copy the Device SSH key to admin-nas user.
    ssh-copy-id -i $a.pub admin-nas@$1

    #Change Device SSH key permissions.
    sudo chmod 777 $a

    #Move Device SSH Key to /mnt/Cloud/Keys_SSH and easily export with Dietpi-Dashboard or Samba.
    sudo mv $a /mnt/Cloud/Data/Keys_SSH

    #Create a Device Wireguard Key.
    sudo pivpn add -n $a

done

#Move Device Wireguard Key to /mnt/Cloud/Keys_VPN and easily export with Dietpi-Dashboard or Samba.
sudo mv /home/admin-nas/configs/* /mnt/Cloud/Data/Keys_VPN
sudo rm -rf /home/admin-nas/configs