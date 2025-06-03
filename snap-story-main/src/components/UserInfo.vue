<template lang="pug">
main.profile
  header.profile-header
    .cover-photo
    .avatar-container
      h1 {{ username }}
      p.bio Esta es tu biografía. Cuéntanos algo sobre ti.

  section.profile-stats
    .stat
      span.count {{ posts.length }}
      span.label Publicaciones
    .stat
      span.count {{ seguidores.length }}
      span.label Seguidores
    .stat
      span.count {{ seguidos.length }}
      span.label Siguiendo
</template>

<script>
export default {
  name: 'Profile',

  data() {
    return {
      username: '',
      myPosts: [],
      seguidores: [],
      seguidos: []
    };
  },

  computed: {
    posts() {
      // Puedes ajustar si deseas mostrar guardados o compartidos
      return this.myPosts;
    }
  },

  mounted() {
    this.username = localStorage.getItem('username') || 'Invitado';
    this.fetchMyPosts();
    this.getSeguidores();
    this.getSeguidos();
  },

  methods: {
    async fetchMyPosts() {
      try {
        const token = localStorage.getItem('token');
        const res = await fetch('http://localhost:4000/api/myposts', {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) {
          this.myPosts = await res.json();
        }
      } catch (e) {
        console.error('Error al obtener publicaciones:', e);
      }
    },

    async getSeguidores() {
      try {
        const token = localStorage.getItem('token');
        const res = await fetch('http://localhost:4000/api/seguidores', {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) {
          this.seguidores = await res.json();
        }
      } catch (e) {
        console.error('Error al obtener seguidores:', e);
      }
    },

    async getSeguidos() {
      try {
        const token = localStorage.getItem('token');
        const res = await fetch('http://localhost:4000/api/seguidos', {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) {
          this.seguidos = await res.json();
        }
      } catch (e) {
        console.error('Error al obtener seguidos:', e);
      }
    }
  }
};
</script>

<style scoped>
.profile {
  margin-top: 150px;
  padding: 20px;
}
.profile-header {
  position: relative;
  text-align: center;
  margin-bottom: 20px;
}
.cover-photo {
  height: 150px;
  background: #ccc;
}
.avatar-container {
  position: relative;
  margin-top: -75px;
}
.bio {
  font-style: italic;
  color: #666;
}
.profile-stats {
  display: flex;
  justify-content: space-around;
  margin: 20px 0;
}
.stat {
  text-align: center;
}
.stat .count {
  font-size: 1.2em;
  font-weight: bold;
}
</style>
