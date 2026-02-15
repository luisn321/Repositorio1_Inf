# RESUMEN EJECUTIVO: 8 OPERACIONES SQL DE SERVITEC

**Documento:** Guía rápida de las operaciones SQL más importantes  
**Proyecto:** SERVITEC - Flutter + ASP.NET Core + MySQL  
**Fecha:** Diciembre 2024  

---

## 📋 INDICE RÁPIDO

| # | Operación | Tipo | Usuario | Ubicación |
|---|-----------|------|---------|-----------|
| 1 | Registrar Cliente | INSERT | Cliente nuevo | AuthService.cs:25-60 |
| 2 | Registrar Técnico | INSERT | Técnico nuevo | AuthService.cs:76-130 |
| 3 | Obtener Perfil Cliente | SELECT | Cliente autenticado | ApiController.cs:88-101 |
| 4 | Listar Técnicos | SELECT | Cliente autenticado | ApiController.cs:182-207 |
| 5 | Actualizar Perfil | UPDATE | Cliente autenticado | ApiController.cs:104-157 |
| 6 | Login (Validar credenciales) | SELECT | Usuario público | AuthService.cs:185-205 |
| 7 | Crear Contratación | INSERT | Cliente autenticado | ContractionsController:395 |
| 8 | Listar Contrataciones | SELECT | Cliente autenticado | ContractionsController:454 |

---

## 1️⃣ REGISTRAR CLIENTE (INSERT)

### 🎯 Cuando se usa
- Nuevo cliente crea cuenta en la app
- Rol: Público (sin necesidad de token JWT)

### 💾 SQL
```sql
INSERT INTO clientes 
(nombre, email, password_hash, telefono, fecha_registro, es_activo, 
 ubicacion_text, latitud, longitud)
VALUES 
(@nombre, @email, @password_hash, @telefono, NOW(), 1, 
 @ubicacion_text, @latitud, @longitud);
SELECT LAST_INSERT_ID();
```

### ⚙️ Parámetros
- `@nombre`: Nombre completo (STRING, requerido)
- `@email`: Email único (STRING, requerido)
- `@password_hash`: Hash BCrypt (STRING, requerido)
- `@telefono`: Teléfono (STRING, opcional)
- `@ubicacion_text`: Dirección (STRING, opcional)
- `@latitud`: Latitud GPS (DECIMAL, opcional)
- `@longitud`: Longitud GPS (DECIMAL, opcional)

### 📤 Retorna
```json
{
  "id_cliente": 1
}
```

---

## 2️⃣ REGISTRAR TÉCNICO (INSERT)

### 🎯 Cuando se usa
- Nuevo técnico crea cuenta en la app
- Rol: Público (sin necesidad de token JWT)

### 💾 SQL
```sql
INSERT INTO tecnicos 
(nombre, email, password_hash, telefono, tarifa_hora, 
 calificacion_promedio, experiencia_years, ubicacion_text, 
 latitud, longitud, fecha_registro, es_activo)
VALUES 
(@nombre, @email, @password_hash, @telefono, @tarifa_hora, 
 0, @experiencia_years, @ubicacion_text, @latitud, @longitud, 
 NOW(), 1);
SELECT LAST_INSERT_ID();
```

### ⚙️ Parámetros
- `@nombre`: Nombre completo (STRING, requerido)
- `@email`: Email único (STRING, requerido)
- `@password_hash`: Hash BCrypt (STRING, requerido)
- `@telefono`: Teléfono (STRING, opcional)
- `@tarifa_hora`: Precio/hora (DECIMAL, requerido)
- `@experiencia_years`: Años de experiencia (INT, requerido)
- `@ubicacion_text`: Dirección (STRING, opcional)
- `@latitud`: Latitud GPS (DECIMAL, opcional)
- `@longitud`: Longitud GPS (DECIMAL, opcional)

### 📤 Retorna
```json
{
  "id_tecnico": 5
}
```

---

## 3️⃣ OBTENER PERFIL CLIENTE (SELECT)

### 🎯 Cuando se usa
- Cliente ve su perfil personal
- Rol: Cliente autenticado (token JWT)

