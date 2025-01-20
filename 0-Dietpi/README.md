# 0-Dietpi

• Login:

    login: roo

    Password: dietpi

• Change Global and root Password.

• When answer about UART, mark 'no'.

    dietpi-config

• Change timezone on 'Language/Regional Options'.

• Change host name to on security options
	
• Change the networking to static and enable ipv6 on 'Network Options: Adapters'.

• When ask about purge all WiFi related APT packages, mark 'yes'.

• On dietpi-software install OpenSSH, uninstall Dropbear.

• Install:

	Fail2Ban
	OpenSSH
	Dietpi-Dashboard
	Samba server
	Docker
	Docker Compose
	Transmission
    Radarr
	Sonarr
	Prowlarr
	Readarr
	Bazarr
	Jellyfin
	Kavita
	AdGuard Home
	Unbound

• AdGuard

	when ask about unbound mark yes.

	when ask about static IP mark skip.

• Dietpi-Dashboard

	Chose Nightly on Dietpi-Dashboard.

	Chose no to only backend on Dietpi-Dashboard.

• FAil2Ban:

	• The status can be checked with these commands:

		sudo fail2ban-client status sshd

		sudo fail2ban-client status dropbear

		sudo fail2ban-client set <sshd or dropbear> unbanip <ip>

• Select 0: Opt OUT and purge uploaded data

• Command dietpi-sync:

    • Change the path to /mnt/Cloud and /mnt/BAK_Cloud
    • Turn on Delete Mode.
    • Turn on Daily Sync.

• Command dietpi-backup

    • Change the path to /mnt/Cloud/Data/dietpi-backup
    • Turn on daily backup.
    • Change the quantity to 3.

• Command dietpi-cron

    • If you want, change the time of daily backup.

• Commands

	apt install git -y
	mkdir /mnt/Cloud
    mount /dev/sdb /mnt/Cloud
    mkdir /mnt/BAK_Cloud
    mount /dev/sda1 /mnt/BAK_Cloud
    cd /mnt/Cloud/Data
    git clone https://github.com/Diogomadeira97/Dietpi
    cd Dietpi/0-Dietpi/Conf/default
    chmod g+x ./*

    bash default-root.sh <SERVER NAME>

	hash=$(echo -n '<PASSWORD>' | sha512sum | mawk '{print $1}')
    secret=$(openssl rand -hex 32)
    G_CONFIG_INJECT 'pass[[:blank:]]' 'pass = true' /opt/dietpi-dashboard/config.toml
    GCI_PASSWORD=1 G_CONFIG_INJECT 'hash[[:blank:]]' "hash = \"$hash\"" /opt/dietpi-dashboard/config.toml
    GCI_PASSWORD=1 G_CONFIG_INJECT 'secret[[:blank:]]' "secret = \"$secret\"" /opt/dietpi-dashboard/config.toml
    unset -v hash secret
    systemctl restart dietpi-dashboard

	bash /mnt/Cloud/Data/default-keys.sh <SERVER NAME> <DEVICE>

	reboot 

• On Windows:

    • Create a private key on PuTTYgen (.ppk extension), after delete the Keys from docs.

    • Save Private Keys (Secret Folder).

    • On putty create a session with the private key.

• On termux

	pkg install openssh

	eval $(ssh-agent -s)

	cd .ssh

	nano <DEVICE> (Put the private key here.)

	ssh-add ~/.ssh/<DEVICE>

	nano config

		Host <SERVER IP>
  		AddKeysToAgent yes
  		IdentityFile ~/.ssh/<DEVICE>"

	cd ../../usr/etc	
	
	nano bash.bashrc

		ssh admin-nas@<SERVER IP>

Commands:

	bash /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/default/default-admin.sh <SERVER NAME>

    bash /mnt/Cloud/Data/default-user.sh <USER> <SERVER NAME>

• AdGuard Home

	• Set Unbound to the DNS resolver on the installation.

	• Set static ip if you don't.

	• Go to web UI and enter with Username: admin Password: Global.

	• On General Settings enable AdGuard browsing security service.

	• Set DNS Blocklists and Custom filtering rules on the web UI.

	• Set DNS on router and devices to the ip of the server.

• Transmission and Arrs

	• Login on Transmission and change the path to /mnt/Cloud/Public/Downloads.

	• Login on Arrs to change user and password.

	• Add the Transmission torrent download client (without category).

	• Add indexers, apps and FlareSolver on Prowlarr.

	• Create language profile on bazar, after add providers to turn on Sonarr and Bazarr.

• Jellyfin and Kavita

	• To force first login on jellyfin use this link: http://<DOMAIN>:8097/web/index.html#/wizardstart.html

	• Create Users and Libraries.

	• Do the the first login on kavita and Users and Libraries.

• Immich

	• On Immich Change user and password, after add Users and Libraries.

• Use Dietpi-Dashboard to:
 	
	• Export /mnt/Cloud/Keys_SSH to D:\Keys.