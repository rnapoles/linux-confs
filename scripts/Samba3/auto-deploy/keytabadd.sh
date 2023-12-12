#!/bin/bash
HOSTNAME="ns1"
DOMINIO="hlg.uci.cu"
rep="y"

while [ $rep = "y" ]; do

kinit kadmin/admin 

HOSTNAME=$( dialog --stdout --inputbox 'Host (ex.:Server-1)' 0 28 )
SERVICE=$( dialog --stdout --inputbox 'Servicio (ex.:ldap)' 0 28 )



kadmin -l add --random-key --max-ticket-life=unlimited --max-renewable-life=unlimited --expiration-time=never --pw-expiration-time=never --attributes= $SERVICE/$HOSTNAME.$DOMINIO
kadmin -l add --random-key --max-ticket-life=unlimited --max-renewable-life=unlimited --expiration-time=never --pw-expiration-time=never --attributes= $SERVICE/$HOSTNAME


kadmin -l ext_keytab $SERVICE/$HOSTNAME.$DOMINIO
kadmin -l ext_keytab $SERVICE/$HOSTNAME

read -p "Addicionar otro record Y/n?: " rep

done

ktutil list