### 💾 SQL
```sql
SELECT 
    id_cliente, nombre, email, telefono, 
    ubicacion_text, latitud, longitud, 
    fecha_registro, es_activo
FROM clientes 
WHERE id_cliente = @id;
```

### ⚙️ Parámetro
- `@id`: ID del cliente (INT, extraído del JWT)

### 📤 Retorna
```json
{
  "id_cliente": 1,
  "nombre": "Juan Pérez",
  "email": "juan@example.com",
  "telefono": "0987654321",
  "ubicacion_text": "Calle Principal 123",
  "latitud": -0.2255,
  "longitud": -78.5249,
  "fecha_registro": "2024-12-15T10:30:45",
  "es_activo": 1
}
```

---

## 4️⃣ LISTAR TÉCNICOS (SELECT)

### 🎯 Cuando se usa
- Cliente busca técnicos disponibles
- Puede filtrar por servicio
- Rol: Cliente autenticado (token JWT)

### 💾 SQL
```sql
SELECT 
    t.id_tecnico, t.nombre, t.email, t.tarifa_hora, 
    t.calificacion_promedio, t.latitud, t.longitud, 
    t.experiencia_years, t.ubicacion_text
FROM tecnicos t
WHERE es_activo = 1
  AND (@servicio IS NULL OR EXISTS (
    SELECT 1 FROM tecnico_servicio ts 
    INNER JOIN servicios s ON ts.id_servicio = s.id_servicio
    WHERE ts.id_tecnico = t.id_tecnico AND s.id_servicio = @servicio
  ))
ORDER BY t.calificacion_promedio DESC, t.tarifa_hora ASC
LIMIT @limit OFFSET @offset;
```

### ⚙️ Parámetros
- `@servicio`: ID del servicio (INT, opcional)
- `@limit`: Cantidad de registros (INT, default 10)
- `@offset`: Página (INT, default 0)

### 📤 Retorna
```json
[
  {
    "id_tecnico": 5,
    "nombre": "Carlos Técnico",
    "email": "carlos@example.com",
    "tarifa_hora": 25.50,
    "calificacion_promedio": 4.8,
    "latitud": -0.2200,
    "longitud": -78.5000,
    "experiencia_years": 5,
    "ubicacion_text": "Avenida Siete 456"
  }
]
```

---

## 5️⃣ ACTUALIZAR PERFIL CLIENTE (UPDATE)

### 🎯 Cuando se usa
- Cliente modifica su perfil (nombre, email, teléfono, ubicación, etc.)
- **Actualización selectiva**: solo cambia los campos enviados
- Rol: Cliente autenticado (token JWT)

### 💾 SQL (Ejemplo con todos los campos)
```sql
UPDATE clientes 
SET 
    nombre = @nombre,
    email = @email,
    telefono = @telefono,
    ubicacion_text = @ubicacion_text,
    latitud = @latitud,
    longitud = @longitud,
    password_hash = @password_hash,
    updated_at = NOW()
WHERE id_cliente = @id;
```

### ⚙️ Parámetros (todos opcionales)
- `@nombre`: Nuevo nombre (STRING, opcional)
- `@email`: Nuevo email (STRING, opcional)
- `@telefono`: Nuevo teléfono (STRING, opcional)
- `@ubicacion_text`: Nueva dirección (STRING, opcional)
- `@latitud`: Nueva latitud (DECIMAL, opcional)
- `@longitud`: Nueva longitud (DECIMAL, opcional)
- `@password_hash`: Nueva contraseña hash (STRING, opcional)

### 📤 Retorna
```json
{
  "message": "Client updated successfully"
}
```

### ✨ Característica especial
```
// Si el cliente solo envía:
{ "email": "nuevo@example.com" }

// Solo se actualiza el email (otros campos no cambian)
```

---

## 6️⃣ LOGIN / VALIDAR CREDENCIALES (SELECT)

### 🎯 Cuando se usa
- Usuario ingresa email y contraseña
- Sistema valida credenciales y retorna datos para generar JWT
- Rol: Público (sin autenticación previa)

### 💾 SQL (Para cliente)
```sql
SELECT id_cliente as id, nombre, email, password_hash, 'client' as rol
FROM clientes 
WHERE email = @email AND es_activo = 1;
```

