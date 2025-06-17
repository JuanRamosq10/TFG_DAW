<template lang="pug">
main
  div.container
    article
      h1 Lo más reciente en SnapStory
    PostGrid(
      :posts="posts"
      @like="likePost"
      @view-post="openModal"
      :showLike="true"
    )

    //– Modal para mostrar la publicación completa y comentarios
    div.modal-backdrop(v-if="showModal" @click="closeModal")
      div.modal-container(@click.stop)
        div.modal-content(v-if="selectedPost")
          //– IZQUIERDA: Imagen en grande
          div.modal-left
            img.post-image(
              v-if="selectedPost.source"
              :src="`http://localhost:4000/${selectedPost.source}`"
              alt="Imagen de la publicación"
            )
            div.no-image(v-else) No hay imagen disponible
          //– DERECHA: Comentarios y likes
          div.modal-right
            div.comments-area
              h3 Comentarios
              div.comment-list
                p(v-if="comments.length === 0").comment-placeholder No hay comentarios aún.
                div.comment(v-for="c in comments" :key="c.comentario_id")
                  strong {{ c.username }}:
                  span {{ c.comentario_text }}
              div.comment-form
                textarea.comment-field(
                  v-model="newComment"
                  placeholder="Añade un comentario..."
                )
                button.btn-send(@click="sendComment") Enviar
            div.likes-area
              span.stat-item
                i.las.la-heart
                |  {{ selectedPost.likes || 0 }} Me gusta
            button.btn-close(@click="closeModal") Cerrar
</template>

<script>
import { ref, onMounted } from 'vue';
import PostGrid from '../components/PostGrid.vue';

export default {
  name: 'Home',
  components: { PostGrid },
  setup() {
    const token        = ref(localStorage.getItem('token') || '');
    const posts        = ref([]);
    const showModal    = ref(false);
    const selectedPost = ref(null);
    const comments     = ref([]);
    const newComment   = ref('');

    const fetchPosts = async () => {
      try {
        const res = await fetch('http://localhost:4000/api/posts');
        posts.value = await res.json();
      } catch (error) {
        console.error('Error fetching posts:', error);
      }
    };

    const openModal = (post) => {
      selectedPost.value = post;
      showModal.value    = true;
      fetchComments(post.post_id);
    };

    const closeModal = () => {
      showModal.value    = false;
      selectedPost.value = null;
      comments.value     = [];
      newComment.value   = '';
    };

    const likePost = async (post) => {
      if (!token.value) {
        alert('Debes iniciar sesión para dar like');
        return;
      }
      try {
        const res = await fetch(`http://localhost:4000/api/posts/${post.post_id}/like`, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${token.value}` }
        });
        if (res.ok) await fetchPosts();
      } catch (error) {
        console.error('Error al dar like:', error);
      }
    };

    const fetchComments = async (postId) => {
      try {
        const res = await fetch(`http://localhost:4000/api/posts/${postId}/comments`);
        comments.value = await res.json();
      } catch (error) {
        console.error('Error al obtener comentarios:', error);
      }
    };

    const sendComment = async () => {
      if (!newComment.value.trim()) return;
      try {
        const res = await fetch(
          `http://localhost:4000/api/posts/${selectedPost.value.post_id}/comments`,
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token.value}`
            },
            body: JSON.stringify({ comentario: newComment.value })
          }
        );
        if (res.ok) {
          newComment.value = '';
          await fetchComments(selectedPost.value.post_id);
        } else {
          alert('Error al enviar comentario');
        }
      } catch (error) {
        console.error('Error al enviar comentario:', error);
      }
    };

    onMounted(fetchPosts);

    return {
      posts,
      showModal,
      selectedPost,
      openModal,
      closeModal,
      likePost,
      comments,
      newComment,
      sendComment
    };
  }
};
</script>

<style lang="stylus" scoped>
main
  background #f9f9f9
  padding-top 100px
  min-height 100vh

.container
  margin 0 auto
  padding 20px

article
  margin-top 30px

.modal-backdrop
  position fixed
  top 0
  left 0
  width 100%
  height 100%
  background-color rgba(0, 0, 0, 0.7)
  display flex
  align-items center
  justify-content center
  z-index 1000

.modal-container
  width 70vw
  height 70vh
  background-color #fff
  overflow hidden
  display flex
  flex-direction column

.modal-content
  display flex
  flex 1

.modal-left
  flex 2
  background #000
  display flex
  align-items center
  justify-content center
  min-height 0
  @media (max-width 768px)
    max-height 300px

.post-image
  width 100%
  height auto
  object-fit contain
  max-height 70vh

.no-image
  color #fff
  font-size 1em
  text-align center

.modal-right
  flex 1
  display flex
  flex-direction column
  padding 20px
  min-height 0

.comments-area
  flex 1
  overflow-y auto
  border-bottom 1px solid #e0e0e0
  padding-bottom 12px
  margin-bottom 12px

  h3
    font-size 1.2em
    margin-bottom 8px
    color #333

  .comment-list
    .comment
      margin-bottom 8px

  .comment-form
    display flex
    flex-direction column
    gap 8px
    textarea.comment-field
      width 100%
      aspect-ratio 1/2
      padding 18px 20px
      resize vertical
      border 1px solid #ccc
      border-radius 20px
      font-size 1.1em
      font-family inherit
      transition all 0.3s ease
      &::placeholder
        color #999
        font-style italic
      &:focus
        border-color #3498db
        outline none
        background-color #f9fcff
    .btn-send
      width 100%
      padding 10px
      background #3498db
      color #fff
      border none
      border-radius 10px
      cursor pointer
      font-weight 500
      transition background-color 0.3s ease
      &:hover
        background #2980b9

.likes-area
  padding-top 12px
  border-top 1px solid #e0e0e0
  text-align center
  flex-none

  .stat-item
    display flex
    align-items center
    justify-content center
    gap 6px
    font-size 1.1em
    color #e74c3c

    i
      font-size 1.4em

.btn-close
  width 100%
  margin-top 12px
  padding 12px 0
  background-color #c0392b
  color #fff
  border none
  border-radius 4px
  cursor pointer
  font-size 1em
  &:hover
    background-color #a93226

@media (max-width 768px)
  .modal-content
    flex-direction column

  .modal-left
    flex none
    max-height 300px

  .post-image
    max-height 300px
    object-fit cover
</style>