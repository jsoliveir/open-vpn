# OpenVPN Server


## Configuration variables (with default values):

```bash

VPN_PROFILE_NAME="VPN"
# The default profile name that should applied when the client imports the .ovpn

VPN_CLIENT_PROFILE=/app/vpn/profile.ovpn
# Where should the client profile be created

VPN_NETWORK_ADDR="10.0.0.0"
# VPN Network address prefix

VPN_NETWORK_MASK="255.255.255.0"
# VPN Network mask

VPN_GATEWAY_HOST="127.0.0.1"
# The public address of the gateway (to be used by the clients to connect)

VPN_GATEWAY_PORT="1194"
# Remote Gateway port (udp)

VPN_GATEWAY_SSL_CERT="/app/ssl/server.crt"
# A Certificate for securing the communication

VPN_GATEWAY_SSL_KEY="/app/ssl/server.key"
# A Certificate Key for securing the communication

VPN_GATEWAY_SSL_CA="/app/ssl/ca.crt"
# A ROOT CA for ensure the right clients

VPN_GATEWAY_SSL_PFX=
# Export certificates and keys from a PFX into the paths given by the vars VPN_GATEWAY_SSL_*

VPN_EXTRA_CLIENT_OPTIONS=
# Extra Options to add to the client's openvpn profile

VPN_EXTRA_SERVER_OPTIONS=
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

VPN_GATEWAY_SSL_PFX=
# Give it a PFX and it will be exported to PEM files

```

# Enable Azure AD Password authentication (Resource Owner Password)

```bash
VPN_AUTH_AZURE_TENANT_ID=
# Azure Tenant Id or domain name
#If not set azure ad authentication will not be enabled

VPN_AUTH_AZURE_CLIENT_ID=
# Azure App Id
#If not set azure ad authentication will not be enabled

VPN_AUTH_AZURE_CLIENT_SECRET=
# Azure App secret
```

# Enable One-Time Password Auth

```bash
VPN_AUTH_OTP_SECRET="<random>"
# Each user will have and different base on the username
# This secret will be used as a seed for generating OTPs 
# If not set a random value will be generated
# Secret + Username == same OTP 

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
    image: ghcr.io/jsoliveir/open-vpn-server:v1.0
    user: root
    ports:
      - 1194:1194/udp
      - 443:443/tcp
      - 80:80/tcp
    environment:
      - VPN_AUTH_AZURE_TENANT_ID=<azure-custom-domain-or-tenant-id>
      - VPN_AUTH_AZURE_CLIENT_SECRET=<azure-client-secret>
      - VPN_AUTH_AZURE_CLIENT_ID=<azure-client-id>
      - VPN_AUTH_OTP_SECRET=<otp-secret>
      - VPN_NETWORK_MASK=255.255.255.0
      - VPN_GATEWAY_HOST=127.0.0.1
      - VPN_NETWORK_ADDR=10.0.0.0
      - VPN_GATEWAY_PORT=1194
      - VPN_PROFILE_NAME=VPN
      - VPN_EXTRA_SERVER_OPTIONS='
          push "route 168.63.129.16"
          push "route 10.0.0.0 255.0.0.0"
          push "dhcp-option DNS 168.63.129.16"
          push "dhcp-option WINS 168.63.129.16"
          push "dhcp-option domain example.com"
          push "dhcp-option domain windows.net"'      
      - VPN_GATEWAY_SSL_PFX=/app/ssl/server.pfx
    volumes:
      - ./certificate.pfx:/app/ssl/server.pfx
```