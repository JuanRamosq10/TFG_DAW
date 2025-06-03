<template lang="pug">
#frame
  #sidepanel
    #profile(:class="currentUser.status")
      .avatar-wrapper
        img.avatar(:src="currentUser.profileImg || defaultAvatar")
      .user-info
        p.username {{ currentUser.username }}
        i.expand-button(@click="toggleStatusOptions") ⌄
      #status-options(:class="{ active: showStatusOptions }")
        ul
          li#status-online.status-item(@click="updateUserStatus('online')")
            span.status-circle
            span.status-label Online
          li#status-away.status-item(@click="updateUserStatus('away')")
            span.status-circle
            span.status-label Away
          li#status-busy.status-item(@click="updateUserStatus('busy')")
            span.status-circle
            span.status-label Busy
          li#status-offline.status-item(@click="updateUserStatus('offline')")
            span.status-circle
            span.status-label Offline

    //- #search
      input(
        type="text"
        placeholder="Buscar conversaciones..."
        v-model="searchTerm"
      )
      i.fa.fa-search.search-icon

    #contacts
      ul
        li.contact(
          v-for="chat in filteredChats"
          :key="chat.chat_id"
          :class="{ active: chat.chat_id === selectedChatId }"
          @click="selectChat(chat)"
        )
          img.contact-img(:src="chat.profileImg || defaultAvatar")
          .contact-meta
            p.contact-name {{ chat.username }}
            span.contact-preview(v-html="chatPreview(chat)")

  .content
    .contact-header(v-if="selectedChat")
      img(:src="selectedChat.profileImg || defaultAvatar")
      .header-info
        p.header-name {{ selectedChat.username }}
        p.full-name {{ selectedChat.full_name }}

    .messages
      ul
        li.message(
          v-for="msg in filteredMessages"
          :key="msg.mensaje_id"
          :class="msg.sender_id === currentUser.id ? 'sent' : 'received'"
        )
          .msg-avatar
            img(:src="getSenderAvatar(msg.sender_id)")
          .msg-bubble
            p.msg-text {{ msg.message_text }}
            span.msg-time {{ formatTime(msg.created_at) }}

    .message-input
      input(
        type="text"
        placeholder="Escribe un mensaje..."
        v-model="newMessage"
        @keyup.enter="sendMessage()"
      )
      button.send-btn(@click="sendMessage()")
        i.las.la-paper-plane
</template>

<script>
import io from 'socket.io-client';
import axios from 'axios';

