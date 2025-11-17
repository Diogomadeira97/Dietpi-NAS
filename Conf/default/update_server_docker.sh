#! /bin/bash

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
sudo docker compose -f docker-compose-ce.yaml pull
sudo docker compose -f docker-compose-ce.yaml up -d

#Update Stirling
cd /mnt/Cloud/Data/Docker/stirling
sudo docker compose pull
sudo docker compose up -d

#Update Vscodium
cd /mnt/Cloud/Data/Docker/vscodium
sudo docker compose pull
sudo docker compose up -d

#Update Esphome
cd /mnt/Cloud/Data/Docker/esphome
sudo docker compose pull
sudo docker compose up -d

#Update Flaresolverr
sudo stop flaresolverr
sudo rm flaresolverr
sudo docker run -d --name=flaresolverr   -p 8191:8191   -e LOG_LEVEL=info   --restart unless-stopped   ghcr.io/flaresolverr/flaresolverr:latest

#Clean old Images
sudo docker image prune -a
