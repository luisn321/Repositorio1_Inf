# GUÍA DE DEFENSA: PRESENTACIÓN DE SERVITEC

**Documento:** Recomendaciones para la defensa oral  
**Asignatura:** Taller de Base de Datos - 5to Semestre  
**Proyecto:** SERVITEC  
**Fecha:** Diciembre 2024

---

## 🎯 OBJETIVOS DE LA PRESENTACIÓN

Tu presentación debe demostrar:

1. ✅ **Comprensión técnica** de ADO.NET y MySQL
2. ✅ **Diseño de BD** correcto (tablas, relaciones, integridad)
3. ✅ **Seguridad** (parámetros, BCrypt, autenticación)
4. ✅ **Prácticas profesionales** (async/await, manejo de errores)
5. ✅ **Integración** entre frontend (Flutter) y backend (ASP.NET)

---

## 📋 ESTRUCTURA RECOMENDADA DE LA PRESENTACIÓN

### Duración: 15-20 minutos

```
0:00 - 1:00     Introducción y contexto del proyecto
1:00 - 3:00     Modelo de datos (ER, tablas)
3:00 - 5:00     Arquitectura (Flutter + API + BD)
5:00 - 12:00    8 Operaciones SQL (demostración en vivo)
12:00 - 15:00   Seguridad e implementación
15:00 - 18:00   Conclusiones y mantenimiento
18:00 - 20:00   Preguntas
```

---

## 📊 PARTE 1: INTRODUCCIÓN (1:00 - 1:00)

### Guión:
> "SERVITEC es una aplicación móvil que conecta clientes con técnicos especializados. 
> El cliente busca un técnico, crea una solicitud de servicio, y el técnico lo atiende.
> 
> Para esto, usamos:
> - **Frontend:** Flutter (multiplataforma)
> - **Backend:** ASP.NET Core (API REST)
> - **BD:** MySQL (persistencia)
> - **Conexión:** ADO.NET (acceso a datos seguro)"

### Visual:
Muestra el logo/icono de la app en pantalla.

---

## 📊 PARTE 2: MODELO DE DATOS (3:00 - 5:00)

### ¿Qué mostrar?

**Opción 1: Diagrama ER** (dibujado o en herramienta)
```
Mostrar:
- Tablas principales (clientes, técnicos, servicios, contrataciones)
- Relaciones (FK)
- Tipos de datos
```

**Opción 2: Estructura de tablas**
```sql
-- Mostrar CREATE TABLE para cada tabla
CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    -- ... más campos
);
```

### Puntos a explicar:
1. ✅ Cada tabla representa una entidad (Cliente, Técnico, etc.)
2. ✅ Relaciones entre tablas usando Foreign Keys
3. ✅ Integridad referencial garantizada por BD
4. ✅ Índices en campos que se buscan (email, id)

---

## 📊 PARTE 3: ARQUITECTURA (5:00 - 7:00)

### Diagrama a mostrar:

```
CLIENTE (Flutter App)
    ↓
API REST (ASP.NET Core)
    ├─ AuthService (login/registro)
    ├─ ApiController (clientes/técnicos)
    └─ ContractionsController (servicios)
    ↓
DATABASE SERVICE (ADO.NET)
    ↓
MySQL Database
```

### Explicar cada capa:

**Capa 1: Cliente (Flutter)**
- Interfaz de usuario
- Inputs del usuario
- Llamadas HTTP a la API

**Capa 2: API (ASP.NET Core)**
- Controllers reciben requests
- DatabaseService realiza operaciones
- Retorna JSON

**Capa 3: BD (MySQL)**
- Almacenamiento persistente
- Integridad de datos
- Concurrencia

### Puntos clave:
- 🔒 Separación de responsabilidades
- 🔐 Comunicación asincrónica
- 📊 Escalabilidad

---

## 📊 PARTE 4: LAS 8 OPERACIONES REALES (7:00 - 15:00)

### Demostración en vivo (recomendado):

Para cada operación, mostrar:

1. **SQL puro** (2 líneas en la diapositiva)
2. **Código C#** (código real del proyecto)
3. **Request/Response** (ejemplo de Postman)
4. **Caso de error** (validación)

---

## ✨ OPERACIÓN 1: REGISTRAR CLIENTE