### 💾 SQL (Para técnico)
```sql
SELECT id_tecnico as id, nombre, email, password_hash, 'technician' as rol
FROM tecnicos 
WHERE email = @email AND es_activo = 1;
```

### ⚙️ Parámetro
- `@email`: Email del usuario (STRING, requerido)

### 🔐 Flujo de validación
```
1. SELECT busca usuario por email
2. Si NO existe → ERROR "Credenciales inválidas"
3. Si existe → BCrypt.Verify(inputPassword, passwordHash)
4. Si NO coincide → ERROR "Credenciales inválidas"
5. Si coincide → Generar JWT y retornar datos
```

### 📤 Retorna (si es correcto)
```json
{
  "id": 1,
  "nombre": "Juan Pérez",
  "email": "juan@example.com",
  "rol": "client",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## 7️⃣ CREAR CONTRATACIÓN (INSERT)

### 🎯 Cuando se usa
- Cliente solicita un servicio a un técnico
- Puede especificar técnico o dejar que el sistema lo asigne
- Rol: Cliente autenticado (token JWT)

### 💾 SQL
```sql
INSERT INTO contrataciones 
(id_cliente, id_tecnico, id_servicio, detalles, 
 fecha_solicitud, fecha_programada, estado)
VALUES 
(@client, @tech, @service, @desc, NOW(), @fecha_programada, 'Pendiente');
SELECT LAST_INSERT_ID();
```

### ⚙️ Parámetros
- `@client`: ID del cliente (INT, del JWT)
- `@tech`: ID del técnico (INT, opcional, 0 si no especifica)
- `@service`: ID del servicio (INT, requerido)
- `@desc`: Descripción (STRING, opcional)
- `@fecha_programada`: Fecha/hora deseada (DATETIME, opcional)

### 📤 Retorna
```json
{
  "id_contratacion": 42,
  "estado": "Pendiente"
}
```

### 📋 Estados posibles
- `Pendiente`: Recién creada
- `Asignado`: Técnico asignado
- `En Progreso`: Técnico trabajando
- `Completado`: Servicio finalizado

---

## 8️⃣ LISTAR CONTRATACIONES DE CLIENTE (SELECT)

### 🎯 Cuando se usa
- Cliente ve sus solicitudes de servicio
- Muestra: servicios, técnicos asignados, estado, fechas
- Rol: Cliente autenticado (token JWT)

### 💾 SQL
```sql
SELECT 
    c.*, 
    s.nombre as service_name,
    t.nombre as technician_name, 
    t.email as technician_email, 
    t.id_tecnico
FROM contrataciones c
JOIN servicios s ON c.id_servicio = s.id_servicio
LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico
WHERE c.id_cliente = @cliente
ORDER BY c.fecha_solicitud DESC;
```

### ⚙️ Parámetro
- `@cliente`: ID del cliente (INT, del JWT)

### 📤 Retorna
```json
[
  {
    "id_contratacion": 42,
    "id_cliente": 1,
    "id_tecnico": 5,
    "id_servicio": 3,
    "detalles": "Reparación de aire acondicionado",
    "fecha_solicitud": "2024-12-15T14:30:00",
    "fecha_programada": "2024-12-20T10:00:00",
    "estado": "Pendiente",
    "service_name": "Reparación de AC",
    "technician_name": "Carlos Técnico",
    "technician_email": "carlos@example.com"
  }
]
```

---

## 🔐 SEGURIDAD EN TODAS LAS OPERACIONES

### ✅ Parámetros (Previene inyecciones SQL)
```csharp
// INSEGURO:
string query = $"SELECT * FROM clientes WHERE email = '{email}'";

// SEGURO:
string query = "SELECT * FROM clientes WHERE email = @email";
var parameters = new Dictionary<string, object> { { "email", email } };
```

### ✅ Encriptación de Contraseñas (BCrypt)
```csharp
// Registrar:
string hash = BCrypt.Net.BCrypt.HashPassword(plainPassword);

