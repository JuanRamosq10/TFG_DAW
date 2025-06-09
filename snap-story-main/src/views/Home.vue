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

    //– Modal grande para mostrar la publicación completa
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
          //– DERECHA: Comentarios arriba + contador de likes abajo
          div.modal-right
            //– Zona de comentarios (scrollable)
            div.comments-area
              h3 Comentarios
              //– Aquí irán los comentarios cuando los implementes
              p.comment-placeholder No hay comentarios aún.
            //– Zona inferior: contador de likes
            div.likes-area
              span.stat-item
                i.las.la-heart
                |  {{ selectedPost.likes || 0 }} Me gusta
            //– Botón de cerrar, ancho completo
            button.btn-close(@click="closeModal") Cerrar
</template>

<script>
import { ref, onMounted } from 'vue';
import PostGrid from '../components/PostGrid.vue';

export default {
  name: 'Home',
  components: { PostGrid },
  setup() {
    const token = ref(localStorage.getItem('token') || '');
    const posts = ref([]);

    const showModal = ref(false);
    const selectedPost = ref(null);

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
        const res = await fetch(
          `http://localhost:4000/api/posts/${post.post_id}/like`,
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token.value}`,
            },
          }
        );
        const data = await res.json();
        if (
          data.message === 'Like agregado correctamente' ||
          data.message === 'Ya le diste like a este post'
        ) {
          await fetchPosts();
        }
      } catch (error) {
        alert('Error al dar like');
      }
    };

    const openModal = (post) => {
      selectedPost.value = post;
      showModal.value = true;
    };

    const closeModal = () => {
      showModal.value = false;
      selectedPost.value = null;
    };

    const formatDate = (isoString) => {
      if (!isoString) return '';
      const date = new Date(isoString);
      const day = date.getDate();
      const month = date.toLocaleString('default', { month: 'long' });
      const year = date.getFullYear();
      return `${day} de ${month} de ${year}`;
    };

    onMounted(fetchPosts);

    return {
      posts,
      likePost,
      showModal,
      selectedPost,
      openModal,
      closeModal,
      formatDate,
    };
  },
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

/*=========================
  Estilos del modal (30 % más pequeño)
=========================*/
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
  /* Ahora ocupa el 70 % de ancho y alto de la pantalla */
  width 70vw
  height 70vh
  border-radius 0
  overflow hidden
  display flex
  flex-direction column
  background-color #fff
  box-shadow none

/* Contenedor principal dividido en dos columnas */
.modal-content
  display flex
  flex 1

/*========= IZQUIERDA: Imagen en grande ========*/
.modal-left
  flex 2                     /* La imagen ocupa 2/3 del ancho */
  background-color #000
  display flex
  align-items center
  justify-content center
  overflow hidden
  min-height 0                /* Importante para que el flex funcione */
  @media (max-width 768px)
    max-height 300px

.post-image
  width 100%
  height auto
  object-fit contain
  max-height 70vh            /* Ajustar para no exceder el modal */

.no-image
  color #fff
  font-size 1em
  text-align center

/*========= DERECHA: Comentarios y contador de likes ========*/
.modal-right
  flex 1                     /* La columna de la derecha ocupa 1/3 del ancho */
  display flex
  flex-direction column
  padding 20px
  min-height 0                /* Para habilitar overflow */

  /*===== Zona de comentarios (scrollable) =====*/
  .comments-area
    flex 1                   /* Ocupa todo el espacio posible */
    overflow-y auto
    border-bottom 1px solid #e0e0e0
    padding-bottom 12px
    margin-bottom 12px

    h3
      font-size 1.2em
      margin-bottom 8px
      color #333

    .comment-placeholder
      font-size 0.9em
      color #777

  /*===== Zona inferior de likes =====*/
  .likes-area
    padding-top 12px
    border-top 1px solid #e0e0e0
    text-align center
    flex-none                 /* No crece ni se encoge con el scroll */

    .stat-item
      display flex
      align-items center
      justify-content center
      gap 6px
      font-size 1.1em
      color #e74c3c

      i
        font-size 1.4em

  /*===== Botón de cerrar =====*/
  .btn-close
    width 100%               /* El botón ocupa todo el ancho de la columna derecha */
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

/* Ajustes en móviles: apilar columnas */
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
