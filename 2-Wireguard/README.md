# 2-Wireguard

Put ONU in Bridge mode and router in PPPoE on ipv4.

On router, enable ipv6 on PPPoE with ip auto, prefix delegation and SLAAC+RDNSS.

Create a DDNS to your public IPv4.

Create a port forwarding using the ipv4 and ipv6 of raspberry pi 5 with the port you chose.

sudo dietpi-software

Install:

	>Pivpn:

Set wireguard and use the default options.

Select DDNS and Put your domain.

sudo pivpn add <DEVICE>

sudo pivpn -qr <DEVICE>

sudo mv configs /mnt/Cloud/Public

Download wireguard on your device and use the QR code or the key to do the connection.

Enable VPN permissions on device

On router, enable networking protection and isolate the devices.

Test if ipv6 and ipv4 is ok




