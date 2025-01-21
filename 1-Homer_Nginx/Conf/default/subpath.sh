#! /bin/bash

sudo nano /var/www/$1/assets/config.yml

echo -e "server{\n	listen 80;\n	listen [::]:80;\n	server_name $3$1$2;\n	return 301 https://\$host\$request_uri;	\n}\n\nserver{\n	listen 443 ssl http2;\n	listen [::]:443 ssl http2;\n\n	root /var/www/$1;\n\n	server_name $3$1$2;\n\n	ssl_certificate /etc/letsencrypt/live/$1$2/fullchain.pem;\n	ssl_certificate_key /etc/letsencrypt/live/$1$2/privkey.pem;\n\n	include /etc/nginx/sites-dietpi/$1;\n}" >> /etc/nginx/sites-available/$1

sudo chown root:root /etc/nginx/sites-available/$1
sudo chmod 544 /etc/nginx/sites-available/$1

cd /etc/nginx/sites-enabled

sudo ln -s /etc/nginx/sites-available/$1 .

sudo nginx -s reload