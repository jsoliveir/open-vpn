# Build QRCode Generator
FROM node as frontend
  WORKDIR /src
    COPY web/ .
    RUN npm install 
    RUN npm run build
  WORKDIR /src/dist
    RUN mv src/index.html .
    RUN rm -rf src/

FROM node as backend
  WORKDIR /src
    COPY web/server .
    RUN find -iname .env -delete
    RUN npm install 

FROM node as modules
 WORKDIR /src
    COPY vpn/auth/ .
    RUN chmod +x -R .;
    RUN for module in $(find -iname package.json -mindepth 1 -maxdepth 3 -type f); do \
      npm -C $(dirname $module) install; \
    done

# Generate self-signed certificates
FROM node as ssl
  WORKDIR /app/ssl
    RUN apt update && apt install -y openssl gnutls-bin
    RUN openssl dhparam -out dh.pem 2048
    COPY vpn/ssl/certificate.info .
    RUN certtool --generate-privkey --no-text --outfile ca.key \
      && certtool --outfile ca.crt \
        --template certificate.info \
        --load-privkey ca.key \
        --generate-self-signed;
    RUN certtool --generate-privkey  --no-text --outfile server.key \
      && certtool --outfile server.crt \
        --template certificate.info \
        --load-privkey server.key \
        --load-ca-certificate ca.crt \
        --load-ca-privkey ca.key \
        --generate-certificate;

# # Add support for powershell modules
# FROM ssl as powershell  
#   RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
#   RUN dpkg -i packages-microsoft-prod.deb
#   RUN apt update && apt install powershell
#   RUN rm packages-microsoft-prod.deb
  
# Install environment
FROM ssl as environment  
  RUN apt update && apt install -y \
    openvpn iptables gettext curl openssl jq
  WORKDIR /app/vpn
    COPY vpn/server.conf .
    COPY vpn/client.conf .
  WORKDIR /app/vpn/auth
    COPY --from=modules /src/ .
  WORKDIR /app/web
    COPY --from=frontend /src/dist/ public/
    COPY --from=backend /src/ server/
  WORKDIR /app
    COPY startup.* startup
    RUN chmod +x /app/*
    ENV NODE_ENV=production
    ENV VPN_GATEWAY_SSL_CERT=/app/ssl/server.crt
    ENV VPN_GATEWAY_SSL_KEY=/app/ssl/server.key
    ENV VPN_GATEWAY_SSL_CA=/app/ssl/ca.crt
    ENV VPN_CLIENT_PROFILE=/app/vpn/profile.ovpn
    ENV VPN_NETWORK_ADDR=172.16.0.0
    ENV VPN_NETWORK_MASK=255.255.255.0
    ENV VPN_NETWORK_ADDR=10.0.0.0
    ENV VPN_GATEWAY_HOST=127.0.0.1
    ENV VPN_GATEWAY_PORT=1194
    ENV VPN_PROFILE_NAME=VPN
    ENV VPN_EXTRA_CLIENT_OPTIONS=
    ENV VPN_EXTRA_SERVER_OPTIONS=
    ENV VPN_GATEWAY_SSL_PFX=
    ENV VPN_AUTH_OTP_SECRET=
    CMD ["/app/startup"]
  
  
  