### Diapositiva:
```
REGISTRACIÓN DE CLIENTE (INSERT)

Tabla: clientes
Rol: Público (sin autenticación)
Endpoint: POST /api/auth/register/client

INSERT INTO clientes (nombre, email, password_hash, ...)
VALUES (@nombre, @email, @password_hash, ...);

Características:
✅ Parámetros → Previene inyecciones SQL
✅ Email único → Validación en BD
✅ Contraseña encriptada → BCrypt
✅ Ubicación opcional → Puede ser NULL
```

### Demostración Postman:
```
1. Abrir Postman
2. POST http://localhost:5000/api/auth/register/client
3. Body:
{
  "firstName": "Juan",
  "lastName": "Pérez",
  "email": "juan@example.com",
  "password": "Password123!",
  "phone": "0987654321",
  "latitude": -0.2255,
  "longitude": -78.5249
}
4. Enviar → Mostrar response: { "id_cliente": 1 }
5. Abrir MySQL Workbench → SELECT * FROM clientes → Mostrar el nuevo registro
```

### Puntos a mencionar:
- "El email es **único** en la tabla"
- "La contraseña se encripta con **BCrypt** antes de guardar"
- "Se retorna el **id_cliente** autogenerado"

---

## ✨ OPERACIÓN 2: REGISTRAR TÉCNICO

### Diapositiva:
```
REGISTRACIÓN DE TÉCNICO (INSERT)

Tabla: tecnicos
Rol: Público (sin autenticación)
Endpoint: POST /api/auth/register/technician

INSERT INTO tecnicos 
(nombre, email, password_hash, tarifa_hora, experiencia_years, ...)
VALUES (...)

Diferencias con cliente:
✅ Requiere tarifa_hora (DECIMAL)
✅ Requiere experiencia_years (INT)
✅ Calificación comienza en 0
✅ Puede ofrecer múltiples servicios
```

### Demostración:
Similar a OP1, pero con request diferente

### Puntos a mencionar:
- "El técnico especifica su **tarifa por hora**"
- "Los años de **experiencia** se validan (no negativos)"
- "La calificación promedio comienza en 0 (sin valoraciones aún)"

---

## ✨ OPERACIÓN 6: LOGIN / AUTENTICACIÓN

### Diapositiva:
```
LOGIN Y VALIDACIÓN (SELECT + Verificación)

Tabla: clientes/tecnicos
Rol: Público (sin autenticación previa)
Endpoint: POST /api/auth/login

SELECT * FROM clientes WHERE email = @email AND es_activo = 1;

Flujo de seguridad:
1. SELECT busca el usuario por email
2. Si NO existe → ERROR "Credenciales inválidas"
3. Si existe → BCrypt.Verify(inputPassword, storedHash)
4. Si NO coincide → ERROR "Credenciales inválidas"
5. Si coincide → Generar JWT token → Retornar

Seguridad:
✅ No se retorna la contraseña
✅ BCrypt valida sin desencriptar
✅ JWT stateless (sin sesiones en servidor)
```

### Demostración:
```
1. Postman: POST /api/auth/login
2. Body: { "email": "juan@example.com", "password": "Password123!" }
3. Respuesta: { "id": 1, "nombre": "Juan Pérez", "token": "eyJhbGc..." }
4. Copiar token → Guardarlo en variable de Postman
5. Explicar: "Este token será usado en los siguientes requests"
```

### Puntos a mencionar:
- "**BCrypt** es una función de hash **irreversible**"
- "El token **JWT** contiene el ID del usuario"
- "Sin contraseña guardada en sesión (stateless)"

---

## ✨ OPERACIÓN 3: VER PERFIL CLIENTE

### Diapositiva:
```
OBTENER PERFIL DE CLIENTE (SELECT)

Tabla: clientes
Rol: Cliente autenticado
Endpoint: GET /api/clients/{id}

SELECT id_cliente, nombre, email, telefono, ... FROM clientes WHERE id_cliente = @id;

Seguridad:
✅ Requiere JWT token válido
✅ El usuario solo ve su propio perfil
✅ El ID se extrae del token (no del usuario)
```

### Demostración:
```
1. Postman: GET /api/clients/1
2. Header: Authorization: Bearer eyJhbGc...
3. Respuesta: JSON con todos los datos del cliente
4. Explicar: "El cliente autenticado solo ve sus datos, no los de otros"
```

### Puntos a mencionar:
- "**Autenticación**: El token verifica que sea el usuario real"
- "**Autorización**: Solo ve sus datos, no ajenos"
- "El **ID viene del token**, no de la URL"

---

## ✨ OPERACIÓN 5: ACTUALIZAR PERFIL

