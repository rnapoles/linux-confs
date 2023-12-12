#!/bin/sh
### BEGIN INIT INFO
# Provides:          firewall
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start and stop firewall
# Description:       Firewall is a networking filter rules.
### END INIT INFO

#---------------------------------- Globals IP ------------------------------------------------------------------------------------------------#
        #DMZ
           dmz="12.0.0.254"
           dns="12.0.0.101"
          ldap="12.0.0.102"
         nginx="12.0.0.103"
        correo="12.0.0.104"
         proxy="12.0.0.105"
      #proxyProv="proxy.ho.rimed.cu"
      proxyProv="192.168.24.12"
        jabber="12.0.0.106"
           web="12.0.0.107"
           ftp="12.0.0.108"

        #LAN
        lan1="196.243.0.1"
        lan2="196.243.0.2"
        lan3="196.243.0.3"

        #WAN
        wan1="192.168.26.146"
        wan2="192.168.26.147"
        wan3="192.168.26.146"

	#Server Prov

#----------------------------------------------------------------------------------------------------------------------------------------------#

do_start() {
        iptables -F
        iptables -F -t nat
        iptables -F -t mangle
        iptables -X
        iptables -Z
        iptables -P INPUT DROP
        iptables -P FORWARD DROP
        echo 1 > /proc/sys/net/ipv4/ip_forward
        echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
        echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
        iptables -A FORWARD -p tcp -m state --state INVALID -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp ! --syn -m state --state NEW -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags SYN RST -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags SYN,FIN SYN,FIN -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN,RST -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags ALL FIN -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags SYN,FIN,PSH SYN,FIN,PSH -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags SYN,FIN,RST SYN,FIN,RST -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags SYN,FIN,RST,PSH SYN,FIN,RST,PSH -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags ALL NONE -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags ALL ALL -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags ALL FIN,URG,PSH -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp --tcp-flags SYN,ACK,FIN,RST RST -j REJECT --reject-with tcp-reset
        iptables -A INPUT -p udp --dport 53 -j ACCEPT
        iptables -A INPUT -p tcp --dport 53 -j ACCEPT

#	iptables -A FORWARD  -s 12.0.0.39 -j DROP

#---------------------------------- TRAFICO DHCP ----------------------------------------------------------------------------------------------#
        iptables -A INPUT -p icmp --icmp-type 8 -m limit --limit 1/s --limit-burst 1 -j ACCEPT
        iptables -A INPUT -i eth1 -p udp --sport 67:68 --dport 67:68 -j ACCEPT
        iptables -t nat -A POSTROUTING -o eth1 -p udp --dport 67:68 -j SNAT --to 196.243.0.1
#---------------------------------- TRAFICO DNS -----------------------------------------------------------------------------------------------#
        iptables -N DNS
        iptables -A DNS -p udp -d ${dns} --dport 53 -j ACCEPT
        iptables -A DNS -p tcp -d ${dns} --dport 53 -j ACCEPT
        iptables -A FORWARD -p udp --dport 53 -j DNS
        iptables -A FORWARD -p tcp --dport 53 -j DNS

        iptables -t nat -A PREROUTING -i eth1 -p tcp -d ${lan1} --dport 53 -j DNAT --to ${dns}
        iptables -t nat -A PREROUTING -i eth1 -p udp -d ${lan1} --dport 53 -j DNAT --to ${dns}
        iptables -t nat -A PREROUTING -i eth1 -p tcp -d ${lan2} --dport 53 -j DNAT --to ${dns}
        iptables -t nat -A PREROUTING -i eth1 -p udp -d ${lan2} --dport 53 -j DNAT --to ${dns}

        iptables -t nat -A PREROUTING -i eth2 -p udp -d ${wan1} --dport 53 -j DNAT --to ${dns}
        iptables -t nat -A PREROUTING -i eth2 -p tcp -d ${wan1} --dport 53 -j DNAT --to ${dns}

        iptables -t nat -A POSTROUTING -o eth1 -p tcp -s ${dns} -d ${lan1} --sport 53 -j SNAT --to ${lan1}
        iptables -t nat -A POSTROUTING -o eth1 -p udp -s ${dns} -d ${lan1} --sport 53 -j SNAT --to ${lan1}
        iptables -t nat -A POSTROUTING -o eth1 -p tcp -s ${dns} -d ${lan2} --sport 53 -j SNAT --to ${lan2}
        iptables -t nat -A POSTROUTING -o eth1 -p udp -s ${dns} -d ${lan2} --sport 53 -j SNAT --to ${lan2}

        iptables -t nat -A POSTROUTING -o eth2 -p udp -s ${dns} --sport 53 -j SNAT --to ${wan1}
        iptables -t nat -A POSTROUTING -o eth2 -p tcp -s ${dns} --sport 53 -j SNAT --to ${wan1}

#---------------------------------- TRAFICO PROXY ---------------------------------------------------------------------------------------------#
#       iptables -A FORWARD -p tcp -d 192.168.159.20 --dport 3128 -j ACCEPT
#       iptables -t nat -A PREROUTING -i eth1 -p tcp -d ${lan1} --dport 3129 -j DNAT --to 192.168.159.20:3128
#       iptables -t nat -A POSTROUTING -o eth1 -p tcp -s 192.168.159.20 --sport 3128 -j SNAT --to ${lan1}:3129
#------------------------------- a travez de router por dmz--------------------#
#       iptables -t nat -A PREROUTING -i eth0 -p tcp -d ${dmz} --dport 3129 -j DNAT --to 192.168.159.20:3128
#       iptables -t nat -A POSTROUTING -o eth0 -p tcp -s 192.168.159.20 --sport 3128 -j SNAT --to ${dmz}:3129

        iptables -N PROXY
        #iptables -A PROXY -p tcp -d ${proxy} --dport 3128 -j ACCEPT
        iptables -A PROXY -p tcp -d ${proxyProv} --dport 3128 -j ACCEPT
        iptables -A FORWARD -p tcp --dport 3128 -j PROXY

        #iptables -t nat -A PREROUTING -i eth1 -p tcp -d ${lan1} --dport 3128 -j DNAT --to ${proxy}
        #iptables -t nat -A POSTROUTING -o eth1 -p tcp -s ${proxy} --sport 3128 -j SNAT --to ${lan1}

        iptables -t nat -A PREROUTING   -p tcp -s 12.0.0.0/16     -d ${lan1} --dport 3128 -j DNAT --to ${proxyProv}
        iptables -t nat -A PREROUTING   -p tcp -s 12.0.0.0/16     -d ${dmz} --dport 3128 -j DNAT --to ${proxyProv}
        iptables -t nat -A PREROUTING   -p tcp -s 196.243.0.0/16  -d ${lan1} --dport 3128 -j DNAT --to ${proxyProv}

#        iptables -t nat -A PREROUTING   -p tcp -s 12.0.0.12     -d ${lan1} --dport 3128 -j DNAT --to ${proxyProv}
#        iptables -t nat -A PREROUTING   -p tcp -s 12.0.0.12     -d ${dmz} --dport 3128 -j DNAT --to ${proxyProv}

        iptables -t nat -A POSTROUTING  -p tcp -s ${proxyProv} --sport 3128 -j SNAT --to ${lan1}

        iptables -t nat -A PREROUTING -i eth2 -p tcp -d ${wan1} --dport 3128 -j DNAT --to ${proxy}
        iptables -t nat -A POSTROUTING -o eth2 -p tcp -s ${proxy} --sport 3128 -j SNAT --to ${wan1}


#       iptables -t nat -A POSTROUTING -o eth2 -p tcp -s ${proxy} -d 200.55.156.0/24 --dport 3128 -j SNAT --to ${wan1}
#       iptables -t nat -A POSTROUTING -o eth2 -p tcp -s ${proxy} -d 100.100.70.0/24 --dport 3128 -j SNAT --to ${wan1}

#-----------------------------------------------------------------------------------------------------------------------------------------------

        iptables -A FORWARD -s 196.243.0.0/16 -p tcp --dport 80  -j ACCEPT
        iptables -A FORWARD -s 196.243.0.0/16 -p tcp --dport 443 -j ACCEPT

#---------------------------------- TRAFICO NTP -----------------------------------------------------------------------------------------------#
        iptables -N NTP
        iptables -A NTP -p udp -d 12.0.0.42 --dport 123 -j ACCEPT
        iptables -A FORWARD -p udp --dport 123 -j NTP

        iptables -t nat -A PREROUTING -i eth1 -p udp -d ${lan1} --dport 123 -j DNAT --to 12.0.0.42
        iptables -t nat -A POSTROUTING -o eth1 -p udp -s 12.0.0.42 --sport 123 -j SNAT --to ${lan1}
#---------------------------------- TRAFICO JABBER --------------------------------------------------------------------------------------------#
        iptables -N JABBER
        iptables -A JABBER -p tcp -d ${jabber} -m multiport --dport 5222,5269,5223 -j ACCEPT
        iptables -A FORWARD -p tcp --dport 5222 -j JABBER
        iptables -A FORWARD -p tcp --dport 5269 -j JABBER
        iptables -A FORWARD -p tcp --dport 5223 -j JABBER

        iptables -t nat -A PREROUTING -i eth1 -p tcp -d ${lan1} -m multiport --dport 5222,5269,5223 -j DNAT --to ${jabber}
        iptables -t nat -A POSTROUTING -o eth1 -p tcp -s ${jabber} -m multiport --sport 5222,5269,5223 -j SNAT --to ${lan1}

        iptables -t nat -A PREROUTING -i eth2 -p tcp -d ${wan1} -m multiport --dport 5222,5269,5223 -j DNAT --to ${jabber}
        iptables -t nat -A POSTROUTING -o eth2 -p tcp -s ${jabber} -m multiport --sport 5222,5269,5223 -j SNAT --to ${wan1}
#---------------------------------- TRAFICO TSPEAK --------------------------------------------------------------------------------------------#
        iptables -N TSPEAK
        iptables -A TSPEAK -p udp -d ${jabber} --dport 9987 -j ACCEPT
        iptables -A TSPEAK -p tcp -d ${jabber} --dport 30033 -j ACCEPT
        iptables -A FORWARD -p udp --dport 9987 -j TSPEAK
        iptables -A FORWARD -p tcp --dport 30033 -j TSPEAK

        iptables -t nat -A PREROUTING -i eth1 -p udp -d ${lan1} --dport 9987 -j DNAT --to ${jabber}
        iptables -t nat -A PREROUTING -i eth1 -p tcp -d ${lan1} --dport 30033 -j DNAT --to ${jabber}
        iptables -t nat -A POSTROUTING -o eth1 -p udp -s ${jabber} --sport 9987 -j SNAT --to ${lan1}
        iptables -t nat -A POSTROUTING -o eth1 -p tcp -s ${jabber} --sport 30033 -j SNAT --to ${lan1}

        iptables -t nat -A PREROUTING -i eth2 -p udp -d ${wan1} --dport 9987 -j DNAT --to ${jabber}
        iptables -t nat -A PREROUTING -i eth2 -p tcp -d ${wan1} --dport 30033 -j DNAT --to ${jabber}
        iptables -t nat -A POSTROUTING -o eth2 -p udp -s ${jabber} --sport 9987 -j SNAT --to ${wan1}
        iptables -t nat -A POSTROUTING -o eth2 -p tcp -s ${jabber} --sport 30033 -j SNAT --to ${wan1}

#------------------------------- TRAFICO HTTP -------------------------------------------------------------------------------------------------#
        iptables -N HTTP
        iptables -A HTTP -p tcp -d ${nginx} -m multiport --dport 80,443 -j ACCEPT
        iptables -A FORWARD -p tcp --dport 80 -j HTTP
        iptables -A FORWARD -p tcp --dport 443 -j HTTP

        iptables -t nat -A PREROUTING -i eth1 -p tcp -d ${lan1} -m multiport --dport 80,443 -j DNAT --to ${nginx}
        iptables -t nat -A PREROUTING -i eth2 -p tcp -d ${wan3} -m multiport --dport 80,443 -j DNAT --to ${nginx}

        iptables -t nat -A POSTROUTING -o eth1 -p tcp -s ${nginx} -m multiport --sport 80,443 -j SNAT --to ${lan1}
        iptables -t nat -A POSTROUTING -o eth2 -p tcp -s ${nginx} -m multiport --sport 80,443 -j SNAT --to ${wan3}
#---------------------------------- TRAFICO TFTP ----------------------------------------------------------------------------------------------#
#       iptables -N TFTP
#       iptables -A TFTP -p udp -d ${dns} --dport 69 -j ACCEPT
#       iptables -A FORWARD -p udp --dport 69 -j TFTP

#       iptables -t nat -A PREROUTING -i eth1 -p udp -d ${lan2} --dport 69 -j DNAT --to ${dns}
#       iptables -t nat -A POSTROUTING -o eth1 -p udp -s ${dns} --sport 69 -j SNAT --to ${lan2}
#---------------------------------- TRAFICO RSYNC ----------------------------------------------------------------------------------------------#
        iptables -N RSYNC
        iptables -A RSYNC -p tcp -d ${ftp} --dport 22 -j ACCEPT
        iptables -A FORWARD -p tcp --dport 22 -j RSYNC

        iptables -t nat -A PREROUTING -i eth2 -p tcp -d ${wan1} --dport 22 -j DNAT --to ${ftp}
        iptables -t nat -A POSTROUTING -o eth2 -p tcp -s ${ftp} --sport 22 -j SNAT --to ${wan1}
#---------------------------------- TRAFICO SMTP ----------------------------------------------------------------------------------------------#
        iptables -N CORREO
        iptables -A CORREO -p tcp -d ${correo} -m multiport --dport 25,143,993,465,110,995 -j ACCEPT
        iptables -A FORWARD -p tcp -m multiport --dport 25,143,993,465,110,995 -j CORREO

#       iptables -t nat -A PREROUTING -i eth1 -p tcp -d ${lan1} -m multiport --dport 25,143,993,465,110,995 -j DNAT --to ${correo}
#       iptables -t nat -A POSTROUTING -o eth1 -p tcp -s ${correo} -d ${lan1} -m multiport --sport 25,143,993,465,110,995 -j SNAT --to ${lan1}
        iptables -t nat -A PREROUTING -i eth1 -p tcp -d ${lan1} --dport 995 -j DNAT --to ${correo}
        iptables -t nat -A POSTROUTING -o eth1 -p tcp -s ${correo} -d ${lan1} --sport 995 -j SNAT --to ${lan1}

        iptables -t nat -A PREROUTING -i eth2 -p tcp -d ${wan1} --dport 25 -j DNAT --to ${correo}
        iptables -t nat -A POSTROUTING -o eth2 -p tcp -s ${correo} --sport 25 -j SNAT --to ${wan1}
#---------------------------------- CONECT SSH ------------------------------------------------------------------------------------------------#
#       iptables -A INPUT -i etch0 -p tcp --dport 22 -s 192.168.24.0/24 -j ACCEPT
#       iptables -A INPUT -i etch1 -p tcp --dport 22 -s 192.168.24.0/24 -j ACCEPT
#----------------------------------------------------------------------------------------------------------------------------------------------#
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A INPUT -i eth0 -j ACCEPT
        iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        iptables -A FORWARD -i eth0 -j ACCEPT
        iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
#----------------------------------------------------------------------------------------------------------------------------------------------#
        iptables -t nat -A POSTROUTING ! -o eth0 -j MASQUERADE
        iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
        iptables -A FORWARD -p tcp -j REJECT --reject-with tcp-reset
#----------------------------------------------------------------------------------------------------------------------------------------------#



}

do_stop() {
#----------------------------------------------------------------------------------------------------------------------------------------------#
        iptables -F
        iptables -F -t nat
        iptables -F -t mangle
        iptables -X
        iptables -Z
        iptables -P INPUT DROP
        iptables -P FORWARD DROP
        iptables -A INPUT -i eth0 -s 12.0.0.0/24 -j ACCEPT
#----------------------------------------------------------------------------------------------------------------------------------------------#
}

case "$1" in
   start)
        echo -n "Started firewall network rules: "
        do_start
        echo -n "Done.\n"
   ;;
   restart)
        $0 stop
        sleep 1
        $0 start
   ;;
   stop)
        echo -n "Stopped firewall network rules: "
        do_stop
        echo -n "Done.\n"
   ;;
esac
exit 0

