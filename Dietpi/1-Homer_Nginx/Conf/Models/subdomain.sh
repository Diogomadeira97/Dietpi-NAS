#! /bin/bash

echo -e "server{\n	listen 80;\n	listen [::]:80;\n	server_name $1.alga-nas.com.br;\n	return 301 https://\$host\$request_uri;	\n}\n\nserver{\n	listen 443 ssl http2;\n	listen [::]:443 ssl http2;\n	server_name $1.alga-nas.com.br;\n	ssl_certificate /etc/letsencrypt/live/alga-nas.com.br/fullchain.pem;\n	ssl_certificate_key /etc/letsencrypt/live/alga-nas.com.br/privkey.pem;\n	set \$url 192.168.68.104:$2;\n\n	location / {\n		proxy_pass http://\$url;\n		proxy_set_header Host \$host;\n		proxy_set_header X-Real-IP \$remote_addr;\n		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n		proxy_set_header X-Forwarded-Proto \$scheme;\n		proxy_set_header X-Forwarded-Protocol \$scheme;\n		proxy_set_header X-Forwarded-Host \$http_host;\n		proxy_buffering off;\n	}\n\n	location /socket {\n		proxy_pass http://\$url;\n		proxy_http_version 1.1;\n		proxy_set_header Upgrade \$http_upgrade;\n		proxy_set_header Connection "upgrade";\n		proxy_set_header Host \$host;\n		proxy_set_header X-Real-IP \$remote_addr;\n		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n		proxy_set_header X-Forwarded-Proto \$scheme;\n		proxy_set_header X-Forwarded-Protocol \$scheme;\n		proxy_set_header X-Forwarded-Host \$http_host;\n	}\n}" >> /etc/nginx/sites-available/$1

cd /etc/nginx/sites-enabled

sudo ln -s /etc/nginx/sites-available/$1 .

LINE='sudo iptables -A INPUT -p tcp ! -s 192.168.68.104 --dport $2 -j DROP'
FILE='/mnt/Cloud/Data/iptables_custom.sh'
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

sudo nginx -s reload