### Diapositiva:
```
ACTUALIZAR PERFIL DE CLIENTE (UPDATE)

Tabla: clientes
Rol: Cliente autenticado
Endpoint: PUT /api/clients/{id}

UPDATE clientes 
SET nombre = @nombre, email = @email, ... WHERE id_cliente = @id;

Característica especial: ACTUALIZACIÓN SELECTIVA
✅ Solo actualiza los campos que se envían
✅ Los campos no enviados NO cambian
✅ Evita sobrescribir datos accidentalmente

Ejemplo:
Request: { "email": "nuevo@example.com" }
Efecto: Solo email cambia, teléfono se mantiene igual
```

### Demostración:
```
1. GET /api/clients/1 → Mostrar datos actuales
2. PUT /api/clients/1 → { "phone": "0999999999" }
3. GET /api/clients/1 → Mostrar que solo teléfono cambió
4. Explicar: "Los otros campos no se modificaron"
```

### Puntos a mencionar:
- "UPDATE **dinámico** basado en parámetros"
- "**Actualización parcial** es más segura"
- "Validaciones de email único, contraseña fuerte, etc."

---

## ✨ OPERACIÓN 4: BUSCAR TÉCNICOS

### Diapositiva:
```
LISTAR TÉCNICOS DISPONIBLES (SELECT + JOIN)

Tablas: tecnicos, tecnico_servicio, servicios
Rol: Cliente autenticado
Endpoint: GET /api/technicians?service=3&limit=10

SELECT t.* FROM tecnicos t
WHERE es_activo = 1 
  AND (@servicio IS NULL OR EXISTS (
    SELECT 1 FROM tecnico_servicio ts 
    WHERE ts.id_tecnico = t.id_tecnico 
    AND ts.id_servicio = @servicio
  ))
ORDER BY calificacion_promedio DESC, tarifa_hora ASC
LIMIT 10 OFFSET 0;

Características:
✅ Filtro por servicio (opcional)
✅ Ordenamiento: calificación ↓, tarifa ↑
✅ Paginación: LIMIT + OFFSET
✅ Solo técnicos activos (es_activo = 1)
```

### Demostración:
```
1. GET /api/technicians → Mostrar todos
2. GET /api/technicians?service=3 → Filtrados por servicio
3. GET /api/technicians?limit=5&offset=0 → Página 1
4. Mostrar: Ordenados por calificación (mejores primero)
```

### Puntos a mencionar:
- "**EXISTS** valida que técnico tenga ese servicio"
- "**ORDER BY** muestra técnicos mejor valorados primero"
- "**LIMIT/OFFSET** implementan paginación eficiente"

---

## ✨ OPERACIÓN 7: CREAR CONTRATACIÓN

### Diapositiva:
```
CREAR SOLICITUD DE SERVICIO (INSERT + Validaciones)

Tabla: contrataciones
Rol: Cliente autenticado
Endpoint: POST /api/contractions

INSERT INTO contrataciones 
(id_cliente, id_tecnico, id_servicio, detalles, fecha_solicitud, 
 fecha_programada, estado)
VALUES (@client, @tech, @service, @desc, NOW(), @fecha_prog, 'Pendiente');

Validaciones:
✅ Cliente existe (FK válido)
✅ Servicio existe (FK válido)
✅ Técnico existe (si se especifica)
✅ Estados: Pendiente → Asignado → En Progreso → Completado

Flujo:
1. Cliente sin técnico especificado → Estado "Pendiente"
2. Sistema busca técnico disponible → "Asignado"
3. Técnico acepta → "En Progreso"
4. Trabajo termina → "Completado"
```

### Demostración:
```
1. POST /api/contractions
2. Body: { "clientId": 1, "serviceId": 3, "technicianId": 5 }
3. Respuesta: { "id_contratacion": 42, "estado": "Asignado" }
4. Mostrar en BD: SELECT * FROM contrataciones WHERE id_contratacion = 42;
```

### Puntos a mencionar:
- "Las **validaciones** previenen datos inconsistentes"
- "Las **FK (Foreign Keys)** garantizan integridad referencial"
- "Los **estados** modelan el ciclo de vida del servicio"

---

## ✨ OPERACIÓN 8: VER MIS CONTRATACIONES

