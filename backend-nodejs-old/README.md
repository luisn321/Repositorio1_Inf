# 🔧 SERVITEC - Backend API

Backend Node.js + Express + MySQL para la plataforma Servitec que conecta clientes con técnicos.

---

## 📋 Requisitos Previos

Antes de empezar, asegúrate de tener instalado:

1. **Node.js** (v14 o superior)
   - Descarga desde: https://nodejs.org/
   - Verifica: `node --version`

2. **MySQL** (v5.7 o superior)
   - Descarga desde: https://www.mysql.com/downloads/mysql/
   - O usa MySQL Workbench

3. **Git** (opcional pero recomendado)

---

## 🚀 Instalación Rápida

### Paso 1: Crear la Base de Datos MySQL

1. Abre **MySQL Workbench** o **MySQL Command Line Client**.
2. Copia y ejecuta todo el contenido del archivo `ddl_servitec.sql`:
   ```bash
   mysql -u root -p < ddl_servitec.sql
   ```
   O en MySQL Workbench:
   - File → Open SQL Script → Selecciona `ddl_servitec.sql`
   - Click en el icono "Execute" (⚡)

3. Verifica que la BD fue creada:
   ```sql
   USE servitec;
   SHOW TABLES;
   ```

### Paso 2: Configurar Variables de Entorno

1. En la carpeta `backend/`, edita el archivo `.env`:
   ```
   PORT=3000
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=tu_password_aqui  ← Cambiar con tu contraseña MySQL
   DB_DATABASE=servitec
   DB_PORT=3306
   JWT_SECRET=tu_jwt_secret_super_seguro_2024
   NODE_ENV=development
   ```

### Paso 3: Instalar Dependencias

```bash
# Entra a la carpeta backend
cd backend

# Instala paquetes npm
npm install
```

### Paso 4: Ejecutar el Servidor

```bash
# Modo desarrollo (con auto-reload)
npm run dev

# O modo producción
npm start
```

Deberías ver:
```
🚀 Servidor Servitec corriendo en puerto 3000
📍 URL: http://localhost:3000
🔗 Health check: http://localhost:3000/api/health
```

---

## 🧪 Probar la API

### Con Postman o Insomnia:

**1. Health Check**
```
GET http://localhost:3000/api/health
```
Respuesta esperada:
```json
{ "status": "API Servitec funcionando correctamente" }
```

**2. Registrar Cliente**
```
POST http://localhost:3000/api/auth/register/client
Content-Type: application/json

{
  "nombre": "Juan",
  "apellido": "Pérez",
  "email": "juan@example.com",
  "password": "pass123",
  "telefono": "1234567890",
  "direccion_text": "Calle 123, Apt 4",
  "lat": 19.4326,
  "lng": -99.1332
}
```

**3. Registrar Técnico**
```
POST http://localhost:3000/api/auth/register/technician
Content-Type: application/json

{
  "nombre": "Carlos",
  "email": "carlos@example.com",
  "password": "pass123",
  "telefono": "0987654321",
  "ubicacion_text": "Zona Centro",
  "lat": 19.4326,
  "lng": -99.1332,
  "tarifa_hora": 250,
  "services": [1, 2],
  "experiencia": 5,
  "descripcion": "Electricista con 5 años de experiencia"
}
```

**4. Login**
```
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "juan@example.com",
  "password": "pass123"
}
```