export default {
  name: 'ChatApp',
  data() {
    return {
      socket: null,
      currentUser: {
        id: null,
        username: '',
        profileImg: '',
        status: 'online'
      },
      defaultAvatar: 'http://emilcarlsson.se/assets/default-avatar.png',
      chats: [],
      messages: [],
      selectedChat: null,
      selectedChatId: null,
      showStatusOptions: false,
      searchTerm: '',
      newMessage: ''
    };
  },
  computed: {
    filteredChats() {
      if (!this.searchTerm) return this.chats;
      return this.chats.filter(chat =>
        chat.username.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        chat.full_name.toLowerCase().includes(this.searchTerm.toLowerCase())
      );
    },
    filteredMessages() {
      return this.messages;
    }
  },
  methods: {
    formatTime(dateString) {
      const date = new Date(dateString);
      return date.toLocaleTimeString([], {
        hour: '2-digit',
        minute: '2-digit'
      });
    },
    getSenderAvatar(senderId) {
      if (senderId === this.currentUser.id) {
        return this.currentUser.profileImg || this.defaultAvatar;
      } else if (this.selectedChat && senderId === this.selectedChat.contact_id) {
        return this.selectedChat.profileImg || this.defaultAvatar;
      }
      return this.defaultAvatar;
    },
    chatPreview(chat) {
      if (chat.last_message) {
        const sender =
          chat.last_message_sender === this.currentUser.id
            ? 'Tú'
            : chat.username.split(' ')[0];
        return `<span>${sender}:</span> ${chat.last_message}`;
      }
      return '<span>Sistema:</span> Sin mensajes aún';
    },
    async fetchChats() {
      try {
        const token = localStorage.getItem('token');
        const resp = await axios.get('http://localhost:4000/api/chats', {
          headers: { Authorization: `Bearer ${token}` }
        });
        this.chats = resp.data.map(c => ({
          chat_id: c.chat_id,
          contact_id: c.contact_id,
          username: c.username,
          full_name: c.full_name,
          last_message: c.last_message,
          last_message_time: c.last_message_time,
          last_message_sender: c.last_message_sender,
          profileImg: this.defaultAvatar
        }));
        if (this.chats.length > 0) {
          this.selectChat(this.chats[0]);
        }
      } catch (err) {
        console.error('❌ Error al cargar conversaciones:', err.response || err);
      }
    },
    async fetchMessages(chat) {
      try {
        const token = localStorage.getItem('token');
        const resp = await axios.get(
          `http://localhost:4000/api/chats/${chat.chat_id}/messages`,
          { headers: { Authorization: `Bearer ${token}` } }
        );
        this.messages = resp.data.map(msg => ({
          mensaje_id: msg.mensaje_id,
          chat_id: msg.chat_id,
          sender_id: msg.sender_id,
          sender_username: msg.sender_username,
          message_text: msg.message_text,
          media_url: msg.media_url,
          created_at: msg.created_at
        }));
        this.$nextTick(() => {
          this.scrollToBottom();
        });
      } catch (err) {
        console.error('❌ Error al cargar mensajes:', err.response || err);
      }
    },
    selectChat(chat) {
      if (this.selectedChatId === chat.chat_id) return;
      this.selectedChat = chat;
      this.selectedChatId = chat.chat_id;
      this.messages = [];
      if (this.socket && this.socket.connected) {
        this.joinChatRoom(chat.chat_id);
      }
      this.fetchMessages(chat);
    },
    connectSocket() {
      const serverUrl = 'http://localhost:4000';
      const token = localStorage.getItem('token');
      if (!token) {
        console.error('No se encontró el token de autenticación.');
        return;
      }
      // Forzar conexión solo por WebSocket (sin polling)
      this.socket = io(serverUrl, {
        transports: ['websocket'],
        auth: { token: `Bearer ${token}` }
      });
      this.socket.on('connect', () => {
        console.log('🔌 Conectado a Socket.IO con ID:', this.socket.id);
        if (this.selectedChatId) {
          this.joinChatRoom(this.selectedChatId);
        }
      });
      this.socket.on('disconnect', reason => {
        console.log('🔌 Desconectado de Socket.IO:', reason);
      });
      this.socket.on('connect_error', err => {
        console.error('❌ Error de conexión Socket.IO:', err.message);
        if (
          err.message === 'Token inválido o expirado' ||
          err.message === 'No token provided'
        ) {
          alert('Error de autenticación: ' + err.message + '. Inicia sesión nuevamente.');
        }
      });
      this.socket.on('newMessage', message => {
        console.log('📩 Mensaje recibido:', message);
        if (this.selectedChatId === message.chat_id) {
          this.messages.push(message);
          this.$nextTick(() => {
            this.scrollToBottom();
          });
          const idx = this.chats.findIndex(c => c.chat_id === message.chat_id);
          if (idx !== -1) {
            const updatedChat = { ...this.chats[idx] };
            updatedChat.last_message = message.message_text;
            updatedChat.last_message_time = message.created_at;
            updatedChat.last_message_sender = message.sender_id;
            this.chats.splice(idx, 1);
            this.chats.unshift(updatedChat);
          }
        } else {
          const idx = this.chats.findIndex(c => c.chat_id === message.chat_id);
          if (idx !== -1) {
            const updatedChat = { ...this.chats[idx] };
            updatedChat.last_message = message.message_text;
            updatedChat.last_message_time = message.created_at;
            updatedChat.last_message_sender = message.sender_id;
            this.chats.splice(idx, 1);
            this.chats.unshift(updatedChat);
          }
        }
      });
    },
    joinChatRoom(chatId) {
      console.log(`🔗 Uniéndose a la sala chat_${chatId}`);
      this.socket.emit('joinChat', { chatId });
    },
    sendMessage() {
      const text = this.newMessage.trim();
      if (!text || !this.selectedChatId || !this.socket || !this.socket.connected) {
        if (!this.socket || !this.socket.connected) {
          console.warn('Socket no conectado. No se puede enviar mensaje.');
        }
        return;
      }
      const payload = {
        chatId: this.selectedChatId,
        messageText: text,
        mediaUrl: null
      };
      this.socket.emit('sendMessage', payload);
      console.log('📤 Mensaje enviado (pendiente):', payload);
      this.newMessage = '';
      this.$nextTick(() => {
        this.scrollToBottom();
      });
    },
    scrollToBottom() {
      const container = this.$el.querySelector('.messages ul');
      if (container) {
        container.scrollTop = container.scrollHeight;
      }
    },
    updateUserStatus(status) {
      this.currentUser.status = status;
      this.showStatusOptions = false;
    },
    toggleStatusOptions() {
      this.showStatusOptions = !this.showStatusOptions;
    }
  },
  async mounted() {
    try {
      const token = localStorage.getItem('token');
      if (token) {
        const perfilResp = await axios.get('http://localhost:4000/api/profile', {
          headers: { Authorization: `Bearer ${token}` }
        });
        this.currentUser.id = perfilResp.data.user.id;
        this.currentUser.username = perfilResp.data.user.username;
      }
    } catch (err) {
      console.error('❌ No se pudo obtener perfil de usuario:', err.response || err);
    }
    this.connectSocket();
    this.fetchChats();
  },
  beforeUnmount() {
    if (this.socket) {
      console.log('🔌 Desconectando socket antes de desmontar componente.');
      this.socket.off('connect');
      this.socket.off('disconnect');
      this.socket.off('connect_error');
      this.socket.off('newMessage');
      this.socket.disconnect();
    }
  }
};
</script>


