### Diapositiva:
```
LISTAR CONTRATACIONES DEL CLIENTE (SELECT + JOINs)

Tablas: contrataciones, servicios, tecnicos
Rol: Cliente autenticado
Endpoint: GET /api/contractions/client/{id}

SELECT c.*, s.nombre as service_name, t.nombre as technician_name
FROM contrataciones c
JOIN servicios s ON c.id_servicio = s.id_servicio
LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico
WHERE c.id_cliente = @cliente
ORDER BY c.fecha_solicitud DESC;

JOINs:
✅ INNER JOIN servicios → Siempre hay servicio
✅ LEFT JOIN tecnicos → Puede no haber técnico (Pendiente)

Información agregada:
✅ Nombre del servicio
✅ Nombre del técnico (si está asignado)
✅ Estado actual
✅ Fechas de solicitud y programación
```

### Demostración:
```
1. GET /api/contractions/client/1
2. Mostrar array con contrataciones
3. Explicar campos del response
4. Mostrar que técnico_name es NULL si aún no asignado
```

### Puntos a mencionar:
- "**LEFT JOIN** permite técnico NULL (contrataciones pendientes)"
- "**INNER JOIN** con servicios (obligatorio tener servicio)"
- "**ORDER BY DESC** muestra más recientes primero"

---

## 🔐 PARTE 5: SEGURIDAD E IMPLEMENTACIÓN (15:00 - 18:00)

### Tema 1: Inyección SQL

**Mostrar código INSEGURO:**
```csharp
// ❌ INSEGURO
string query = $"SELECT * FROM clientes WHERE email = '{email}'";
// Problema: Si email = "' OR '1'='1" → Retorna todos los usuarios
```

**Mostrar código SEGURO:**
```csharp
// ✅ SEGURO
string query = "SELECT * FROM clientes WHERE email = @email";
var parameters = new Dictionary<string, object> { { "email", email } };
// La BD trata @email como VALOR, no como código
```

### Tema 2: Encriptación de Contraseñas

**Mostrar:**
```csharp
// Registrar
string plainPassword = "Password123!";
string hash = BCrypt.Net.BCrypt.HashPassword(plainPassword);
// hash = "$2a$11$N9qo8uLO..." (imposible desencriptar)

// Login
bool isValid = BCrypt.Net.BCrypt.Verify(plainPassword, hash);
// Retorna true si coinciden
```

**Explicar:**
- "BCrypt es **hash** (irreversible), no encriptación"
- "Cada password tiene **salt** único"
- "Aunque tengas el hash, no puedes obtener el password"

### Tema 3: Autenticación JWT

**Mostrar token:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
.eyJzdWIiOiIxIiwibmFtZSI6IkpvaG4ifQ
.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

**Estructura:**
```
Header.Payload.Signature

Header: { "alg": "HS256", "typ": "JWT" }
Payload: { "sub": "1", "name": "John", "iat": 1516239022 }
Signature: HMAC_SHA256(Header + Payload, secret)
```

**Ventajas:**
- Stateless (sin sesiones en servidor)
- Escalable (múltiples servidores)
- Mobile-friendly (token en header)

### Tema 4: Manejo de Recursos

```csharp
// ✅ CORRECTO: Using statement
using (var connection = GetConnection())
{
    await connection.OpenAsync();
    // Usar la conexión
}
// Aquí la conexión se cierra automáticamente
```

**Explicar:**
- "**Using** garantiza liberación de recursos"
- "Aunque ocurra excepción, la conexión se cierra"
- "Previene memory leaks y saturación de conexiones"

---

## 💻 PARTE 6: DEMOSTRACIÓN EN VIVO (Opcional pero recomendado)

### Si tienes tiempo, hacer prueba en vivo:

```
1. Abrir Visual Studio Code
2. Terminal: dotnet run (backend)
3. Terminal 2: flutter run (app en emulador o dispositivo)
4. Postman: Hacer request a /api/auth/register/client
5. MySQL Workbench: SELECT * FROM clientes (mostrar insert)
6. Flutter: Ir a login → Ingresar credenciales
7. API: Ver logs en terminal (consultas realizadas)
```

### Qué logra esto:
- Demuestra que **realmente funciona**
- Muestra integración **frontend ↔ backend ↔ BD**
- Genera confianza en el tribunal

---

## 🎯 CONCLUSIONES (18:00 - 19:00)

### Diapositiva Final:

