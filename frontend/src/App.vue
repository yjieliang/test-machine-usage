<template>
  <div id="app">
    <MachineUsage
      v-if="bkExtData"
      :bkExtData="bkExtData"
    />
  </div>
</template>

<script>
import MachineUsage from "./components/MachineUsage.vue"

export default {
    name: "App",
    components: {
        MachineUsage
    },
    data() {
        return {
            bkExtData: null
        }
    },
    mounted() {
        window.addEventListener("data:syncCustomData", this.onReceiveData)
    },
    beforeDestroy() {
        window.removeEventListener("data:syncCustomData", this.onReceiveData)
    },
    methods: {
        onReceiveData(e) {
            this.bkExtData = e.detail || {}
            console.log("get this.bkExtData", this.bkExtData)
        }
    }
}
</script>

<style>
html, body {
  height: 100%;
}
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  height: 100%;
}
</style>
