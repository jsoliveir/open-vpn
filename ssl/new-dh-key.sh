#!/bin/bash
set -e && cd /app/ssl

echo "Generating diffie hellman key ..."

openssl dhparam \
    -out $VPN_SSL_DH_KEY 2048
