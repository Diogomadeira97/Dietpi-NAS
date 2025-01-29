sudo apt install certbot python3-certbot-nginx python3-certbot-dns-cloudflare

sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Conf/cloudflare.ini /etc/letsencrypt
sudo chmod /etc/letsencrypt/cloudflare.ini

sudo chmod 600 cloudflare.ini

sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials cloudflare.ini -d *.alga-nas.com.br -d alga-nas.com.br

cd /tmp
curl -fLO 'https://github.com/walkxcode/homer-theme/archive/main.tar.gz'
tar xf main.tar.gz
rm main.tar.gz
sudo cp homer-theme-main/assets/custom.css /var/www/homer/assets/custom.css
sudo cp homer-theme-main/assets/wallpaper.jpeg /var/www/homer/assets/wallpaper.jpeg
sudo cp homer-theme-main/assets/wallpaper-light.jpeg /var/www/homer/assets/wallpaper-light.jpeg
sudo cp -R homer-theme-main/assets/fonts /var/www/homer/assets/
rm -R homer-theme-main

cd /var/www/

sudo rm index.nginx-debian.html

sudo mkdir alga-nas
sudo mv homer/* alga-nas
sudo rm -rf homer

cd alga-nas

sudo rm logo.png
sudo rm index.html
sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Conf/index.html .

cd assets

sudo rm config.yml.dist
sudo rm config-demo.yml.dist
sudo rm config.yml
sudo rm manifest.json

sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Conf/config.yml .

sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Conf/manifest.json .

cd icons

sudo rm favicon.ico
sudo rm logo.svg
sudo rm apple-touch-icon.png
sudo rm pwa-512x512.png
sudo rm pwa-192x192.png
sudo rm README.md

sudo mv sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Icons/* .

cd /etc/nginx/sites-available

sudo rm default

sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Conf/alga-nas .

cd ../sites-enabled

sudo rm default

sudo ln -s /etc/nginx/sites-available/alga-nas .

cd /mnt/Cloud/Data/Dietpi/2-Homer_Nginx

sudo chmod g+x Conf/Models/subdomain.sh
sudo chmod g+x Conf/Models/subpath.sh

sudo bash Conf/Models/subdomain.sh adguard 8083

sudo bash Conf/Models/subdomain.sh transmission 9091

sudo bash Conf/Models/subdomain.sh prowlarr 9696

sudo bash Conf/Models/subdomain.sh radarr 7878

sudo bash Conf/Models/subdomain.sh sonarr 8989

sudo bash Conf/Models/subdomain.sh readarr 8787

sudo bash Conf/Models/subdomain.sh bazdarr 6767

sudo bash Conf/Models/subdomain.sh jellyfin 8097

sudo bash Conf/Models/subdomain.sh kavita 2036

sudo bash Conf/Models/subdomain.sh immich 2283

sudo nginx -s reload

sudo mv Conf/Models/iptables_custom.sh /mnt/Cloud/Data

sudo chmod 755 /mnt/Cloud/Data/iptables_custom.sh

sudo mv Conf/Models/crontab.txt /mnt/Cloud/Data

sudo chmod 755 /mnt/Cloud/Data/crontab.txt

sudo crontab /mnt/Cloud/Data/crontab.txt 