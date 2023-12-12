#!/bin/bash
HOSTNAME="ns1"
DOMINIO="hlg.uci.cu"

rm -f /etc/ldap/ldap.keytab

kadmin -l ext_keytab -k /etc/ldap/ldap.keytab ldap/$HOSTNAME.$DOMINIO
kadmin -l ext_keytab -k /etc/ldap/ldap.keytab ldap/$HOSTNAME

chown openldap.openldap /etc/ldap/ldap.keytab
chmod 400 /etc/ldap/ldap.keytab

 
