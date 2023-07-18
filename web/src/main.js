import { createStore } from 'vuex'
import { createApp } from 'vue'
import router from './router'
import App from './App.vue'
import './assets/main.css'

const app = createApp(App)

const store = createStore({
  mutations: {
    session(state,session) {
      state.session = session;
    }
  },
  state: {}
})

app.use(store)

app.use(router)

app.mount('#app')
