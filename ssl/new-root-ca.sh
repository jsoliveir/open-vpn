#!/bin/bash
set -e && cd /app/ssl

echo "Generating rootca certificate..."

cat info | envsubst > info.root

# Generate client key
certtool \
    --outfile $VPN_SSL_CA_KEY \
    --generate-privkey \
    --no-text

certtool \
    --load-privkey $VPN_SSL_CA_KEY \
    --outfile $VPN_SSL_CA_CERT \
    --generate-self-signed \
    --template info.root

rm info.root