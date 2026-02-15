# GUÍA DE PRUEBA: TESTEAR LAS 8 OPERACIONES SQL

**Documento:** Guía para probar cada operación manualmente  
**Herramientas:** Postman, cURL, o Thunder Client  
**Proyecto:** SERVITEC  
**Fecha:** Diciembre 2024

---

## ⚙️ CONFIGURACIÓN PREVIA

### 1. Asegúrate que el servidor esté corriendo

```bash
# En la carpeta backend-csharp/
dotnet run

# O en Windows:
run-backend.bat
```

**Esperado:** Ver mensaje como:
```
info: Microsoft.Hosting.Lifetime
      Now listening on: http://localhost:5000
      Application started. Press Ctrl+C to stop.
```

### 2. Importa en Postman

```
URL Base: http://localhost:5000
Headers: 
  - Content-Type: application/json
```

---

## 1️⃣ TEST: REGISTRAR CLIENTE (INSERT)

### 📌 Endpoint
```
POST http://localhost:5000/api/auth/register/client
```

### 📤 Request Body
```json
{
  "firstName": "Juan",
  "lastName": "Pérez",
  "email": "juan.perez@example.com",
  "password": "Password123!",
  "phone": "0987654321",
  "location": "Calle Principal 123, Quito",
  "latitude": -0.2255,
  "longitude": -78.5249
}
```

### ✅ Response Esperado (201 Created)
```json
{
  "id_cliente": 1,
  "message": "Client registered successfully"
}
```

### ❌ Casos de Error

**Error 1: Email ya existe**
```
Request: mismo email de antes
Response: 400 Bad Request
{
  "error": "Email already exists"
}
```

**Error 2: Contraseña débil**
```
Request: password = "123"
Response: 400 Bad Request
{
  "error": "Password must be at least 8 characters"
}
```

**Error 3: Email inválido**
```
Request: email = "correosinvalido"
Response: 400 Bad Request
{
  "error": "Invalid email format"
}
```

### 🔍 Verificación en BD
```sql
-- Ejecutar en MySQL
SELECT id_cliente, nombre, email, es_activo 
FROM clientes 
WHERE email = 'juan.perez@example.com';

-- Esperado:
-- | 1 | Juan Pérez | juan.perez@example.com | 1 |
```

---

## 2️⃣ TEST: REGISTRAR TÉCNICO (INSERT)

### 📌 Endpoint
```
POST http://localhost:5000/api/auth/register/technician
```

### 📤 Request Body
```json
{
  "firstName": "Carlos",
  "lastName": "Técnico",
  "email": "carlos.tecnico@example.com",
  "password": "Password123!",
  "phone": "0987654322",
  "hourlyRate": 25.50,
  "experienceYears": 5,
  "location": "Avenida Siete 456, Quito",
  "latitude": -0.2200,
  "longitude": -78.5000
}
```

### ✅ Response Esperado (201 Created)
```json
{
  "id_tecnico": 5,
  "message": "Technician registered successfully"
}
```

### ❌ Casos de Error

**Error 1: Tarifa inválida**
```
Request: hourlyRate = -10
Response: 400 Bad Request
{
  "error": "Hourly rate must be greater than 0"
}
```

**Error 2: Experiencia negativa**
```
Request: experienceYears = -1
Response: 400 Bad Request
{
  "error": "Experience years cannot be negative"
}
```

### 🔍 Verificación en BD
```sql
SELECT id_tecnico, nombre, email, tarifa_hora, experiencia_years 
FROM tecnicos 
WHERE email = 'carlos.tecnico@example.com';

-- Esperado:
-- | 5 | Carlos Técnico | carlos.tecnico@example.com | 25.50 | 5 |
```

---

## 3️⃣ TEST: LOGIN (SELECT + Validación)

### 📌 Endpoint
```
POST http://localhost:5000/api/auth/login
```

### 📤 Request Body
```json
{
  "email": "juan.perez@example.com",
  "password": "Password123!",
  "userType": "client"
}
```

### ✅ Response Esperado (200 OK)
```json
{
  "id": 1,
  "nombre": "Juan Pérez",
  "email": "juan.perez@example.com",
  "rol": "client",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwibmFtZSI6Ikpvw4NvIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
}
```

### ❌ Casos de Error

**Error 1: Email no existe**
```
Request: email = "noexiste@example.com"
Response: 401 Unauthorized
{
  "error": "Invalid credentials"
}
```

