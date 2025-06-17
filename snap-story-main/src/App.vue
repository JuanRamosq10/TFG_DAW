<template lang="pug">
  #app
    header#main-header(:class="{'only-logo': !details}")
      nav
        .container
          div.flex.align-center
            div.column
              h1.logo
                router-link(to="/home") SnapStory
            // Se muestra el formulario de búsqueda solo si 'details' es true
            form(v-if="details")
              div.search-box
                i.las.la-search
                input(type="text" placeholder="Buscar")
            div.column(v-if="details")
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
    router-view
</template>

<script>
export default {
  data() {
    return {
      details: true,
      logged: false,
      userId: null
    };
  },
  created() {
    this.checkRoute(this.$route);
  },
  methods: {
    checkRoute(to) {
      const routes = ['/', '/login', '/register'];
      if (routes.includes(to.path)) {
        this.details = false;
      } else {
        this.details = true;
      }
      // Verifica si hay token en localStorage para determinar si el usuario está logueado
      this.logged = !!localStorage.getItem('token');
    },
    logout() {
      // Elimina token y username del localStorage
      localStorage.removeItem('token');
      localStorage.removeItem('username');
      this.logged = false;
      // Redirige al login
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
  },
  watch: {
    '$route'(to) {
      this.checkRoute(to);
    }
  }
};
</script>

<style lang="stylus" src="./assets/styles/main.styl" />