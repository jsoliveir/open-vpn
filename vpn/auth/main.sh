#!/bin/bash -eE
set -eE

if [[ ! -z $VPN_AUTH_OTP_SECRET ]]; then
  echo "checking OTP authentication for the  user $username ..."
  /app/vpn/auth/otp/main.js; auth=$?
fi

if [[ $auth != 0 ]]; then
  echo "Authentication failed."
fi

exit ${auth:-1}