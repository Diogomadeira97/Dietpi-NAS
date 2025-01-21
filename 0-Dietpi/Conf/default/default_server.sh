sudo apt install certbot python3-certbot-nginx python3-certbot-dns-cloudflare -y

cd /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/Nginx
sudo echo -e "server{\n	listen 80 default_server;\n	listen [::]:80 default_server;\n\n	listen 443 default_server;\n	listen [::]:443 default_server;\n	ssl_reject_handshake on;\n	server_name _;\n	return 444	\n}\n\n" >> $1
sudo echo -e "server{\n	listen 80;\n	listen [::]:80;\n	server_name $1$2;\n	return 301 https://\$host\$request_uri;	\n}\n\nserver{\n	listen 443 ssl http2;\n	listen [::]:443 ssl http2;\n	server_name $1$2;\n	root /var/www/$1$2;\n\n	ssl_certificate /etc/letsencrypt/live/$1$2/fullchain.pem;\n	ssl_certificate_key /etc/letsencrypt/live/$1$2/privkey.pem;\n}" >> $1
sudo echo -e        '<title>'"$1"'</title>' >> index.html
sudo echo -e index_temp.html >> index.html
sudo echo -e '{"name":"'"$1"'","short_name":"'"$1"'","start_url":"../","display":"standalone","background_color":"#ffffff","lang":"en","scope":"../","description":"'"$1"'","theme_color":"#3367D6","icons":[{"src":"./icons/logo.svg","type":"image/svg"}]}' >> manifest.json
sudo echo -e '# Homepage configuration\ntitle: "'"$1"'"' >> config.yml
sudo echo -e config_temp.yml >> config.yml
echo -e "#Cloudflare API token used by Certbot\ndns_cloudflare_api_token = $4" >> cloudflare.ini
echo -e "#! /bin/bash" >> iptables_custom.sh

sudo mv cloudflare.ini /etc/letsencrypt
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

