#!/bin/bash
set -e && cd /app/ssl

if [ ! -f $VPN_SSL_DH_KEY ]; then
    echo "Generating diffie hellman key ..."
    openssl dhparam \
        -out $VPN_SSL_DH_KEY 2048
fi
