// ============================================================
// SERVITEC - Backend API Server
// Express.js + MySQL
// ============================================================

const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
const bcryptjs = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// ============================================================
// CONFIGURACIÓN DE BASE DE DATOS
// ============================================================

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  port: process.env.DB_PORT,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// ============================================================
// UTILIDADES
// ============================================================

// Generar JWT
const generateToken = (user_id, user_type) => {
  return jwt.sign(
    { user_id, user_type },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
};

// Middleware para verificar token
const authMiddleware = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ error: 'Token no proporcionado' });
    }
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(401).json({ error: 'Token inválido' });
  }
};

// ============================================================
// RUTAS: AUTH
// ============================================================

// POST /api/auth/register/client
app.post('/api/auth/register/client', async (req, res) => {
  try {
    const { nombre, apellido, email, password, telefono, direccion_text, lat, lng } = req.body;

    // Validaciones
    if (!nombre || !email || !password) {
      return res.status(400).json({ error: 'Campos requeridos: nombre, email, password' });
    }

    const connection = await pool.getConnection();

    // Verificar si email existe
    const [existingClient] = await connection.query(
      'SELECT id_cliente FROM clientes WHERE email = ?',
      [email]
    );
    if (existingClient.length > 0) {
      connection.release();
      return res.status(409).json({ error: 'El email ya está registrado' });
    }

    // Hash de contraseña
    const password_hash = await bcryptjs.hash(password, 10);

    // Insertar cliente
    const [result] = await connection.query(
      'INSERT INTO clientes (nombre, apellido, email, password_hash, telefono, direccion_text, latitud, longitud) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [nombre, apellido, email, password_hash, telefono, direccion_text, lat, lng]
    );

    connection.release();

    const id_cliente = result.insertId;
    const token = generateToken(id_cliente, 'client');

    res.status(201).json({
      success: true,
      id_cliente,
      token,
      user_type: 'client'
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al registrar cliente' });
  }
});

// POST /api/auth/register/technician
app.post('/api/auth/register/technician', async (req, res) => {
  try {
    const { nombre, email, password, telefono, ubicacion_text, lat, lng, tarifa_hora, services, experiencia, descripcion } = req.body;

    if (!nombre || !email || !password) {
      return res.status(400).json({ error: 'Campos requeridos: nombre, email, password' });
    }

    const connection = await pool.getConnection();

    // Verificar si email existe
    const [existingTech] = await connection.query(
      'SELECT id_tecnico FROM tecnicos WHERE email = ?',
      [email]
    );
    if (existingTech.length > 0) {
      connection.release();
      return res.status(409).json({ error: 'El email ya está registrado' });
    }

    // Hash de contraseña
    const password_hash = await bcryptjs.hash(password, 10);

    // Insertar técnico
    const [result] = await connection.query(
      'INSERT INTO tecnicos (nombre, email, password_hash, telefono, ubicacion_text, latitud, longitud, tarifa_hora, experiencia_years, descripcion) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [nombre, email, password_hash, telefono, ubicacion_text, lat, lng, tarifa_hora, experiencia, descripcion]
    );

    const id_tecnico = result.insertId;

    // Insertar servicios que ofrece
    if (services && Array.isArray(services)) {
      for (const id_servicio of services) {
        await connection.query(
          'INSERT INTO tecnico_servicio (id_tecnico, id_servicio) VALUES (?, ?)',
          [id_tecnico, id_servicio]
        );
      }
    }

    connection.release();

    const token = generateToken(id_tecnico, 'technician');

    res.status(201).json({
      success: true,
      id_tecnico,
      token,
      user_type: 'technician'
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al registrar técnico' });
  }
});

// POST /api/auth/login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email y contraseña requeridos' });
    }

    const connection = await pool.getConnection();

    // Buscar en clientes
    let [clients] = await connection.query(
      'SELECT * FROM clientes WHERE email = ?',
      [email]
    );

    if (clients.length > 0) {
      const client = clients[0];
      const passwordMatch = await bcryptjs.compare(password, client.password_hash);

      if (!passwordMatch) {
        connection.release();
        return res.status(401).json({ error: 'Email o contraseña incorrectos' });
      }

      connection.release();
      const token = generateToken(client.id_cliente, 'client');

      return res.json({
        success: true,
        token,
        user_type: 'client',
        id_user: client.id_cliente,
        nombre: client.nombre
      });
    }

    // Buscar en técnicos
    let [technicians] = await connection.query(
      'SELECT * FROM tecnicos WHERE email = ?',
      [email]
    );

    if (technicians.length > 0) {
      const tech = technicians[0];
      const passwordMatch = await bcryptjs.compare(password, tech.password_hash);

      if (!passwordMatch) {
        connection.release();
        return res.status(401).json({ error: 'Email o contraseña incorrectos' });
      }

      connection.release();
      const token = generateToken(tech.id_tecnico, 'technician');

      return res.json({
        success: true,
        token,
        user_type: 'technician',
        id_user: tech.id_tecnico,
        nombre: tech.nombre
      });
    }

    connection.release();
    res.status(401).json({ error: 'Email o contraseña incorrectos' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al iniciar sesión' });
  }
});

// ============================================================
// RUTAS: SERVICIOS
// ============================================================

// GET /api/services
app.get('/api/services', async (req, res) => {
  try {
    const connection = await pool.getConnection();
    const [services] = await connection.query('SELECT * FROM servicios');
    connection.release();

    res.json(services);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener servicios' });
  }
});

// ============================================================
// RUTAS: TÉCNICOS
// ============================================================

// GET /api/technicians?service_id=X&lat=X&lng=Y&radius=R
app.get('/api/technicians', async (req, res) => {
  try {
    const { service_id, lat, lng, radius = 50 } = req.query;

    const connection = await pool.getConnection();

    let query = `
      SELECT t.*, GROUP_CONCAT(ts.id_servicio) AS services
      FROM tecnicos t
      LEFT JOIN tecnico_servicio ts ON t.id_tecnico = ts.id_tecnico
      WHERE t.is_active = 1
    `;
    const params = [];

    if (service_id) {
      query += ` AND t.id_tecnico IN (SELECT id_tecnico FROM tecnico_servicio WHERE id_servicio = ?)`;
      params.push(service_id);
    }

    query += ` GROUP BY t.id_tecnico ORDER BY t.calificacion_promedio DESC`;

    const [technicians] = await connection.query(query, params);
    connection.release();

    // Nota: Para búsqueda por proximidad (lat/lng), considera usar PostGIS o calcular distancia en la app
    res.json(technicians);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener técnicos' });
  }
});

// GET /api/technicians/:id
app.get('/api/technicians/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const connection = await pool.getConnection();
    const [technicians] = await connection.query(
      'SELECT * FROM tecnicos WHERE id_tecnico = ?',
      [id]
    );

    if (technicians.length === 0) {
      connection.release();
      return res.status(404).json({ error: 'Técnico no encontrado' });
    }

    const tech = technicians[0];

    // Obtener servicios que ofrece
    const [services] = await connection.query(
      'SELECT s.* FROM servicios s JOIN tecnico_servicio ts ON s.id_servicio = ts.id_servicio WHERE ts.id_tecnico = ?',
      [id]
    );

    connection.release();

    res.json({
      ...tech,
      servicios: services
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener técnico' });
  }
});

// ============================================================
// RUTAS: CONTRATACIONES
// ============================================================

// POST /api/contractations
app.post('/api/contractations', authMiddleware, async (req, res) => {
  try {
    const { id_tecnico, id_servicio, fecha_programada, detalles } = req.body;
    const id_cliente = req.user.user_id;

    if (!id_servicio || !fecha_programada) {
      return res.status(400).json({ error: 'Campos requeridos: id_servicio, fecha_programada' });
    }

    const connection = await pool.getConnection();
    const [result] = await connection.query(
      'INSERT INTO contrataciones (id_cliente, id_tecnico, id_servicio, fecha_programada, detalles, estado) VALUES (?, ?, ?, ?, ?, ?)',
      [id_cliente, id_tecnico, id_servicio, fecha_programada, detalles, 'Pendiente']
    );

    connection.release();

    res.status(201).json({
      success: true,
      id_contratacion: result.insertId,
      estado: 'Pendiente'
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al crear contratación' });
  }
});

// GET /api/contractations/:id
app.get('/api/contractations/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;

    const connection = await pool.getConnection();
    const [contractations] = await connection.query(
      'SELECT * FROM contrataciones WHERE id_contratacion = ?',
      [id]
    );

    if (contractations.length === 0) {
      connection.release();
      return res.status(404).json({ error: 'Contratación no encontrada' });
    }

    connection.release();
    res.json(contractations[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al obtener contratación' });
  }
});

// ============================================================
// RUTAS: PAGOS
// ============================================================

// POST /api/payments
app.post('/api/payments', authMiddleware, async (req, res) => {
  try {
    const { id_contratacion, monto, metodo_pago, transaction_ref } = req.body;

    if (!id_contratacion || !monto) {
      return res.status(400).json({ error: 'Campos requeridos: id_contratacion, monto' });
    }

    const connection = await pool.getConnection();
    const [result] = await connection.query(
      'INSERT INTO pagos (id_contratacion, monto, metodo_pago, transaction_ref, estado_pago) VALUES (?, ?, ?, ?, ?)',
      [id_contratacion, monto, metodo_pago, transaction_ref, 'Completado']
    );

    // Actualizar estado de contratación a 'Pagada'
    await connection.query(
      'UPDATE contrataciones SET estado = ? WHERE id_contratacion = ?',
      ['Pagada', id_contratacion]
    );

    connection.release();

    res.status(201).json({
      success: true,
      id_pago: result.insertId,
      estado_pago: 'Completado'
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al procesar pago' });
  }
});

// ============================================================
// RUTAS: CALIFICACIONES
// ============================================================

// POST /api/ratings
app.post('/api/ratings', authMiddleware, async (req, res) => {
  try {
    const { id_contratacion, id_tecnico, puntuacion, comentario } = req.body;

    if (!id_tecnico || !puntuacion || puntuacion < 1 || puntuacion > 5) {
      return res.status(400).json({ error: 'Puntuación inválida (1-5 requerida)' });
    }

    const connection = await pool.getConnection();

    // Insertar calificación
    const [result] = await connection.query(
      'INSERT INTO calificaciones (id_contratacion, id_tecnico, puntuacion, comentario) VALUES (?, ?, ?, ?)',
      [id_contratacion, id_tecnico, puntuacion, comentario]
    );

    // Actualizar promedio de calificaciones del técnico
    const [ratings] = await connection.query(
      'SELECT AVG(puntuacion) as avg_rating, COUNT(*) as count FROM calificaciones WHERE id_tecnico = ?',
      [id_tecnico]
    );

    const avg = ratings[0].avg_rating || 0;
    const count = ratings[0].count || 0;

    await connection.query(
      'UPDATE tecnicos SET calificacion_promedio = ?, num_calificaciones = ? WHERE id_tecnico = ?',
      [avg, count, id_tecnico]
    );

    connection.release();

    res.status(201).json({
      success: true,
      id_calificacion: result.insertId
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al guardar calificación' });
  }
});

// ============================================================
// HEALTH CHECK
// ============================================================

app.get('/api/health', (req, res) => {
  res.json({ status: 'API Servitec funcionando correctamente' });
});

// ============================================================
// INICIO DEL SERVIDOR
// ============================================================

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor Servitec corriendo en puerto ${PORT}`);
  console.log(`📍 URL: http://localhost:${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
});
