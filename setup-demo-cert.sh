#!/bin/sh

set -x

PASSWORD=pass:"pass"

openssl req -x509 -newkey rsa:4096 -passout $PASSWORD -keyout authenticode.key -out authenticode.crt -days 365 -subj "/C=CA/ST=DemoState/L=DemoDepartment/O=DemoCompany/OU=DemoUnit/CN=demo/emailAddress=root@demo"
/usr/bin/openssl pkcs12 -export -out authenticode.pfx -inkey authenticode.key -in authenticode.crt -passout $PASSWORD -passin $PASSWORD
/usr/bin/openssl pkcs12 -in authenticode.pfx -nocerts -nodes -out key.pem -password $PASSWORD
/usr/bin/openssl rsa -in key.pem -outform PVK -pvk-strong -out authenticode.pvk -passout $PASSWORD
/usr/bin/openssl pkcs12 -in authenticode.pfx -nokeys -nodes -out cert.pem -passin $PASSWORD
/usr/bin/openssl crl2pkcs7 -nocrl -certfile cert.pem -outform DER -out authenticode.spc
