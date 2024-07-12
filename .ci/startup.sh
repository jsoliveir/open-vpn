#!/bin/bash
chmod +x /app -R; set -e

# Apply proper network rules
iptables -t nat -A POSTROUTING -j MASQUERADE

# Generate RSA keys certificates
ssl/dh.sh \
  && ssl/ca.sh \
  && ssl/server.sh \
  && ssl/client.sh

export \
  __VPN_SSL_CLIENT_CERT__=$(cat $VPN_SSL_CLIENT_CERT) \
  __VPN_SSL_CLIENT_KEY__=$(cat $VPN_SSL_CLIENT_KEY) \
  __VPN_SSL_SERVER_CA__=$(cat $VPN_SSL_CA_CERT)

# Generate an OpenVPN server profile
cat /app/server.conf | envsubst > server.tmp \
  && mv server.tmp /app/server.conf

# Generate an OpenVPN client profile
cat /app/client.conf | envsubst > client.tmp \
  && mv client.tmp $VPN_CLIENT_PROFILE


openvpn /app/server.conf
