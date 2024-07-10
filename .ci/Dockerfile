# Install environment
FROM ubuntu as ovpn   
  WORKDIR /app/ssl
    RUN apt update && apt install -y openvpn iptables gettext curl openssl gnutls-bin jq python3  
    RUN openssl dhparam -out dh.pem 2048
    RUN mkdir -p certificates && cd certificates
    COPY ssl/info .
    # Generate root CA key
    RUN certtool \
        --generate-privkey \
        --outfile ca.key \
        --no-text 
    # Generate root CA certificate
    RUN certtool \
        --outfile ca.crt \
        --generate-self-signed \
        --load-privkey ca.key \
        --template info
    # Generate server private key
    RUN certtool \
        --generate-privkey \
        --outfile server.key \
        --no-text
    # Generate server private certificate
    RUN certtool \
        --outfile server.crt \
        --load-privkey server.key \
        --load-ca-certificate ca.crt \
        --load-ca-privkey ca.key \
        --generate-certificate \
        --template info
    # Generate client private key
    RUN certtool \
        --generate-privkey \
        --outfile client.key \
        --no-text
    # Generate client certificate
    RUN certtool \
        --outfile client.crt \
        --load-privkey client.key \
        --load-ca-certificate ca.crt \
        --load-ca-privkey ca.key \
        --generate-certificate \
        --template info

FROM ovpn as config 
  WORKDIR /app/www
  WORKDIR /app  
    COPY .ci/startup* startup
    COPY auth/* auth/
    COPY profiles/* .
    ENV VPN_CLIENT_SSL_CERT=/app/ssl/client.crt
    ENV VPN_CLIENT_SSL_KEY=/app/ssl/client.key
    ENV VPN_SERVER_SSL_CERT=/app/ssl/server.crt
    ENV VPN_SERVER_SSL_KEY=/app/ssl/server.key
    ENV VPN_SERVER_SSL_CA=/app/ssl/ca.crt
    ENV VPN_CLIENT_PROFILE=/app/profile.ovpn
    ENV VPN_NETWORK_ADDR=172.16.0.0
    ENV VPN_NETWORK_MASK=255.255.255.0
    ENV VPN_NETWORK_ADDR=10.0.0.0
    ENV VPN_SERVER_HOST=127.0.0.1
    ENV VPN_SERVER_PORT=1194
    ENV VPN_PROFILE_NAME=VPN
    ENV VPN_CLIENT_OPTIONS=
    ENV VPN_SERVER_OPTIONS=
    ENV VPN_SERVER_SSL_PFX=
    RUN chmod -R +x /app
    CMD ["/app/startup"]
  
  
  