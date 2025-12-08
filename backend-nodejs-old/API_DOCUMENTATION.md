# 📚 DOCUMENTACIÓN API SERVITEC

Documento completo con todos los endpoints, payloads y respuestas esperadas.

---

## 🔐 AUTENTICACIÓN

### POST /api/auth/register/client
Registra un nuevo cliente en el sistema.

**Request:**
```json
{
  "nombre": "Juan",
  "apellido": "Pérez",
  "email": "juan@example.com",
  "password": "SeguroPass123",
  "telefono": "+34912345678",
  "direccion_text": "Calle Principal 123, Apt 4B, Madrid",
  "lat": 40.4168,
  "lng": -3.7038
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "id_cliente": 1,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VyX3R5cGUiOiJjbGllbnQiLCJpYXQiOjE3MDI2MzI4MzcsImV4cCI6MTcwNTMxMDgzN30.xxxx",
  "user_type": "client"
}
```

**Errores:**
- `400` - Campos faltantes
- `409` - Email ya registrado

---

### POST /api/auth/register/technician
Registra un nuevo técnico en el sistema.

**Request:**
```json
{
  "nombre": "Carlos Mendez",
  "email": "carlos@example.com",
  "password": "TecnicoPass123",
  "telefono": "+34698765432",
  "ubicacion_text": "Zona Centro, Madrid",
  "lat": 40.4168,
  "lng": -3.7038,
  "tarifa_hora": 250,
  "services": [1, 2],
  "experiencia": 5,
  "descripcion": "Electricista certificado con 5 años de experiencia en instalaciones y mantenimiento."
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "id_tecnico": 1,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxx",
  "user_type": "technician"
}
```

**Notas:**
- `services`: Array de IDs de servicios que ofrece (ej: [1, 2] = Electricista + Plomería)
- `experiencia`: Años de experiencia (número entero)

---

### POST /api/auth/login
Autentica un usuario (cliente o técnico).

**Request:**
```json
{
  "email": "juan@example.com",
  "password": "SeguroPass123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxx",
  "user_type": "client",
  "id_user": 1,
  "nombre": "Juan Pérez"
}
```

