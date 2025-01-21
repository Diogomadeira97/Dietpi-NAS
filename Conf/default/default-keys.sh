#! /bin/bash

#Go to .ssh folder to create SSH Keys.
cd ~/.ssh

#Do it while have a Device.
for i in $(seq 2 $D);
do

    #Generate a Device SSH key.
    ssh-keygen -f $i

    #Copy Device SSH Key to default user.
    ssh-copy-id -i $i.pub admin-nas@$1

    #Change Device SSH key permissions.
    chmod 777 $i

    #Move Device SSH Key to /mnt/Cloud/Keys_SSH and easily export with Dietpi-Dashboard.
    mv $i /mnt/Cloud/Data/Keys_SSH

done