```
RESUMEN DE LOGROS

✅ Aplicación completa: Flutter + ASP.NET Core + MySQL
✅ 8 operaciones SQL reales documentadas
✅ Seguridad: BCrypt + JWT + parámetros
✅ Buenas prácticas: async/await, manejo de errores
✅ Integridad de datos: Foreign keys, validaciones
✅ Escalabilidad: Arquitectura en capas

TECNOLOGÍAS USADAS

Frontend:  Flutter + Dart
Backend:   ASP.NET Core + C#
Base de datos: MySQL + ADO.NET
Seguridad: BCrypt + JWT + HTTPS

MEJORAS FUTURAS

→ Pagos con Stripe/PayPal
→ Notificaciones push
→ Calificación y reviews
→ Chat en tiempo real (WebSockets)
→ Integración con Google Maps
→ Sistema de reportes
```

---

## ❓ PREGUNTAS COMUNES DEL TRIBUNAL

### P: "¿Por qué usar ADO.NET en lugar de Entity Framework?"

**Respuesta sugerida:**
> "ADO.NET nos da control total sobre las consultas SQL. 
> Es mejor para queries complejas con múltiples JOINs.
> Entity Framework es más rápido para CRUD simple, pero menos flexible.
> En este proyecto preferimos control + rendimiento."

### P: "¿Cómo previenen inyecciones SQL?"

**Respuesta sugerida:**
> "Usamos **parámetros** en lugar de concatenación de strings.
> Cada valor va en @nombre_param, que la BD trata como VALOR, no código.
> Si alguien intenta: email = \"' OR '1'='1\", se interpreta literalmente, no como lógica SQL."

### P: "¿Por qué BCrypt y no SHA256?"

**Respuesta sugerida:**
> "BCrypt es más lento (es intencional) → Dificulta ataques de fuerza bruta.
> BCrypt incluye SALT único por contraseña → Mismo password ≠ mismo hash.
> SHA256 es rápido, vulnerable a ataques de diccionario.
> Seguridad > Velocidad en este caso."

### P: "¿Cómo se autentican los usuarios?"

**Respuesta sugerida:**
> "En login, validamos email + contraseña con BCrypt.
> Si son correctos, generamos un JWT token.
> El cliente guarda el token en SharedPreferences.
> Cada request incluye: Authorization: Bearer TOKEN.
> El servidor verifica que el token sea válido."

### P: "¿Qué pasa si alguien obtiene el JWT?"

**Respuesta sugerida:**
> "El JWT viaja en HTTPS (encriptado en tránsito).
> Si se obtiene, el atacante puede actuar como ese usuario.
> Por eso: usar HTTPS, renovar tokens, logout claro.
> El token tiene expiración (ej: 24 horas)."

### P: "¿Cómo manejan transacciones?"

**Respuesta sugerida:**
> "En operaciones simples, cada INSERT/UPDATE es automáticamente guardado (autocommit).
> En operaciones complejas (ej: crear contratación + registrar pago),
> podríamos usar transacciones (BEGIN TRANSACTION, COMMIT, ROLLBACK).
> Eso garantiza atomicidad: o se hacen todas o ninguna."

### P: "¿Cómo escalan a millones de usuarios?"

**Respuesta sugerida:**
> "En producción implementaríamos:
> - Índices en campos frecuentes (email, id_tecnico)
> - Caché (Redis) para queries frecuentes
> - Base de datos replicada (redundancia)
> - API en múltiples servidores (load balancing)
> - Async/await previene bloqueos
> Hoy con ADO.NET + MySQL podemos ~1000 usuarios concurrentes."

### P: "¿Qué patrones de diseño usaron?"

**Respuesta sugerida:**
> "Usamos:
> - **DAO (Data Access Object)** → DatabaseService
> - **MVC** → Controllers + Views (Flutter)
> - **Inyección de dependencias** → Pasar DatabaseService al constructor
> - **Parámetros** → Patrón de consultas seguras
> Estos patrones hacen el código mantenible y testeable."

---

## 📝 TIPS PARA LA PRESENTACIÓN

### ✅ Haz:

1. **Practica el guión** varias veces (solo 20 min, tienes que ser rápido)
2. **Simula preguntas** que podría hacer el tribunal
3. **Ten el código abierto** en VS Code (por si preguntan detalles)
4. **Ten Postman abierto** con requests preparados
5. **Habla claro** y a ritmo moderado (no muy rápido)
6. **Mantén contacto visual** con el tribunal
7. **Usa ejemplos concretos** (de la app real)
8. **Sé honesto** si no sabes algo ("Es una buena pregunta, requiere investigación")

### ❌ No hagas:

