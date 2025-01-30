#! /bin/bash

#Authorize password authentication.
sudo echo -e "# Added by DietPi:\nPasswordAuthentication yes\nPermitRootLogin no" >> dietpi.conf
sudo mv dietpi.conf /etc/ssh/sshd_config.d
sudo chmod 644 /etc/ssh/sshd_config.d/dietpi.conf
sudo service sshd restart

#Create folders to put the private keys.
sudo mkdir /mnt/Cloud/Public/Keys_VPN /mnt/Cloud/Public/Keys_SSH

#Go to .ssh folder to create SSH Keys.
cd ~/.ssh

ARS=( "$@" )

#Do it while have a Device.
for (( i=2; i<$#; i++)); 
do

    #Device.
    a=${ARS[i]}

    #Generate a Device SSH key.
    sudo ssh-keygen -f $a -P ""

    #Copy the Device SSH key to admin user.
    sudo ssh-copy-id -i $a.pub "$a@$1$2"

    #Change Device SSH key permissions.
    sudo chmod 777 $a

    #Move Device SSH Key to /mnt/Cloud/Keys_SSH and easily export with Dietpi-Dashboard or Samba.
    sudo mv $a /mnt/Cloud/Public/Keys_SSH

    #Create a Device Wireguard Key.
    sudo pivpn add -n $a

done

#Deny password authentication.
sudo echo -e "# Added by DietPi:\nPasswordAuthentication no\nPermitRootLogin no" >> dietpi.conf
sudo mv dietpi.conf /etc/ssh/sshd_config.d
sudo chmod 644 /etc/ssh/sshd_config.d/dietpi.conf
sudo service sshd restart

#Give right permissions to files and folder
sudo chmod -R 777 /mnt/Cloud/Public/Keys_SSH

#Move Device Wireguard Key to /mnt/Cloud/Keys_VPN and easily export with Dietpi-Dashboard or Samba.
sudo chmod 777 /home/$3/configs/*
sudo mv /home/$3/configs/* /mnt/Cloud/Public/Keys_VPN
sudo rm -rf /home/$3/configs