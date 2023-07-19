import { config } from 'dotenv'; config(); 
import { authenticator } from 'otplib'
import { base32 } from 'rfc4648'
import crypto from 'crypto';

const vpnProfileName = process.env.VPN_PROFILE_NAME || 'VPN'
const hmacSecret = process.env.VPN_AUTH_OTP_SECRET

export default class OTP {

  static ENABLED = true
  
  static getSecret(uid) {
    if(!uid) throw "uid cannot be empty"
    const hmac = crypto.createHmac('SHA512', hmacSecret)
    const secret = hmac.update(uid).digest('base32').substring(0,32)
    const encoded =  base32.stringify(secret)
    return encoded
  }

  static getURI ({uid,digits=6,window=0}){
    const otpSecret = OTP.getSecret(uid)
    const issuer = `${vpnProfileName} (v${new Date().toJSON().split('T')[0].replace(/[^0-9]/g, "")})`
    authenticator.options = {window,digits}
    return authenticator.keyuri(uid, issuer, otpSecret)
  }

  static authorized({uid,otp,digits=6,window=0}) {
    authenticator.options = {window,digits}
    return authenticator.check(otp,OTP.getSecret(uid))
  }

  static get({uid,digits=6,window=0}) {
    authenticator.options = {window,digits}
    return authenticator.generate(OTP.getSecret(uid))
  }

}