<style lang="stylus" scoped>
// Variables de Stylus (convertidas desde CSS Custom Properties)
gradient-start = #FFC107
gradient-end = #ff6b6b
accent-color = #ff6b6b
accent-color-light = #ff7f7f
soft-gray = #f0f2f5
white-color = #ffffff
dark-color = #ff6b6b // Originalmente --dark, igual que accent-color
primary-color = #FFC107 // Originalmente --primary, igual que gradient-start
gray-light = #ecf0f1
gray-dark = #bdc3c7
lime-color = #32cd32
break-point = 735px // Para media queries

// Importación de fuente (si no está disponible globalmente)
// @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap')

// Estilos globales dentro del scope del componente
*
  box-sizing border-box

// Contenedor principal del componente, aplicando estilos base
#frame
  display flex
  width 100vw
  height calc(100vh - 80px) // Asume un header/navbar de 80px fuera de este componente
  margin-top 80px
  border-radius 15px
  overflow hidden
  box-shadow 0 15px 30px rgba(0, 0, 0, 0.08), 0 5px 15px rgba(0, 0, 0, 0.05)
  margin-left auto
  margin-right auto
  max-width 1200px
  // Estilos que estaban en 'body', aplicados al root del componente
  font 14px/1.6 'Inter', sans-serif // Asegúrate que 'Inter' esté disponible
  background soft-gray // Fondo general del chat frame
  color dark-color // Color de texto por defecto para el frame (puede ser sobrescrito)

// -----------------------------------------
//   PANEL LATERAL
// -----------------------------------------
#sidepanel
  width 320px
  background linear-gradient(180deg, primary-color, dark-color)
  color white-color
  display flex
  flex-direction column
  position relative

// Perfil del usuario
#profile
  padding 30px 20px 20px
  text-align center
  position relative

  .avatar-wrapper
    width 90px
    height 90px
    margin 0 auto
    border 4px solid white-color
    border-radius 50%
    overflow hidden
    box-shadow 0 5px 15px rgba(0, 0, 0, 0.15)

    img.avatar
      width 100%
      display block

  .user-info
    margin-top 10px

    .username
      font-size 20px
      font-weight 600

  i.expand-button
    position absolute
    top 35px
    right 20px
    cursor pointer
    font-size 18px
    transition transform 0.2s ease

    &:hover
      transform rotate(180deg)

