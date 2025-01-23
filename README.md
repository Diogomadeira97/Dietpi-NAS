# Dietpi-NAS

## Index:

• [Description](#Description)

• [Notes](#Notes)

• [Requirements](#Requirements)

• [Recommendations](#Recommendations)

• [Tips](#Tips)

• [Installation](#Installation)

> • [First Steps](#First-Steps)

> • [Commands](#Commands)

• [Services Configuration](#Services-Configuration)

> • [Dietpi-Dashboard](#Dietpi-Dashboar)

> • [AdGuard Home](#AdGuard-Home)

> • [Fail2Ban](#Fail2Ban)

> • [Transmission and Arrs](#Transmission-and-Arrs)

> • [Jellyfin and Kavita](#Jellyfin-and-Kavita)

> • [Immich](#Immich)

> • [PiVPN](#PiVPN)

> • [Nginx - Certbot](#Nginx-Certbot)

• [Devices Configuration](#Devices-Configuration)

> • [On Windows](#On-Windows)

> • [On Termux](#On-Termux)

## Description:

Collection of scripts to perform a complete installation of a NAS-Server running Dietpi. The goal is to have a home lab that runs very lightly and very safely, so the focus of this configuration is on:

• Permissions.

• Private Keys.

• Encryption.

• Variety of passwords.

• Secure Remote Access.

• Virtual Private Networking (VPN).

• Network Masking.

In addition to security, another fundamental objective is to be an environment where users have full control of their files, so services that use third-party servers are limited to cloudflare, to perform DNS pointing, and a DDNS server chosen by the user to point the Dynamic Public IP ([see recommendations](#DDNS)). All other services running are self-hosted and free, so you don't need to pay nothing or subscribe to any paid subscription. The services running so far are:

• [Fail2Ban](https://dietpi.com/docs/software/system_security/#fail2ban).

• [OpendSSH](https://dietpi.com/docs/software/ssh/#openssh).

• [Dietpi-Dashboard](https://dietpi.com/docs/software/system_stats/#dietpi-dashboard).

• [Samba Server](https://dietpi.com/docs/software/file_servers/#samba).

• [Docker](https://dietpi.com/docs/software/programming/#docker).

• [Docker_Compose](https://dietpi.com/docs/software/programming/#docker-compose).

• [Transmission](https://dietpi.com/docs/software/bittorrent/#transmission).

• [Sonarr](https://dietpi.com/docs/software/bittorrent/#sonarr).

• [Radarr](https://dietpi.com/docs/software/bittorrent/#radarr).

• [Prowlarr](https://dietpi.com/docs/software/bittorrent/#prowlarr).

• [Readarr](https://dietpi.com/docs/software/bittorrent/#readarr).

• [Bazarr](https://dietpi.com/docs/software/bittorrent/#bazarr).

• [Jellyfin](https://dietpi.com/docs/software/media/#jellyfin).

• [Kavita](https://dietpi.com/docs/software/media/#kavita).

• [AdGuard Home](https://dietpi.com/docs/software/dns_servers/#adguard-home).

• [Unbound](https://dietpi.com/docs/software/dns_servers/#unbound).

• [PiVPN(Wireguard)](https://dietpi.com/docs/software/vpn/#pivpn).

• [Homer](https://dietpi.com/docs/software/system_stats/#homer).

• [Nginx Web Server](https://dietpi.com/docs/software/webserver_stack/#nginx).

• [Certbot Let’s Encrypt](https://dietpi.com/docs/software/system_security/#lets-encrypt).

• [Flaresolver](https://github.com/FlareSolverr/FlareSolverr).

• [Immich](https://immich.app/).

Last but not least, the installation was thought out to be practical, so that people with little knowledge can install without worrying about the security of their network. In this sense, it is possible to use some scripts in the post-installation located in /mnt/Cloud/Data:

• [default.sh](Conf/default/default.sh).

> Reconfigure folders to default permissions and default owners.

	bash /mnt/Cloud/Data/default.sh

• [default-user.sh](Conf/default/default-user.sh).

> Create Users with the default configuration to folders, permissions, groups, and Samba Share.

	bash /mnt/Cloud/Data/default-user.sh

• [default-Keys.sh](Conf/default/default-Keys.sh).

> Create SSH Private keys to multiple devices (Need root login).

	bash /mnt/Cloud/Data/default-Keys.sh

• [subdomain.sh](Conf/default/subdomain.sh).

> Create subdomain to a service in Nginx and Homer.

	bash /mnt/Cloud/Data/subdomain.sh

• [subpath.sh](Conf/default/subpath.sh).

> Create subpath to a service in Nginx and Homer.

	bash /mnt/Cloud/Data/subpath.sh

## Notes:

The remote used of this installation is designed to be only with a VPN, so the only port forwarding that is being performed is for the Wireguard (UDP). It is not recommended to use this installation to expose your public IP directly on the Internet. If you want to do it, is at your own risk.

## Requirements:

• Domain with DNS pointing to Cloudflare.

• Public IPv4 and IPv6 (Static or Dynamic).

• Prefix delegation and SLAAC+RDNSS (IPv6) on router.

• Two Storage Devices.

• A support device for Dietpi. Check available devices [here](https://dietpi.com/).

## Recommendations:

• Put ONT or ONU in Bridge and connect router with <a name="PPPoE">PPPoE</a>. This will greatly increase the speed and stability of the network by preventing a double NAT. If You have a router that is also an ONT or ONU, you can skip that part.

• It is recommended that your public IP IPv4 be dynamic, so that there is one more layer of network protection. However, it is necessary to use a <a name="DDNS">DDNS</a> service such as [Duck DNS](https://www.duckdns.org/) or [No IP](https://www.noip.com/) for example.

• A router with some kind of network protection.

• Connect the server only on <a name="LAN">LAN</a> and purge all WiFi related APT packages. This will improve network stability and device security.

• The primary storage device should preferably be an SSD, and the backup one HD.

• Some kind of cooling on the device running the server.

• Offsite backups at least every month.

• Different passwords for each variable in [default-variables.sh](Conf/default/default-variables.sh).

• Protect your private keys very well, because with it anyone can access your server.

## Tips:

• Copy the text of [default-variables.sh](Conf/default/default-variables.sh) to a code editor and, with the help of a password generator, fill in all the information. When run "nano default-variables.sh" on [commands](#Commands), use Crtl+6 and then Crtl+K to delete everything. Fill in with the text you created.

•  The private keys of Samba Server and Wireguard will be create on /mnt/Cloud/Data/Keys_SSH and /mnt/Cloud/Data/Keys_VPN consecutively and use Samba or Diet-Dashboard to easily export. Use one key per device and store them very well, you don't want them to fall into the wrong hands.

## Pre-Installation:

• Put router in Dynamic DHCP.

• On router, enable IPv6 with IP auto, prefix delegation and SLAAC+RDNSS (If is set [PPPoE](#PPPoE) on IPv4 put here too).

• Create a port <a name="forwarding">forwarding</a> (UDP), using the IPv4 and IPv6 of the server, with the port you chose (default is 51820).

• If you are going to make the [DDNS](#DDNS) recommendation, create a domain.

## Installation:

• Download the last image of Dietpi to your device [here](https://dietpi.com/).

• If necessary, use [Rufus](https://rufus.ie/) to create a bootable USB drive.

### First Steps:

Do the first login and follow the instructions.

**Login:**

> login: root

> Password: dietpi

• Change Global and root Password.

• When ask about UART, mark 'no'.

	dietpi-software

• install OpenSSH, uninstall Dropbear.

• Select 0: Opt OUT and purge uploaded data mark no.

	dietpi-config

• Change timezone on 'Language/Regional Options'.

• Change host name on 'Security Options'.
	
• Change the networking to **STATIC** and enable IPv6 on 'Network Options: Adapters'.

• When ask about purge all WiFi related APT packages, mark 'yes', as stated in the [LAN](#LAN) recommendation.

	dietpi-sync

• Change Source Location to /mnt/Cloud.

• Change Target Location to /mnt/BAK_Cloud.

• Turn on Delete Mode.

• Turn on Daily Sync.

	dietpi-backup

• Change the location path to /mnt/Cloud/Data/dietpi-backup.

• Turn on daily backup.

• Change the quantity to 3.

	dietpi-cron

• If you want, change the time of daily backup.

#### Commands:
	
	apt install git -y
    git clone https://github.com/Diogomadeira97/Dietpi-NAS
	cd Dietpi-NAS/Conf/default
    chmod +x ./*
	nano default-variables.sh
	bash default-variables.sh

#### Dietpi-Dashboard:
 	
• Chose Nightly on Dietpi-Dashboard.

• Chose no to "only backend".

#### PiVPN:

• Chose admin-nas to user.

• Set wireguard and use the default options.

• Choose a port based on the (forwarding)[#forwarding] you made in the pre-installation.

• Set the DNS provider to "PiVPN-is-local-DNS".

• If the [DDNS](#DDNS) recommendation is being made, chose DDNS and put your domain.

• Download wireguard on your device and use the QR code or the key to do the connection.

• Enable VPN permissions on device.

• Test if ipv6 and ipv4 is ok.

### Services Configuration:

#### AdGuard Home:

• Set Unbound to the DNS resolver on the installation.

• Set static ip if you don't.

• Login on web UI with: 

> Username: admin

> Password: Global.

• On General Settings enable AdGuard browsing security service.

• Set DNS Blocklists and Custom filtering rules on the web UI.

• Set DNS on router and devices to the ip of the server.

#### FAil2Ban:

• The status can be checked with these commands:

	sudo fail2ban-client status sshd

	sudo fail2ban-client status dropbear

	sudo fail2ban-client set <sshd or dropbear> unbanip <ip>

#### Transmission:

• Login on web UI with: 

> Username: root

> Password: Global.

• Change the path to /mnt/Cloud/Public/Downloads.

 #### Arrs:

• Login on Arrs to change users and passwords.

• Add the Transmission to download client (without category).

• Add indexers, apps and FlareSolver on Prowlarr.

• Create language profile on bazar, after add providers to turn on Sonarr and Bazarr.

#### Jellyfin and Kavita:

• To force first login on jellyfin use this link "https://jellyfin.<DOMAIN>/web/index.html#/wizardstart".html.

• Create Users and Libraries.

• Do the the first login on kavita and crate Users and Libraries.

#### Immich:

• On Immich Change user and password

• Create Users and Libraries.

#### Nginx - Certbot

• Create a 'A' record to the domain and a 'A' record to the wildcard, point both to your server private ip.

• On AdGuarde rewrite DNS to your domain and wildcard, pointing to your server private ip.

• On Cloudflare create a token and put IPv4 and IPv6 to filter.

• Put the token on cloudlfare.ini.

### Devices Configuration:

#### On Windows:

• Create a private key on PuTTYgen (.ppk extension), after delete the Keys from docs.

• Save Private Keys (Secret Folder).

• On putty create a session with the private key.

#### On termux:

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