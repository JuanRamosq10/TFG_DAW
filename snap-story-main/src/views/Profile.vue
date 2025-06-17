<template lang="pug">
main.profile
  header.profile-header
    div.cover-photo
    div.avatar-container
      h1 {{ username }}
      p.bio Esta es tu biografía. Cuéntanos algo sobre ti.
  
  // Botones condicionales
  div.button-wrapper
  div.buttons(v-if="isCurrentUser")
    button.btn-edit Editar Perfil
  div.buttons(v-else)
    button.btn-follow(@click="toggleSeguir") {{ yaSigo ? 'Dejar de seguir' : 'Seguir' }}
    button.btn-message Enviar mensaje



  section.profile-stats
    div.stat
      span.count {{ posts.length }}
      span.label  Publicaciones
    div.stat
      span.count {{ seguidores.length }}
      span.label  Seguidores
    div.stat
      span.count {{ seguidos.length }}
      span.label  Siguiendo

  section.profile-tabs
    button(
      v-for="(title, index) in tabTitles"
      :key="index"
      :class="{ active: currentTab === index }"
      @click="currentTab = index"
    ) {{ title }}

  section.profile-posts
    h2(v-text="tabTitles[currentTab]")
    div.posts-grid
      PostGrid(:posts="currentPosts" :showLike="false")
      
</template>

<script>
import PostGrid from '@/components/PostGrid.vue';

export default {
  name: 'Profile',
  components: { PostGrid },
  data() {
    return {
      username: '',
      currentTab: 0,
      tabTitles: ['Publicaciones', 'Publicaciones guardadas', 'Publicaciones compartidas'],
      myPosts: [],
      savedPosts: [],
      sharedPosts: [],
      seguidores: [],
      seguidos: [],
      yaSigo: false  // 👈 asegúrate que esté aquí
    };
  },
  computed: {
    posts() {
      return this.myPosts;
    },
    currentPosts() {
      if (this.currentTab === 0) return this.myPosts;
      if (this.currentTab === 1) return this.savedPosts;
      if (this.currentTab === 2) return this.sharedPosts;
      return [];
    },
    isCurrentUser() {
    const loggedUserId = localStorage.getItem('userId');
    const profileUserId = this.$route.params.userId;
    return loggedUserId === profileUserId;
    }
  },
  mounted() {
    this.loadProfileData();
  },
  watch: {
    '$route.params.userId'(newUserId, oldUserId) {
      if (newUserId !== oldUserId) {
        this.loadProfileData();
      }
    }
  },
  methods: {
    loadProfileData() {
      this.checkSiYaSigo();
      this.fetchMyPosts();
      this.fetchSavedPosts();
      this.fetchSharedPosts();
      this.getSeguidores();
      this.getSeguidos();
      this.fetchProfileUser();
    },
    async fetchProfileUser() {
      try {
        const token = localStorage.getItem('token');
        const userId = this.$route.params.userId;

        const res = await fetch(`http://localhost:4000/api/users/${userId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });

        if (res.ok) {
          const user = await res.json();
          this.username = user.username;
          this.fullName = user.full_name;
          this.bio = user.bio || ''; // Si agregas biografía
          this.profileImg = user.profile_img;
          this.email = user.email;
        } else {
          console.error('❌ Error al obtener perfil:', await res.text());
        }
      } catch (e) {
        console.error('❌ Error en fetchProfileUser:', e);
      }
    },
    async fetchMyPosts() {
      try {
        const token = localStorage.getItem('token');
        const userId = this.$route.params.userId;
        const res = await fetch(`http://localhost:4000/api/posts/${userId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) this.myPosts = await res.json();
      } catch (e) {
        console.error('Error al obtener publicaciones:', e);
      }
    },
    async fetchSavedPosts() {
      try {
        const token = localStorage.getItem('token');
        const userId = this.$route.params.userId;
        const res = await fetch(`http://localhost:4000/api/savedposts/${userId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) this.savedPosts = await res.json();
      } catch (e) {
        console.error('Error al obtener guardados:', e);
      }
    },
    async fetchSharedPosts() {
      try {
        const token = localStorage.getItem('token');
        const userId = this.$route.params.userId;
        const res = await fetch(`http://localhost:4000/api/sharedposts/${userId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) this.sharedPosts = await res.json();
      } catch (e) {
        console.error('Error al obtener compartidos:', e);
      }
    },
    async getSeguidores() {
      try {
        const token = localStorage.getItem('token');
        const userId = this.$route.params.userId;
        const res = await fetch(`http://localhost:4000/api/seguidores/${userId}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.ok) this.seguidores = await res.json();
      } catch (e) {
        console.error('Error al obtener seguidores:', e);
    }
    },
    async getSeguidos() {
      try {
        const token = localStorage.getItem('token');
        const userId = this.$route.params.userId;
        const res = await fetch(`http://localhost:4000/api/seguidos/${userId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) this.seguidos = await res.json();
        console.log('📌 Seguidores:', this.seguidores);
      } catch (e) {
        console.error('Error al obtener seguidos:', e);
      }
    },
    async checkSiYaSigo() {
      try {
        const token = localStorage.getItem('token');
        const userId = this.$route.params.userId;
        const miId = parseInt(localStorage.getItem('userId'));

        const res = await fetch(`http://localhost:4000/api/seguidores/${userId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });

        if (res.ok) {
          const seguidores = await res.json();
          this.seguidores = seguidores;

          // Busca si el logueado está en la lista de seguidores
          this.yaSigo = seguidores.some(s => s.user_id === miId);
          console.log('¿Ya sigo?', this.yaSigo);
        }
      } catch (e) {
        console.error('Error verificando si ya sigues al usuario:', e);
      }
    },
    async toggleSeguir() {
  const token = localStorage.getItem('token');
  const userId = this.$route.params.userId;
  const miId = localStorage.getItem('userId');

  try {
    const url = `http://localhost:4000/api/seguir/${userId}`;
    const options = {
      method: this.yaSigo ? 'DELETE' : 'POST',
      headers: { Authorization: `Bearer ${token}` }
    };

    const res = await fetch(url, options);

    if (res.ok) {
      this.yaSigo = !this.yaSigo; // Cambia el estado visual del botón
      await this.getSeguidores(); // Refresca la lista para actualizar los contadores
    } else {
      const errData = await res.json();
      console.error('Error:', errData.message);
    }
  } catch (e) {
    console.error('Error al alternar seguimiento:', e);
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
.profile-tabs {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}
.profile-tabs button {
  margin: 0 10px;
  padding: 10px 15px;
  background: transparent;
  border: 2px solid #034378;
  border-radius: 4px;
  color: #034378;
  cursor: pointer;
  font-weight: bold;
  transition: background-color 0.3s, color 0.3s;
}
.profile-tabs button.active,
.profile-tabs button:hover {
  background-color: #034378;
  color: white;
}
.button-wrapper {
  display: flex;
  justify-content: center;
  margin: 15px 0;
}

.buttons {
  display: flex;
  gap: 10px;
}

.btn-edit,
.btn-follow,
.btn-message {
  background-color: #ffc107;
  border: none;
  border-radius: 20px;
  padding: 6px 16px;
  font-size: 0.85em;
  font-weight: bold;
  color: #fff;
  cursor: pointer;
  transition: background-color 0.3s;
}

.btn-edit:hover,
.btn-follow:hover,
.btn-message:hover {
  background-color: #e0a800;
}


</style>
