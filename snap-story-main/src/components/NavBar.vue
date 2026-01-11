<template lang="pug">
header#main-header(:class="{ 'only-logo': !details }")
  nav
    .container
      .flex.align-center
        .column
          h1.logo
            router-link(to="/home") SnapStory
        //– muestra el formulario de búsqueda solo si details es true
        form(v-if="details")
          .search-box
            i.las.la-search
            input(type="text" placeholder="Buscar")
        .column(v-if="details")
          ul.user-actions(v-if="logged")
            li
              router-link(to="/upload")
                i.las.la-plus-circle
            li
              a(href="#" @click.prevent="goToProfile")
                i.las.la-user-circle
            li
              router-link(to="/chat")
                i.las.la-comment
            li
              a(href="#" @click="logout")
                i.las.la-sign-out-alt
          router-link(tag="button" to="/" v-if="!logged") Publicar
</template>

<script>
export default {
  name: 'NavBar',
  data() {
    return {
      details: true,
      logged: false
    };
  },
  created() {
    this.updateState(this.$route);
  },
  watch: {
    '$route'(to) {
      this.updateState(to);
    }
  },
  methods: {
    updateState(route) {
      // oculta detalles si estamos en /, /login o /register
      const hiddenOn = ['/', '/login', '/register'];
      this.details = !hiddenOn.includes(route.path);
      this.logged = !!localStorage.getItem('token');
    },
    logout() {
      localStorage.removeItem('token');
      localStorage.removeItem('username');
      this.logged = false;
      this.$router.push({ name: 'Login' });
    },
    goToProfile() {
      const id = localStorage.getItem('userId');
      if (id) {
        this.$router.push(`/profile/${id}`);
      } else {
        alert('No se encontró el ID del usuario.');
      }
    }
  }
};
</script>

<style lang="stylus" src="../assets/styles/main.styl" />
