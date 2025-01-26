#! /bin/bash

#Authorize password authentication.
sudo echo -e "# Added by DietPi:\nPasswordAuthentication yes\nPermitRootLogin no" >> dietpi.conf
sudo mv dietpi.conf /etc/ssh/sshd_config.d
sudo chmod 644 /etc/ssh/sshd_config.d/dietpi.conf
sudo service sshd restart

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
    sudo sshpass -p "$(echo "$2")" ssh-copy-id -i $a.pub admin-nas@$1

    #Change Device SSH key permissions.
    sudo chmod 777 $a

    #Move Device SSH Key to /mnt/Cloud/Keys_SSH and easily export with Dietpi-Dashboard or Samba.
    sudo mv $a /mnt/Cloud/Data/Keys_SSH

    #Create a Device Wireguard Key.
    sudo pivpn add -n $a

done

#Deny password authentication.
sudo echo -e "# Added by DietPi:\nPasswordAuthentication no\nPermitRootLogin no" >> dietpi.conf
sudo mv dietpi.conf /etc/ssh/sshd_config.d
sudo chmod 644 /etc/ssh/sshd_config.d/dietpi.conf
sudo service sshd restart

#Move Device Wireguard Key to /mnt/Cloud/Keys_VPN and easily export with Dietpi-Dashboard or Samba.
sudo mv /home/admin-nas/configs/* /mnt/Cloud/Data/Keys_VPN
sudo rm -rf /home/admin-nas/configs