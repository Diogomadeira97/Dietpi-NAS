# Dietpi-NAS

## Description:

Collection of scripts to perform a complete installation of a NAS-Server running Dietpi. The goal is to have a home lab that runs very lightly and very safely, so the focus of this configuration is on:

> Permissions

> Private Keys

> Encryption

> Variety of passwords

> Secure Remote Access

> Network Masking

> 

## Requirements:

• Domain with DNS pointing to Cloudflare.

• Public IPv4 and IPv6 (Static or Dynamic).

• Prefix delegation and SLAAC+RDNSS (IPv6) on router.

• Two Storage Devices.

• A support device for Dietpi [Check available devices here](https://dietpi.com/).

## Recommendations:

• Put ONU in Bridge and connect router with PPPoE (IPv4 and IPv6).

• A router with some kind of network protection.

• The primary storage device should preferably be an SSD, and the backup one HD.

• Some kind of cooling on the device running the server.

• Offsite backups at least every month.

• Different passwords for each variable in [Contribution guidelines for this project](Conf/default/default-variables.sh).

## Installation:

• Download the last image of Dietpi to your device [here](https://dietpi.com/).

• If necessary, use [Rufus](https://rufus.ie/) to create a bootable USB drive.

### First Steps:

Do the first login and follow the instructions.

**Login:**

> login: root

> Password: dietpi

• Change Global and root Password.

• When answer about UART, mark 'no'.

• On dietpi-software install OpenSSH, uninstall Dropbear.

• Select 0: Opt OUT and purge uploaded data.

	dietpi-config:

> Change timezone on 'Language/Regional Options'.

> Change host name to on 'Security Options'.

> Change the networking to static and enable ipv6 on 'Network Options: Adapters'.

> When ask about purge all WiFi related APT packages, mark 'yes'.

	dietpi-sync:

>Change the path to /mnt/Cloud and /mnt/BAK_Cloud.

>Turn on Delete Mode.

>Turn on Daily Sync.

	dietpi-backup

>Change the path to /mnt/Cloud/Data/dietpi-backup.

>Turn on daily backup.

>Change the quantity to 3.

	dietpi-cron

>If you want, change the time of daily backup.

#### Commands:

	apt install git -y
	mkdir /mnt/Cloud
    mount /dev/sdb /mnt/Cloud
    mkdir /mnt/BAK_Cloud
    mount /dev/sda1 /mnt/BAK_Cloud
    cd /mnt/Cloud/Data
    git clone https://github.com/Diogomadeira97/Dietpi-NAS
    cd Dietpi-NAS/Conf/default
    chmod g+x ./*

	nano default-variables.sh

	bash default-variables.sh

### Services Configuration:

#### Dietpi-Dashboard to:
 	
> Chose Nightly on Dietpi-Dashboard.

> Chose no to only backend on Dietpi-Dashboard.

> Export /mnt/Cloud/Keys_SSH to D:\Keys.

#### AdGuard Home

> Set Unbound to the DNS resolver on the installation.

> Set static ip if you don't.

> Go to web UI and enter with Username: admin Password: Global.

> On General Settings enable AdGuard browsing security service.

> Set DNS Blocklists and Custom filtering rules on the web UI.

> Set DNS on router and devices to the ip of the server.

#### FAil2Ban:

> The status can be checked with these commands:

	sudo fail2ban-client status sshd

	sudo fail2ban-client status dropbear

	sudo fail2ban-client set <sshd or dropbear> unbanip <ip>

#### Transmission and Arrs

> Login on Transmission and change the path to /mnt/Cloud/Public/Downloads.

> Login on Arrs to change user and password.

> Add the Transmission torrent download client (without category).

> Add indexers, apps and FlareSolver on Prowlarr.

> Create language profile on bazar, after add providers to turn on Sonarr and Bazarr.

#### Jellyfin and Kavita

> To force first login on jellyfin use this link: http://<DOMAIN>:8097/web/index.html#/wizardstart.html

> Create Users and Libraries.

> Do the the first login on kavita and Users and Libraries.

#### Immich

> On Immich Change user and password, after add Users and Libraries.

#### Pivpn

> Set wireguard and use the default options.

> Select DDNS and Put your domain.

> Create a DDNS to your public IPv4.

> Put ONU in Bridge and connect router with PPPoE (Optional).

> Put router in Dynamic DHCP.

> On router, enable IPv6 with IP auto, prefix delegation and SLAAC+RDNSS (If is set PPPoE on IPv4 put here too).

> Create a port forwarding using the IPv4 and IPv6 of raspberry pi with the port you chose.

> Download wireguard on your device and use the QR code or the key to do the connection.

> Enable VPN permissions on device

> On router, enable networking protection and isolate the devices (Optional).

> Test if ipv6 and ipv4 is ok.

#### Nginx - Certbot

> Create a 'A' record to the domain and a 'A' record to the wildcard, point both to your server private ip.

> On AdGuarde rewrite DNS to your domain and wildcard, pointing to your server private ip.

> On Cloudflare create a token and put IPv4 and IPv6 to filter.

> Put the token on cloudlfare.ini.

### Devices Configuration.

#### On Windows:

> Create a private key on PuTTYgen (.ppk extension), after delete the Keys from docs.

> Save Private Keys (Secret Folder).

> On putty create a session with the private key.

#### On termux

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