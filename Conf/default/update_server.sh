#! /bin/bash

#Update and upgrade pkgs
sudo apt-get update -y
sudo apt-get upgrade -y

#Update Dietpi
sudo dietpi-update

#Update Esphome
cd /mnt/Cloud/Data/Docker/esphome
sudo docker compose pull
sudo docker compose up -d

#Update Gimp
cd /mnt/Cloud/Data/Docker/gimp
sudo docker compose pull
sudo docker compose up -d

#Update Immich
cd /mnt/Cloud/Data/Docker/immich-app
sudo docker compose pull
sudo docker compose up -d

#Update Passbolt
cd /mnt/Cloud/Data/Docker/passbolt
docker compose -f docker-compose-ce.yaml pull
docker compose -f docker-compose-ce.yaml up -d

#Update Stirling
cd /mnt/Cloud/Data/Docker/stirling
sudo docker compose pull
sudo docker compose up -d

#Update Vscodium
cd /mnt/Cloud/Data/Docker/vscodium
sudo docker compose pull
sudo docker compose up -d

#Update Flaresolverr
sudo stop flaresolverr
sudo rm flaresolverr
sudo docker run -d --name=flaresolverr   -p 8191:8191   -e LOG_LEVEL=info   --restart unless-stopped   ghcr.io/flaresolverr/flaresolverr:latest

#Clean old Images
sudo docker image prune -a

#Update Fail2Ban, Dietpi-Dashboard, PiVPN(Wireguard), Unbound, AdGuard_Home, Samba_server, Transmission, Sonarr, Radarr, Prowlarr, Readarr, Bazarr, Jellyfin, Kavita, Nginx, LEMP, Docker, Docker_Compose, Portainer, Home-Assistant, Homer, Certbot, Samba Client and Nextcloud.
sudo /boot/dietpi/dietpi-software reinstall 73 200 117 182 126 96 44 144 145 151 180 203 178 212 85 79 134 162 185 157 1 114 92