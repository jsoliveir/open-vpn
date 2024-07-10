#!/bin/python3
import http.client
import os, sys
import json

target_org = 'MyOrganization'
username =  os.environ['username']
password = os.environ['password']

def user_in_org(access_token, target_org):
    headers = {}
    headers['Authorization'] = f'Bearer {access_token}'
    headers['User-Agent'] = f'VPN Client'
    conn = http.client.HTTPSConnection("api.github.com")
    conn.request("GET", "/user/orgs", headers=headers)
    response = conn.getresponse()
    if response.status == 200:
        data = response.read()
        orgs = json.loads(data)
        print(orgs)
        return any(org['login'] == target_org for org in orgs)
    else:
        print(response,response.read())

if user_in_org(password, target_org):
    sys.exit(0)

# unauthorized
print(f'{username} was not authorized')
sys.exit(1)
