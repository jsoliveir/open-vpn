#!/bin/bash -eE
set -eE

if [[ ! -z $VPN_AUTH_OTP_SECRET ]]; then
  echo "checking OTP authentication for the  user $username ..."
  export password=$(echo $original_password | cut -d ':' -f3 | base64 -d )
  /app/vpn/auth/otp/main.js; auth=$(($auth+$?))
fi

if [[ $auth != 0 ]]; then
  echo "Authentication failed."
fi

exit ${unauth:-1}