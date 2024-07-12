#!/bin/bash
set -e && cd /app/ssl

cat info | envsubst > info.server

if [ ! -f $VPN_SSL_SERVER_KEY ]; then
    echo "Generating server private key..."
    # Generate SERVER key
    certtool \
        --outfile $VPN_SSL_SERVER_KEY \
        --generate-privkey \
        --no-text
fi

if [ ! -f $VPN_SSL_SERVER_CERT ]; then
    echo "Generating server certificate..."
    # Generate SERVER certificate
    certtool \
        --load-ca-certificate $VPN_SSL_CA_CERT \
        --load-ca-privkey $VPN_SSL_CA_KEY \
        --load-privkey $VPN_SSL_SERVER_KEY \
        --outfile $VPN_SSL_SERVER_CERT \
        --generate-certificate \
        --template info.server
fi

rm info.server
