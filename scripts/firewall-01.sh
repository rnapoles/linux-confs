#!/bin/bash
### BEGIN INIT INFO
# Provides:          firewall
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start and stop firewall
# Description:       Firewall is a networking filter rules.
### END INIT INFO

case "$1" in
    start)

	echo -n Aplicando Reglas de Firewall...

	# Con esto permitimos hacer forward de paquetes en el firewall, o sea
	# que otras máquinas puedan salir a traves del firewall.
	echo 1 > /proc/sys/net/ipv4/ip_forward
	dmz="eth0"
	lan="eth1"

	## FLUSH de reglas
	iptables -F
	iptables -X
	iptables -Z
	iptables -t nat -F

	## Establecemos politica por defecto
	iptables -P INPUT DROP
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD DROP
	iptables -t nat -P PREROUTING ACCEPT
	iptables -t nat -P POSTROUTING ACCEPT
	iptables -A INPUT -i lo -j ACCEPT
	#iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	
	#Equipos denegados
	iptables -A FORWARD -i $lan -s 192.168.2.53 -p tcp --dport 25 -j DROP

	#yamile
	
	iptables -A INPUT -i $lan -p tcp --dport 25 -s 192.168.2.220 -m mac --mac-source 7c:05:07:21:ab:73 -j ACCEPT

	#iptables -A INPUT -p tcp --dport 25 -s 192.168.2.206 -j ACCEPT
	#iptables -A INPUT  -p tcp --dport 25 -s 192.168.2.206 -d 192.168.2.254 -j ACCEPT

	#iptables -A INPUT -s 192.168.2.206 -p tcp --dport 25 -j ACCEPT
	#iptables -A INPUT -p tcp --dport 25 -j ACCEPT
	iptables -A INPUT -s 192.168.2.52 -p tcp --dport 25 -j ACCEPT
	#iptables -A INPUT -s 192.168.2.254 -p tcp --dport 25 -j ACCEPT

	## Empezamos a filtrar

	#Aceptamos todo de la DMZ
	iptables -A INPUT -s 192.168.0.0/24 -j ACCEPT

	iptables -A INPUT -s 192.168.0.0/24  -p tcp  -j ACCEPT
	iptables -A INPUT -s 192.168.0.0/24  -p udp  -j ACCEPT

	iptables -A FORWARD -s 192.168.0.0/24  -p tcp  -j ACCEPT
	iptables -A FORWARD -s 192.168.0.0/24  -p udp  -j ACCEPT

	#Ruteo lan
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp -d 192.168.2.0/24  -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p udp -d 192.168.2.0/24 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p icmp -d 192.168.2.0/24 -j ACCEPT

	# ICMP
	iptables -A FORWARD -p icmp -m recent --name icmp-atk --update --seconds 120 --hitcount 10 -j DROP
	iptables -A FORWARD -p icmp -m recent --set --name icmp-atk -j ACCEPT

	iptables -A INPUT -p icmp -m recent --name icmp-atk --update --seconds 120 --hitcount 10 -j DROP
	iptables -A INPUT -p icmp -m recent --set --name icmp-atk -j ACCEPT

	#rnapoles
	iptables -A FORWARD -s 192.168.2.0/24 -d 192.168.0.0/24 -j ACCEPT
	iptables -A INPUT -s 192.168.2.149 -m mac --mac-source 10:bf:48:40:90:74 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.149 -m mac --mac-source 10:bf:48:40:90:74 -j ACCEPT


	#iptables -A FORWARD -p tcp --dport 25 -s 192.168.2.220 -d 192.168.2.254 -m mac --mac-source 7c:05:07:21:ab:73 -j ACCEPT

	# Aceptamos que consulten los DNS
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 53 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p udp --dport 53 -j ACCEPT

	# Aceptamos que vayan a puertos 80
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 80 -j ACCEPT

	#iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 22 -j ACCEPT
	#iptables -A INPUT -p tcp --dport 22 -s 192.168.2.149 -m mac --mac-source 10:bf:48:40:90:74 -j ACCEPT

	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 25 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 110 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 143 -j ACCEPT
	
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 139 -j ACCEPT

	iptables -A FORWARD  -s 192.168.2.0/24   -p udp -m udp --dport  137 -j ACCEPT
	iptables -A FORWARD  -s 192.168.2.0/24   -p udp -m udp --dport  138 -j ACCEPT
	iptables -A FORWARD  -s 192.168.2.0/24   -p udp -m udp --dport  139 -j ACCEPT

	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 443 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 445 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 993 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 995 -j ACCEPT

	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 3128 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 3389 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 8080 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 5222 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 5223 -j ACCEPT

	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 1084 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 1433 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p udp --dport 1434 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 2725 -j ACCEPT
	iptables -A FORWARD -s 192.168.2.0/24  -p tcp --dport 2433 -j ACCEPT


	# Y denegamos el resto. Si se necesita alguno, ya avisaran
	#iptables -A FORWARD -s 192.168.2.0/24  -j DROP

	#iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
	

	# Ahora hacemos enmascaramiento de la red local
	# y activamos el BIT DE FORWARDING (imprescindible!!!!!)
	#iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o eth0 -j MASQUERADE

	#up route add -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.0.253
	#route del -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.0.253

	# Fin del script

	echo ""



    ;;

    stop)
	echo Firewall IPTABLES Vulnerable **DANGER**
	iptables -F INPUT
	iptables -F FORWARD
	iptables -F OUTPUT
	iptables -X
	iptables -Z
	iptables -t nat -F
	iptables -P INPUT ACCEPT
	iptables -P FORWARD DROP
	iptables -P OUTPUT ACCEPT
	    ;;

    restart)

	$0 stop
	$0 start

    ;;

	*)
    echo "Use start/stop"
	;;
    esac

