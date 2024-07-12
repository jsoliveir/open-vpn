#!/bin/bash
set -e && cd /app/ssl

cat info | envsubst > info.root

if [ ! -f $VPN_SSL_CA_KEY ]; then
    echo "Generating CA private key..."
    # Generate CA key
    certtool \
        --outfile $VPN_SSL_CA_KEY \
        --generate-privkey \
        --no-text
fi

if [ ! -f $VPN_SSL_CA_CERT ]; then
    echo "Generating CA certificate..."
    # Generate CA certificate
    certtool \
        --load-privkey $VPN_SSL_CA_KEY \
        --outfile $VPN_SSL_CA_CERT \
        --generate-self-signed \
        --template info.root
fi

rm info.root