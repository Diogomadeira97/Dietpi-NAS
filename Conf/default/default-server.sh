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
echo -e '\n       <title>'"$5"'</title>' >> index.html
cat index_temp.html >> index.html

#Create manifest.json to Domain.
echo -e '{"name":"'"$1"'","short_name":"'"$1"'","start_url":"../","display":"standalone","background_color":"#ffffff","lang":"en","scope":"../","description":"'"$1"'","theme_color":"#3367D6","icons":[{"src":"./icons/logo.svg","type":"image/svg"}]}' >> manifest.json

#Edit config.yml of Domain.
echo -e '# Homepage configuration\ntitle: "'"$1"'"' >> config.yml
cat config_temp.yml >> config.yml

#Create Cloudlfare token file.
echo -e "#Cloudflare API token used by Certbot\ndns_cloudflare_api_token = $4" >> cloudflare.ini

#Add Cloudflare token
mv cloudflare.ini /etc/letsencrypt
chown root:root /etc/letsencrypt/cloudflare.ini
chmod 600 /etc/letsencrypt/cloudflare.ini

#Change default files permissions.
chown root:root ./*
chmod 644 ./*

#Create SSL Keys.
certbot certonly --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini -d *.$1$2 -d $1$2

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

#Start.
echo -e 'services:' >> /var/www/$1/assets/config.yml

#Mídias Section.
echo -e '   - name: "Mídias"\n     icon: "fa-solid fa-photo-film"\n     items:' >> /var/www/$1/assets/config.yml

#Jellyfin.
bash subdomain.sh $1 $2 jellyfin 8097 $3

echo -e '      - name: "Jellyfin"\n        logo: "assets/icons/jellyfin.svg"\n        subtitle: "Reprodutor de filmes e séries."\n        url: "https://jellyfin.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Kavita.
bash subdomain.sh $1 $2 kavita 2036 $3

echo -e '      - name: "Kavita"\n        logo: "assets/icons/kavita.svg"\n        subtitle: "Leitor de E-Book."\n        url: "https://kavita.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Immich.
bash subdomain.sh $1 $2 immich 2283 $3

echo -e '      - name: "Immich"\n        logo: "assets/icons/immich.svg"\n        subtitle: "Galeria de Mídias."\n        url: "https://immich.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Downloads section.
echo -e '   - name: "Downloads"\n     icon: "fa-solid fa-download"\n     items:' >> /var/www/$1/assets/config.yml

#Transmission.
bash subdomain.sh $1 $2 transmission 9091 $3

echo -e '      - name: "Transmission"\n        logo: "assets/icons/transmission.svg"\n        subtitle: "Gestor de Downloads."\n        url: "https://transmission.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Radarr.
bash subdomain.sh $1 $2 radarr 7878 $3

echo -e '      - name: "Radarr"\n        logo: "assets/icons/radarr.svg"\n        subtitle: "Rastreador de Filmes."\n        url: "https://radarr.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Sonarr.
bash subdomain.sh $1 $2 sonarr 8989 $3

echo -e '      - name: "Sonarr"\n        logo: "assets/icons/sonarr.svg"\n        subtitle: "Rastreador de TV-Shows."\n        url: "https://sonarr.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Readarr.
bash subdomain.sh $1 $2 readarr 8787 $3

echo -e '      - name: "Readarr"\n        logo: "assets/icons/readarr.svg"\n        subtitle: "Rastreador de Livros."\n        url: "https://readarr.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Prowlarr.
bash subdomain.sh $1 $2 prowlarr 9696 $3

echo -e '      - name: "Prowlarr"\n        logo: "assets/icons/prowlarr.svg"\n        subtitle: "Rastreador de indexadores."\n        url: "https://radarr.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Bazarr.
bash subdomain.sh $1 $2 bazarr 6767 $3

echo -e '      - name: "Bazarr"\n        logo: "assets/icons/bazarr.svg"\n        subtitle: "Rastreador de Legendas."\n        url: "https://bazarr.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Smart Home section.
echo -e '   - name: "Casa Inteligente"\n     icon: "fa-solid fa-home"\n     items:' >> /var/www/$1/assets/config.yml

#Home Assistant.
echo -e '      - name: "Home Asssistant"\n        logo: "assets/icons/home-assistant.svg"\n        subtitle: "Automação Residencial."\n        url: "https://home-assistant.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Server management section.
echo -e '   - name: "Gestão"\n     icon: "fa-solid fa-gear"\n     items:' >> /var/www/$1/assets/config.yml

#AdGuard Home
bash subdomain.sh $1 $2 adguard 8083 $3

echo -e '      - name: "AdGuard"\n        logo: "assets/icons/adguardhome.svg"\n        subtitle: "Servidor DNS."\n        url: "https://adguard.'"$1$2"'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Dietpi-Dashboard
echo -e '      - name: "Dietpi Dashboard"\n        logo: "assets/icons/dietpi-logo.svg"\n        subtitle: "Gestão do servidor."\n        url: "'"$1$2"':5252"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Reload Nginx Server
nginx -s reload
