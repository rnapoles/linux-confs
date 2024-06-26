#!/bin/bash
ldaphost='192.168.0.1'
ldapbase='ou=Usuarios,dc=hlg,dc=desoft,dc=cu'
ldapbind='cn=samba,dc=hlg,dc=desoft,dc=cu'
ldappass='p@55w0rd'
ldapfile='/tmp/modify.ldif'

users=`cat /root/script/ip.txt |awk '{print $1}'`
for user in $users; do
  ip=`cat /root/script/ip.txt |grep $user |awk '{print $2}'`

  dn=`ldapsearch  -x -h $ldaphost -b $ldapbase uid=$i dn |perl -p0e 's/\n //g'  |grep ^dn`
  echo $dn > $ldapfile
  echo "changetype: modify" >> $ldapfile
  echo "replace: ServProxyIp">> $ldapfile
  echo ServProxyIp: $ip >> $ldapfile
  echo "-" >>  $ldapfile
  echo "replace: ServProxyMac">> $ldapfile
  echo ServProxyMac:  $mac >> $ldapfile
  #ldapmodify -x -h $ldaphost -D $ldapbind -w $ldappass -f $ldapfile
  #echo $dn.
  exit 0
done