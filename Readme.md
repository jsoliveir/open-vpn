# OpenVPN

A simple OpenVPN server that works

# How it works

It is a simple setup built on top of OpenVPN binaries with a couple more features to make the VPN experience greater.

What comes with the package:

* OpenVPN Server
* Authententication via custom scripts

Create an authentication script and put in in the `auth/` folder
Then, invoke it from the main `authentication.sh`

# SSL Certificates

By default the server will generate self-signed certificates and a root ca.
You can set the certificates data by editing the `ssl/info` file.
Alternatively, you can bring your own server and client certificates and keys _(for now only one client certificate is supported)_

## Configuration variables (with default values):

```bash

VPN_PROFILE_NAME="VPN"
# The default profile name that should be applied when the client imports the .ovpn

VPN_CLIENT_PROFILE=/app/profile.ovpn
# The default path of the generated client profile (at startup)

VPN_CLIENT_SSL_CERT=/app/ssl/client.crt
# The default client certificate

VPN_CLIENT_SSL_KEY=/app/ssl/client.key
# The default client certificate key

VPN_SERVER_SSL_CERT=/app/ssl/server.crt
# The default server certificate

VPN_SERVER_SSL_KEY=/app/ssl/server.key
# The default server certificate key

VPN_SERVER_SSL_CA=/app/ssl/ca.crt
# The default client/server root ca

VPN_NETWORK_MASK=255.255.255.0
# VPN network mask

VPN_NETWORK_ADDR=10.0.0.0
# VPN network address

VPN_SERVER_PORT=1194
# Server listening port

VPN_CLIENT_PROFILE_NAME=VPN
# Default client profile display name

VPN_CLIENT_OPTIONS=
# Extra Options to add to the client's openvpn profile

VPN_SERVER_OPTIONS=
# Extra Options to add to the servers's openvpn profile
# Use this variable to push routes to the clients or to apply extra configurations
# Eg:
#  VPN_EXTRA_SERVER_OPTIONS="management localhost 7505"
# or:
# VPN_EXTRA_SERVER_OPTIONS="
#  push "route 168.63.129.16"
#  push "route 10.0.0.0 255.0.0.0"
#  push "dhcp-option DNS 168.63.129.16"
#  push "dhcp-option WINS 168.63.129.16"
#  push "dhcp-option domain example.com"
#  push "dhcp-option domain windows.net"'    
#  "

```

# Enabling the VPN management console

```bash
  VPN_EXTRA_SERVER_OPTIONS="management localhost 7505"
```

# Example of how to spin up the server

Docker
```yaml
services:
  vpn:
    privileged: true
    user: root
    image: ghcr.io/jsoliveir/openvpn
    ports:
      - 1194:1194/udp
      - 7505:7505/tcp
    volumes:
      # generated client profile
      - ./data/profile:/app/client
      # custom authentication
      - ./auth:/app/auth
    environment:
      # Optional Variables
      VPN_CLIENT_PROFILE: /app/client/profile.ovpn
      VPN_CLIENT_SSL_CERT: /app/ssl/client.crt
      VPN_CLIENT_SSL_KEY: /app/ssl/client.key
      VPN_SERVER_SSL_CERT: /app/ssl/server.crt
      VPN_SERVER_SSL_KEY: /app/ssl/server.key
      VPN_SERVER_SSL_CA: /app/ssl/ca.crt
      # Not mandatory but useful 
      VPN_NETWORK_MASK: 255.255.255.0
      VPN_NETWORK_ADDR: 10.0.0.0
      VPN_SERVER_PORT: 1194
      VPN_CLIENT_PROFILE_NAME: VPN
      VPN_SERVER_OPTIONS: |
        management localhost 7505
        push "route 168.63.129.16"
        push "route 10.0.0.0 255.0.0.0"
        push "dhcp-option DNS 168.63.129.16"
        push "dhcp-option WINS 168.63.129.16"
        push "dhcp-option domain example.com"
        push "dhcp-option domain windows.net"
```