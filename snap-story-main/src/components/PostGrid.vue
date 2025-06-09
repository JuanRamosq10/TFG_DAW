<template lang="pug">
div.row
  PostCard(
    v-for="post in posts"
    :key="post.post_id"
    :post="post"
    :showLike="showLike"
    @like="$emit('like', $event)"
    @view-post="$emit('view-post', $event)"
  )
</template>

<script>
import PostCard from './PostCard.vue';

export default {
  name: 'PostGrid',
  components: {
    PostCard
  },
  props: {
    posts: {
      type: Array,
      required: true
    },
    showLike: {
      type: Boolean,
      default: true
    }
  },
  emits: ['like', 'view-post']
};
</script>

<style scoped lang="stylus">
.row
  max-width 1200px
  margin 0 auto
  display flex
  flex-wrap wrap
  justify-content space-between
</style>
