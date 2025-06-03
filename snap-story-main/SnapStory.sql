-- Eliminar la base de datos si ya existe
DROP DATABASE IF EXISTS snap_story;

-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS snap_story;

-- Usar la base de datos recién creada
USE snap_story;

-- Crear la tabla 'users' con una estructura mejorada incluyendo 'username'
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,  -- Nombre de usuario único
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear la tabla 'posts'
CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    source VARCHAR(255),
    user_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);


INSERT INTO posts (title, description, source, user_id)
VALUES ('Chains in black', 'Cadenas en monocroma', 'uploads/1.jpg', 1);

