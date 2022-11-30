import Vue from 'vue'
import App from './App.vue'
import bkMagic from '@tencent/bk-magic-vue'
import '@tencent/bk-magic-vue/dist/bk-magic-vue.min.css'

Vue.use(bkMagic)
Vue.config.productionTip = false



new Vue({
  render: h => h(App),
}).$mount('#app')
