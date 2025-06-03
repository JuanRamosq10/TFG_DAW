const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: 'http://localhost:8080',
    methods: ['GET', 'POST'],
    credentials: true
  }
});

const saltRounds = 10;
const secretKey = process.env.JWT_SECRET || "mi_clave_secreta";

app.use(cors({ origin: 'http://localhost:8080', credentials: true }));
app.use(express.json({ limit: '50mb' }));
app.use(express.static('public'));

// Multer setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'public/uploads/'),
  filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
});
const upload = multer({ storage, limits: { fileSize: 40 * 1024 * 1024 } });

// MySQL Connection
const db = mysql.createConnection({ host: 'localhost', user: 'root', password: '', database: 'snap_story' });
db.connect(err => err ? console.error('❌ MySQL error:', err) : console.log('✅ MySQL connected'));

// JWT middleware
function verifyToken(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ message: 'No token provided' });
  }
  const parts = authHeader.split(' ');
  if (parts.length !== 2) {
    return res.status(401).json({ message: 'Token mal formado' });
  }
  const scheme = parts[0];
  const token = parts[1];
  if (!/^Bearer$/i.test(scheme)) {
    return res.status(401).json({ message: 'Token mal formado' });
  }
  jwt.verify(token, secretKey, (err, decoded) => {
    if (err) {
      return res.status(401).json({ message: 'Token inválido o expirado' });
    }
    req.user = decoded;
    next();
  });
}

// ----------- USUARIOS ----------- //
app.post('/api/register', (req, res) => {
  const { username, full_name, email, password } = req.body;
  if (!username || !full_name || !email || !password) {
    return res.status(400).json({ message: 'Todos los campos (username, full_name, email, password) son requeridos' });
  }
  bcrypt.hash(password, saltRounds, (err, hash) => {
    if (err) {
      console.error('❌ Error al hashear la contraseña:', err);
      return res.status(500).json({ message: 'Error al procesar la contraseña' });
    }
    const query = 'INSERT INTO users (username, full_name, email, password) VALUES (?, ?, ?, ?)';
    db.query(query, [username, full_name, email, hash], (err, results) => {
      if (err) {
        console.error('❌ Error insertando el usuario:', err);
        return res.status(500).json({ message: 'Error del servidor' });
      }
      res.json({ message: 'Usuario registrado correctamente', user_id: results.insertId });
    });
  });
});

app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ message: 'Username y contraseña son requeridos' });
  }
  const query = 'SELECT * FROM users WHERE username = ?';
  db.query(query, [username], (err, results) => {
    if (err) {
      console.error('❌ Error en la consulta:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    if (results.length === 0) {
      return res.status(401).json({ message: 'Usuario no encontrado' });
    }
    const user = results[0];
    bcrypt.compare(password, user.password, (err, isMatch) => {
      if (err) {
        console.error('❌ Error al comparar contraseñas:', err);
        return res.status(500).json({ message: 'Error del servidor' });
      }
      if (!isMatch) {
        return res.status(401).json({ message: 'Contraseña incorrecta' });
      }
      const token = jwt.sign(
        { id: user.user_id, username: user.username },
        secretKey,
        { expiresIn: '1h' }
      );
      res.json({
        message: 'ok',
        token,
        user: {
          id: user.user_id,
          username: user.username,
          full_name: user.full_name,
          email: user.email
        }
      });
    });
  });
});

app.get('/api/profile', verifyToken, (req, res) => {
  res.json({
    message: 'Perfil accedido correctamente',
    user: req.user
  });
});

// ----------- POSTS (ahora con contador de likes) ----------- //
app.get('/api/posts', (req, res) => {
  const query = `
    SELECT 
      posts.post_id,
      posts.title,
      posts.description,
      posts.source,
      posts.user_id,
      posts.created_at,
      users.username,
      COUNT(likes.like_id) AS likes
    FROM posts
    LEFT JOIN users ON posts.user_id = users.user_id
    LEFT JOIN likes ON posts.post_id = likes.post_id
    GROUP BY posts.post_id
  `;
  db.query(query, (err, results) => {
    if (err) {
      console.error('❌ Error en la consulta:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    const posts = results.map(post => ({
      ...post,
      likes: Number(post.likes) || 0
    }));
    res.json(posts);
  });
});

// ----------- RUTAS DE LIKES ----------- //

