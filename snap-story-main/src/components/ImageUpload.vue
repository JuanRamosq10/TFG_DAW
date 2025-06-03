<template lang="pug">
  div.dropzone(@dragenter.prevent.stop="noop" @dragover.prevent.stop="noop" @drop="loadImage")
    template(v-if="imageSrc")
      img(:src="imageSrc", alt="Imagen subida")
    template(v-else)
      div.message
        h2 Arrastra una imagen para subirla
        i.las.la-cloud-upload-alt
</template>





<script>
export default {
  name: 'ImageUpload',
  data() {
    return {
      imageSrc: '',
    };
  },
  mounted() {
    const width = this.$el.clientWidth;
    this.$el.style.height = width + 'px';
  },
  methods: {
    noop() {
      // Función vacía para prevenir el comportamiento por defecto
    },
    loadImage(e) {
      e.preventDefault();
      if (e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files.length > 0) {
        const file = e.dataTransfer.files[0];
        const reader = new FileReader();
        reader.onload = (event) => {
          this.imageSrc = event.target.result;
          // Emite un objeto con la imagen en base64 y el objeto File
          this.$emit('image-uploaded', { base64: this.imageSrc, file: file });
        };
        reader.readAsDataURL(file);
      } else {
        console.warn('No se encontró ningún archivo en dataTransfer');
      }
    },
  },
};
</script>



<style lang="stylus" scoped>
.dropzone
  width 100%
  background transparent
  border 2px dashed #C1C1C1
  margin 10px 0
  display: flex
  justify-content: center
  align-items: center

.message
  display: flex
  flex-direction: column
  align-items: center

h2
  text-align: center
  color rgba(0, 0, 0, 0.2)
  user-select: none

i.las.la-cloud-upload-alt
  font-size 200px
  color rgba(0, 0, 0, 0.2)
  
img
  max-width: 100%
  max-height: 100%
  object-fit: contain
</style>
