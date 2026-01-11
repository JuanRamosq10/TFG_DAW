<template lang="pug">
main.profile
  header.profile-header
    div.cover-photo
    div.avatar-container
      h1 {{ username }}
      p.bio {{ bio }}

  // Botones condicionales
  div.button-wrapper
    div.buttons(v-if="isCurrentUser")
      button.btn-edit(@click="editarPerfil") Editar Perfil
    div.buttons(v-else)
      button.btn-follow(
        @click="toggleSeguir"
        v-text="yaSigo ? 'Dejar de seguir' : 'Seguir'"
      )
      button.btn-message(@click="createOrOpenChat") Enviar mensaje

  section.profile-stats
    div.stat
      span.count {{ posts.length }}
      span.label Publicaciones
    div.stat
      span.count {{ seguidores.length }}
      span.label Seguidores
    div.stat
      span.count {{ seguidos.length }}
      span.label Siguiendo

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
      bio: '',
      currentTab: 0,
      tabTitles: ['Publicaciones', 'Guardadas', 'Compartidas'],
      myPosts: [],
      savedPosts: [],
      sharedPosts: [],
      seguidores: [],
      seguidos: [],
      yaSigo: false
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
      return String(localStorage.getItem('userId')) === this.$route.params.userId;
    }
  },
  async mounted() {
    this.username = localStorage.getItem('username') || 'Invitado';
    this.bio = localStorage.getItem('bio') || '';
    await this.loadProfileData();
  },
  watch: {
    '$route.params.userId'(newId, oldId) {
      if (newId !== oldId) this.loadProfileData();
    }
  },
  methods: {
    async loadProfileData() {
      await Promise.all([
        this.fetchProfileUser(),
        this.fetchMyPosts(),
        this.fetchSavedPosts(),
        this.fetchSharedPosts(),
        this.getSeguidores(),
        this.getSeguidos()
      ]);
      if (!this.isCurrentUser) {
        this.checkSiYaSigo();
      }
    },
    // 1. Datos de usuario
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
          this.bio = user.bio || '';
        }
      } catch (e) {
        console.error('Error fetchProfileUser:', e);
      }
    },
    // 2. Publicaciones
    async fetchMyPosts() {
      try {
        const token = localStorage.getItem('token');
        const userId = this.$route.params.userId;
        const res = await fetch(`http://localhost:4000/api/posts/${userId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) this.myPosts = await res.json();
      } catch (e) {
        console.error('Error fetchMyPosts:', e);
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
        console.error('Error fetchSavedPosts:', e);
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
        console.error('Error fetchSharedPosts:', e);
      }
    },
    // 3. Seguidores / Seguidos
    async getSeguidores() {
      try {
        const token = localStorage.getItem('token');
        const userId = this.$route.params.userId;
        const res = await fetch(`http://localhost:4000/api/seguidores/${userId}`, {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) this.seguidores = await res.json();
      } catch (e) {
        console.error('Error getSeguidores:', e);
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
      } catch (e) {
        console.error('Error getSeguidos:', e);
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
          const list = await res.json();
          this.yaSigo = list.some(s => s.user_id === miId);
        }
      } catch (e) {
        console.error('Error checkSiYaSigo:', e);
      }
    },
    async toggleSeguir() {
      try {
        const token = localStorage.getItem('token');
        const userId = this.$route.params.userId;
        const method = this.yaSigo ? 'DELETE' : 'POST';
        const res = await fetch(`http://localhost:4000/api/seguir/${userId}`, {
          method,
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) {
          this.yaSigo = !this.yaSigo;
          this.getSeguidores();
        }
      } catch (e) {
        console.error('Error toggleSeguir:', e);
      }
    },
    // 4. Chat
    async createOrOpenChat() {
      try {
        const token = localStorage.getItem('token');
        const participantId = parseInt(this.$route.params.userId);
        const res = await fetch('http://localhost:4000/api/chats', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`
          },
          body: JSON.stringify({ participantId })
        });
        if (res.ok) {
          const { chatId } = await res.json();
          this.$router.push({ name: 'Chat', params: { chatId } });
        } else {
          alert('No se pudo abrir el chat, inténtalo de nuevo.');
        }
      } catch (e) {
        console.error('Error createOrOpenChat:', e);
        alert('Hubo un problema al iniciar el chat.');
      }
    },
    // 5. Edición de perfil
    editarPerfil() {
      this.$router.push({ name: 'EditProfile' });
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
section.profile-posts {
  padding: 0 20px;
}
.posts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 10px;
}
</style>
