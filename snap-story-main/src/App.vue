<template lang="pug">
#app
  NavBar
  router-view
</template>

<script>
import NavBar from './components/NavBar.vue';

export default {
  name: 'App',
  components: {
    NavBar
  }
};
</script>

<style lang="stylus" src="./assets/styles/main.styl" />


