#!/usr/local/bin/node
const { authenticator } = require('otplib')
const { base32 } = require('rfc4648')
const process = require('process')
const crypto = require('crypto')

const hmacSecret = process.env.VPN_AUTH_OTP_SECRET
const uid        = process.env.username
let otp          = process.env.password

if (!otp)
  process.exit(1)

const hmac = crypto.createHmac('SHA512', hmacSecret)
const secret = hmac.update(uid).digest('base32').substring(0,32)
const encoded =  base32.stringify(secret)

const validOtp = authenticator.check(otp, encoded)
if (validOtp) {
  process.exit(0)
}
else {
  console.log("❌ invalid otp for user ", uid)
  process.exit(1)
}
