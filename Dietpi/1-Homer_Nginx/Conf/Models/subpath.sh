#! /bin/bash

sudo nano /var/www/alga-nas/assets/config.yml

echo -e "server{\n	listen 80;\n	listen [::]:80;\n	server_name $1.alga-nas.com.br;\n	return 301 https://\$host\$request_uri;	\n}\n\nserver{\n	listen 443 ssl http2;\n	listen [::]:443 ssl http2;\n\n	root /var/www/$1;\n\n	server_name $1.alga-nas.com.br;\n\n	ssl_certificate /etc/letsencrypt/live/alga-nas.com.br/fullchain.pem;\n	ssl_certificate_key /etc/letsencrypt/live/alga-nas.com.br/privkey.pem;\n\n	include /etc/nginx/sites-dietpi/$1;\n}" >> /etc/nginx/sites-available/$1

cd /etc/nginx/sites-enabled

sudo ln -s /etc/nginx/sites-available/$1 .

sudo nginx -s reload