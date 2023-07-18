#!/bin/bash -eE
set -eE

original_password=$password 

if [[ $password =~ ^.+:[A-Za-z0-9+/=]+:[A-Za-z0-9+/=]+$ ]]; then
  if [[ ! -z $VPN_AUTH_AZURE_CLIENT_ID ]]; then
    echo "checking azure credentials for the user $username ..."
    export password=$(echo $original_password | cut -d ':' -f2 | base64 -d )
    /app/vpn/auth/azure/main.sh; unauth=$(($unauth+$?))
  fi

  if [[ ! -z $VPN_AUTH_OTP_SECRET ]]; then
    echo "checking OTP authentication for the  user $username ..."
    export password=$(echo $original_password | cut -d ':' -f3 | base64 -d )
    /app/vpn/auth/otp/main.js; unauth=$(($unauth+$?))
  fi

else
  echo "Authentication password could not be parsed"
  unauth=1
fi

exit ${unauth:-1}