// Login:
bool isValid = BCrypt.Net.BCrypt.Verify(plainPassword, storedHash);
```

### ✅ Validación de Existencia
```csharp
// Antes de INSERT/UPDATE/DELETE, siempre validar que exista
var exists = await _db.ExecuteScalarAsync<int>(
    "SELECT COUNT(*) FROM clientes WHERE id_cliente = @id",
    new Dictionary<string, object> { { "id", clientId } }
);
if (exists == 0) return BadRequest("Client does not exist");
```

### ✅ Autenticación con JWT
```csharp
// Extraer ID del token
var clientId = int.Parse(User.FindFirst("sub")?.Value);

// Solo ese cliente puede ver/modificar sus datos
WHERE id_cliente = @id  // @id viene del JWT
```

### ✅ Gestión de Recursos (Using Statement)
```csharp
using (var connection = GetConnection())
{
    // Conexión se cierra automáticamente
}
```

---

## 📊 RELACIÓN ENTRE OPERACIONES

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENTE                              │
│  ┌──────────────┐                                       │
│  │ OP 1: INSERT │  Registrar nuevo cliente              │
│  └──────────────┘                                       │
│         ↓                                               │
│  ┌──────────────┐                                       │
│  │ OP 6: SELECT │  Login (validar credenciales)        │
│  └──────────────┘                                       │
│         ↓                                               │
│  ┌──────────────┐                                       │
│  │ OP 3: SELECT │  Ver su perfil                        │
│  └──────────────┘                                       │
│         ↓                                               │
│  ┌──────────────┐                                       │
│  │ OP 5: UPDATE │  Editar su perfil                     │
│  └──────────────┘                                       │
│         ↓                                               │
│  ┌──────────────┐                                       │
│  │ OP 4: SELECT │  Buscar técnicos                      │
│  └──────────────┘                                       │
│         ↓                                               │
│  ┌──────────────┐                                       │
│  │ OP 7: INSERT │  Crear contratación                   │
│  └──────────────┘                                       │
│         ↓                                               │
│  ┌──────────────┐                                       │
│  │ OP 8: SELECT │  Ver sus contrataciones               │
│  └──────────────┘                                       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    TÉCNICO                              │
│  ┌──────────────┐                                       │
│  │ OP 2: INSERT │  Registrar nuevo técnico              │
│  └──────────────┘                                       │
│         ↓                                               │
│  ┌──────────────┐                                       │
│  │ OP 6: SELECT │  Login (validar credenciales)        │
│  └──────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```

---

## 🎓 PARA LA DEFENSA

### Puntos a mencionar:
1. ✅ **ADO.NET** → Tecnología de acceso a datos de Microsoft
2. ✅ **Parámetros** → Previenen inyecciones SQL
3. ✅ **BCrypt** → Encriptación segura de contraseñas
4. ✅ **JWT** → Autenticación sin sesiones (estateless)
5. ✅ **Async/Await** → No bloquea la aplicación
6. ✅ **Validaciones** → Verifican existencia antes de operar
7. ✅ **Transacciones** → Atomicidad en múltiples operaciones
8. ✅ **Gestión de recursos** → Using statements cierran conexiones

### Ejemplo de respuesta:
> "SERVITEC usa **ADO.NET** para comunicarse con MySQL. Cada operación usa **parámetros** para prevenir inyecciones SQL, **validaciones** para garantizar integridad, y **BCrypt** para encriptar contraseñas. Los datos del cliente se protegen con **JWT**, permitiendo acceso solo a sus propios registros. Todo es **asincrónico** para no bloquear la aplicación."

---

## 📝 CHECKLIST PARA IMPLEMENTACIÓN

- [ ] OP 1: INSERT Cliente (AuthService)
- [ ] OP 2: INSERT Técnico (AuthService)
- [ ] OP 3: SELECT Perfil (ApiController)
- [ ] OP 4: SELECT Técnicos (ApiController)
- [ ] OP 5: UPDATE Perfil (ApiController)
- [ ] OP 6: SELECT Login (AuthService)
- [ ] OP 7: INSERT Contratación (ContractionsController)
- [ ] OP 8: SELECT Contrataciones (ContractionsController)

---

**Última actualización:** Diciembre 2024  
**Estado:** ✅ Completo y verificado  
**Código:** Extraído del proyecto real en `backend-csharp/`
