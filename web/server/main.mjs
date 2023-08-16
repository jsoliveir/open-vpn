import RequestHandler from './modules/RequestHandler.js'
import OpenVPN from './modules/OpenVpn.js'
import AzureAD from './modules/AzureAD.js'
import Crypto from './modules/Crypto.js'
import OTP from './modules/OTP.js'
import rateLimit from "express-rate-limit"
import express from 'express'
import dotenv from 'dotenv'
import https from 'https'
import http from 'http'
import fs from 'fs'

dotenv.config({ path: 'server/.env' });

const port_http = process.env.PORT_HTTP || 80
const port_https = process.env.PORT_HTTPS || 443
const ssl_cert = process.env.VPN_GATEWAY_SSL_CERT || "server/cert.key"
const ssl_key = process.env.VPN_GATEWAY_SSL_KEY || "server/cert.crt"
const app = express()

app.use(rateLimit({
  message: "Too many request from this IP",
  windowMs: 60000,
  max: 600
}));

app.use(express.static("public"))

app.options("/", async (req, res) => {
  new RequestHandler(req, res).invoke(function (log) {
    const protocol = req.headers['x-forwarded-proto'] || req.protocol
    const options = {
      profileName: OpenVPN.profileName,
      authentication: 'required',
      profileUrl: '/profile',
    }
    if (AzureAD.enabled) {
      options.oidc = AzureAD.getAzureOIDCRedirectUrl(
        `${protocol}://${req.headers.host}${req.path}`
      )
    }
    return options
  })
})

app.get('/profile', async (req, res) => {
  new RequestHandler(req, res).invoke(async function (log) {
    if (!await AzureAD.authorize(req.headers))
      throw 401

    const token = AzureAD.parseToken(req.headers)
    const session = AzureAD.getTokenData(token)
    const { upn, email, oid, tid } = session
    const apiToken = Crypto.encrypt(JSON.stringify({ user:upn || email, id:oid, tenant:tid }))
    return {
      user: upn,
      otpUri: OTP.getURI({ uid: session.upn || session.email }),
      downloadProfileUrl: '/profile/ovpn?c=' + encodeURIComponent(apiToken)
    }
  })
})

app.get('/profile/ovpn', async (req, res) => {
  new RequestHandler(req, res).invoke(async function (log) {
    const session = JSON.parse(Crypto.decrypt(decodeURIComponent(req.query.c)))
    const user = await AzureAD.getUser(session.user);
    const token = await AzureAD.getServerToken()
    const server = AzureAD.getTokenData(token)
  
    if (session.tenant != server.tid)
      throw 403
  
    if (session.id != user.id)
      throw 401

    res.set('Content-Type', 'application/x-openvpn-profile');
    res.set('Content-Disposition', `attachment; filename=profile.ovpn`);
    return OpenVPN.getProfile()
  })
})

var httpServer = http.createServer(app);
console.log(`Listening on the port ${port_http}...`);
httpServer.listen(port_http);

if (!fs.existsSync(ssl_cert)) {
  console.log("SSL Certificates not found...")
  console.log("Generating a self-signed certificates ...");
  const { execSync } = await import('child_process');
  execSync([
    "openssl req -config server/ssl.cnf",
    "-newkey rsa:2048", "-new -nodes -x509 -days 3650",
    `-keyout ${ssl_key} `,
    `-out  ${ssl_cert} 2>&1`
  ].join(" "));
}

var privateKey = fs.readFileSync(ssl_key);
var certificate = fs.readFileSync(ssl_cert);
var options = {
  key: privateKey,
  cert: certificate,
  requestCert: false,
  rejectUnauthorized: false
};
var httpsServer = https.createServer(options, app);
console.log(`Listening on the port ${port_https}...`);
httpsServer.listen(port_https);

process.on('uncaughtException', function (err, origin) {
  console.error(err)
})

if (process.env.NODE_ENV != "production") {
  import('vite').then(async ({ createServer }) => {
    app.use(
      (await createServer({
        server: { middlewareMode: true },
        appType: 'custom'
      })).middlewares
    )
  })
}