**Error 2: Contraseña incorrecta**
```
Request: password = "WrongPassword123!"
Response: 401 Unauthorized
{
  "error": "Invalid credentials"
}
```

**Error 3: Usuario desactivado**
```
-- Primero desactivar en BD:
UPDATE clientes SET es_activo = 0 WHERE id_cliente = 1;

-- Luego:
Request: con email y password correctos
Response: 401 Unauthorized
{
  "error": "Invalid credentials"
}
```

### 🔑 Guardar el Token
**En Postman:**
1. Response → Tests
2. Agregar:
```javascript
var jsonData = pm.response.json();
pm.environment.set("token", jsonData.token);
```
3. Ahora puedes usar `{{token}}` en otros requests

---

## 4️⃣ TEST: OBTENER PERFIL CLIENTE (SELECT)

### 📌 Endpoint
```
GET http://localhost:5000/api/clients/1
```

### 🔐 Headers (con autenticación)
```
Authorization: Bearer {{token}}
Content-Type: application/json
```

### ✅ Response Esperado (200 OK)
```json
{
  "id_cliente": 1,
  "nombre": "Juan Pérez",
  "email": "juan.perez@example.com",
  "telefono": "0987654321",
  "ubicacion_text": "Calle Principal 123, Quito",
  "latitud": -0.2255,
  "longitud": -78.5249,
  "fecha_registro": "2024-12-15T10:30:45",
  "es_activo": 1
}
```

### ❌ Casos de Error

**Error 1: Sin token**
```
Request: sin header Authorization
Response: 401 Unauthorized
{
  "error": "Unauthorized"
}
```

**Error 2: Token inválido**
```
Authorization: Bearer invalid_token_here
Response: 401 Unauthorized
{
  "error": "Invalid token"
}
```

**Error 3: ID no existe**
```
GET /api/clients/999
Response: 404 Not Found
{
  "error": "Client not found"
}
```

---

## 5️⃣ TEST: ACTUALIZAR PERFIL CLIENTE (UPDATE)

### 📌 Endpoint
```
PUT http://localhost:5000/api/clients/1
```

### 🔐 Headers
```
Authorization: Bearer {{token}}
Content-Type: application/json
```

### 📤 Request Body (Solo actualizar email y teléfono)
```json
{
  "email": "juannuevo@example.com",
  "phone": "0999999999"
}
```

### ✅ Response Esperado (200 OK)
```json
{
  "message": "Client updated successfully"
}
```

### 🔍 Verificación
```bash
# Hacer GET /api/clients/1 nuevamente
GET http://localhost:5000/api/clients/1

# Debe mostrar:
{
  "email": "juannuevo@example.com",
  "telefono": "0999999999",
  // ... otros campos sin cambiar
}
```

### ❌ Casos de Error

**Error 1: Email ya existe**
```
Request:
{
  "email": "carlos.tecnico@example.com"
}
Response: 400 Bad Request
{
  "error": "Email already exists"
}
```

**Error 2: Actualizar con valores vacíos**
```
Request: {} (objeto vacío)
Response: 400 Bad Request
{
  "error": "No fields to update"
}
```

### 💡 Prueba todos los campos
```json
{
  "firstName": "Juan Carlos",
  "email": "juancarlos@example.com",
  "phone": "0999888877",
  "locationText": "Nueva Dirección 789",
  "latitude": -0.2300,
  "longitude": -78.5300
}
```

---

## 6️⃣ TEST: LISTAR TÉCNICOS (SELECT)

### 📌 Endpoint (sin filtro)
```
GET http://localhost:5000/api/technicians
```

### 📌 Endpoint (con filtro de servicio)
```
GET http://localhost:5000/api/technicians?service=3&limit=10&offset=0
```

### 🔐 Headers
```
Authorization: Bearer {{token}}
```

### ✅ Response Esperado (200 OK)
```json
[
  {
    "id_tecnico": 5,
    "nombre": "Carlos Técnico",
    "email": "carlos.tecnico@example.com",
    "tarifa_hora": 25.50,
    "calificacion_promedio": 4.8,
    "latitud": -0.2200,
    "longitud": -78.5000,
    "experiencia_years": 5,
    "ubicacion_text": "Avenida Siete 456, Quito"
  },
  {
    "id_tecnico": 6,
    "nombre": "María Experta",
    "email": "maria@example.com",
    "tarifa_hora": 30.00,
    "calificacion_promedio": 4.9,
    "latitud": -0.2250,
    "longitud": -78.5100,
    "experiencia_years": 8,
    "ubicacion_text": "Avenida Principal 100"
  }
]
```

