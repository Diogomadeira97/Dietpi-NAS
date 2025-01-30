#! /bin/bash

#Install Homer Nginx Certbot.
/boot/dietpi/dietpi-software install 205 85 92

#Install Certboot extensions.
apt install python3-certbot-nginx python3-certbot-dns-cloudflare -y

#Go to Nginx Folder and create the files that are still missing.
cd /mnt/Cloud/Data/Dietpi-NAS/Conf/Nginx

#Create Nginx config to Domain.
echo -e "server{\n	listen 80 default_server;\n	listen [::]:80 default_server;\n\n	listen 443 default_server;\n	listen [::]:443 default_server;\n	ssl_reject_handshake on;\n	server_name _;\n	return 444;	\n}\n\n" >> $1
echo -e "server{\n	listen 80;\n	listen [::]:80;\n	server_name $1$2;\n	return 301 https://\$host\$request_uri;	\n}\n\nserver{\n	listen 443 ssl http2;\n	listen [::]:443 ssl http2;\n	server_name $1$2;\n	root /var/www/$1;\n\n	ssl_certificate /etc/letsencrypt/live/$1$2/fullchain.pem;\n	ssl_certificate_key /etc/letsencrypt/live/$1$2/privkey.pem;\n}" >> $1

#Edit index.html of Domain.
echo -e '\n        <title>'"$5"'</title>' >> index.html
cat index_temp.html >> index.html

#Create manifest.json to Domain.
echo -e '{"name":"'"$1"'","short_name":"'"$1"'","start_url":"../","display":"standalone","background_color":"#ffffff","lang":"en","scope":"../","description":"'"$1"'","theme_color":"#3367D6","icons":[{"src":"./icons/logo.svg","type":"image/svg"}]}' >> manifest.json

#Create Cloudlfare token file.
echo -e "#Cloudflare API token used by Certbot\ndns_cloudflare_api_token = $4" >> cloudflare.ini
mv cloudflare.ini /etc/letsencrypt
chown root:root /etc/letsencrypt/cloudflare.ini
chmod 600 /etc/letsencrypt/cloudflare.ini

#Edit config.yml of Domain.
echo -e '# Homepage configuration\ntitle: "'"$1"'"' >> config.yml
cat config_temp.yml >> config.yml

#Change default files permissions.
chown root:root ./*
chmod 644 ./*

#Create SSL Keys.
certbot certonly --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini -d *.$1$2 -d $1$2 --non-interactive --agree-tos -m $6

#Install Homer theme of Walkx Code.
cd /tmp
curl -fLO 'https://github.com/walkxcode/homer-theme/archive/main.tar.gz'
tar xf main.tar.gz
rm main.tar.gz
cp homer-theme-main/assets/custom.css /var/www/homer/assets/custom.css
cp homer-theme-main/assets/wallpaper.jpeg /var/www/homer/assets/wallpaper.jpeg
cp homer-theme-main/assets/wallpaper-light.jpeg /var/www/homer/assets/wallpaper-light.jpeg
cp -R homer-theme-main/assets/fonts /var/www/homer/assets/
rm -R homer-theme-main

#Go to www folder.
cd /var/www/
rm index.nginx-debian.html

#Create Domain folder with right owner and permissions.
mkdir $1
chown root:root $1
chmod 755 $1

#Move Homer to Domain folder.
mv homer/* $1
rm -rf homer

#Go to Domain folder and set the default files.
cd $1
rm logo.png
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Nginx/index.html .

#Go to assets folder and set the default files.
cd assets
rm config.yml.dist
rm config-demo.yml.dist
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Nginx/config.yml .
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Nginx/manifest.json .

#Go to icons folder and set the default files.
cd icons
rm ./*
mv /mnt/Cloud/Data/Dietpi-NAS/Icons/* .
chown root:root ./*
chmod 644 ./*


#Change the default site available.
cd /etc/nginx/sites-available
rm default
mv /mnt/Cloud/Data/Dietpi-NAS/Conf/Nginx/$1 .
chmod 544 $1

#Change the default site enabled.
cd ../sites-enabled
rm default
ln -s /etc/nginx/sites-available/$1 .

#Add Services with default configs.
cd /mnt/Cloud/Data/Commands

domain=$1

tpdomain=$2

section(){
    echo -e '   - name: "'$1'"\n     icon: "'$2'"\n     items:' >> /var/www/$domain/assets/config.yml
}

item(){
    echo -e '      - name: "'${1^}'"\n        logo: "assets/icons/'$1'.svg"\n        subtitle: "'$2'"\n        url: "https://'$1'.'$domain$tpdomain'"\n        target: "_blank"' >> /var/www/$domain/assets/config.yml
}

#Start.
echo -e 'services:' >> /var/www/$1/assets/config.yml

#Mídias Section.
section $1 "Mídias" "fa-solid fa-photo-film"

#Jellyfin.
bash subdomain.sh $1 $2 "jellyfin" 8097 $3

item "jellyfin" "Reprodutor de filmes e séries."

#Kavita.
bash subdomain.sh $1 $2 "kavita" 2036 $3

item "kavita" "Leitor de E-Book." $domain

#Immich.
bash subdomain.sh $1 $2 "immich" 2283 $3

item "immich" "Galeria de Mídias." $domain

#Downloads section.
section $1 "Downloads" "fa-solid fa-download" $domain

#Transmission.
bash subdomain.sh $1 $2 "transmission" 9091 $3

item "transmission" "Gestor de Downloads." $domain

#Radarr.
bash subdomain.sh $1 $2 "radarr" 7878 $3

item "radarr" "Rastreador de Filmes." $domain

#Sonarr.
bash subdomain.sh $1 $2 "sonarr" 8989 $3

item "sonarr" "Rastreador de TV-Shows." $domain

#Readarr.
bash subdomain.sh $1 $2 "readarr" 8787 $3

item "readarr" "Rastreador de Livros." $domain

#Prowlarr.
bash subdomain.sh $1 $2 "prowlarr" 9696 $3

item "prowlarr" "Rastreador de indexadores." $domain

#Bazarr.
bash subdomain.sh $1 $2 "bazarr" 6767 $3

item "bazarr" "Rastreador de Legendas." $domain

#Smart Home section.
section $1 "Casa Inteligente" "fa-solid fa-home"

#Home Assistant.
bash subdomain.sh $1 $2 "home-assistant" 8123 $3

item "home-assistant" "Automação Residencial." $domain

#Server management section.
section $1 "Gestão" "fa-solid fa-gear"

#AdGuard Home
bash subdomain.sh $1 $2 "adguard" 8083 $3

item "adguard" "Servidor DNS." $domain

#Dietpi-Dashboard
item "dietpi-dashboard" "Servidor DNS."

#Reload Nginx Server
nginx -s reload
