# 1-Homer_Nginx

Buy a domain and point DNS server to Cloudflare.

Create a A record to the domain and a A record to the wildcard, point both to your server private ip.

On AdGuarde rewrite DNS to your domain and wildcard, pointing to your server private ip.

	sudo dietpi-software

Install:

	>Homer
	>Nginx
	>Certbot

On Cloudflare create a token and put IPv4 and IPv6 to filter.

Put the token on cloudlfare.ini.

Commands:

	cd /mnt/Cloud/Data/Dietpi/2-Homer_Nginx/default
	sudo chmod g+x ./*
	
	sudo default.sh <SERVER DOMAIN NAME> <GENERIC AND COUNTRY TOP-LEVEL DOMAIN> <IP>
