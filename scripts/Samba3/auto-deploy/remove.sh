#!/bin/bash

aptitude purge bind9 libsasl2-modules-gssapi-heimdal winbind libpam-winbind cifs-utils \
libnss-ldap slapd ldap-utils libpam-krb5 heimdal-kdc heimdal-clients libkrb5-dev heimdal-docs \
heimdal-servers libkadm5clnt7-heimdal libkadm5srv8-heimdal libhdb9-heimdal libgssapi3-heimdal \
libkrb5-26-heimdal libasn1-8-heimdal krb5-config heimdal-kcm smbclient samba samba-common samba-doc \
libsmbclient smbldap-tools libkafs0-heimdal libhx509-5-heimdal libnss-winbind libheimntlm0-heimdal \
samba-common-bin libkdc2-heimdal libhcrypto4-heimdal slapd-smbk5pwd libotp0-heimdal heimdal-kcm

rm -rf /etc/ldap/schema

aptitude install binutils gzip ntp ipcalc

#dpkg --remove --force-remove-reinstreq