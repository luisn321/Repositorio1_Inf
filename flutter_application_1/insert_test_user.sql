-- Script para insertar usuarios de prueba
USE servitec;

-- Insertar un cliente de prueba
-- Email: cliente@test.com
-- Contraseña: password123 (hasheada con BCrypt)
INSERT INTO clientes (nombre, apellido, email, password_hash, telefono, direccion_text, latitud, longitud)
VALUES (
    'Juan',
    'Pérez',
    'cliente@test.com',
    '$2a$11$YourHashHere', -- This will be replaced by PHP hash
    '1234567890',
    'Calle Principal 123',
    40.7128,
    -74.0060
);

-- Insertar un técnico de prueba
-- Email: tecnico@test.com
-- Contraseña: password123 (hasheada con BCrypt)
INSERT INTO tecnicos (nombre, email, password_hash, telefono, ubicacion_text, latitud, longitud, tarifa_hora, experiencia_years, descripcion)
VALUES (
    'Carlos García',
    'tecnico@test.com',
    '$2a$11$YourHashHere', -- This will be replaced by PHP hash
    '9876543210',
    'Barrio Industrial 456',
    40.7580,
    -73.9855,
    50.00,
    5,
    'Técnico con 5 años de experiencia en electricidad'
);

-- Insertar relación técnico-servicio
-- Primero necesitamos los IDs que se generaron
-- SELECT LAST_INSERT_ID(); para obtener el ID del técnico

INSERT INTO tecnico_servicio (id_tecnico, id_servicio)
VALUES (
    LAST_INSERT_ID(),
    1  -- Electricista
);

INSERT INTO tecnico_servicio (id_tecnico, id_servicio)
VALUES (
    LAST_INSERT_ID(),
    2  -- Plomero
);
