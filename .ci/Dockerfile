# Install environment
FROM ubuntu as ovpn   
  RUN apt update && apt install -y openvpn iptables gettext curl openssl gnutls-bin jq python3 python3-pip unzip wget

FROM ovpn as ssl
  WORKDIR /app/ssl
    COPY ssl/* .
  WORKDIR /app/ssl/keys
    ENV VPN_SSL_ORIGANIZATION_NAME=VPN
    ENV VPN_SSL_ORIGANIZATION_DOMAIN=vpn.net
    ENV VPN_SSL_CLIENT_CERT=/app/ssl/keys/client.crt
    ENV VPN_SSL_CLIENT_KEY=/app/ssl/keys/client.key
    ENV VPN_SSL_SERVER_CERT=/app/ssl/keys/server.crt
    ENV VPN_SSL_SERVER_KEY=/app/ssl/keys/server.key
    ENV VPN_SSL_SERVER_CA=/app/ssl/keys/ca.crt
    ENV VPN_SSL_DH_KEY=/app/ssl/keys/dh.pem

FROM ssl as selenium
  RUN pip install --break-system-packages selenium webdriver-manager  
  RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
  RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
  RUN apt-get -y update && apt-get install -y google-chrome-stable
  WORKDIR /nonexistent
    RUN chmod 777 .  
  WORKDIR /.local
    RUN chmod 777 .
  ENV DISPLAY=:99

FROM selenium as config 
  WORKDIR /app/www
  WORKDIR /app  
  COPY .ci/startup.sh .
  COPY auth/*.* auth/
  COPY profiles/* .
    ENV VPN_AUTH_SCRIPT=/app/auth/microsoft.pt
    ENV VPN_CLIENT_PROFILE=/app/profile.ovpn
    ENV VPN_NETWORK_ADDR=172.16.0.0
    ENV VPN_NETWORK_MASK=255.255.255.0
    ENV VPN_NETWORK_ADDR=10.0.0.0
    ENV VPN_SERVER_HOST=127.0.0.1
    ENV VPN_SERVER_PORT=1194
    ENV VPN_PROFILE_NAME=VPN
    ENV VPN_CLIENT_OPTIONS=
    ENV VPN_SERVER_OPTIONS=
    ENV VPN_SSL_SERVER_PFX=
    CMD ["/app/startup.sh"]
  
  
  