// Opciones de estado
#status-options
  position absolute
  top 120px // Ajustar según el contenido encima
  left 50%
  transform translateX(-50%)
  background white-color
  color dark-color // Color de texto para las opciones
  border-radius 12px
  box-shadow 0 8px 20px rgba(0, 0, 0, 0.15)
  overflow hidden
  display none // Se activa con la clase .active
  z-index 10

  &.active // Estilo cuando la clase .active está presente
    display block

  ul
    margin 0
    padding 0
    list-style none

  li.status-item
    display flex
    align-items center
    padding 10px 20px
    cursor pointer
    transition background 0.2s ease, transform 0.1s ease

    &:hover
      background soft-gray
      transform translateX(3px)

    .status-circle
      width 14px
      height 14px
      border-radius 50%
      margin-right 10px

    .status-label
      font-size 14px
      font-weight 500

  // Colores específicos para cada estado
  #status-online .status-circle // Estos IDs están en el pug, se pueden usar clases también
    background #2ecc71
  #status-away .status-circle
    background #f1c40f
  #status-busy .status-circle
    background #e74c3c
  #status-offline .status-circle
    background gray-dark

// Barra de búsqueda
#search // Si la barra de búsqueda se elimina del Pug, esta sección no aplicará
  position relative
  padding 15px 20px
  background primary-color // Fondo para la sección de búsqueda

  input // Estilo para el input de búsqueda
    width 100%
    background white-color
    padding 12px 45px 12px 20px // Espacio para el ícono
    border none
    border-radius 25px
    color dark-color // Color del texto del input
    font-size 15px
    box-shadow inset 0 1px 3px rgba(0, 0, 0, 0.05)

    &::placeholder
      color gray-dark

    &:focus
      outline none
      box-shadow inset 0 1px 3px rgba(0, 0, 0, 0.1), 0 0 0 2px primary-color

  .search-icon // Ícono dentro de la barra de búsqueda
    position absolute
    right 35px
    top 50%
    transform translateY(-50%)
    color primary-color

// Lista de contactos
#contacts
  flex 1
  overflow-y auto // Permitir scroll si hay muchos contactos

  ul
    margin 0
    padding 0
    list-style none

  li.contact
    display flex
    align-items center
    padding 15px 20px
    cursor pointer
    transition background 0.2s ease // Quitado transform para evitar saltos innecesarios

    &:hover
      background rgba(255, 255, 255, 0.1) // Ligero hover en el sidepanel oscuro

    &.active
      background dark-color // Color de fondo para el contacto activo
      box-shadow inset 3px 0 0 accent-color // Indicador visual

  img.contact-img
    width 50px
    height 50px
    border-radius 50%
    border 2px solid rgba(255, 255, 255, 0.8)
    margin-right 15px
    box-shadow 0 2px 8px rgba(0, 0, 0, 0.1)

  .contact-meta
    overflow hidden // Para que text-overflow ellipsis funcione

    .contact-name
      font-size 17px
      font-weight 500
      white-space nowrap // Evitar que el nombre se rompa en varias líneas

    .contact-preview
      font-size 13px
      color rgba(255, 255, 255, 0.7)
      white-space nowrap // Importante para ellipsis
      overflow hidden
      text-overflow ellipsis // Mostrar '...' si el texto es muy largo
      max-width 200px // Ajustar según el ancho disponible menos el avatar y padding

      span // Para el "Tú:" o "Nombre:" en la preview
        color white-color // Color blanco para el nombre del remitente en la preview
        font-weight 500

// Botón inferior para añadir contacto
#bottom-bar // Si se elimina del Pug, esta sección no aplica
  padding 15px
  background dark-color // Fondo para la barra inferior
  text-align center

  button.add-contact
    background accent-color
    color white-color
    border none
    padding 12px 25px
    border-radius 25px
    font-weight 500
    font-size 15px
    cursor pointer
    transition background 0.2s ease, transform 0.2s ease, box-shadow 0.2s ease

    &:hover
      background accent-color-light
      transform translateY(-2px)
      box-shadow 0 4px 10px rgba(255, 107, 107, 0.4)