### 🔍 Casos de Prueba

**Caso 1: Sin filtro (todos los técnicos)**
```
GET /api/technicians
Esperado: Array con todos los técnicos activos
```

**Caso 2: Filtrar por servicio**
```
GET /api/technicians?service=3
Esperado: Solo técnicos que ofrecen servicio #3
```

**Caso 3: Paginación**
```
GET /api/technicians?limit=5&offset=0
Esperado: Primeros 5 técnicos

GET /api/technicians?limit=5&offset=5
Esperado: Técnicos 6-10
```

**Caso 4: Sin resultados**
```
GET /api/technicians?service=999
Esperado: [] (array vacío)
```

---

## 7️⃣ TEST: CREAR CONTRATACIÓN (INSERT)

### 📌 Endpoint
```
POST http://localhost:5000/api/contractions
```

### 🔐 Headers
```
Authorization: Bearer {{token}}
Content-Type: application/json
```

### 📤 Request Body (Sin técnico especificado)
```json
{
  "clientId": 1,
  "serviceId": 3,
  "description": "Reparación de aire acondicionado en sala principal",
  "scheduledDate": "2024-12-20T10:00:00"
}
```

### ✅ Response Esperado (201 Created)
```json
{
  "id_contratacion": 42,
  "estado": "Pendiente"
}
```

### 📤 Request Body (Con técnico especificado)
```json
{
  "clientId": 1,
  "technicianId": 5,
  "serviceId": 3,
  "description": "Reparación de aire acondicionado",
  "scheduledDate": "2024-12-20T10:00:00"
}
```

### ✅ Response (con técnico)
```json
{
  "id_contratacion": 43,
  "estado": "Asignado"
}
```

### ❌ Casos de Error

**Error 1: Cliente no existe**
```
Request: clientId = 999
Response: 400 Bad Request
{
  "error": "Client does not exist"
}
```

**Error 2: Servicio no existe**
```
Request: serviceId = 999
Response: 400 Bad Request
{
  "error": "Service does not exist"
}
```

**Error 3: Técnico no existe**
```
Request: technicianId = 999
Response: 400 Bad Request
{
  "error": "Technician does not exist"
}
```

### 🔍 Verificación en BD
```sql
SELECT id_contratacion, id_cliente, id_tecnico, estado
FROM contrataciones
WHERE id_cliente = 1
ORDER BY fecha_solicitud DESC;

-- Esperado: La nueva contratación aparece al principio
```

---

## 8️⃣ TEST: LISTAR CONTRATACIONES DE CLIENTE (SELECT)

### 📌 Endpoint
```
GET http://localhost:5000/api/contractions/client/1
```

### 🔐 Headers
```
Authorization: Bearer {{token}}
```

### ✅ Response Esperado (200 OK)
```json
[
  {
    "id_contratacion": 43,
    "id_cliente": 1,
    "id_tecnico": 5,
    "id_servicio": 3,
    "detalles": "Reparación de aire acondicionado",
    "fecha_solicitud": "2024-12-15T14:30:00",
    "fecha_programada": "2024-12-20T10:00:00",
    "estado": "Asignado",
    "service_name": "Reparación de AC",
    "technician_name": "Carlos Técnico",
    "technician_email": "carlos.tecnico@example.com"
  },
  {
    "id_contratacion": 42,
    "id_cliente": 1,
    "id_tecnico": null,
    "id_servicio": 3,
    "detalles": "Reparación de aire acondicionado en sala principal",
    "fecha_solicitud": "2024-12-15T13:00:00",
    "fecha_programada": "2024-12-20T10:00:00",
    "estado": "Pendiente",
    "service_name": "Reparación de AC",
    "technician_name": null,
    "technician_email": null
  }
]
```

### 🔍 Casos de Prueba

**Caso 1: Con contrataciones (caso exitoso de arriba)**
```
GET /api/contractions/client/1
Esperado: Array con todas las contrataciones
```

**Caso 2: Sin contrataciones**
```
-- Crear nuevo cliente y consultar inmediatamente
GET /api/contractions/client/999
Esperado: [] (array vacío)
```

