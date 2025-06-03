<template lang="pug">
  main
    div.container
      article
        h1 Crea una publicación
        div.flex
          // Columna izquierda: Componente para subir la imagen
          div.column
            image-upload(@image-uploaded="handleImageUpload")
          // Columna derecha: Formulario para título y descripción
          div.column
            form(@submit.prevent="submitPost")
              input(type="text", placeholder="Título", v-model="title", required)
              textarea(placeholder="Descripción", v-model="description", required)
              button(type="submit") Publicar
</template>

<script>
import ImageUpload from '@/components/ImageUpload.vue';

export default {
  name: 'Upload',
  components: {
    ImageUpload,
  },
  data() {
    return {
      title: '',
      description: '',
      imageFile: null,    // Objeto File recibido de ImageUpload
      imageBase64: '',    // Para vista previa (opcional)
    };
  },
  methods: {
    handleImageUpload(payload) {
      // payload es un objeto { base64, file }
      this.imageBase64 = payload.base64;
      this.imageFile = payload.file;
    },
    async submitPost() {
      // Validación básica
      if (!this.imageFile || !this.title || !this.description) {
        alert("Por favor, completa todos los campos y sube una imagen.");
        return;
      }
      try {
        const token = localStorage.getItem('token');
        // Se crea un objeto FormData para enviar la imagen como archivo
        const formData = new FormData();
        formData.append('title', this.title);
        formData.append('description', this.description);
        formData.append('image', this.imageFile);  // Envía el archivo

        const response = await fetch('http://localhost:4000/api/posts', {
          method: 'POST',
          headers: {
            // No es necesario establecer Content-Type para FormData
            Authorization: `Bearer ${token}`,
          },
          body: formData,
        });

        if (response.ok) {
          console.log('Post subido con éxito');
          // Aquí puedes redirigir o mostrar un mensaje de éxito
          // Reinicia los campos si lo deseas:
          this.title = '';
          this.description = '';
          this.imageFile = null;
          this.imageBase64 = '';
        } else {
          console.error('Error al subir el post:', response.statusText);
        }
      } catch (error) {
        console.error('Error al subir el post:', error);
      }
    },
  },
};
</script>


<style lang="stylus" scoped>
  main
    background: #f9f9f9
    padding-top: 100px
    min-height: 100vh
    h1
      margin: 0

    div.container
      margin 0 auto
      padding 20px
    
    article
      margin-top: 30px
  div.column
    width: 50%

  form
    padding-left: 20px

</style>



<!-- <style lang="stylus" scoped>
  main
    background: #f9f9f9
    padding-top: 100px
    min-height: 100vh
    h1
      margin: 0

    div.container
      margin 0 auto
      padding 20px
    
    article
      margin-top: 30px
  div.column
    width: 50%

  form
    padding-left: 20px

</style> -->
