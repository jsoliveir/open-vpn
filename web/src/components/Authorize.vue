<script setup>
import jwtDecode from 'jwt-decode'
import { useStore } from 'vuex';
import { ref } from 'vue'
import router from '../router';

const store = useStore();

const apiBaseUrl = `${window.location.protocol}//${window.location.host}`

var session = ref() 

session.value = {
  apiBaseUrl: apiBaseUrl,
  isLoading : true
}

async function getOptions(){
  const options = await fetch(apiBaseUrl, {
    method: 'OPTIONS'
  })
  return await options.json()
}

setTimeout(async function () {  
  try{
    const hashParams = new URLSearchParams(window.location.hash.slice(1));
    const options = await getOptions()
    session.value = options
    if(options.oidc){
      if(!hashParams.has(options.oidc.tokenParam)){
        localStorage.setItem('redirect', window.location.href);
        window.location.assign(options.oidc.redirectUrl)
        return;
      }else{
        session.value.token = hashParams.get(options.oidc.tokenParam)
      }
    }

    store.commit('session',session.value)

    const resumeLocation = localStorage.getItem('redirect')
    localStorage.removeItem('redirect')
    if (resumeLocation && resumeLocation != window.location.href) {
      router.push(resumeLocation.split(window.location.origin)[1]); 
    }
  }catch(e){
    console.error(e)
    session.value.error = e
  } finally{
    session.value.isLoading = false 
  }
},500)
</script>

<template>
  <div v-if="session.isLoading" class="container" >
    <br/>
    <p>Loading ...</p>
    <p>{{ session.error }}</p>
  </div>
  <slot v-if="!session.isLoading"></slot>
</template>