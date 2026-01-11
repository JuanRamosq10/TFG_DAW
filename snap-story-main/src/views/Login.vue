<template lang="pug">
  main
    section.full.flex
      div.column.image
        img(src="@/assets/img/login-snake.jpeg")
      div.column.flex.text
        div.content
          h1.text-center Inicia sesión
          Form(@submit="submitLogin")
            div
              label(for="username") Username
              Field(name="username" id="username" v-model="username" type="text" placeholder="Username" rules="required")
              ErrorMessage(name="username" class="text-red-500")
            div
              label(for="password") Contraseña
              Field(name="password" id="password" v-model="password" type="password" placeholder="Contraseña" rules="required")
              ErrorMessage(name="password" class="text-red-500")
            button(type="submit") Iniciar
          p.text-center
            // Enlace para ir a la página de registro
            router-link(to="/register") Crear una cuenta
          div(v-if="message" :class="{'text-green-500': success, 'text-red-500': !success}")
            p {{ message }}
          div(v-if="serverResponse")
            p.text-blue-500 {{ serverResponse }}
        ul.social
          li: a(href="#"): i.lab.la-facebook
          li: a(href="#"): i.lab.la-instagram
</template>

<script>
import { Field, Form, ErrorMessage, defineRule } from 'vee-validate';
import { required } from '@vee-validate/rules';
import { ref, onMounted, onUnmounted } from 'vue';
import { useRouter } from 'vue-router';
import api from '@/api.js';

// Definir regla de validación "required"
defineRule('required', required);

export default {
  components: {
    Field,
    Form,
    ErrorMessage,
  },
  setup() {
    const router = useRouter();
    const username = ref('');
    const password = ref('');
    const message = ref('');
    const success = ref(false);
    const serverResponse = ref('');

    // Al montar el componente se agrega la clase "only-logo"
    // onMounted(() => {
    //   const header = document.getElementById('main-header');
    //   if (header) {
    //     header.classList.add('only-logo');
    //   }
    // });

    // Al desmontar se remueve la clase para que en otras vistas se muestre correctamente
    onUnmounted(() => {
      const header = document.getElementById('main-header');
      if (header) {
        header.classList.remove('only-logo');
      }
    });

    // Función de login (lógica de autenticación)
    const login = async () => {
      console.log("🛠 Evento de login ejecutado!");
      message.value = "";
      serverResponse.value = "";

      if (!username.value || !password.value) {
        console.log("⚠️ Campos vacíos detectados");
        message.value = "⚠️ Por favor, complete todos los campos.";
        success.value = false;
        return;
      }

      console.log("📨 Enviando solicitud a la API con:", { username: username.value, password: password.value });

      try {
        // Usamos 'login' ya que el baseURL de Axios es 'http://localhost:4000/api'
        const response = await api.post('login', { username: username.value, password: password.value });
        console.log("✅ Respuesta del servidor recibida:", response.data);

        if (response.data.message === "ok") {
          message.value = `✔️ Bienvenido, ${response.data.user.full_name}`;
          success.value = true;
          // Guarda el token en localStorage
          localStorage.setItem("token", response.data.token);
          localStorage.setItem("username", response.data.user.username); // guarda el username en localStorage
          localStorage.setItem("userId", response.data.user.id) // guarda el userId en localStorage
          // Redirige a la página de home
          router.push({ name: 'Home' });
        } else {
          message.value = "❌ Usuario o contraseña incorrectos.";
          success.value = false;
        }
        serverResponse.value = response.data.message;
      } catch (error) {
        console.error("❌ Error en la solicitud:", error);
        message.value = "❌ Error al conectar con el servidor.";
        success.value = false;
        serverResponse.value = error.response?.data?.message || "Error desconocido.";
      }
    };

    // Función que se llama al enviar el formulario
    const submitLogin = async (values, { resetForm }) => {
      await login();
      resetForm();
    };

    return {
      username,
      password,
      message,
      success,
      serverResponse,
      submitLogin,
    };
  },
};
</script>

<style lang="stylus" scoped>
.image
  width 60%
  img
    width 100%
    display block
    height 100%
    object-fit cover

div.text
  align-self: center
  flex-basis: 40%
  align-items: center
  justify-content: center
  div.content
    width: 320px

ul.social
  position: absolute
  bottom: 20px
  margin: 0
  padding: 0
  li
    display: inline-block
    margin: 0 10px
    i
      font-size: 2em
      color: #ffb6c1
      &:hover
        color: #ff69b4
</style>
