-- Eliminar la base de datos si ya existe
DROP DATABASE IF EXISTS snap_story;

-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS snap_story;

-- Usar la base de datos recién creada
USE snap_story;

-- Tabla: categorias
CREATE TABLE categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_Categoria VARCHAR(255) NOT NULL UNIQUE
);

-- Tabla: chats
CREATE TABLE chats (
    chat_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: users
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    profile_img VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: posts
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    source VARCHAR(255),
    categoria_id INT,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Tabla: comentarios
CREATE TABLE comentarios (
    comentario_id INT AUTO_INCREMENT PRIMARY KEY,
    comentario_text TEXT,
    usuario_comenta_id INT NOT NULL,
    post_comentado_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_comenta_id) REFERENCES users(user_id),
    FOREIGN KEY (post_comentado_id) REFERENCES posts(post_id)
);

-- Tabla: compartidos
CREATE TABLE compartidos (
    compartido_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_comparte_id INT NOT NULL,
    post_compartido_id INT NOT NULL,
    UNIQUE KEY compartido_unico (usuario_comparte_id, post_compartido_id),
    FOREIGN KEY (usuario_comparte_id) REFERENCES users(user_id),
    FOREIGN KEY (post_compartido_id) REFERENCES posts(post_id)
);

-- Tabla: guardados
CREATE TABLE guardados (
    guardado_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_guarda_id INT NOT NULL,
    post_guardado_id INT NOT NULL,
    UNIQUE KEY guardado_unico (usuario_guarda_id, post_guardado_id),
    FOREIGN KEY (usuario_guarda_id) REFERENCES users(user_id),
    FOREIGN KEY (post_guardado_id) REFERENCES posts(post_id)
);

-- Tabla: historias
CREATE TABLE historias (
    historia_id INT AUTO_INCREMENT PRIMARY KEY,
    source VARCHAR(255),
    categoria_id INT,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Tabla: likes
CREATE TABLE likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);

-- Tabla: seguimientos
CREATE TABLE seguimientos (
    seguimiento_id INT AUTO_INCREMENT PRIMARY KEY,
    seguidor_id INT NOT NULL,
    seguido_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY seguimiento_unico (seguidor_id, seguido_id),
    FOREIGN KEY (seguidor_id) REFERENCES users(user_id),
    FOREIGN KEY (seguido_id) REFERENCES users(user_id)
);

-- Tabla: chat_participantes
CREATE TABLE chat_participantes (
    chat_id INT NOT NULL,
    user_id INT NOT NULL,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (chat_id, user_id),
    FOREIGN KEY (chat_id) REFERENCES chats(chat_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Tabla: mensajes
CREATE TABLE mensajes (
    mensaje_id INT AUTO_INCREMENT PRIMARY KEY,
    chat_id INT NOT NULL,
    sender_id INT NOT NULL,
    message_text TEXT NOT NULL,
    media_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (chat_id) REFERENCES chats(chat_id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE
);

