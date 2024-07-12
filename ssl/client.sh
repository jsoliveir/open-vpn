#!/bin/bash
set -e && cd /app/ssl

cat info | envsubst > info.client

if [ ! -f $VPN_SSL_CLIENT_KEY ]; then
    echo "Generating client private key..."
    # Generate client key
    certtool \
        --outfile $VPN_SSL_CLIENT_KEY \
        --generate-privkey \
        --no-text
fi

if [ ! -f $VPN_SSL_CLIENT_CERT ]; then
    echo "Generating client certificate..."
    # Generate client certificate
    certtool \
        --load-ca-certificate $VPN_SSL_CA_CERT \
        --load-ca-privkey $VPN_SSL_CA_KEY \
        --load-privkey $VPN_SSL_CLIENT_KEY \
        --outfile $VPN_SSL_CLIENT_CERT \
        --generate-certificate \
        --template info.client
fi

rm info.client