**Response si es técnico:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxx",
  "user_type": "technician",
  "id_user": 1,
  "nombre": "Carlos Mendez"
}
```

**Errores:**
- `400` - Email o contraseña faltantes
- `401` - Email o contraseña incorrectos

---

## 🛠️ SERVICIOS

### GET /api/services
Obtiene la lista de todos los servicios disponibles.

**Request:**
```
GET /api/services
```

**Response (200 OK):**
```json
[
  {
    "id_servicio": 1,
    "nombre": "Electricista",
    "descripcion": "Servicios de instalación y reparación eléctrica",
    "icono": "Icons.bolt",
    "created_at": "2024-12-03T10:00:00Z"
  },
  {
    "id_servicio": 2,
    "nombre": "Plomero",
    "descripcion": "Reparación de tuberías y sistemas de agua",
    "icono": "Icons.plumbing",
    "created_at": "2024-12-03T10:00:00Z"
  },
  {
    "id_servicio": 3,
    "nombre": "Carpintero",
    "descripcion": "Trabajos de carpintería y carpintería",
    "icono": "Icons.handyman",
    "created_at": "2024-12-03T10:00:00Z"
  }
]
```

---

## 👷 TÉCNICOS

### GET /api/technicians
Obtiene lista de técnicos con filtros opcionales.

**Request:**
```
GET /api/technicians
GET /api/technicians?service_id=1
GET /api/technicians?service_id=1&lat=40.4168&lng=-3.7038&radius=50
```

**Query Parameters:**
- `service_id` (optional) - Filtra técnicos por servicio
- `lat` (optional) - Latitud para búsqueda por proximidad
- `lng` (optional) - Longitud para búsqueda por proximidad
- `radius` (optional) - Radio de búsqueda en km (default: 50)

**Response (200 OK):**
```json
[
  {
    "id_tecnico": 1,
    "nombre": "Carlos Mendez",
    "email": "carlos@example.com",
    "telefono": "+34698765432",
    "ubicacion_text": "Zona Centro, Madrid",
    "latitud": 40.4168,
    "longitud": -3.7038,
    "tarifa_hora": 250,
    "experiencia_years": 5,
    "descripcion": "Electricista certificado...",
    "calificacion_promedio": 4.8,
    "num_calificaciones": 12,
    "is_active": 1,
    "services": "1,2"
  }
]
```

---

### GET /api/technicians/:id
Obtiene detalles completos de un técnico específico.

**Request:**
```
GET /api/technicians/1
```

**Response (200 OK):**
```json
{
  "id_tecnico": 1,
  "nombre": "Carlos Mendez",
  "email": "carlos@example.com",
  "telefono": "+34698765432",
  "ubicacion_text": "Zona Centro, Madrid",
  "latitud": 40.4168,
  "longitud": -3.7038,
  "tarifa_hora": 250,
  "experiencia_years": 5,
  "descripcion": "Electricista certificado con 5 años de experiencia...",
  "calificacion_promedio": 4.8,
  "num_calificaciones": 12,
  "is_active": 1,
  "servicios": [
    {
      "id_servicio": 1,
      "nombre": "Electricista",
      "descripcion": "Servicios de instalación y reparación eléctrica",
      "icono": "Icons.bolt"
    },
    {
      "id_servicio": 2,
      "nombre": "Plomero",
      "descripcion": "Reparación de tuberías y sistemas de agua",
      "icono": "Icons.plumbing"
    }
  ]
}
```

**Errores:**
- `404` - Técnico no encontrado

---

## 📋 CONTRATACIONES (Requests)

### POST /api/contractations
Crea una nueva solicitud de servicio.

**Headers requeridos:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request:**
```json
{
  "id_tecnico": 1,
  "id_servicio": 1,
  "fecha_programada": "2024-12-15",
  "detalles": "Instalación de 3 focos LED en la sala de estar"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "id_contratacion": 1,
  "estado": "Pendiente"
}
```

**Errores:**
- `400` - Campos faltantes (id_servicio, fecha_programada)
- `401` - Token inválido o no proporcionado

---

### GET /api/contractations/:id
Obtiene detalles de una contratación específica.

**Headers requeridos:**
```
Authorization: Bearer <token>
```

**Request:**
```
GET /api/contractations/1
```

**Response (200 OK):**
```json
{
  "id_contratacion": 1,
  "id_cliente": 1,
  "id_tecnico": 1,
  "id_servicio": 1,
  "fecha_solicitud": "2024-12-03T15:30:00Z",
  "fecha_programada": "2024-12-15",
  "detalles": "Instalación de 3 focos LED en la sala de estar",
  "estado": "Pendiente",
  "created_at": "2024-12-03T15:30:00Z",
  "updated_at": "2024-12-03T15:30:00Z"
}
```

**Estados posibles:**
- `Pendiente` - Recién creada
- `Aceptada` - El técnico aceptó
- `En Progreso` - Técnico trabajando
- `Completada` - Servicio finalizado
- `Cancelada` - Cancelada por cliente

**Errores:**
- `401` - Token inválido
- `404` - Contratación no encontrada

---

## 💳 PAGOS

### POST /api/payments
Registra un pago para una contratación.

**Headers requeridos:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request:**
```json
{
  "id_contratacion": 1,
  "monto": 250.00,
  "metodo_pago": "tarjeta_credito",
  "transaction_ref": "TXN-2024-123456"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "id_pago": 1,
  "estado_pago": "Completado"
}
```

**Métodos de pago soportados:**
- `tarjeta_credito`
- `tarjeta_debito`
- `transferencia`
- `paypal`

**Errores:**
- `400` - Campos faltantes
- `401` - Token inválido

---

## ⭐ CALIFICACIONES

### POST /api/ratings
Registra una calificación/reseña de un técnico.

**Headers requeridos:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request:**
```json
{
  "id_contratacion": 1,
  "id_tecnico": 1,
  "puntuacion": 5,
  "comentario": "Excelente trabajo, muy profesional y rápido. Recomendado."
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "id_calificacion": 1
}
```

**Puntuación:**
- `1` - Muy malo
- `2` - Malo
- `3` - Regular
- `4` - Bueno
- `5` - Excelente

**Errores:**
- `400` - Puntuación inválida (no entre 1-5)
- `401` - Token inválido

---

## 🔧 UTILIDADES

### GET /api/health
Verifica que el servidor está funcionando.

**Request:**
```
GET /api/health
```

**Response (200 OK):**
```json
{
  "status": "API Servitec funcionando correctamente"
}
```

---

## 🔒 Tokens JWT

Todos los endpoints que requieren autenticación esperan un header:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

El token se obtiene al registrar o hacer login y expira en 30 días.

---

## ❌ Códigos de Error Estándar

| Código | Significado | Causa |
|--------|------------|-------|
| `200` | OK | Solicitud exitosa |
| `201` | Created | Recurso creado exitosamente |
| `400` | Bad Request | Datos inválidos o faltantes |
| `401` | Unauthorized | Token no válido o no proporcionado |
| `404` | Not Found | Recurso no encontrado |
| `409` | Conflict | El recurso ya existe (ej: email duplicado) |
| `500` | Server Error | Error interno del servidor |

---

## 📝 Notas Importantes

1. **Fechas:** Se usan formato ISO 8601 (YYYY-MM-DD)
2. **Contraseñas:** Mínimo 6 caracteres, se hashean con bcryptjs
3. **Coordenadas:** Latitud/Longitud en formato decimal
4. **Validación de email:** Se valida formato básico
5. **Rate Limiting:** Se puede implementar para prevenir abuso

---

## 🧪 Testing con cURL

```bash
# Health check
curl http://localhost:3000/api/health

# Obtener servicios
curl http://localhost:3000/api/services

# Registrar cliente
curl -X POST http://localhost:3000/api/auth/register/client \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan@example.com",
    "password": "pass123",
    "telefono": "123456",
    "direccion_text": "Calle 1",
    "lat": 40.4168,
    "lng": -3.7038
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "juan@example.com",
    "password": "pass123"
  }'
```

---

**Última actualización:** Diciembre 2024
