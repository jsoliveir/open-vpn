#!/bin/bash
set -e

export __VPN_CLIENT_SSL_CERT__=$(cat $VPN_CLIENT_SSL_CERT)
export __VPN_CLIENT_SSL_KEY__=$(cat $VPN_CLIENT_SSL_KEY)
export __VPN_SERVER_SSL_CA__=$(cat $VPN_SERVER_SSL_CA)

# Generate an OpenVPN server profile
cat /app/server.conf | envsubst > server.tmp \
  && mv server.tmp /app/server.conf

cat /app/authentication | envsubst > auth.tmp \
  && mv auth.tmp /app/authentication \
  && chmod +x /app/authentication 

cat /app/client.conf | envsubst > client.tmp \
  && mv client.tmp $VPN_CLIENT_PROFILE

# Apply proper network rules
iptables -t nat -A POSTROUTING -j MASQUERADE

ln -s -f  $VPN_CLIENT_PROFILE /app/www/profile

if [ ! -f /app/users.json ];then 
  echo "{}" > /app/users.json 
  chmod 777 users.json
fi

openvpn /app/server.conf
