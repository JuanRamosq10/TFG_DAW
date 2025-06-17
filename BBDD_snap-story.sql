-- Eliminar la base de datos si ya existe
DROP DATABASE IF EXISTS snap_story;

-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS snap_story;

-- Usar la base de datos recién creada
USE snap_story;

-- Crear la tabla 'users'
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear la tabla 'categorias'
CREATE TABLE categorias (
categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_Categoria VARCHAR(255) NOT NULL UNIQUE
);

-- Crear la tabla 'posts'
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


-- Crear la tabla 'historias'
CREATE TABLE historias (
historia_id INT AUTO_INCREMENT PRIMARY KEY,
    source VARCHAR(255),
    categoria_id INT,
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


-- Crear la tabla 'seguimientos'
CREATE TABLE seguimientos (
seguimiento_id INT AUTO_INCREMENT PRIMARY KEY,
    seguidor_id INT NOT NULL,
    seguido_id INT NOT NULL,
    foreign key (seguidor_id) references users(user_id),
    foreign key (seguido_id) references users(user_id),
    constraint seguimiento_unico UNIQUE (seguidor_id, seguido_id) -- Para que un usuario no pueda seguir mas de una vez al mismo usuario
);


-- Crear la tabla 'compartidos'
CREATE TABLE compartidos (
compartido_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_comparte_id INT NOT NULL,
    post_compartido_id INT NOT NULL,
    foreign key (usuario_comparte_id) references users(user_id),
    foreign key (post_compartido_id) references posts(post_id),
    constraint compartido_unico UNIQUE (usuario_comparte_id, post_compartido_id) -- Para que un usuario no pueda compartir un post mas de una vez
);

-- Crear la tabla 'likes'
CREATE TABLE likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);


-- Crear la tabla 'guardados'
CREATE TABLE guardados (
Guardado_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_guarda_id INT NOT NULL,
    post_guardado_id INT NOT NULL,
    foreign key (usuario_guarda_id) references users(user_id),
    foreign key (post_guardado_id) references posts(post_id),
    constraint compartido_unico UNIQUE (usuario_guarda_id, post_guardado_id) -- Para que un usuario no pueda compartir un post mas de una vez
);


-- Crear la tabla 'comentarios'
CREATE TABLE comentarios (
comentario_id INT AUTO_INCREMENT PRIMARY KEY,
    comentario_text text,
    usuario_comenta_id INT NOT NULL,
    post_comentado_id INT NOT NULL,
    foreign key (usuario_comenta_id) references users(user_id),
    foreign key (post_comentado_id) references posts(post_id)
);
