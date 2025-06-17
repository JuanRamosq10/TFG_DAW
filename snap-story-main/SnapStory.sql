CREATE DATABASE  IF NOT EXISTS `snap_story` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `snap_story`;
-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: snap_story
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `categoria_id` int NOT NULL AUTO_INCREMENT,
  `nombre_Categoria` varchar(255) NOT NULL,
  PRIMARY KEY (`categoria_id`),
  UNIQUE KEY `nombre_Categoria` (`nombre_Categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_participantes`
--

DROP TABLE IF EXISTS `chat_participantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_participantes` (
  `chat_id` int NOT NULL,
  `user_id` int NOT NULL,
  `joined_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`chat_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `chat_participantes_ibfk_1` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`chat_id`) ON DELETE CASCADE,
  CONSTRAINT `chat_participantes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_participantes`
--

LOCK TABLES `chat_participantes` WRITE;
/*!40000 ALTER TABLE `chat_participantes` DISABLE KEYS */;
INSERT INTO `chat_participantes` VALUES (1,1,'2025-06-13 15:57:27'),(1,2,'2025-06-13 15:57:27'),(2,1,'2025-06-13 17:52:49'),(2,3,'2025-06-13 17:52:49');
/*!40000 ALTER TABLE `chat_participantes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chats`
--

DROP TABLE IF EXISTS `chats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chats` (
  `chat_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`chat_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chats`
--

LOCK TABLES `chats` WRITE;
/*!40000 ALTER TABLE `chats` DISABLE KEYS */;
INSERT INTO `chats` VALUES (1,'Chat de Andres y Juan','2025-06-13 15:57:27'),(2,'Chat de Andres y Pedro','2025-06-13 17:52:49');
/*!40000 ALTER TABLE `chats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comentarios`
--

DROP TABLE IF EXISTS `comentarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comentarios` (
  `comentario_id` int NOT NULL AUTO_INCREMENT,
  `comentario_text` text,
  `usuario_comenta_id` int NOT NULL,
  `post_comentado_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comentario_id`),
  KEY `usuario_comenta_id` (`usuario_comenta_id`),
  KEY `post_comentado_id` (`post_comentado_id`),
  CONSTRAINT `comentarios_ibfk_1` FOREIGN KEY (`usuario_comenta_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `comentarios_ibfk_2` FOREIGN KEY (`post_comentado_id`) REFERENCES `posts` (`post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comentarios`
--

LOCK TABLES `comentarios` WRITE;
/*!40000 ALTER TABLE `comentarios` DISABLE KEYS */;
INSERT INTO `comentarios` VALUES (1,'Bonita imagen',2,1,'2025-06-13 18:14:52'),(2,'gracias juan',1,1,'2025-06-13 18:15:10'),(3,'hermosa montaña',3,5,'2025-06-13 18:36:36'),(4,'Bonita noche',1,2,'2025-06-17 10:48:48'),(5,'daasdfasdfsf',1,6,'2025-06-17 12:38:24'),(6,'kaksasaaaaaaaaaaaaaaaaaaaaaaaaaa  sdaaaaaaaaaaaa assss',1,6,'2025-06-17 12:55:13'),(7,'dasdasdasd\ndasdsad\nsadasd',1,6,'2025-06-17 12:59:51'),(8,'holaa\nhola',1,6,'2025-06-17 13:00:07');
/*!40000 ALTER TABLE `comentarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compartidos`
--

DROP TABLE IF EXISTS `compartidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compartidos` (
  `compartido_id` int NOT NULL AUTO_INCREMENT,
  `usuario_comparte_id` int NOT NULL,
  `post_compartido_id` int NOT NULL,
  PRIMARY KEY (`compartido_id`),
  UNIQUE KEY `compartido_unico` (`usuario_comparte_id`,`post_compartido_id`),
  KEY `post_compartido_id` (`post_compartido_id`),
  CONSTRAINT `compartidos_ibfk_1` FOREIGN KEY (`usuario_comparte_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `compartidos_ibfk_2` FOREIGN KEY (`post_compartido_id`) REFERENCES `posts` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compartidos`
--

LOCK TABLES `compartidos` WRITE;
/*!40000 ALTER TABLE `compartidos` DISABLE KEYS */;
/*!40000 ALTER TABLE `compartidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guardados`
--

DROP TABLE IF EXISTS `guardados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guardados` (
  `guardado_id` int NOT NULL AUTO_INCREMENT,
  `usuario_guarda_id` int NOT NULL,
  `post_guardado_id` int NOT NULL,
  PRIMARY KEY (`guardado_id`),
  UNIQUE KEY `guardado_unico` (`usuario_guarda_id`,`post_guardado_id`),
  KEY `post_guardado_id` (`post_guardado_id`),
  CONSTRAINT `guardados_ibfk_1` FOREIGN KEY (`usuario_guarda_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `guardados_ibfk_2` FOREIGN KEY (`post_guardado_id`) REFERENCES `posts` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guardados`
--

LOCK TABLES `guardados` WRITE;
/*!40000 ALTER TABLE `guardados` DISABLE KEYS */;
/*!40000 ALTER TABLE `guardados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historias`
--

DROP TABLE IF EXISTS `historias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historias` (
  `historia_id` int NOT NULL AUTO_INCREMENT,
  `source` varchar(255) DEFAULT NULL,
  `categoria_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`historia_id`),
  KEY `categoria_id` (`categoria_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `historias_ibfk_1` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`categoria_id`),
  CONSTRAINT `historias_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historias`
--

LOCK TABLES `historias` WRITE;
/*!40000 ALTER TABLE `historias` DISABLE KEYS */;
/*!40000 ALTER TABLE `historias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `likes`
--

DROP TABLE IF EXISTS `likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `likes` (
  `like_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `post_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `user_id` (`user_id`,`post_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `likes`
--

LOCK TABLES `likes` WRITE;
/*!40000 ALTER TABLE `likes` DISABLE KEYS */;
INSERT INTO `likes` VALUES (1,1,1,'2025-06-13 17:45:58'),(2,1,2,'2025-06-13 18:26:12'),(3,1,3,'2025-06-13 18:26:35'),(4,1,4,'2025-06-13 18:26:54'),(5,3,1,'2025-06-13 18:34:22'),(6,1,5,'2025-06-13 18:36:59'),(7,1,6,'2025-06-17 11:00:20');
/*!40000 ALTER TABLE `likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mensajes`
--

DROP TABLE IF EXISTS `mensajes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mensajes` (
  `mensaje_id` int NOT NULL AUTO_INCREMENT,
  `chat_id` int NOT NULL,
  `sender_id` int NOT NULL,
  `message_text` text NOT NULL,
  `media_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`mensaje_id`),
  KEY `idx_mensajes_chat` (`chat_id`),
  KEY `idx_mensajes_sender` (`sender_id`),
  CONSTRAINT `mensajes_ibfk_1` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`chat_id`) ON DELETE CASCADE,
  CONSTRAINT `mensajes_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mensajes`
--

LOCK TABLES `mensajes` WRITE;
/*!40000 ALTER TABLE `mensajes` DISABLE KEYS */;
INSERT INTO `mensajes` VALUES (1,1,1,'Hola juan',NULL,'2025-06-13 15:57:38'),(2,1,2,'Hola Andres',NULL,'2025-06-13 15:58:13'),(3,1,1,'fsdfsdf',NULL,'2025-06-13 17:20:13'),(4,2,1,'hola',NULL,'2025-06-13 17:53:01'),(5,2,3,'dsadsda',NULL,'2025-06-17 12:37:26');
/*!40000 ALTER TABLE `mensajes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `posts` (
  `post_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `source` varchar(255) DEFAULT NULL,
  `categoria_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`),
  KEY `categoria_id` (`categoria_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`categoria_id`),
  CONSTRAINT `posts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts`
--

LOCK TABLES `posts` WRITE;
/*!40000 ALTER TABLE `posts` DISABLE KEYS */;
INSERT INTO `posts` VALUES (1,'Black Chains','Cadenas en monocroma','uploads/1749830360687-2113.jpg',NULL,1,'2025-06-13 15:59:20'),(2,'Luna','Noche de Luna llena','uploads/1749830391913-2128.jpg',NULL,2,'2025-06-13 15:59:51'),(3,'Jungla','Wallpaper Omen de Jungla','uploads/1749830420528-Jungle.png',NULL,1,'2025-06-13 16:00:20'),(4,'Galaxy','Foto al cielo nocturno despejado','uploads/1749830477537-2185.jpg',NULL,2,'2025-06-13 16:01:17'),(5,'Montaña','Montaña Monocroma','uploads/1749839450467-qdaTKo.jpg',NULL,3,'2025-06-13 18:30:50'),(6,'sdadsa','asddd','uploads/1750157956297-2113.jpg',NULL,1,'2025-06-17 10:59:16');
/*!40000 ALTER TABLE `posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seguimientos`
--

DROP TABLE IF EXISTS `seguimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seguimientos` (
  `seguimiento_id` int NOT NULL AUTO_INCREMENT,
  `seguidor_id` int NOT NULL,
  `seguido_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`seguimiento_id`),
  UNIQUE KEY `seguimiento_unico` (`seguidor_id`,`seguido_id`),
  KEY `seguido_id` (`seguido_id`),
  CONSTRAINT `seguimientos_ibfk_1` FOREIGN KEY (`seguidor_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `seguimientos_ibfk_2` FOREIGN KEY (`seguido_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seguimientos`
--

LOCK TABLES `seguimientos` WRITE;
/*!40000 ALTER TABLE `seguimientos` DISABLE KEYS */;
/*!40000 ALTER TABLE `seguimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `profile_img` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Andres','Andres Salinas','andres@andres.com','$2b$10$pn5VIooi19tp7wwmjrG9.u6Xmq2EWdG9dHA04V0qOzVnze804NMYO',NULL,'2025-06-13 15:55:42'),(2,'Juan','Juan Ramos','juan@juan.com','$2b$10$X/VPOV4nDH/5kH6Os8wHdOhJCedRNzdK3/gz3AQuHbX8JbLJzy1ga',NULL,'2025-06-13 15:55:54'),(3,'Pedro','Pedro Jimenez','pedro@pero.com','$2b$10$svjBBMkzXRhrP66XHnXJq.mt3ydsCjM51o0io42Etvbg/Nf4uKq/K',NULL,'2025-06-13 17:47:55');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-17 15:09:41
