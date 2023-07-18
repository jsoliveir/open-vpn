#!/bin/bash
set -e

# Apply proper network rules
iptables -t nat -A POSTROUTING -j MASQUERADE

# Generate an OpenVPN server profile
cat /app/vpn/server.conf | envsubst > server.tmp \
  && mv server.tmp /app/vpn/server.conf

# Making sure that env variables are availables when the login script runs
# We also need to make sure that we don't allow multi-line variables in the config file
for var in $(env); do 
  variable=${var/\"/}; variable="${variable/=/=\"}\"";
  if [[ "$variable" =~ ^VPN_.+=\".+\"$ ]]; then
    echo "setenv ${variable/=/ } " >> /app/vpn/server.conf;
    echo "$variable" > /app/web/server/.env
  fi
done

# Export PFX if provided
if [ ! -z $VPN_GATEWAY_SSL_PFX ]; then
  echo "exporting private key $VPN_GATEWAY_SSL_PFX => $VPN_GATEWAY_SSL_KEY"
  openssl pkcs12 \
    -in $VPN_GATEWAY_SSL_PFX \
    -passin "pass:" \
    -nocerts \
    -nodes\
  | openssl pkcs8 -nocrypt -out $VPN_GATEWAY_SSL_KEY

  echo "exporting certificate $VPN_GATEWAY_SSL_PFX => $VPN_GATEWAY_SSL_CERT"
  openssl pkcs12 \
    -in $VPN_GATEWAY_SSL_PFX \
    -clcerts -nokeys  \
    -passin "pass:" \
  | openssl x509 -out $VPN_GATEWAY_SSL_CERT

  echo "exporting ca $VPN_GATEWAY_SSL_PFX => $VPN_GATEWAY_SSL_CA"
  openssl pkcs12 \
    -in $VPN_GATEWAY_SSL_PFX \
    -passin "pass:" \
    -cacerts \
    -nokeys \
    -chain \
    -nodes \
    -out - \
    | awk '/-----BEGIN/{a=1}/-----END/{print;a=0}a' \
    > $VPN_GATEWAY_SSL_CA
fi

# Generate an OpenVPN client profile
export VPN_SSL_ROOT_CA=$(cat $VPN_GATEWAY_SSL_CA)

# Generating a Web Encription Key for session tokens
# This secret must be shared if running multiple instances of the server
export VPN_WEB_ENCRYPTION_KEY=$(cat $VPN_GATEWAY_SSL_KEY | base64 | head -c 32)

# If VPN_AUTH_OTP_SECRET not set generate a random one
if [[ -z $VPN_AUTH_OTP_SECRET ]];
  then 
    echo "warn: VPN_AUTH_OTP_SECRET is not set a random value will be generated"
    export VPN_AUTH_OTP_SECRET=$(cat /dev/random | head -c32 | base64)
fi

cat /app/vpn/client.conf | envsubst > client.tmp \
  && mv client.tmp $VPN_CLIENT_PROFILE

cd /app/web &&  node server/main.mjs &

openvpn /app/vpn/server.conf 

