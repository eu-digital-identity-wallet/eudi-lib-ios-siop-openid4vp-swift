config_content="[ req ]
req_extensions = v3_req

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = example.com
DNS.2 = subdomain.example.com
DNS.3 = client_identifer.example.com
IP.1 = 192.168.1.1
URI.1 = https://www.example.com
"

echo "$config_content" > openssl.cnf

openssl genpkey -algorithm RSA -out private-key.pem
openssl req -new -key private-key.pem -out csr.pem -subj "/CN=example.com"
openssl x509 -req -in csr.pem -signkey private-key.pem -out certificate.pem -extfile openssl.cnf -extensions v3_req -days 365
openssl x509 -in certificate.pem -text -noout
cat certificate.pem | sed -e '/-----BEGIN CERTIFICATE-----/d' -e '/-----END CERTIFICATE-----/d' | tr -d '\n\r'

rm openssl.cnf
rm private-key.pem
rm csr.pem
rm certificate.pem