sudo apt install certbot python3-certbot-nginx python3-certbot-dns-cloudflare

sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Conf/cloudflare.ini /etc/letsencrypt
sudo nano /etc/letsencrypt/cloudflare.ini
sudo chmod 600 /etc/letsencrypt/cloudflare.ini

sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials cloudflare.ini -d *.$1$2 -d $1$2

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

sudo mkdir $1
sudo mv homer/* $1
sudo rm -rf homer

cd $1

sudo rm logo.png
sudo rm index.html
sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Conf/index.html .
sudo nano index.html

cd assets

sudo rm config.yml.dist
sudo rm config-demo.yml.dist
sudo rm config.yml
sudo rm manifest.json

sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Conf/config.yml .
sudo nano config.yml

sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Conf/manifest.json .
sudo nano manifest.json

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

sudo mv /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/Conf/$1 .
sudo nano $1

cd ../sites-enabled

sudo rm default

sudo ln -s /etc/nginx/sites-available/$1 .

cd /mnt/Cloud/Data/Dietpi/2-Homer_Nginx

sudo chmod g+x Conf/default/subdomain.sh
sudo chmod g+x Conf/default/subpath.sh

sudo bash Conf/default/subdomain.sh $1 $2 adguard 8083 $3

sudo bash Conf/default/subdomain.sh $1 $2 transmission 9091 $3

sudo bash Conf/default/subdomain.sh $1 $2 prowlarr 9696 $3

sudo bash Conf/default/subdomain.sh $1 $2 radarr 7878 $3

sudo bash Conf/default/subdomain.sh $1 $2 sonarr 8989 $3

sudo bash Conf/default/subdomain.sh $1 $2 readarr 8787 $3

sudo bash Conf/default/subdomain.sh $1 $2 bazdarr 6767 $3

sudo bash Conf/default/subdomain.sh $1 $2 jellyfin 8097 $3

sudo bash Conf/default/subdomain.sh $1 $2 kavita 2036 $3

sudo bash Conf/default/subdomain.sh $1 $2 immich 2283 $3

sudo nginx -s reload

sudo mv Conf/default/iptables_custom.sh /mnt/Cloud/Data

sudo chmod 600 /mnt/Cloud/Data/iptables_custom.sh

sudo mv Conf/crontab.txt /mnt/Cloud/Data

sudo chmod 600 /mnt/Cloud/Data/crontab

sudo crontab /mnt/Cloud/Data/crontab

sudo rm -rf /mnt/Cloud/Data/Dietpi/2-Homer_Nginx