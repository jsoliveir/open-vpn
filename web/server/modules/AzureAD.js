import { DefaultAzureCredential } from "@azure/identity"
import { config } from 'dotenv'; config();

process.env = {
  AZURE_TOKEN_SCOPE: "https://graph.microsoft.com/.default",
  AZURE_CLIENT_SECRET: process.env.VPN_AUTH_AZURE_CLIENT_SECRET,
  AZURE_TENANT_ID: process.env.VPN_AUTH_AZURE_TENANT_ID,
  AZURE_CLIENT_ID: process.env.VPN_AUTH_AZURE_CLIENT_ID,
  ... process.env,
}

const azureCredential = new DefaultAzureCredential()

var __token_cache__ = null

export default class AzureAD {
  static enabled = process.env.AZURE_CLIENT_ID && process.env.AZURE_TENANT_ID

  static getAzureOIDCRedirectUrl(redirectUri) {
    let clientId = process.env.AZURE_CLIENT_ID
    let tenantId = process.env.AZURE_TENANT_ID
    let scope = "openid profile email";
    let responseType = "token";
    let authEndpoint = `https://login.microsoftonline.com/${tenantId}/oauth2/v2.0/authorize`;
    let redirectUrl = `${authEndpoint}?client_id=${clientId}&response_type=${responseType}&redirect_uri=${redirectUri}&scope=${scope}&prompt=select_account`;
    return {
      tokenParam: "access_token",
      tokenUserParam: "upn",
      redirectUrl,
      clientId,
      tenantId,
    }
  }

  static async getServerToken() {
    if(!__token_cache__)
      __token_cache__ = (await azureCredential.getToken(process.env.AZURE_TOKEN_SCOPE)).token

    const token = AzureAD.getTokenData(__token_cache__)
    if(token.exp < (new Date().getTime() / 1000))
      __token_cache__ = (await azureCredential.getToken(process.env.AZURE_TOKEN_SCOPE)).token

    return __token_cache__
  }
  
  static parseToken({ authorization }) {
    return authorization.split(/bearer/i)[1].trim()
  }

  static getTokenData(token) {
    return JSON.parse(atob(token.split('.')[1]))
  }

  static async getSession(authorization) {
    const token = AzureAD.parseToken({authorization})
    return AzureAD.getTokenData(token)
  }

  static async getUser(user) {
    const serverToken = await AzureAD.getServerToken()
    const request = await fetch(`https://graph.microsoft.com/v1.0/users/${user}`, {
      headers: { 'Authorization': `bearer ${serverToken}` }
    })

    const response = await request.json()
    if (request.status != 200){
      console.warn(`https://graph.microsoft.com/v1.0/users/${user}`, "returned",request.status)
      console.error(response.error)
      throw 401
    }
    return response
  }

  static async authorize({ authorization }) {
      const serverToken = await AzureAD.getServerToken()
      const userToken = AzureAD.parseToken({ authorization })
      if (!serverToken || !userToken)
        throw 403

      const userTokenData = AzureAD.getTokenData(userToken)
      const user = await AzureAD.getUser(userTokenData.oid)
      if (!user)
        throw 403
     
      const serverData = AzureAD.getTokenData(serverToken)
      if (serverData.tid == userTokenData.tid)
        return userToken
        
    throw 401
  }
}