// -----------------------------------------
//   CONTENIDO PRINCIPAL DEL CHAT
// -----------------------------------------
.content
  flex 1
  display flex
  flex-direction column
  background soft-gray // Fondo del área de contenido

// Encabezado de contacto en el área de chat
.contact-header
  display flex
  align-items center
  padding 15px 25px
  background white-color // Fondo para el header del chat
  box-shadow 0 2px 8px rgba(0, 0, 0, 0.08) // Sombra sutil

  img
    width 55px
    height 55px
    border-radius 50%
    border 2px solid gray-light
    margin-right 15px

  .header-info
    .header-name
      font-size 20px
      font-weight 600

    .social-icons i // Para íconos de redes sociales si los tienes
      margin-right 12px
      cursor pointer
      color gray-dark
      font-size 18px
      transition color 0.2s ease

      &:hover
        color accent-color

// -----------------------------------------
//   MENSAJES
// -----------------------------------------
.messages
  flex 1
  padding 25px 30px
  background soft-gray // Fondo del área de mensajes (puede ser el mismo que .content)
  overflow-y auto // Scroll para los mensajes

  // Estilos para la barra de scroll (WebKit)
  &::-webkit-scrollbar
    width 8px
  &::-webkit-scrollbar-thumb
    background-color rgba(primary-color, 0.3) // Usar una variable de color
    border-radius 10px
  &::-webkit-scrollbar-track
    background-color transparent // Fondo del track

  ul
    margin 0
    padding 0
    list-style none

  li.message
    display flex
    margin-bottom 15px

    // Mensajes enviados (alineados a la derecha)
    &.sent
      justify-content flex-end

      .msg-bubble
        background linear-gradient(45deg, gradient-start, gradient-end)
        color white-color
        border-bottom-right-radius 5px // Para dar forma de "cola" si se desea
        // order 1 // Burbuja primero
        // margin-left 10px // Espacio entre avatar y burbuja (si el avatar va a la izquierda)
        // No, en sent, el avatar va a la derecha de la burbuja si estuviera
        // la plantilla original tenía el avatar siempre a la izquierda, lo cambio:
        order 2

      .msg-avatar
        // order 2 // Avatar después (derecha)
        margin-left 10px // Espacio si el avatar está a la derecha de la burbuja
        order 1


    // Mensajes recibidos (alineados a la izquierda)
    &.received
      justify-content flex-start

      .msg-bubble
        background white-color
        color dark-color // Color de texto para mensajes recibidos
        border-bottom-left-radius 5px
        order 1 // Burbuja primero
        margin-right 10px // Espacio entre burbuja y avatar

      .msg-avatar
        order 2 // Avatar después (derecha)


  .msg-avatar // Contenedor del avatar en el mensaje
    width 45px
    height 45px
    border-radius 50%
    overflow hidden
    border 2px solid white-color // Borde para el avatar
    box-shadow 0 1px 5px rgba(0, 0, 0, 0.05)
    align-self flex-end // Alinea el avatar al final del espacio del mensaje

    img // Imagen del avatar
      width 100%
      display block

  .msg-bubble // Burbuja del mensaje
    max-width 65%
    padding 12px 18px
    border-radius 20px // Bordes redondeados para la burbuja
    position relative // Para la "cola" si se implementa con pseudo-elementos
    font-size 15px
    box-shadow 0 2px 5px rgba(0, 0, 0, 0.08)
    display flex // Para alinear texto y hora
    flex-direction column

  .msg-text // Texto del mensaje
    margin 0
    line-height 1.4

  .msg-time // Hora del mensaje
    display block
    font-size 10px
    margin-top 6px
    color gray-dark // Color para la hora (puede variar en .sent)
    text-align right
    opacity 0.8
    
    // Para mensajes enviados, la hora podría ser más clara si el fondo es oscuro
    // Esto se puede hacer anidando dentro de li.message.sent .msg-time
    // Pero por ahora, es un color general.
    // Por ejemplo:
    // li.message.sent & // (usando & para referirse a .msg-time dentro de .sent)
    // color rgba(white-color, 0.7)


