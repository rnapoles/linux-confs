#!/bin/bash


apt-get install -y dialog --force-yes  || { echo "imposible continuar,error en los paquetes"; exit 1;}


DOMINIO="hlg.desoft.cu"
PASSCERT="p@55w0rd"
PAIS="CU"
ESTADO="Holguin"
CIDADE="Holguin"
EMAIL="admin@$DOMINIO"
EMPRESA="Desoft Holguin"
SETOR="MIC"
#HOSTNAME="correo"
DOMINIOCERT=$(echo $DOMINIO|cut -d . -f1)
DIRCERT="/etc/nginx"
rep='y'
# Configuracao do certificado digital do LDAP;
# Configuracao do certificado digital do LDAP;
#rm -rf $DIRCERT/ssl
mkdir -p $DIRCERT/ssl

while [ $rep = "y" ]; do

HOSTNAME=$( dialog --stdout --inputbox 'Host (ex.:Server-1)' 0 28 )

cd $DIRCERT/ssl
mkdir certs
mkdir private
chmod 700 private
echo '01' > serial
touch index.txt

echo "[ ca ]
default_ca  = local_ca

[ local_ca  ]
dir = $DIRCERT/ssl
certificate = $DIRCERT/ssl/$HOSTNAME-cacert.pem
database = $DIRCERT/ssl/index.txt
new_certs_dir = $DIRCERT/ssl/certs
private_key = $DIRCERT/ssl/private/cakey.pem
serial = $DIRCERT/ssl/serial
default_crl_days = 3650
default_days = 3650
default_md = md5
default_bits = 1024
encrypt_key = yes
policy = local_ca_policy
x509_extensions = local_ca_extensions
unique_subject = no

[ local_ca_policy ]
commonName = supplied
stateOrProvinceName = supplied
countryName = supplied
emailAddress = supplied
organizationName = supplied
organizationalUnitName = supplied

[ local_ca_extensions ]
subjectAltName = DNS:$HOSTNAME.$DOMINIO
basicConstraints = CA:false
nsCertType = server

[ req ]
default_bits = 2048
default_keyfile = $DIRCERT/ssl/private/cakey.pem
default_md = md5
prompt = no
distinguished_name = $DOMINIOCERT
x509_extensions = x509_cert

[ $DOMINIOCERT ]
countryName = $PAIS
stateOrProvinceName = $ESTADO
localityName = $CIDADE
emailAddress = $EMAIL
organizationName = $EMPRESA
organizationalUnitName = $SETOR
commonName = $HOSTNAME.$DOMINIO

[ x509_cert ]
nsCertType = server
basicConstraints = CA:true
" > $DIRCERT/ssl/CA.conf

echo "[ req ]
prompt = no
distinguished_name = $DOMINIOCERT

[ $DOMINIOCERT ]
countryName = $PAIS
stateOrProvinceName = $ESTADO
localityName = $CIDADE
emailAddress = $EMAIL
organizationName = $EMPRESA
organizationalUnitName  = $SETOR
commonName = $HOSTNAME.$DOMINIO
" > $DIRCERT/ssl/LocalServer.conf

export OPENSSL_CONF=$DIRCERT/ssl/CA.conf
openssl req -x509 -newkey rsa:1024 -out $HOSTNAME-cacert.pem -outform PEM -days 3650 -passout pass:$PASSCERT
export OPENSSL_CONF=$DIRCERT/ssl/LocalServer.conf
openssl req -newkey rsa:1024 -keyout tempkey.pem -keyform PEM -out tempreq.pem -outform PEM -passout pass:$PASSCERT
openssl rsa < tempkey.pem > $HOSTNAME-serverkey.pem -passin pass:$PASSCERT
chmod 400 $HOSTNAME-serverkey.pem
export OPENSSL_CONF=$DIRCERT/ssl/CA.conf
openssl ca -in tempreq.pem -out $HOSTNAME-servercrt.pem -passin pass:$PASSCERT << EOF
y
y
EOF

echo "

server {
  listen 80;
  server_name $HOSTNAME.$DOMINIO;
  rewrite ^(.*) https://\$host\$1 permanent;
}


server {
  listen 80;
  server_name $HOSTNAME;
  rewrite ^(.*) https://$HOSTNAME.$DOMINIO\$1 permanent;
}


server {
   listen              443;
   server_name         $HOSTNAME.$DOMINIO;

    access_log  /var/log/nginx/$HOSTNAME.log;
    error_log  /var/log/nginx/$HOSTNAME-err.log;

    ssl on;
    ssl_certificate  /etc/nginx/ssl/$HOSTNAME-servercrt.pem;
    ssl_certificate_key /etc/nginx/ssl/$HOSTNAME-serverkey.pem;

    ssl_session_timeout 5m;

    ssl_protocols SSLv3 TLSv1;
    ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv3:+EXP;
    ssl_prefer_server_ciphers on;

  location / {
    proxy_pass http://192.168.0.14:8069/; # aqui el ip o el dns del sitio real (tambien se puede pedir por https:// al sitio real)
    #proxy_set_header Host $HOSTNAME.$DOMINIO; # aqui el nombre de host que pasa en las cabezeras al server real
    error_page 500 502 503 504 /50x.html;
  }

  location = /50x.html {
    root /var/www/nginx-default;
  }


}

" > /etc/nginx/sites-enabled/$HOSTNAME


rm -rf tempkey.pem tempreq.pem certs index.txt.attr  serial  index.txt index.txt.old private serial.old CA.conf LocalServer.conf

read -p "Addicionar otro record Y/n?: " rep
done
