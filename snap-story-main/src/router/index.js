import { createRouter, createWebHistory } from 'vue-router'
import Login from '@/views/Login.vue'
import Register from '@/views/Register.vue'
import Home from '@/views/Home.vue'
import Profile from '@/views/Profile.vue'
import Upload from '@/views/Upload.vue'
import Chat from '@/views/Chat.vue'

const routes = [
  { path: '/', name: 'Login', component: Login },
  { path: '/register', name: 'Register', component: Register },
  { path: '/home', name: 'Home', component: Home },
  { path: '/profile', name: 'Profile', component: Profile, meta: { requiresAuth: true } },
  { path: '/upload', name: 'Upload', component: Upload, meta: { requiresAuth: true } },
  { path: '/chat', name: 'Chat', component: Chat, meta: { requiresAuth: true } },

]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

// Guard global
router.beforeEach((to, from, next) => {
  // Controla el estilo del header
  const header = document.getElementById('main-header')
  if (header) {
    if (to.name === 'Login' || to.name === 'Register') {
      header.classList.add('only-logo')
    } else {
      header.classList.remove('only-logo')
    }
  }

  // Verifica autenticación si es requerida
  if (to.meta.requiresAuth) {
    const token = localStorage.getItem('token')
    if (!token) {
      return next({ name: 'Login' })
    }
  }

  next()
})

export default router