// -----------------------------------------
//   ÁREA DE ENTRADA DE MENSAJE
// -----------------------------------------
.message-input
  display flex
  align-items center
  padding 15px 20px // Aumentado padding para más espacio
  background white-color // Fondo del área de input
  box-shadow 0 -2px 8px rgba(0, 0, 0, 0.08) // Sombra superior
  position sticky // Para que se quede abajo al hacer scroll
  bottom 0
  z-index 10 // Para que esté sobre los mensajes

  input // Campo de texto para el mensaje
    flex 1
    padding 12px 20px
    border none
    border-radius 25px
    background gray-light // Fondo del input
    margin-right 10px
    font-size 15px
    color dark-color // Color del texto del input

    &::placeholder
      color gray-dark

    &:focus
      outline none
      box-shadow 0 0 0 2px primary-color // Highlight al enfocar

  // Botón enviar
  .send-btn
    background linear-gradient(45deg, gradient-start, gradient-end) // Gradiente para el botón
    border none
    width 45px // Tamaño del botón
    height 45px
    border-radius 50% // Botón circular
    display flex
    align-items center
    justify-content center
    cursor pointer
    // margin-left auto // No es necesario si el input es flex:1
    transition background 0.2s ease, transform 0.1s ease

    i // Ícono dentro del botón
      font-size 1.5em
      color white-color
      transition transform 0.1s ease // Para el efecto de hover en el ícono

    &:hover
      background linear-gradient(45deg, lighten(gradient-start, 10%), lighten(gradient-end, 10%)) // Aclarar gradiente en hover
      transform scale(1.05)

      i // Efecto en el ícono
        transform scale(1.1)


    &:active
      transform scale(0.95) // Efecto al presionar


// -----------------------------------------
//   MEDIA QUERIES PARA RESPONSIVIDAD
// -----------------------------------------
@media (max-width: break-point) // Usar la variable de Stylus para el breakpoint
  #frame
    margin-top 0
    height 100vh
    border-radius 0
    flex-direction column // Cambiar a layout de columna para móvil

  #sidepanel
    width 100%
    height auto // Altura automática para el panel lateral
    order 2 // Panel lateral abajo en móvil

  .content
    flex 1 // El contenido toma el espacio restante
    // height auto // No es necesario, flex:1 lo maneja
    order 1 // Contenido del chat arriba

  // Ajustes de padding y tamaño para móvil
  #profile
    padding 20px 15px
    .avatar-wrapper
      width 60px
      height 60px
    .user-info .username
      font-size 16px
    i.expand-button
      top 25px
      right 15px

  #status-options
    top 80px // Ajustar posición

  #search
    padding 10px 15px
    input
      padding 10px 40px 10px 15px
      font-size 13px
    .search-icon
      right 25px

  #contacts
    max-height 200px // Limitar altura de contactos en móvil para no ocupar toda la pantalla
    // Considerar ocultar/mostrar contactos con un botón en móvil si el espacio es limitado
    li.contact
      padding 10px 15px
    img.contact-img
      width 40px
      height 40px
    .contact-meta
      .contact-name
        font-size 15px
      .contact-preview
        font-size 12px
        max-width 150px // Ajustar preview max-width para móvil

  #bottom-bar
    padding 10px
    button.add-contact
      padding 10px 20px // Aumentado un poco el padding del botón
      font-size 14px

  .contact-header
    padding 12px 15px // Reducir padding
    img
      width 45px
      height 45px
    .header-info .header-name
      font-size 18px // Reducir tamaño de fuente
    .header-info .social-icons i
      font-size 16px

  .messages
    padding 15px

    li.message // Ajustes para burbujas y avatares de mensajes
      .msg-avatar
        width 40px // Reducir tamaño de avatar
        height 40px
      .msg-bubble
        max-width 75% // Permitir que las burbujas sean un poco más anchas
        padding 10px 15px // Reducir padding de burbuja
        font-size 14px
      .msg-time
        font-size 9px

  .message-input
    padding 10px 15px
    input
      padding 10px 15px
      font-size 14px
    .send-btn
      width 40px
      height 40px
      i
        font-size 1.3em
</style>