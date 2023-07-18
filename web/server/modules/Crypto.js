import crypto from 'crypto';
import { config } from 'dotenv';
import { cursorTo } from 'readline';
config({path: 'server/.env'});

const algorithm = 'aes-256-cbc'; 

if(!process.env.VPN_WEB_ENCRYPTION_KEY)
  console.warn(
    "VPN_WEB_ENCRYPTION_KEY is not defined",
    "a random key is going to be generated...")

const key = process.env.VPN_WEB_ENCRYPTION_KEY || crypto.randomUUID();

const keyBytes = Buffer.from(btoa(key), 'base64').subarray(0,32)

const ivBytes = Buffer.from(btoa(key), 'base64').subarray(0,16)


export default class Crypto {
 
  static encrypt(string){
    const cipher = crypto.createCipheriv(algorithm, keyBytes, ivBytes);  
    const encrypted = Buffer.concat([cipher.update(string), cipher.final()])
    return encrypted.toString('base64')
  }
  
  static decrypt(string){
    const decipher = crypto.createDecipheriv(algorithm, keyBytes,ivBytes);
    const decrypted = Buffer.concat([decipher.update(Buffer.from(string, 'base64')), decipher.final()])
    return decrypted.toString()
  }
}
