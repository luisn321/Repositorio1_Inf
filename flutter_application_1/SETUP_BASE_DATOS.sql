-- ============================================================
-- SERVITEC - DDL MySQL (PARA C# BACKEND)
-- Base de datos correctamente alineada con el backend ASP.NET
-- ============================================================

-- Crear base de datos
DROP DATABASE IF EXISTS servitec;
CREATE DATABASE servitec CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE servitec;

-- ============================================================
-- TABLA: usuarios
-- Almacena todos los usuarios (clientes y técnicos)
-- ============================================================
CREATE TABLE usuarios (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  apellido VARCHAR(120),
  email VARCHAR(150) NOT NULL UNIQUE,
  contrasena VARCHAR(255) NOT NULL,
  tipo_usuario VARCHAR(50) NOT NULL, -- 'client' o 'technician'
  telefono VARCHAR(30),
  
  -- Para clientes
  direccion_text TEXT,
  
  -- Para técnicos
  ubicacion_text TEXT,
  tarifa_hora DECIMAL(10,2),
  
  -- Comunes
  latitud DOUBLE,
  longitud DOUBLE,
  foto_perfil_url VARCHAR(500),
  
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  activo TINYINT(1) DEFAULT 1,
  
  INDEX idx_email (email),
  INDEX idx_tipo_usuario (tipo_usuario),
  INDEX idx_fecha_registro (fecha_registro)
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: servicios
-- Catálogo de servicios disponibles
-- ============================================================
CREATE TABLE servicios (
  id_servicio INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  icono VARCHAR(50),
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Insertar servicios predefinidos
INSERT INTO servicios (nombre, descripcion, icono) VALUES
('Electricista', 'Servicios de electricidad y mantenimiento eléctrico', 'electricity'),
('Plomero', 'Servicios de plomería y tuberías', 'plumbing'),
('Carpintero', 'Servicios de carpintería y construcción', 'carpenter'),
('Técnico PC', 'Soporte técnico de computadoras', 'computer'),
('Jardinería', 'Servicios de jardinería y paisajismo', 'garden'),
('Línea Blanca', 'Reparación de electrodomésticos', 'appliances');

-- ============================================================
-- TABLA: tecnico_servicio
-- Relación many-to-many: técnicos y servicios que ofrecen
-- ============================================================
CREATE TABLE tecnico_servicio (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tecnico INT NOT NULL,
  id_servicio INT NOT NULL,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE KEY ux_tecnico_servicio (id_tecnico, id_servicio),
  FOREIGN KEY (id_tecnico) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: calificaciones
-- Reseñas y calificaciones de técnicos
-- ============================================================
CREATE TABLE calificaciones (
  id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
  id_tecnico INT NOT NULL,
  id_cliente INT NOT NULL,
  puntuacion INT CHECK (puntuacion >= 1 AND puntuacion <= 5),
  comentario TEXT,
  fecha_calificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_tecnico) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  FOREIGN KEY (id_cliente) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  INDEX idx_tecnico (id_tecnico),
  INDEX idx_cliente (id_cliente)
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: contrataciones
-- Solicitudes de servicio entre clientes y técnicos
-- ============================================================
CREATE TABLE contrataciones (
  id_contratacion INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  id_servicio INT NOT NULL,
  id_tecnico INT,
  estado VARCHAR(50) DEFAULT 'pending', -- pending, accepted, completed, cancelled
  detalles TEXT,
  fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_programada DATETIME,
  fecha_completada DATETIME,
  
  FOREIGN KEY (id_cliente) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  FOREIGN KEY (id_tecnico) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
  FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio) ON DELETE CASCADE,
  INDEX idx_cliente (id_cliente),
  INDEX idx_tecnico (id_tecnico),
  INDEX idx_estado (estado),
  INDEX idx_fecha_solicitud (fecha_solicitud)
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: pagos
-- Registro de pagos por servicios completados
-- ============================================================
CREATE TABLE pagos (
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_contratacion INT NOT NULL,
  id_cliente INT NOT NULL,
  id_tecnico INT NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  estado VARCHAR(50) DEFAULT 'pending', -- pending, completed, cancelled
  metodo_pago VARCHAR(50), -- credit_card, cash, transfer, etc.
  fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_contratacion) REFERENCES contrataciones(id_contratacion) ON DELETE CASCADE,
  FOREIGN KEY (id_cliente) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  FOREIGN KEY (id_tecnico) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  INDEX idx_cliente (id_cliente),
  INDEX idx_tecnico (id_tecnico),
  INDEX idx_estado (estado),
  INDEX idx_fecha_pago (fecha_pago)
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: chat_mensajes
-- Mensajes de chat entre clientes y técnicos
-- ============================================================
CREATE TABLE chat_mensajes (
  id_mensaje INT AUTO_INCREMENT PRIMARY KEY,
  id_remitente INT NOT NULL,
  id_destinatario INT NOT NULL,
  id_contratacion INT,
  mensaje TEXT NOT NULL,
  leido TINYINT(1) DEFAULT 0,
  fecha_mensaje TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_remitente) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  FOREIGN KEY (id_destinatario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  FOREIGN KEY (id_contratacion) REFERENCES contrataciones(id_contratacion) ON DELETE SET NULL,
  INDEX idx_remitente (id_remitente),
  INDEX idx_destinatario (id_destinatario),
  INDEX idx_fecha (fecha_mensaje)
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: notificaciones
-- Sistema de notificaciones para usuarios
-- ============================================================
CREATE TABLE notificaciones (
  id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  tipo VARCHAR(50), -- contact_request, service_completed, payment, etc.
  titulo VARCHAR(200),
  mensaje TEXT,
  url_referencia VARCHAR(500),
  leida TINYINT(1) DEFAULT 0,
  fecha_notificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  INDEX idx_usuario (id_usuario),
  INDEX idx_leida (leida),
  INDEX idx_fecha (fecha_notificacion)
) ENGINE=InnoDB;

-- ============================================================
-- VISTAS ÚTILES PARA CONSULTAS
-- ============================================================

-- Vista: Técnicos con sus servicios
CREATE VIEW vw_tecnicos_servicios AS
SELECT 
  u.id_usuario,
  u.nombre,
  u.apellido,
  u.email,
  u.telefono,
  u.ubicacion_text,
  u.latitud,
  u.longitud,
  u.tarifa_hora,
  u.foto_perfil_url,
  GROUP_CONCAT(s.nombre SEPARATOR ', ') AS servicios,
  COUNT(c.id_calificacion) AS num_calificaciones,
  IFNULL(AVG(c.puntuacion), 0) AS calificacion_promedio
FROM usuarios u
LEFT JOIN tecnico_servicio ts ON u.id_usuario = ts.id_tecnico
LEFT JOIN servicios s ON ts.id_servicio = s.id_servicio
LEFT JOIN calificaciones c ON u.id_usuario = c.id_tecnico
WHERE u.tipo_usuario = 'technician'
GROUP BY u.id_usuario;

-- Vista: Contrataciones activas
CREATE VIEW vw_contrataciones_activas AS
SELECT 
  c.id_contratacion,
  c.id_cliente,
  uc.nombre AS nombre_cliente,
  c.id_tecnico,
  ut.nombre AS nombre_tecnico,
  s.nombre AS nombre_servicio,
  c.estado,
  c.fecha_solicitud,
  c.fecha_programada
FROM contrataciones c
JOIN usuarios uc ON c.id_cliente = uc.id_usuario
LEFT JOIN usuarios ut ON c.id_tecnico = ut.id_usuario
JOIN servicios s ON c.id_servicio = s.id_servicio
WHERE c.estado IN ('pending', 'accepted');

-- ============================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- ============================================================

CREATE INDEX idx_usuarios_email_tipo ON usuarios(email, tipo_usuario);
CREATE INDEX idx_contrataciones_cliente_tecnico ON contrataciones(id_cliente, id_tecnico);
CREATE INDEX idx_pagos_estado_fecha ON pagos(estado, fecha_pago);

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
-- Nota: Las contraseñas deben hasharse con BCrypt en el backend
-- Ejemplo en C#: BCrypt.Net.BCrypt.HashPassword(password);
