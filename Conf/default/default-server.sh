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
echo -e '# Homepage configuration\ntitle: "'"$5"'"' >> config.yml
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
section "Mídias" "fa-solid fa-photo-film"

#Jellyfin.
bash subdomain.sh $1 $2 "jellyfin" 8097 $3

item "jellyfin" "Reprodutor de filmes e séries."

#Kavita.
bash subdomain.sh $1 $2 "kavita" 2036 $3

item "kavita" "Leitor de E-Book."

#Immich.
bash subdomain-docker.sh $1 $2 "immich" 2283 $3

item "immich" "Galeria de Mídias."

#Downloads section.
section "Downloads" "fa-solid fa-download"

#Transmission.
bash subdomain.sh $1 $2 "transmission" 9091 $3

item "transmission" "Gestor de Downloads."

#Radarr.
bash subdomain.sh $1 $2 "radarr" 7878 $3

item "radarr" "Rastreador de Filmes."

#Sonarr.
bash subdomain.sh $1 $2 "sonarr" 8989 $3

item "sonarr" "Rastreador de TV-Shows."

#Readarr.
bash subdomain.sh $1 $2 "readarr" 8787 $3

item "readarr" "Rastreador de Livros."

#Prowlarr.
bash subdomain.sh $1 $2 "prowlarr" 9696 $3

item "prowlarr" "Rastreador de indexadores."

#Bazarr.
bash subdomain.sh $1 $2 "bazarr" 6767 $3

item "bazarr" "Rastreador de Legendas."

#Tools Section.
section "Ferramentas" "fa-solid fa-screwdriver-wrench"

#Vscodium.
bash subdomain-docker.sh $1 $2 "vscodium" 3040 $3

item "vscodium" "Editor de Código."

#Gimp.
bash subdomain-docker.sh $1 $2 "gimp" 3030 $3

item "gimp" "Editor de Imagens."

#Passbolt.
#bash subdomain.sh $1 $2 "passbolt" 3030 $3

item "passbolt" "Gerenciador de Senhas."

#Nextcloud.
#bash subdomain.sh $1 $2 "nextcloud" 3030 $3

item "nextcloud" "Gerenciador de Arquivos."

#Onlyoffice.
#bash subdomain-docker.sh $1 $2 "gimp" 3030 $3
bash subdomain.sh $1 $2 "onlyoffice" 8090 $3

item "onlyoffice" "Plataforma de Produtividade."

#Stirling.
#bash subdomain-docker.sh $1 $2 "gimp" 3030 $3

item "stirling" "Manipulador de PDF."

#Server management section.
section "Gestão" "fa-solid fa-gear"

#AdGuard Home
bash subdomain.sh $1 $2 "adguard" 8083 $3

item "adguard" "Servidor DNS."

#Home Assistant.
bash subdomain.sh $1 $2 "home-assistant" 8123 $3

item "home-assistant" "Automação Residencial."

#Portainer
bash subdomain.sh $1 $2 "home-assistant" 9002 $3

item "portainer" "Gerenciador de Containers."

#Dietpi-Dashboard
echo -e '      - name: "Dietpi Dashboard"\n        logo: "assets/icons/dietpi-dashboard.svg"\n        subtitle: "Gestão de Servidor."\n        url: "http://'$1$2:5252'"\n        target: "_blank"' >> /var/www/$1/assets/config.yml

#Reload Nginx Server
nginx -s reload
