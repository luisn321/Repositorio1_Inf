-- ============================================================
-- SERVITEC - DDL MySQL (VERSIÓN CONSOLIDADA - PRODUCCIÓN)
-- Versión: 2.0 (Incluye Stripe Escrow, Propuestas y Calificaciones)
-- ============================================================

CREATE DATABASE IF NOT EXISTS servitec CHARACTER SET = 'utf8mb4' COLLATE = 'utf8mb4_general_ci';
USE servitec;

-- ============================================================
-- 1. TABLA: clientes
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
  foto_perfil_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_active TINYINT(1) DEFAULT 1,
  INDEX idx_email (email)
) ENGINE=InnoDB;

-- ============================================================
-- 2. TABLA: servicios
-- ============================================================
CREATE TABLE servicios (
  id_servicio INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  icono VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- 3. TABLA: tecnicos
-- ============================================================
CREATE TABLE tecnicos (
  id_tecnico INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  apellido VARCHAR(100),
  email VARCHAR(150) UNIQUE,
  password_hash VARCHAR(255),
  telefono VARCHAR(30),
  ubicacion_text TEXT,
  latitud DOUBLE,
  longitud DOUBLE,
  tarifa_hora DECIMAL(10,2),
  experiencia_years INT,
  descripcion TEXT,
  foto_perfil_url VARCHAR(500),
  calificacion_promedio DECIMAL(3,2) DEFAULT 0.00,
  num_calificaciones INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  is_active TINYINT(1) DEFAULT 1,
  INDEX idx_email (email)
) ENGINE=InnoDB;

-- ============================================================
-- 4. TABLA: tecnico_servicio (Relación M:N)
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
-- 5. TABLA: contrataciones
-- Incluye flujo de propuestas, reagendado y Stripe Escrow
-- ============================================================
CREATE TABLE contrataciones (
  id_contratacion INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  id_tecnico INT DEFAULT NULL,
  id_servicio INT NOT NULL,
  estado VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
  fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_programada DATETIME, -- Usada como fecha estimada/programada
  hora_solicitada VARCHAR(20),
  detalles TEXT,
  ubicacion TEXT,
  fotos_cliente_urls TEXT, -- Almacenado como JSON string
  fotos_trabajo_urls TEXT, -- Almacenado como JSON string
  
  -- Lógica de Montos y Pago (Stripe)
  monto_propuesto DECIMAL(12,2) DEFAULT NULL,
  estado_monto VARCHAR(30) DEFAULT 'Sin Propuesta',
  payment_intent_id VARCHAR(255),
  clabe_tecnico VARCHAR(18),
  monto_pagado DECIMAL(12,2),
  fecha_pago DATETIME,

  -- Propuestas de cambio de fecha/hora (Reagendado)
  fecha_propuesta_cambios TIMESTAMP NULL,
  fecha_propuesta_solicitada DATE NULL,
  hora_propuesta_solicitada VARCHAR(20) NULL,
  motivo_cambio TEXT NULL,

  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE,
  FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id_tecnico) ON DELETE SET NULL,
  FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio),
  INDEX idx_estado (estado),
  INDEX idx_estado_monto (estado_monto)
) ENGINE=InnoDB;

-- ============================================================
-- 6. TABLA: calificaciones
-- ============================================================
CREATE TABLE calificaciones (
  id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
  id_contratacion INT,
  id_tecnico INT,
  puntuacion TINYINT NOT NULL,
  comentario TEXT,
  fotos_resena_urls TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_contratacion) REFERENCES contrataciones(id_contratacion) ON DELETE SET NULL,
  FOREIGN KEY (id_tecnico) REFERENCES tecnicos(id_tecnico) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- RESTRICCIONES Y VALIDACIONES (CONSTRAINTS)
-- ============================================================
ALTER TABLE calificaciones ADD CONSTRAINT chk_puntuacion CHECK (puntuacion BETWEEN 1 AND 5);

ALTER TABLE contrataciones ADD CONSTRAINT chk_estado_contratacion 
  CHECK (estado IN ('Pendiente', 'Aceptada', 'En Progreso', 'Completada', 'Cancelada'));

ALTER TABLE contrataciones ADD CONSTRAINT chk_estado_monto 
  CHECK (estado_monto IN ('Sin Propuesta', 'Propuesto', 'Aceptado', 'Rechazado', 'Pagado (Retenido)', 'Pago Liberado', 'Reembolsado'));

-- ============================================================
-- DATOS INICIALES: Servicios
-- ============================================================
INSERT INTO servicios (nombre, descripcion, icono) VALUES
('Electricista', 'Servicios de instalación y reparación eléctrica', 'Icons.bolt'),
('Plomero', 'Reparación de tuberías y sistemas de agua', 'Icons.plumbing'),
('Carpintero', 'Trabajos de carpintería y muebles', 'Icons.handyman'),
('Técnico PC', 'Reparación y mantenimiento de computadoras', 'Icons.computer'),
('Jardinería', 'Cuidado de plantas y áreas verdes', 'Icons.forest'),
('Línea Blanca', 'Reparación de electrodomésticos y estufas', 'Icons.bolt');

-- ============================================================
-- TRIGGER: Actualizar estadísticas de técnico al calificar
-- ============================================================
DELIMITER //
CREATE TRIGGER tr_update_tecnico_stats
AFTER INSERT ON calificaciones
FOR EACH ROW
BEGIN
  UPDATE tecnicos SET 
    num_calificaciones = (SELECT COUNT(*) FROM calificaciones WHERE id_tecnico = NEW.id_tecnico),
    calificacion_promedio = (SELECT AVG(puntuacion) FROM calificaciones WHERE id_tecnico = NEW.id_tecnico)
  WHERE id_tecnico = NEW.id_tecnico;
END //
DELIMITER ;
