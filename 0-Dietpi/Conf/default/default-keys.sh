cd ~/.ssh

ssh-keygen -f $2

ssh-copy-id -i $2.pub admin-nas@$1

chmod 777 $2

mv $2 /mnt/Cloud/Keys_SSH