// Contar likes de un post
app.get('/api/posts/:postId/likes', (req, res) => {
  const postId = req.params.postId;
  const query = 'SELECT COUNT(*) AS likes FROM likes WHERE post_id = ?';
  db.query(query, [postId], (err, results) => {
    if (err) {
      console.error('❌ Error contando likes:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    res.json({ postId, likes: results[0].likes });
  });
});

// ─── 2) Ruta “dar like” CON log ───
app.post('/api/posts/:postId/like', verifyToken, (req, res) => {
  const postId = parseInt(req.params.postId, 10);
  const userId = req.user.id;
  console.log(`↳ [LIKE] userId=${userId}, postId=${postId}`);

  db.query('SELECT 1 FROM posts WHERE post_id = ?', [postId], (err, rows) => {
    if (err) {
      console.error('❌ Error comprobando post:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    if (rows.length === 0) {
      console.log('⚠️ Post no encontrado:', postId);
      return res.status(404).json({ message: 'Post no encontrado' });
    }

    db.query(
      'INSERT IGNORE INTO likes (post_id, user_id) VALUES (?, ?)',
      [postId, userId],
      (err, result) => {
        if (err) {
          console.error('❌ Error al dar like:', err);
          return res.status(500).json({ message: 'Error del servidor' });
        }
        if (result.affectedRows === 0) {
          console.log('ℹ️ Like ya existente para', { userId, postId });
          return res.json({ message: 'Ya le diste like a este post' });
        }
        console.log('✅ Like agregado:', { userId, postId });
        res.json({ message: 'Like agregado correctamente' });
      }
    );
  });
});

// Quitar like
app.delete('/api/posts/:postId/like', verifyToken, (req, res) => {
  const postId = req.params.postId;
  const userId = req.user.id;
  const query = 'DELETE FROM likes WHERE post_id = ? AND user_id = ?';
  db.query(query, [postId, userId], (err, results) => {
    if (err) {
      console.error('❌ Error al quitar like:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    res.json({ message: 'Like eliminado correctamente' });
  });
});

// ----------- RESTO DE POSTS ----------- //
app.post('/api/posts', verifyToken, upload.single('image'), (req, res) => {
  const { title, description } = req.body;
  const user_id = req.user.id;
  if (!title || !description || !req.file) {
    return res.status(400).json({ message: 'Faltan campos obligatorios o la imagen' });
  }
  const image = 'uploads/' + req.file.filename;
  const query = 'INSERT INTO posts (title, description, source, user_id) VALUES (?, ?, ?, ?)';
  db.query(query, [title, description, image, user_id], (err, results) => {
    if (err) {
      console.error('❌ Error insertando el post:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    res.json({ message: 'Post creado correctamente', postId: results.insertId });
  });
});

app.get('/api/myposts', verifyToken, (req, res) => {
  const userId = req.user.id;
  const query = `
    SELECT posts.*, users.username, COUNT(likes.like_id) AS likes
    FROM posts 
    LEFT JOIN users ON posts.user_id = users.user_id
    LEFT JOIN likes ON posts.post_id = likes.post_id
    WHERE posts.user_id = ?
    GROUP BY posts.post_id
  `;
  db.query(query, [userId], (err, results) => {
    if (err) {
      console.error('❌ Error en la consulta:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    res.json(results);
  });
});

app.delete('/api/posts/:postId', verifyToken, (req, res) => {
  const postId = req.params.postId;
  const userId = req.user.id;
  const selectQuery = 'SELECT * FROM posts WHERE post_id = ? AND user_id = ?';
  db.query(selectQuery, [postId, userId], (err, results) => {
    if (err) {
      console.error('❌ Error al verificar el post:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    if (results.length === 0) {
      return res.status(403).json({ message: 'No autorizado para eliminar este post' });
    }
    const deleteQuery = 'DELETE FROM posts WHERE post_id = ?';
    db.query(deleteQuery, [postId], (err, results) => {
      if (err) {
        console.error('❌ Error eliminando el post:', err);
        return res.status(500).json({ message: 'Error del servidor' });
      }
      res.json({ message: 'Post eliminado correctamente' });
    });
  });
});

app.put('/api/posts/:postId', verifyToken, (req, res) => {
  const postId = req.params.postId;
  const { title } = req.body;
  const userId = req.user.id;
  if (!title) {
    return res.status(400).json({ message: 'El título es obligatorio' });
  }
  const selectQuery = 'SELECT * FROM posts WHERE post_id = ? AND user_id = ?';
  db.query(selectQuery, [postId, userId], (err, results) => {
    if (err) {
      console.error('Error al verificar el post:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    if (results.length === 0) {
      return res.status(403).json({ message: 'No autorizado para modificar este post' });
    }
    const updateQuery = 'UPDATE posts SET title = ? WHERE post_id = ?';
    db.query(updateQuery, [title, postId], (err, results) => {
      if (err) {
        console.error('Error al actualizar el post:', err);
        return res.status(500).json({ message: 'Error del servidor' });
      }
      res.json({ message: 'Título actualizado correctamente' });
    });
  });
});

app.put('/api/posts/:postId/description', verifyToken, (req, res) => {
  const postId = req.params.postId;
  const { description } = req.body;
  const userId = req.user.id;
  if (!description) {
    return res.status(400).json({ message: 'La descripción es obligatoria' });
  }
  const selectQuery = 'SELECT * FROM posts WHERE post_id = ? AND user_id = ?';
  db.query(selectQuery, [postId, userId], (err, results) => {
    if (err) {
      console.error('Error al verificar el post:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    if (results.length === 0) {
      return res.status(403).json({ message: 'No autorizado para modificar este post' });
    }
    const updateQuery = 'UPDATE posts SET description = ? WHERE post_id = ?';
    db.query(updateQuery, [description, postId], (err, results) => {
      if (err) {
        console.error('Error al actualizar el post:', err);
        return res.status(500).json({ message: 'Error del servidor' });
      }
      res.json({ message: 'Descripción actualizada correctamente' });
    });
  });
});

//****JUAN**********

// ➤ Ruta para recuperar los seguidores de un usuario (requiere token válido)
app.get('/api/seguidores', verifyToken, (req, res) => {
  const userId = req.user.id;
  const query = `
    SELECT s.*, u.username, u.full_name
    FROM seguimientos s
    JOIN users u ON s.seguidor_id = u.user_id
    WHERE s.seguido_id = ?
  `;
  db.query(query, [userId], (err, results) => {
    if (err) {
      console.error('❌ Error en la consulta de seguidores:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    const seguidores = results.map(r => ({
      user_id:    r.seguidor_id,
      username:   r.username,
      full_name:  r.full_name,
      seguido_at: r.created_at
    }));
    res.json(seguidores);
  });
});

// ➤ Ruta para recuperar a quién sigue el usuario (requiere token válido)
app.get('/api/seguidos', verifyToken, (req, res) => {
  const userId = req.user.id;
  const query = `
    SELECT s.*, u.username, u.full_name
    FROM seguimientos s
    JOIN users u ON s.seguido_id = u.user_id
    WHERE s.seguidor_id = ?
  `;
  db.query(query, [userId], (err, results) => {
    if (err) {
      console.error('❌ Error en la consulta de seguidos:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    const seguidos = results.map(r => ({
      user_id:    r.seguido_id,
      username:   r.username,
      full_name:  r.full_name,
      seguido_at: r.created_at
    }));
    res.json(seguidos);
  });
});

// ➤ Ruta para seguir a un usuario (requiere token válido)
app.post('/api/seguir/:userId', verifyToken, (req, res) => {
  const userIdToFollow = parseInt(req.params.userId, 10);
  const userId       = req.user.id;

  if (userId === userIdToFollow) {
    return res.status(400).json({ message: 'No puedes seguirte a ti mismo' });
  }

  db.query('SELECT 1 FROM users WHERE user_id = ?', [userIdToFollow], (err, rows) => {
    if (err) {
      console.error('❌ Error comprobando usuario a seguir:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Usuario a seguir no encontrado' });
    }

    const q = `
      INSERT IGNORE INTO seguimientos (seguidor_id, seguido_id)
      VALUES (?, ?)
    `;
    db.query(q, [userId, userIdToFollow], (err, result) => {
      if (err) {
        console.error('❌ Error siguiendo al usuario:', err);
        return res.status(500).json({ message: 'Error del servidor' });
      }
      if (result.affectedRows === 0) {
        return res.status(200).json({ message: 'Ya sigues a este usuario' });
      }
      console.log(`✅ Usuario ${userId} sigue ahora a ${userIdToFollow}`);
      res.json({ message: 'Usuario seguido correctamente' });
    });
  });
});

// Recoger posts compartidos por el usuario autenticado
app.get('/api/sharedposts', verifyToken, (req, res) => {
  const userId = req.user.id;

  const query = `
    SELECT p.*, u.username
    FROM compartidos c
    JOIN posts p ON c.post_compartido_id = p.post_id
    JOIN users u ON p.user_id = u.user_id
    WHERE c.usuario_comparte_id = ?;
  `;

  db.query(query, [userId], (err, results) => {
    if (err) {
      console.error('❌ Error en la consulta:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    res.json(results);
  });
});


// Recoger posts guardados por el usuario autenticado
app.get('/api/savedposts', verifyToken, (req, res) => {
  const userId = req.user.id;

  const query = `
    SELECT p.*, u.username
    FROM guardados g
    JOIN posts p ON g.post_guardado_id = p.post_id
    JOIN users u ON p.user_id = u.user_id
    WHERE g.usuario_guarda_id = ?;
  `;

  db.query(query, [userId], (err, results) => {
    if (err) {
      console.error('❌ Error en la consulta:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    res.json(results);
  });
});




//****JUAN**********

// ----------- RUTAS DE CHAT ----------- //

// Ruta para obtener chats del usuario logueado
app.get('/api/chats', verifyToken, (req, res) => {
  const userId = req.user.id;

  const query = `
    SELECT
      c.chat_id,
      u.user_id         AS contact_id,
      u.username,
      u.full_name,
      m.message_text    AS last_message,
      m.created_at      AS last_message_time,
      m.sender_id       AS last_message_sender_id
    FROM chats c
    JOIN chat_participantes cp_self 
      ON c.chat_id = cp_self.chat_id AND cp_self.user_id = ?
    JOIN chat_participantes cp_other 
      ON c.chat_id = cp_other.chat_id AND cp_other.user_id != ?
    JOIN users u 
      ON cp_other.user_id = u.user_id
    LEFT JOIN (
      -- Primero obtenemos el mensaje con mayor mensaje_id por cada chat_id
      SELECT m1.*
      FROM mensajes m1
      JOIN (
        SELECT chat_id, MAX(mensaje_id) AS max_mid
        FROM mensajes
        GROUP BY chat_id
      ) sub ON m1.chat_id = sub.chat_id
             AND m1.mensaje_id = sub.max_mid
    ) m ON m.chat_id = c.chat_id
    ORDER BY m.created_at DESC;
  `;

  db.query(query, [userId, userId], (err, results) => {
    if (err) {
      console.error('❌ Error al obtener lista de chats:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    const chats = results.map(row => ({
      chat_id:             row.chat_id,
      contact_id:          row.contact_id,
      username:            row.username,
      full_name:           row.full_name,
      last_message:        row.last_message || '',
      last_message_time:   row.last_message_time || null,
      last_message_sender: row.last_message_sender_id || null
    }));
    res.json(chats);
  });
});


// 2.2) Obtener mensajes de un chat específico
app.get('/api/chats/:chatId/messages', verifyToken, (req, res) => {
  const userId = req.user.id;
  const chatId = parseInt(req.params.chatId, 10);

  if (isNaN(chatId)) {
    return res.status(400).json({ message: 'chatId inválido' });
  }

  const verifyQuery = 'SELECT 1 FROM chat_participantes WHERE chat_id = ? AND user_id = ?';
  db.query(verifyQuery, [chatId, userId], (err, rows) => {
    if (err) {
      console.error('❌ Error verificando participación en chat:', err);
      return res.status(500).json({ message: 'Error del servidor' });
    }
    if (rows.length === 0) {
      return res.status(403).json({ message: 'No autorizado para ver estos mensajes' });
    }

    const query = `
      SELECT 
        m.mensaje_id,
        m.chat_id,
        m.sender_id,
        u.username AS sender_username,
        u.full_name   AS sender_full_name,
        m.message_text,
        m.media_url,
        m.created_at
      FROM mensajes m
        JOIN users u ON m.sender_id = u.user_id
      WHERE m.chat_id = ?
      ORDER BY m.created_at ASC;
    `;
    db.query(query, [chatId], (err, results) => {
      if (err) {
        console.error('❌ Error al obtener mensajes:', err);
        return res.status(500).json({ message: 'Error del servidor' });
      }
      res.json(results);
    });
  });
});

// ----------- SOCKET.IO CHAT ----------- //
io.use((socket, next) => {
  const { token: authToken } = socket.handshake.auth;
  if (!authToken) {
    return next(new Error('No token provided'));
  }
  let token = authToken;
  if (token.startsWith('Bearer ')) {
    token = token.slice(7);
  }
  jwt.verify(token, secretKey, (err, decoded) => {
    if (err) {
      return next(new Error('Token inválido o expirado'));
    }
    socket.user = decoded;
    next();
  });
});

io.on('connection', socket => {
  console.log(`🔌 Usuario conectado: ${socket.user.username}`);

  socket.on('joinChat', ({ chatId }) => {
    socket.join(`chat_${chatId}`);
  });

  socket.on('sendMessage', ({ chatId, messageText, mediaUrl }) => {
    const insert = 'INSERT INTO mensajes (chat_id, sender_id, message_text, media_url) VALUES (?, ?, ?, ?)';
    db.query(insert, [chatId, socket.user.id, messageText, mediaUrl], (err, result) => {
      if (err) return console.error('❌ Error insertando mensaje:', err);
      const message = {
        mensaje_id: result.insertId,
        chat_id: chatId,
        sender_id: socket.user.id,
        message_text: messageText,
        media_url: mediaUrl,
        created_at: new Date()
      };
      io.to(`chat_${chatId}`).emit('newMessage', message);
    });
  });

  socket.on('disconnect', () => {
    console.log(`❌ Usuario desconectado: ${socket.user.username}`);
  });
});

// ----------- INICIO SERVIDOR ----------- //
server.listen(4000, () => {
  console.log('🚀 Servidor corriendo en http://localhost:4000');
});
