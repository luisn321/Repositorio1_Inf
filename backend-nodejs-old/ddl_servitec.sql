-- ============================================================
-- SERVITEC - DDL MySQL
-- Base de datos para conectar clientes con técnicos
-- ============================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS servitec CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_general_ci';
USE servitec;

-- ============================================================
-- TABLA: clientes
-- Almacena datos de clientes que solicitan servicios
-- ============================================================
CREATE TABLE clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100),
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  direccion_text TEXT,
  latitud DOUBLE,
  longitud DOUBLE,
  telefono VARCHAR(30),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_active TINYINT(1) DEFAULT 1,
  INDEX idx_email (email),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: servicios
-- Catálogo de servicios disponibles (Electricista, Plomero, etc.)
-- ============================================================
CREATE TABLE servicios (
  id_servicio INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  icono VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: tecnicos
-- Datos de técnicos que ofrecen servicios
-- ============================================================
CREATE TABLE tecnicos (
  id_tecnico INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  email VARCHAR(150) UNIQUE,
  password_hash VARCHAR(255),
  telefono VARCHAR(30),
  ubicacion_text TEXT,
  latitud DOUBLE,
  longitud DOUBLE,
  tarifa_hora DECIMAL(10,2),
  experiencia_years INT,
  descripcion TEXT,
  calificacion_promedio DECIMAL(3,2) DEFAULT 0.00,
  num_calificaciones INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_active TINYINT(1) DEFAULT 1,
  INDEX idx_email (email),
  INDEX idx_latlong (latitud, longitud),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: tecnico_servicio
-- Relación many-to-many entre técnicos y servicios
-- Un técnico puede ofrecer múltiples servicios
-- ============================================================
CREATE TABLE tecnico_servicio (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_tecnico INT NOT NULL,
  id_servicio INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY ux_tecnico_servicio (id_tecnico, id_servicio),
  FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id_tecnico) ON DELETE CASCADE,
  FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: contrataciones
-- Solicitudes de servicio creadas por clientes
-- ============================================================
CREATE TABLE contrataciones (
  id_contratacion INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  id_tecnico INT DEFAULT NULL,
  id_servicio INT NOT NULL,
  fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_programada DATE,
  detalles TEXT,
  estado VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE,
  FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id_tecnico) ON DELETE SET NULL,
  FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio),
  INDEX idx_id_cliente (id_cliente),
  INDEX idx_id_tecnico (id_tecnico),
  INDEX idx_estado (estado),
  INDEX idx_fecha_programada (fecha_programada)
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: pagos
-- Registro de pagos por contrataciones
-- ============================================================
CREATE TABLE pagos (
  id_pago INT AUTO_INCREMENT PRIMARY KEY,
  id_contratacion INT NOT NULL,
  monto DECIMAL(12,2) NOT NULL,
  metodo_pago VARCHAR(50),
  transaction_ref VARCHAR(255),
  fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  estado_pago VARCHAR(30) DEFAULT 'Pendiente',
  FOREIGN KEY (id_contratacion) REFERENCES contrataciones(id_contratacion) ON DELETE CASCADE,
  INDEX idx_estado_pago (estado_pago),
  INDEX idx_fecha_pago (fecha_pago)
) ENGINE=InnoDB;

-- ============================================================
-- TABLA: calificaciones
-- Reseñas y calificaciones de clientes sobre técnicos
-- ============================================================
CREATE TABLE calificaciones (
  id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
  id_contratacion INT,
  id_tecnico INT,
  puntuacion TINYINT NOT NULL,
  comentario TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_contratacion) REFERENCES contrataciones(id_contratacion) ON DELETE SET NULL,
  FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id_tecnico) ON DELETE SET NULL,
  INDEX idx_id_tecnico (id_tecnico),
  INDEX idx_puntuacion (puntuacion)
) ENGINE=InnoDB;

-- ============================================================
-- INSERTS DE DATOS INICIALES (Servicios)
-- ============================================================
INSERT INTO servicios (nombre, descripcion, icono) VALUES
('Electricista', 'Servicios de instalación y reparación eléctrica', 'Icons.bolt'),
('Plomero', 'Reparación de tuberías y sistemas de agua', 'Icons.plumbing'),
('Carpintero', 'Trabajos de carpintería y carpintería', 'Icons.handyman'),
('Técnico PC', 'Reparación y mantenimiento de computadoras', 'Icons.computer'),
('Jardinería', 'Cuidado de plantas, tala de arboles y paisajismo', 'Icons.forest'),
('Reparación Línea Blanca', 'Reparación de electrodomésticos', 'Icons.bolt');

-- ============================================================
-- Restricciones y validaciones
-- ============================================================
-- CHECK para puntuaciones (1-5)
ALTER TABLE calificaciones ADD CONSTRAINT chk_puntuacion CHECK (puntuacion BETWEEN 1 AND 5);

-- CHECK para estados válidos
ALTER TABLE contrataciones ADD CONSTRAINT chk_estado_contratacion 
  CHECK (estado IN ('Pendiente', 'Aceptada', 'En Progreso', 'Completada', 'Cancelada'));

ALTER TABLE pagos ADD CONSTRAINT chk_estado_pago 
  CHECK (estado_pago IN ('Pendiente', 'Completado', 'Fallido'));

-- ============================================================
-- ÍNDICES ADICIONALES PARA QUERIES FRECUENTES
-- ============================================================
CREATE INDEX idx_cliente_contrataciones ON contrataciones(id_cliente, estado);
CREATE INDEX idx_tecnico_calificaciones ON calificaciones(id_tecnico, puntuacion);