1. ❌ No leas las diapositivas (habla libremente)
2. ❌ No muestres código sin explicar (booooring)
3. ❌ No hagas demostraciones sin preparar (pueden fallar)
4. ❌ No hables muy rápido por nervios
5. ❌ No criticar a compañeros o la materia
6. ❌ No improvisar en código en vivo (riesgoso)
7. ❌ No ignores las preguntas del tribunal

---

## 🎬 SECUENCIA DE PRESENTACIÓN RECOMENDADA

```
⏰ 0:00-1:00   INTRODUCCIÓN
               "Qué es SERVITEC, qué problema resuelve"
               
⏰ 1:00-3:00   MODELO DE DATOS
               Mostrar diagrama ER y tablas
               
⏰ 3:00-5:00   ARQUITECTURA
               Diagrama: Flutter → API → BD
               
⏰ 5:00-7:00   OPERACIÓN 1-2: REGISTRO
               Mostrar código + demostración Postman
               
⏰ 7:00-9:00   OPERACIÓN 6: LOGIN
               Explicar BCrypt y JWT
               
⏰ 9:00-11:00  OPERACIÓN 3-5: PERFIL
               Ver y editar datos del cliente
               
⏰ 11:00-13:00 OPERACIÓN 4: BÚSQUEDA
               Filtros y paginación
               
⏰ 13:00-15:00 OPERACIÓN 7-8: CONTRATACIÓN
               Crear y listar servicios
               
⏰ 15:00-18:00 SEGURIDAD
               SQL Injection, BCrypt, JWT
               
⏰ 18:00-20:00 CONCLUSIONES + PREGUNTAS
```

---

## 📚 DOCUMENTOS QUE DEBES LLEVAR IMPRESOS

1. ✅ **REPORTE_SCRIPT_CONEXION_ADONET.md** (detallado)
2. ✅ **RESUMEN_OPERACIONES_SQL.md** (rápido)
3. ✅ **DIAGRAMA_VISUAL_OPERACIONES.md** (visual)
4. ✅ **GUIA_PRUEBA_OPERACIONES.md** (técnico)
5. ✅ **Este documento de defensa**

---

## 🏆 CÓMO CAUSAR BUENA IMPRESIÓN

### Los jueces buscan:

1. **Dominio técnico**
   - Entiendes QUÉ y POR QUÉ de cada línea
   - Puedes explicar decisiones de diseño
   - Reconoces trade-offs (velocidad vs seguridad)

2. **Pensamiento crítico**
   - No solo "copié un tutorial"
   - Pensaste en seguridad desde el inicio
   - Tienes mejoras futuras identificadas

3. **Comunicación clara**
   - Traduces conceptos técnicos al español
   - Das ejemplos que el tribunal entiende
   - Verificas que todos te entiendan

4. **Preparación**
   - Todos los archivos listos
   - Código ejecutable sin "un momentito..."
   - Respuestas a preguntas comunes

5. **Profesionalismo**
   - Código limpio y comentado
   - Documentación clara
   - Respeto por el tribunal y compañeros

---

## 🎓 PUNTOS DE DEFENSA CLAVES

**Práctica estos 5 puntos hasta soñar con ellos:**

### 1. ADO.NET y parámetros
> "ADO.NET es la tecnología de Microsoft para acceder a datos.
> Los **parámetros** (@nombre) previenen inyecciones SQL.
> Nunca concatenamos strings en queries."

### 2. Flujo de autenticación
> "Cliente se registra → Contraseña se encripta con BCrypt →
> En login, comparamos con BCrypt.Verify() →
> Generamos JWT token → Cliente lo envía en cada request →
> Servidor verifica que sea válido"

### 3. Las 8 operaciones
> "2 INSERT (registro), 1 SELECT login, 2 SELECT de datos, 
> 1 UPDATE de perfil, 1 INSERT contratación, 1 SELECT con JOINs"

### 4. Seguridad multinivel
> "Parámetros previenen SQL injection, BCrypt previene password cracking,
> JWT previene acceso sin autenticación, HTTPS previene sniffing"

### 5. Buenas prácticas
> "Async/await no bloquea, Using garantiza liberar recursos,
> Validaciones de FK previenen datos inconsistentes"

---

## 🚀 FRASE FINAL RECOMENDADA

> "SERVITEC demuestra integración completa entre frontend móvil,
> backend escalable y base de datos segura, aplicando buenas prácticas
> de seguridad, integridad y rendimiento. El código está listo para producción."

---

Última actualización: Diciembre 2024  
Versión: 1.0 Completo  
Estado: ✅ Listo para presentación oral
