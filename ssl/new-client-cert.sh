#!/bin/bash
set -e && cd /app/ssl

echo "Generating client certificate..."

cat info | envsubst > info.client

# Generate client key
certtool \
    --outfile $VPN_SSL_CLIENT_KEY \
    --generate-privkey \
    --no-text

# Generate client certificate
certtool \
    --load-ca-certificate $VPN_SSL_CA_CERT \
    --load-ca-privkey $VPN_SSL_CA_KEY \
    --load-privkey $VPN_SSL_CLIENT_KEY \
    --outfile $VPN_SSL_CLIENT_CERT \
    --generate-certificate \
    --template info.client

rm info.client
