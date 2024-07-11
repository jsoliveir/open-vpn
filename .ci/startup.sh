#!/bin/bash
set -e

if [ ! -f  $VPN_SSL_DH_KEY ];
  then ssl/new-dh-key.sh
fi

if [ ! -f  $VPN_SSL_SERVER_CA ];
  then ssl/new-root-ca.sh
fi

if [ ! -f $VPN_SSL_SERVER_KEY ];
  then ssl/new-server-cert.sh
fi

if [ ! -f $VPN_SSL_CLIENT_KEY ];
  then ssl/new-client-cert.sh
fi

export __VPN_SSL_CLIENT_CERT__=$(cat $VPN_SSL_CLIENT_CERT)
export __VPN_SSL_CLIENT_KEY__=$(cat $VPN_SSL_CLIENT_KEY)
export __VPN_SSL_SERVER_CA__=$(cat $VPN_SSL_SERVER_CA)

chmod +x /app -R

# Generate an OpenVPN server profile
cat /app/server.conf | envsubst > server.tmp \
  && mv server.tmp /app/server.conf

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