Respuesta:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user_type": "client",
  "id_user": 1,
  "nombre": "Juan"
}
```

**5. Obtener Servicios**
```
GET http://localhost:3000/api/services
```

**6. Listar Técnicos**
```
GET http://localhost:3000/api/technicians?service_id=1
```

**7. Obtener Detalles de Técnico**
```
GET http://localhost:3000/api/technicians/1
```

**8. Crear Contratación (requiere token)**
```
POST http://localhost:3000/api/contractations
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "id_tecnico": 1,
  "id_servicio": 1,
  "fecha_programada": "2024-12-15",
  "detalles": "Instalación de 3 focos LED"
}
```

---

## 🗄️ Estructura de Base de Datos

### Tablas Principales:

| Tabla | Descripción |
|-------|------------|
| `clientes` | Datos de usuarios que solicitan servicios |
| `tecnicos` | Datos de técnicos que ofrecen servicios |
| `servicios` | Catálogo de tipos de servicios (Electricista, Plomero, etc.) |
| `tecnico_servicio` | Relación N:M entre técnicos y servicios |
| `contrataciones` | Solicitudes de servicio (requests) |
| `pagos` | Registro de pagos por contratación |
| `calificaciones` | Reseñas y ratings de técnicos |

---

## 📡 Endpoints Disponibles

### Auth
- `POST /api/auth/register/client` - Registrar cliente
- `POST /api/auth/register/technician` - Registrar técnico
- `POST /api/auth/login` - Login (cliente o técnico)

### Servicios
- `GET /api/services` - Listar servicios disponibles

### Técnicos
- `GET /api/technicians` - Listar técnicos (con filtro por servicio)
- `GET /api/technicians/:id` - Detalles de técnico

### Contrataciones
- `POST /api/contractations` - Crear solicitud de servicio (requiere auth)
- `GET /api/contractations/:id` - Obtener estado de contratación (requiere auth)

### Pagos
- `POST /api/payments` - Registrar pago (requiere auth)

### Calificaciones
- `POST /api/ratings` - Registrar calificación/reseña (requiere auth)

### Salud
- `GET /api/health` - Verificar que el servidor está funcionando

---

## 🔒 Seguridad

### Contraseñas
- Se hashean con **bcryptjs** (algoritmo secure).
- Nunca se almacenan en texto plano.

### Autenticación
- Se usa **JWT (JSON Web Tokens)** con expiración de 30 días.
- Token se incluye en header: `Authorization: Bearer <token>`

### CORS
- Habilitado para acceso desde Flutter app.
- En producción, especificar origen exacto.

---

## 🐛 Troubleshooting

### Error: "connect ECONNREFUSED 127.0.0.1:3306"
- MySQL no está corriendo.
- Solución: Inicia MySQL desde servicios o línea de comandos.

### Error: "Access denied for user 'root'@'localhost'"
- Contraseña MySQL incorrecta en `.env`.
- Solución: Verifica que `DB_PASSWORD` sea correcta.

### Error: "Unknown database 'servitec'"
- La BD no fue creada.
- Solución: Ejecuta nuevamente `ddl_servitec.sql`.

### Error: "Cannot find module 'express'"
- Dependencias no instaladas.
- Solución: Ejecuta `npm install`.

---

## 📝 Próximos Pasos

1. **Integración con Flutter:**
   - La app Flutter ya tiene `ApiService` configurado para apuntar a `http://10.0.2.2:3000/api` (emulador Android).
   - Para dispositivo real, cambiar a IP de tu PC (ej: `http://192.168.x.x:3000/api`).

2. **Validaciones avanzadas:**
   - Implementar rate limiting.
   - Validar coordenadas GPS válidas.
   - Verificar emails con Regex mejorado.

3. **Búsqueda por proximidad:**
   - Usar PostGIS (extension de PostgreSQL) o cálculo de distancia en app.

4. **Autenticación de dos factores (2FA).**

5. **Notificaciones en tiempo real (WebSockets).**

---

## 📞 Soporte

Si encuentras problemas:
1. Revisa los logs en la consola.
2. Verifica la conexión MySQL.
3. Asegúrate de que `.env` está configurado correctamente.
4. Prueba endpoints con Postman/Insomnia antes de integrar con Flutter.

---

## 📜 Licencia

Proyecto académico - 2024

---

**¡Listo! Tu backend está configurado y listo para recibir requests desde la app Flutter.** 🚀
