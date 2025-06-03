<template lang="pug">
figure.card.example-1
  .wrapper(:style="{ backgroundImage: post.source ? 'url(http://localhost:4000/' + post.source + ')' : 'url(https://placecats.com/300/300)' }")
    .date
      span.day {{ day }}
      span.month {{ month }}
      span.year {{ year }}
    .data
      .content
        .info-row
          span.author Autor: {{ post.username }}
          .icons
            a.las.la-bookmark(href="#", title="Guardar")
            a.las.la-heart(
              v-if="showLike"
              href="#"
              @click.prevent="$emit('like', post)"
              title="Me gusta"
            )
            span.count {{ post.likes || 0 }}
            a.las.la-comment(href="#", title="Comentarios")
            span.count 0
        h1.title
          a(href="#") {{ post.title }}
        p.text {{ post.description }}
</template>

<script>
export default {
  name: 'PostCard',
  props: {
    post: Object,
    showLike: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    day() {
      return new Date(this.post.created_at).getDate();
    },
    month() {
      return new Date(this.post.created_at).toLocaleString('default', { month: 'short' });
    },
    year() {
      return new Date(this.post.created_at).getFullYear();
    }
  }
}
</script>

<style lang="stylus" scoped>
@import url('https://fonts.googleapis.com/css?family=Open+Sans:300,400,700')

$regal-blue = #034378
$san-juan = #2d4e68
$bermuda = #77d7b9
$white = #fff
$black = #000
$open-sans = 'Open Sans', sans-serif

*
  box-sizing border-box

.card
  width calc(33.333% - 20px)
  margin 10px
  position relative
  padding 0

.wrapper
  background-color $white
  min-height 540px
  position relative
  overflow hidden
  box-shadow 0 19px 38px rgba($black, 0.3), 0 15px 12px rgba($black, 0.2)
  background-size cover
  background-repeat no-repeat
  background-position center

  &:hover .data
    transform translateY(0)

.date
  position absolute
  top 0
  left 0
  background-color $bermuda
  color $white
  padding 0.8em

  span
    display block
    text-align center

  .day
    font-weight 700
    font-size 24px
    text-shadow 2px 3px 2px rgba($black, 0.18)

  .month, .year
    font-size 12px
    text-transform uppercase

.data
  position absolute
  bottom 0
  width 100%
  transform translateY(calc(70px + 1em))
  transition transform 0.3s
  background-color rgba(255, 255, 255, 0.0)
  backdrop-filter blur(0px)
  color #fff

  .content
    padding 1em
    position relative
    z-index 1
    background-color transparent
    color inherit

.info-row
  display flex
  justify-content space-between
  align-items center
  margin-bottom 0.5em

.author
  font-size 12px
  color white

.icons
  display flex
  gap 10px
  align-items center

  a
    font-size 18px
    color white
    transition color 0.3s
    cursor pointer
    &:hover
      color $bermuda

.count
  font-size 10px
  color white

.title
  margin-top 10px

  a
    color white
    font-weight 700
    font-size 1.2em

.text
  height 70px
  margin 0
  overflow hidden
  color white
</style>
