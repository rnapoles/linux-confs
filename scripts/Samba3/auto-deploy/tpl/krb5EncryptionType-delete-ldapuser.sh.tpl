#!/bin/bash
#
# Bug Japa krb4Enc - By Eduardo Sachs (edu.sachs@terra.com.br)
#
# Quando o usuario altera a senha atraves do kpasswd, o Heimdal cria um objeto no LDAP chamado "krb5EncryptionType",
# e depois isso o usuario nao consegue mais alterar a senha. 
# A solucao foi deletar o objeto "krb5EncryptionType" da entrada do usuario.
#
# O script procura o obejto "sambaSamAccount" em conjunto com o "krb5EncryptionType", se achar algum usuario com esse objeto, 
# automaticamente o "krb5EncryptionType" é deletado da conta do usuario.
#
# Mais sobre o bug: 
# http://www.stacken.kth.se/lists/heimdal-discuss/2006-05/msg00074.html
# 
# Erro:
# Type or value exists: krb5EncryptionType: value #0 provided more than once
#

PASSWDLDAP=`cat /etc/smbldap-tools/smbldap_bind.conf|grep masterPw|cut -d \" -f2`

LDAPSEARCH_KRB5ENC=`ldapsearch -H ldaps://HOSTNAME.DOMINIO/ -x -D "krb5PrincipalName=ldapmaster/admin@KRB_TPL_DOMAIN,ou=KerberosPrincipals,LDAPDC" -w $PASSWDLDAP -b "LDAPDC" "(&(objectClass=sambaSamAccount)(krb5EncryptionType=*))"|grep dn:|sed '/ou=KerberosPrincipals,$LDAPDC/ a\delete: krb5EncryptionType\'|sed '/EncryptionType/ a\\'`

if [ "$LDAPSEARCH_KRB5ENC" ] ; then
     echo -n "`date` " >> /var/log/heimdal/krb5enc-delete.log
     echo "Encontrado krb5EncryptionType na base." >> /var/log/heimdal/krb5enc-delete.log      
     ldapsearch -H ldaps://HOSTNAME.DOMINIO/ -x -D "krb5PrincipalName=ldapmaster/admin@KRB_TPL_DOMAIN,ou=KerberosPrincipals,LDAPDC" -w $PASSWDLDAP -b "LDAPDC" "(&(objectClass=sambaSamAccount)(krb5EncryptionType=*))"|grep dn:|sed '/ou=KerberosPrincipals,LDAPDC/ a\delete: krb5EncryptionType\'|sed '/EncryptionType/ a\\' > /tmp/krb5enc-delete.ldif
     ldapmodify -H ldaps://HOSTNAME.DOMINIO/ -x -D "krb5PrincipalName=ldapmaster/admin@KRB_TPL_DOMAIN,ou=KerberosPrincipals,LDAPDC" -w $PASSWDLDAP -f /tmp/krb5enc-delete.ldif >> /var/log/heimdal/krb5enc-delete.log
       else
         echo -n "`date` " >> /var/log/heimdal/krb5enc-delete.log
         echo "Nao foi achado krb5EncryptionType na base." >> /var/log/heimdal/krb5enc-delete.log           
fi