**Caso 3: Orden de resultados**
```
Esperado: Ordenadas por fecha_solicitud DESC (más recientes primero)
```

---

## 🔄 FLUJO COMPLETO DE PRUEBA

### Paso 1: Registrar Cliente
```
POST /api/auth/register/client
Response: id_cliente = 1, token guardado
```

### Paso 2: Registrar Técnico
```
POST /api/auth/register/technician
Response: id_tecnico = 5
```

### Paso 3: Login del Cliente
```
POST /api/auth/login (userType: "client")
Response: token guardado (para cliente)
```

### Paso 4: Ver Perfil
```
GET /api/clients/1
Headers: Authorization: Bearer {{token}}
Response: Datos del cliente
```

### Paso 5: Actualizar Perfil
```
PUT /api/clients/1
Body: { "phone": "0999999999" }
Response: OK
```

### Paso 6: Listar Técnicos
```
GET /api/technicians
Headers: Authorization: Bearer {{token}}
Response: Array de técnicos
```

### Paso 7: Crear Contratación
```
POST /api/contractions
Body: { clientId: 1, serviceId: 3, technicianId: 5 }
Response: id_contratacion = 42
```

### Paso 8: Listar Contrataciones
```
GET /api/contractions/client/1
Headers: Authorization: Bearer {{token}}
Response: Array con la nueva contratación
```

---

## 📊 TABLA DE RESUMEN: PRUEBAS COMPLETADAS

| # | Operación | Método | Status | Comentarios |
|---|-----------|--------|--------|-------------|
| 1 | Registrar Cliente | POST | ✅ | Email debe ser único |
| 2 | Registrar Técnico | POST | ✅ | Tarifa y experiencia obligatorios |
| 3 | Login | POST | ✅ | Retorna token JWT |
| 4 | Ver Perfil | GET | ✅ | Requiere autenticación |
| 5 | Actualizar Perfil | PUT | ✅ | Actualización selectiva |
| 6 | Listar Técnicos | GET | ✅ | Soporta filtros |
| 7 | Crear Contratación | POST | ✅ | Valida existencia de registros |
| 8 | Listar Contrataciones | GET | ✅ | Con JOINs y LEFT JOINs |

---

## 🐛 TROUBLESHOOTING

### Problema: "Connection refused"
```
Solución: Verifica que:
1. El servidor esté corriendo: dotnet run
2. Puerto correcto: http://localhost:5000
3. MySQL esté activo
```

### Problema: "Invalid token"
```
Solución:
1. El token expiró (se genera uno nuevo con login)
2. El token está corrupto (copy-paste incorrecto)
3. Verifica header: "Authorization: Bearer TOKEN_HERE"
```

### Problema: "Email already exists"
```
Solución:
1. Usa un email diferente
2. O elimina el registro anterior de la BD
```

### Problema: "Technician does not exist"
```
Solución:
1. Primero registra un técnico (Operación 2)
2. Usa el id_tecnico correcto
```

---

## 📝 CHECKLIST DE PRUEBAS

- [ ] OP 1: Registrar cliente (email válido)
- [ ] OP 1: Validar error (email duplicado)
- [ ] OP 2: Registrar técnico (todos los campos)
- [ ] OP 2: Validar error (tarifa negativa)
- [ ] OP 6: Login exitoso (cliente)
- [ ] OP 6: Login fallido (email incorrecto)
- [ ] OP 6: Login fallido (contraseña incorrecta)
- [ ] OP 3: Ver perfil (con token válido)
- [ ] OP 3: Validar error (sin token)
- [ ] OP 5: Actualizar un campo
- [ ] OP 5: Actualizar múltiples campos
- [ ] OP 5: Validar error (campo vacío)
- [ ] OP 4: Listar técnicos (sin filtro)
- [ ] OP 4: Listar técnicos (con filtro servicio)
- [ ] OP 4: Listar técnicos (con paginación)
- [ ] OP 7: Crear contratación (sin técnico)
- [ ] OP 7: Crear contratación (con técnico)
- [ ] OP 7: Validar error (cliente no existe)
- [ ] OP 8: Listar contrataciones (sin contrataciones)
- [ ] OP 8: Listar contrataciones (con contrataciones)

---

Última actualización: Diciembre 2024  
Versión: 1.0 Completo  
Estado: ✅ Listo para presentación
