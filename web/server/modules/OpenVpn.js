import { config } from 'dotenv';
config({path: 'server/.env'});
import path from 'path';
import fs from 'fs';

const vpnProfile = (function(){
  let profile = fs.readFileSync(path.join(process.env.VPN_CLIENT_PROFILE),"utf8")
  for(let env in process.env)
    profile = profile.replace(new RegExp(`[$]${env}`,"gi"),process.env[env])
  return profile.replace(/[$].*?\W/ig,"")
})()

export default class OpenVPN {
  static profileName = process.env.VPN_PROFILE_NAME || 'VPN'
  
  static getProfile() {
    return vpnProfile
  }
}
