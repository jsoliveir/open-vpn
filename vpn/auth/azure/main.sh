#!/bin/bash
set -e

response=$(
  curl "https://login.microsoftonline.com/$VPN_AUTH_AZURE_TENANT_ID/oauth2/v2.0/token" \
    --header "Content-Type: application/x-www-form-urlencoded" \
    --request post \
    --show-error \
    --silent \
    --data "scope=user.read%20openid%20profile%20offline_access
      &client_id=$VPN_AUTH_AZURE_CLIENT_ID
      &grant_type=password
      &username=$username
      &password=$password"
)

authenticated=$(
  echo $response | jq \
    'isempty(.error_codes) or first(.error_codes[]) == 50076'
)

if [[ $authenticated == 'true' ]]; 
  then exit 0;
fi

echo "❌ Azure auth failed for user $username" \
  && echo $response \
  && exit 1
