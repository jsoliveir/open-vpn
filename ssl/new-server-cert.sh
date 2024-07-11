#!/bin/bash
set -e && cd /app/ssl

echo "Generating server certificate..."

cat info | envsubst > info.server

# Generate server private key
certtool \
    --outfile $VPN_SSL_SERVER_KEY \
    --generate-privkey \
    --no-text

# Generate server private certificate
certtool \
    --load-ca-certificate $VPN_SSL_CA_CERT \
    --load-ca-privkey $VPN_SSL_CA_KEY \
    --load-privkey $VPN_SSL_SERVER_KEY \
    --outfile $VPN_SSL_SERVER_CERT \
    --generate-certificate \
    --template info.server

rm info.server
