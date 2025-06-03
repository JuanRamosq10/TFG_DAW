<template lang="pug">
  main
    section.full.flex
      div.column.image
        // Puedes cambiar la imagen si lo deseas
        img(src="@/assets/img/login-snake.jpeg")
      div.column.flex.text
        div.content
          h1.text-center Crea tu cuenta
          // Formulario de registro
          Form(@submit="submitRegister")
            div
              //- label(for="username") Username
              Field(name="username" id="username" v-model="username" type="text" placeholder="Username" rules="required")
              ErrorMessage(name="username" class="text-red-500")
            div
              //- label(for="full_name") Nombre Completo
              Field(name="full_name" id="full_name" v-model="full_name" type="text" placeholder="Nombre Completo" rules="required")
              ErrorMessage(name="full_name" class="text-red-500")
            div
              //- label(for="email") Email
              Field(name="email" id="email" v-model="email" type="email" placeholder="Email" rules="required|email")
              ErrorMessage(name="email" class="text-red-500")
            div
              //- label(for="password") Contraseña
              Field(name="password" id="password" v-model="password" type="password" placeholder="Contraseña" rules="required")
              ErrorMessage(name="password" class="text-red-500")
            button(type="submit") Registrar
          p.text-center
            router-link(to="/") Inicia sesión
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
import { required, email as emailRule } from '@vee-validate/rules';
import { ref, onMounted, onUnmounted } from 'vue';
import api from '@/api.js';

// Definir reglas de validación
defineRule('required', required);
defineRule('email', emailRule);

export default {
  components: {
    Field,
    Form,
    ErrorMessage,
  },
  setup() {
    const username = ref('');
    const full_name = ref('');
    const email = ref('');
    const password = ref('');
    const message = ref('');
    const success = ref(false);
    const serverResponse = ref('');

    // Al montar el componente se agrega la clase "only-logo" al header
    // onMounted(() => {
    //   const header = document.getElementById('main-header');
    //   if (header) {
    //     header.classList.add('only-logo');
    //   }
    // });

    // Al desmontar se remueve la clase para que en otras vistas el logo recupere su estilo original
    onUnmounted(() => {
      const header = document.getElementById('main-header');
      if (header) {
        header.classList.remove('only-logo');
      }
    });

    // Función de registro (lógica de autenticación)
    const register = async () => {
      console.log("🛠 Evento de registro ejecutado!");
      message.value = "";
      serverResponse.value = "";

      if (!username.value || !full_name.value || !email.value || !password.value) {
        console.log("⚠️ Campos vacíos detectados");
        message.value = "⚠️ Por favor, complete todos los campos.";
        success.value = false;
        return;
      }

      console.log("📨 Enviando solicitud a la API con:", {
        username: username.value,
        full_name: full_name.value,
        email: email.value,
        password: password.value,
      });

      try {
        // Usamos 'register' ya que el baseURL de Axios es 'http://localhost:4000/api'
        const response = await api.post('register', {
          username: username.value,
          full_name: full_name.value,
          email: email.value,
          password: password.value,
        });
        console.log("✅ Respuesta del servidor recibida:", response.data);

        if (response.data.message === "Usuario registrado correctamente") {
          message.value = "✔️ Usuario registrado correctamente.";
          success.value = true;
        } else {
          message.value = "❌ Error en el registro.";
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

    const submitRegister = async (values, { resetForm }) => {
      await register();
      resetForm();
    };

    return {
      username,
      full_name,
      email,
      password,
      message,
      success,
      serverResponse,
      submitRegister,
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
