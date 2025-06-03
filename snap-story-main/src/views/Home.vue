<template lang="pug">
main
  div.container
    article
      h1 Lo más reciente en SnapStory
    PostGrid(:posts="posts" @like="likePost" :showLike="true")
</template>

<script>
import { ref, onMounted } from 'vue';
import PostGrid from '@/components/PostGrid.vue';

export default {
  name: 'Home',
  components: {
    PostGrid
  },
  setup() {
    const token = ref(localStorage.getItem('token') || '');
    const posts = ref([]);

    const fetchPosts = async () => {
      try {
        const res = await fetch('http://localhost:4000/api/posts');
        const data = await res.json();
        posts.value = data;
      } catch (error) {
        console.error('Error fetching posts:', error);
      }
    };

    const likePost = async (post) => {
      if (!token.value || token.value === 'No hay token almacenado') {
        alert('Debes iniciar sesión para dar like');
        return;
      }
      try {
        const res = await fetch(`http://localhost:4000/api/posts/${post.post_id}/like`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token.value}`,
          },
        });
        const data = await res.json();
        if (data.message === 'Like agregado correctamente' || data.message === 'Ya le diste like a este post') {
          await fetchPosts(); // Actualiza la lista y los contadores
        }
      } catch (error) {
        alert('Error al dar like');
      }
    };

    onMounted(fetchPosts);

    return { posts, likePost };
  },
};
</script>

<style lang="stylus" scoped>
main
  background: #f9f9f9
  padding-top: 100px
  min-height: 100vh

.container
  margin 0 auto
  padding 20px

article
  margin-top: 30px
</style>
