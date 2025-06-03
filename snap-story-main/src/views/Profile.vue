<template lang="pug">
main.profile
  header.profile-header
    div.cover-photo
    div.avatar-container
      h1 {{ username }}
      p.bio Esta es tu biografía. Cuéntanos algo sobre ti.

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
      tabTitles: ['Mis publicaciones', 'Publicaciones guardadas', 'Publicaciones compartidas'],
      myPosts: [],
      savedPosts: [],
      sharedPosts: [],
      seguidores: [],
      seguidos: []
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
    }
  },
  mounted() {
    this.username = localStorage.getItem('username') || 'Invitado';
    this.fetchMyPosts();
    this.fetchSavedPosts();
    this.fetchSharedPosts();
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
        if (res.ok) this.myPosts = await res.json();
      } catch (e) {
        console.error('Error al obtener publicaciones:', e);
      }
    },
    async fetchSavedPosts() {
      try {
        const token = localStorage.getItem('token');
        const res = await fetch('http://localhost:4000/api/savedposts', {
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
        const res = await fetch('http://localhost:4000/api/sharedposts', {
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
        const res = await fetch('http://localhost:4000/api/seguidores', {
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
        const res = await fetch('http://localhost:4000/api/seguidos', {
          headers: { Authorization: `Bearer ${token}` }
        });
        if (res.ok) this.seguidos = await res.json();
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
</style>
