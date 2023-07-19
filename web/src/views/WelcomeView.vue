<script setup>
import OtpQrCode from '@/components/OtpQrCode.vue'
import WelcomeItem from '@/components/WelcomeItem.vue'
import ToolingIcon from '@/components/icons/IconTooling.vue'
import EcosystemIcon from '@/components/icons/IconEcosystem.vue'
import DocumentationIcon from '@/components/icons/IconDocumentation.vue'
import SupportIcon from '@/components/icons/IconSupport.vue'
import { useStore } from 'vuex'
import { ref } from 'vue'
const store = useStore()
const state = ref('')
const error = ref('')
const profileAPI = fetch(store.state.session.profileUrl, {
  method: 'GET',
  headers: {
    authorization: `Bearer ${store.state.session.token}`
  }
})
profileAPI.then(async (response)=>{
  const data = await response.json()
  const host = window.location.host.replace(/^localhost/i, '127.0.0.1')
  state.value = {}
  state.value.downloadUrl = `https://${host}${data.downloadProfileUrl}`
  state.value.importUrl = `openvpn://import-profile/${state.value.downloadUrl}`
  state.value.otpUri = data.otpUri
  state.value.user = data.user
}).catch(e=>error.value = `You're not authorized to download the VPN Profile`)
</script>
<template>

  <main>
    <header>
      <h1 style="text-align: center">Open VPN Profile</h1>
      <h5 style="text-align: center">{{ state.user }}</h5>
    </header>
    <body>
      <div class="error" v-if="error" :key="error">{{ error }}</div>
      <WelcomeItem>
        <template #icon>
          <ToolingIcon />
        </template>
        <template #heading>Install OpenVPN Client</template>
        <ul>
          <li><a target="_blank" href="https://openvpn.net/client-connect-vpn-for-windows/">Windows</a></li>
          <li><a target="_blank" href="https://openvpn.net/client-connect-vpn-for-mac-os/">MacOS</a></li>
          <li><a target="_blank"
              href="https://play.google.com/store/apps/details?id=net.openvpn.openvpn&pli=1">Android</a></li>
          <li><a target="_blank" href="https://apps.apple.com/us/app/openvpn-connect-openvpn-app/id590379981">iOS</a></li>
        </ul>
      </WelcomeItem>
      <WelcomeItem>
        <template #icon>
          <SupportIcon />
        </template>
        <template #heading>Install Microsoft Authenticator</template>
        <p><i style="font-size:80%;">If you prefer any other authenticator app go for it</i></p>
        <ul>
          <li><a target="_blank"
              href="https://play.google.com/store/apps/details?id=com.azure.authenticator&hl=pt_PT&gl=US">Download for
              Android</a></li>
          <li><a target="_blank" href="https://apps.apple.com/us/app/microsoft-authenticator/id983156458">Download for
              iOS</a></li>
        </ul>
      </WelcomeItem>
      <WelcomeItem v-if="state.otpUri">
        <template #icon>
          <EcosystemIcon />
        </template>
        <template #heading>Scan the QR code</template>
        <p><i style="font-size:80%;color:darkgoldenrod;">If you're on the mobile phone, tap on it</i></p>
        <OtpQrCode size="256" :data="state.otpUri" :key="state.otpUri" />
      </WelcomeItem>
      <WelcomeItem v-if="state.importUrl">
        <template #icon>
          <DocumentationIcon />
        </template>
        <template #heading>Import the OpenVPN profile</template>
        <p>
          <a target="_blank" :href="state.importUrl" class="button" >Click to import</a>
          <a target="_blank" :href="state.downloadUrl" > or download profile</a>
        </p>
        <br />
        <ol>
          <li><i style="font-size:80%;">Username: your <b>email</b> address</i></li>
          <li><i style="font-size:80%;">Password: your email <b>password</b></i></li>
          <li><i style="font-size:80%;">OTP: when promted get it from the <b>authenticator</b></i></li>
          <li><i style="font-size:80%;">Hint: You can save the password in the app settings</i></li>
        </ol>
       
      
      </WelcomeItem>
    </body>
    <br />
    <br />
  </main>
</template>
<style scoped>
header {
  display: flexbox;
  place-items: center;
  padding-right: calc(var(--section-gap) / 2);
}

.logo {
  display: block;
  margin: 0 auto 2rem;
}
</style>