sudo chown root:root /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/Nginx/*
sudo chmod 644 /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/Nginx/*

cd /var/www/

sudo rm index.nginx-debian.html

sudo mkdir $1
sudo chown root:root $1
sudo chmod 755 $1
sudo mv homer/* $1
sudo rm -rf homer

cd $1

sudo rm logo.png
sudo mv /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/Nginx/index.html .

cd assets

sudo rm config.yml.dist
sudo rm config-demo.yml.dist

sudo mv /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/Nginx/config.yml .
sudo mv /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/Nginx/manifest.json .

cd icons

sudo rm favicon.ico
sudo rm logo.svg
sudo rm apple-touch-icon.png
sudo rm pwa-512x512.png
sudo rm pwa-192x192.png
sudo rm README.md

sudo mv sudo mv /mnt/Cloud/Data/Dietpi/0-Dietpi/Icons/* .

cd /etc/nginx/sites-available

sudo rm default

sudo mv /mnt/Cloud/Data/Dietpi/0-Dietpi/Conf/$1 .

cd ../sites-enabled

sudo rm default

sudo ln -s /etc/nginx/sites-available/$1 .

cd /mnt/Cloud/Data/Dietpi/0-Dietpi

sudo chmod 700 Conf/default/*
sudo mv subdomain.sh /mnt/Cloud/Data
sudo mv subpath.sh /mnt/Cloud/Data

echo -e 'services:\n\n  - name: "Mídias"\n    icon: "fa-solid fa-photo-film"\n    items:\n\n' >> /var/www/$1/assets/config.yml

sudo bash /mnt/Cloud/Data/subdomain.sh $1 $2 jellyfin 8097 $3

echo -e '      - name: "Jellyfin"\n        logo: "assets/icons/jellyfin.svg"\n        subtitle: "Reprodutor de filmes e séries."\n        url: "https://jellyfin.'"$1$2"'"\n        target: "_blank"\n\n' >> /var/www/$1/assets/config.yml

sudo bash /mnt/Cloud/Data/subdomain.sh $1 $2 kavita 2036 $3

echo -e '      - name: "Kavita"\n        logo: "assets/icons/kavita.svg"\n        subtitle: "Leitor de E-Book."\n        url: "https://kavita.'"$1$2"'"\n        target: "_blank"\n\n' >> /var/www/$1/assets/config.yml

sudo bash /mnt/Cloud/Data/subdomain.sh $1 $2 immich 2283 $3

echo -e '      - name: "Immich"        logo: "assets/icons/immich.svg"\n        subtitle: "Galeria de Mídias."\n        url: "https://immich.'"$1$2"'"\n        target: "_blank"\n\n' >> /var/www/$1/assets/config.yml

echo -e '  - name: "Downloads"\n    icon: "fa-solid fa-download"\n   items:\n\n' >> /var/www/$1/assets/config.yml

sudo bash /mnt/Cloud/Data/subdomain.sh $1 $2 transmission 9091 $3

echo -e '      - name: "Transmission"\n        logo: "assets/icons/transmission.svg"\n        subtitle: "Gestor de Downloads."\n        url: "https://transmission.'"$1$2"'"\n        target: "_blank"\n\n' >> config.yml

sudo bash /mnt/Cloud/Data/subdomain.sh $1 $2 radarr 7878 $3

echo -e '      - name: "Radarr"\n        logo: "assets/icons/radarr.svg"\n        subtitle: "Rastreador de Filmes."\n        url: "https://radarr.'"$1$2"'"\n        target: "_blank"\n\n' >> config.yml

sudo bash /mnt/Cloud/Data/subdomain.sh $1 $2 sonarr 8989 $3

echo -e '      - name: "Sonarr"\n        logo: "assets/icons/sonarr.svg"\n        subtitle: "Rastreador de TV-Shows."\n        url: "https://sonarr.'"$1$2"'"\n        target: "_blank"\n\n' >> config.yml

sudo bash /mnt/Cloud/Data/subdomain.sh $1 $2 readarr 8787 $3

echo -e '      - name: "Readarr"\n        logo: "assets/icons/readarr.svg"\n        subtitle: "Rastreador de Livros."\n        url: "https://readarr.'"$1$2"'"\n        target: "_blank"\n\n' >> config.yml

sudo bash /mnt/Cloud/Data/subdomain.sh $1 $2 prowlarr 9696 $3

echo -e '      - name: "Prowlarr"\n        logo: "assets/icons/prowlarr.svg"\n        subtitle: "Rastreador de indexadores."\n        url: "https://radarr.'"$1$2"'"\n        target: "_blank"\n\n' >> config.yml

sudo bash /mnt/Cloud/Data/subdomain.sh $1 $2 bazarr 6767 $3

echo -e '      - name: "Bazarr"\n        logo: "assets/icons/bazarr.svg"\n        subtitle: "Rastreador de Legendas."\n        url: "https://bazarr.'"$1$2"'"\n        target: "_blank"\n\n' >> config.yml

echo -e '  - name: "Casa Inteligente"\n    icon: "fa-solid fa-home"\n    items:\n\n' >> config.yml

echo -e '      - name: "Home Asssistant"\n        logo: "assets/icons/home-assistant.svg"\n        subtitle: "Automação Residencial."\n        url: "https://home-assistant.'"$1$2"'"\n        target: "_blank"\n\n' >> config.yml

echo -e '  - name: "Gestão"\n    icon: "fa-solid fa-gear"\n    items:\n\n' >> config.yml

sudo bash /mnt/Cloud/Data/subdomain.sh $1 $2 adguard 8083 $3

echo -e '      - name: "AdGuard"\n        logo: "assets/icons/adguardhome.svg"\n        subtitle: "Servidor DNS."\n        url: "https://adguard.'"$1$2"'"\n        target: "_blank"\n\n' >> config.yml

echo -e '      - name: "Dietpi Dashboard"\n        logo: "assets/icons/dietpi-logo.svg"\n        subtitle: "Gestão do servidor."\n        url: "'"$1$2"':5252"\n        target: "_blank"\n\n' >> config.yml

sudo nginx -s reload

sudo mv Conf/default/iptables_custom.sh /mnt/Cloud/Data

sudo chmod 700 /mnt/Cloud/Data/iptables_custom.sh

sudo mv Conf/crontab.txt /mnt/Cloud/Data

sudo chmod 600 /mnt/Cloud/Data/crontab

sudo crontab /mnt/Cloud/Data/crontab

sudo rm -rf /mnt/Cloud/Data/Dietpi/0-Dietpi
