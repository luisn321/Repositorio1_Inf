# DIAGRAMA VISUAL: FLUJO DE OPERACIONES SQL EN SERVITEC

**Documento:** Guía visual de flujos de datos  
**Proyecto:** SERVITEC  
**Fecha:** Diciembre 2024

---

## 🔄 FLUJO COMPLETO DEL CLIENTE

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        APLICACIÓN FLUTTER                               │
│                                                                         │
│  1. Cliente abre la app                                                │
│     ↓                                                                  │
│  2. ¿Ya tiene cuenta?                                                 │
│     ├─ NO → OPERACIÓN 1: Registrarse (INSERT Cliente)                │
│     │       screen/signup.dart → POST /api/auth/register/client      │
│     │                                                                 │
│     │       INSERT INTO clientes                                     │
│     │       (nombre, email, password_hash, ...)                      │
│     │       → Retorna: id_cliente                                   │
│     │                                                                 │
│     └─ SÍ → Ir a login                                              │
│             ↓                                                         │
│  3. OPERACIÓN 6: Ingresar credenciales (SELECT Login)               │
│     screen/login.dart → POST /api/auth/login                        │
│                                                                      │
│     SELECT * FROM clientes                                          │
│     WHERE email = @email AND es_activo = 1                          │
│     → Validar: BCrypt.Verify(password, password_hash)              │
│     → Retorna: JWT token                                           │
│                                                                      │
│  4. Token guardado en SharedPreferences                             │
│     ↓                                                                │
│  5. OPERACIÓN 3: Ver perfil (SELECT Perfil)                        │
│     screen/profile.dart → GET /api/clients/{id}                    │
│                                                                      │
│     SELECT id_cliente, nombre, email, telefono, ...                │
│     FROM clientes WHERE id_cliente = @id                           │
│     → Retorna: Datos del cliente                                   │
│                                                                      │
│  6. OPERACIÓN 5: Editar perfil (UPDATE Perfil)                     │
│     screen/edit_profile.dart → PUT /api/clients/{id}               │
│                                                                      │
│     UPDATE clientes                                                │
│     SET nombre = @nombre, email = @email, ...                      │
│     WHERE id_cliente = @id                                         │
│     → Retorna: {"message": "OK"}                                   │
│                                                                      │
│  7. OPERACIÓN 4: Buscar técnicos (SELECT Técnicos)                │
│     screen/technicians.dart → GET /api/technicians?service=3      │
│                                                                      │
│     SELECT * FROM tecnicos                                         │
│     WHERE es_activo = 1                                            │
│     AND (servicio_id IS NULL OR ...)                               │
│     ORDER BY calificacion DESC                                     │
│     → Retorna: Lista de técnicos                                   │
│                                                                      │
│  8. Cliente selecciona un técnico                                  │
│     ↓                                                                │
│  9. OPERACIÓN 7: Crear contratación (INSERT Contratación)          │
│     screen/hire_technician.dart → POST /api/contractions           │
│                                                                      │
│     INSERT INTO contrataciones                                     │
│     (id_cliente, id_tecnico, id_servicio, detalles, ...)           │
│     → Retorna: id_contratacion                                     │
│                                                                      │
│  10. OPERACIÓN 8: Ver mis contrataciones (SELECT Contrataciones)  │
│      screen/my_jobs.dart → GET /api/contractions/client/{id}      │
│                                                                      │
│      SELECT c.*, s.nombre, t.nombre                               │
│      FROM contrataciones c                                         │
│      JOIN servicios s ON c.id_servicio = s.id_servicio             │
│      LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico           │
│      WHERE c.id_cliente = @id                                      │
│      → Retorna: Lista de contrataciones                            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 FLUJO COMPLETO DEL TÉCNICO

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        APLICACIÓN FLUTTER                               │
│                                                                         │
│  1. Técnico abre la app                                               │
│     ↓                                                                  │
│  2. ¿Ya tiene cuenta?                                                 │
│     ├─ NO → OPERACIÓN 2: Registrarse (INSERT Técnico)                │
│     │       screen/signup_technician.dart                            │
│     │       → POST /api/auth/register/technician                     │
│     │                                                                 │
│     │       INSERT INTO tecnicos                                     │
│     │       (nombre, email, password_hash, tarifa_hora,              │
│     │        experiencia_years, ...)                                 │
│     │       → Retorna: id_tecnico                                   │
│     │                                                                 │
│     └─ SÍ → Ir a login                                              │
│             ↓                                                         │
│  3. OPERACIÓN 6: Ingresar credenciales (SELECT Login)               │
│     screen/login.dart → POST /api/auth/login?type=technician        │
│                                                                      │
│     SELECT * FROM tecnicos                                          │
│     WHERE email = @email AND es_activo = 1                          │
│     → Validar: BCrypt.Verify(password, password_hash)              │
│     → Retorna: JWT token                                           │
│                                                                      │
│  4. Token guardado en SharedPreferences                             │
│     ↓                                                                │
│  5. Dashboard: Ver solicitudes pendientes                           │
│     screen/technician_jobs.dart                                     │
│     (Nota: Se requiere crear esta operación)                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 ARQUITECTURA DE LAS OPERACIONES

```
┌──────────────────────────────────────────────────────────────────┐
│                      CLIENTE (FLUTTER)                           │
└───────────────────────┬──────────────────────────────────────────┘
                        │ HTTP Requests
                        ↓
┌──────────────────────────────────────────────────────────────────┐
│                 API REST (ASP.NET CORE)                         │
│                                                                 │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    CONTROLLERS                              │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │ │
│  │  │ AuthService  │  │ ApiController│  │  Contractions│     │ │
│  │  │              │  │  Controller  │  │  Controller  │     │ │
│  │  ├─ OP 1: Reg  │  ├─ OP 3: Get  │  ├─ OP 7: POST  │     │ │
│  │  │   Cliente   │  │   Perfil    │  │   Contrata   │     │ │
│  │  ├─ OP 2: Reg  │  ├─ OP 4: List │  ├─ OP 8: GET   │     │ │
│  │  │   Técnico   │  │   Técnicos  │  │   Contratas  │     │ │
│  │  ├─ OP 6: Login│  ├─ OP 5: Update│  └──────────────┘     │ │
│  │  │             │  │   Perfil    │                         │ │
│  │  └──────────────┘  └──────────────┘                         │ │
│  └────────────────┬───────────────────────────────────────────┘ │
│                   │ DatabaseService._db.ExecuteQueryAsync()     │
│  ┌────────────────↓───────────────────────────────────────────┐ │
│  │          DATABASE SERVICE (ADO.NET)                        │ │
│  │                                                            │ │
│  │  • ExecuteScalarAsync<T>() → Para SELECT COUNT()          │ │
│  │  • ExecuteQueryAsync()     → Para SELECT queries          │ │
│  │  • ExecuteNonQueryAsync()  → Para INSERT/UPDATE/DELETE    │ │
│  │  • HashPassword()          → BCrypt.HashPassword()        │ │
│  │  • VerifyPassword()        → BCrypt.Verify()            │ │
│  └────────────────┬───────────────────────────────────────────┘ │
│                   │ MySql.Data.MySqlClient                      │
└───────────────────↓──────────────────────────────────────────────┘
                    │
┌───────────────────↓──────────────────────────────────────────────┐
│                   MySQL DATABASE                                 │
│                                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐    │
│  │ Tabla    │  │ Tabla    │  │ Tabla    │  │ Tabla        │    │
│  │ clientes │  │ tecnicos │  │ servicios│  │ contrataciones│   │
│  │          │  │          │  │          │  │              │    │
│  │ • INSERT │  │ • INSERT │  │ • JOIN   │  │ • INSERT     │    │
│  │ • SELECT │  │ • SELECT │  │ • SELECT │  │ • SELECT     │    │
│  │ • UPDATE │  │ • UPDATE │  │          │  │ • UPDATE     │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────┘    │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Tabla: tecnico_servicio (relación M:N)                   │   │
│  │ • FK: id_tecnico → tecnicos                              │   │
│  │ • FK: id_servicio → servicios                            │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🔐 FLUJO DE SEGURIDAD (LOGIN)

```
┌──────────────────────────────────────────────────────────────┐
│  USUARIO INGRESA: email="juan@example.com", password="123" │
└─────────────────────┬──────────────────────────────────────┘
                      │
                      ↓
          ┌──────────────────────────┐
          │ OPERACIÓN 6: LOGIN        │
          │ POST /api/auth/login      │
          └────────┬─────────────────┘
                   │
                   ↓
    ┌─────────────────────────────────────┐
    │ SELECT * FROM clientes              │
    │ WHERE email = @email AND es_activo=1│
    └────────┬────────────────────────────┘
             │
             ↓
    ┌─────────────────────┐
    │ ¿Existe el email?  │
    └────┬────────────┬──┘
         │            │
        SÍ            NO
         │            │
         ↓            ↓
    ┌───────┐   ┌──────────────────────┐
    │ Ir    │   │ return ERROR          │
    │ paso  │   │ "Invalid credentials" │
    │ 2     │   └──────────────────────┘
    └───┬───┘
        │
        ↓
    ┌──────────────────────────────────────┐
    │ BCrypt.Verify(inputPassword,         │
    │               storedPasswordHash)     │
    └────┬───────────────────────┬─────────┘
         │                       │
       VÁLIDO              INVÁLIDO
         │                       │
         ↓                       ↓
    ┌─────────┐        ┌──────────────────┐
    │ Generar │        │ return ERROR     │
    │ JWT     │        │ "Invalid password"│
    │ Token   │        └──────────────────┘
    └────┬────┘
         │
         ↓
    ┌──────────────────────────────────────┐
    │ return {                              │
    │   id: 1,                              │
    │   nombre: "Juan Pérez",               │
    │   email: "juan@example.com",          │
    │   rol: "client",                      │
    │   token: "eyJhbGc..." (JWT TOKEN)    │
    │ }                                     │
    └──────────────────────────────────────┘
```

---

## 📝 FLUJO DE REGISTRO (INSERT CLIENTE)

```
┌──────────────────────────────────────────────────────────────┐
│  USUARIO COMPLETA FORMULARIO DE REGISTRO                     │
│  nombre, email, password, telefono, ubicacion, etc.         │
└─────────────────────┬──────────────────────────────────────┘
                      │
                      ↓
          ┌──────────────────────────────────┐
          │ OPERACIÓN 1: REGISTRAR CLIENTE    │
          │ POST /api/auth/register/client    │
          └────────┬────────────────────────┘
                   │
                   ↓
    ┌──────────────────────────────────────────┐
    │ ¿Email ya existe en BD?                   │
    │ SELECT COUNT(*) FROM clientes             │
    │ WHERE email = @email                      │
    └────┬──────────────────────┬───────────────┘
         │                      │
       NO                      SÍ
         │                      │
         ↓                      ↓
    ┌─────────┐        ┌──────────────────┐
    │ Continuar│        │ return ERROR    │
    │ paso 2  │        │ "Email exists"  │
    └────┬────┘        └──────────────────┘
         │
         ↓
    ┌─────────────────────────────────────┐
    │ Encriptar contraseña                │
    │ passwordHash =                      │
    │   BCrypt.HashPassword(plainPassword)│
    └────┬────────────────────────────────┘
         │
         ↓
    ┌──────────────────────────────────────┐
    │ INSERT INTO clientes (               │
    │   nombre, email, password_hash,      │
    │   telefono, ubicacion_text,          │
    │   latitud, longitud, fecha_registro, │
    │   es_activo                          │
    │ ) VALUES (...)                       │
    │                                      │
    │ SELECT LAST_INSERT_ID()              │
    └────┬─────────────────────────────────┘
         │
         ↓
    ┌──────────────────────────────────┐
    │ return {                          │
    │   id_cliente: 1,                  │
    │   message: "Registered successfully"
    │ }                                 │
    └──────────────────────────────────┘
```

---

## 🔍 FLUJO DE BÚSQUEDA DE TÉCNICOS

```
┌─────────────────────────────────────────────────────────────┐
│  CLIENTE ABRE PANTALLA "BUSCAR TÉCNICOS"                    │
│  Puede filtrar por: servicio, ubicación, calificación      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
        ┌──────────────────────────────────────┐
        │ OPERACIÓN 4: LISTAR TÉCNICOS          │
        │ GET /api/technicians?service=3       │
        └────────┬─────────────────────────────┘
                 │
                 ↓
    ┌────────────────────────────────────────────────┐
    │ SELECT t.* FROM tecnicos t                     │
    │ WHERE es_activo = 1                            │
    │                                               │
    │ if (serviceId != null) {                       │
    │   AND EXISTS (                                 │
    │     SELECT 1 FROM tecnico_servicio ts          │
    │     WHERE ts.id_tecnico = t.id_tecnico         │
    │     AND ts.id_servicio = @service              │
    │   )                                            │
    │ }                                              │
    │                                               │
    │ ORDER BY calificacion_promedio DESC            │
    │          tarifa_hora ASC                       │
    │ LIMIT 10 OFFSET 0                              │
    └────────┬─────────────────────────────────────┘
             │
             ↓
    ┌─────────────────────────────────────┐
    │ return [                             │
    │   {                                  │
    │     id_tecnico: 5,                   │
    │     nombre: "Carlos Técnico",        │
    │     tarifa_hora: 25.50,              │
    │     calificacion_promedio: 4.8,      │
    │     ubicacion_text: "...",           │
    │     ...                              │
    │   },                                 │
    │   { ... },                           │
    │   { ... }                            │
    │ ]                                    │
    └─────────────────────────────────────┘
```

---

## 💼 FLUJO DE CREACIÓN DE CONTRATACIÓN

```
┌──────────────────────────────────────────────────────────┐
│  CLIENTE SELECCIONA TÉCNICO Y PRESIONA "CONTRATAR"      │
└─────────────────┬────────────────────────────────────────┘
                  │
                  ↓
      ┌───────────────────────────────────────┐
      │ OPERACIÓN 7: CREAR CONTRATACIÓN       │
      │ POST /api/contractions                │
      │ {                                     │
      │   clientId: 1,                        │
      │   technicianId: 5,                    │
      │   serviceId: 3,                       │
      │   description: "...",                 │
      │   scheduledDate: "2024-12-20T10:00"  │
      │ }                                     │
      └────────┬─────────────────────────────┘
               │
               ↓
    ┌──────────────────────────────────────────────┐
    │ Validación 1: ¿Existe el cliente?            │
    │ SELECT COUNT(*) FROM clientes                │
    │ WHERE id_cliente = @client                   │
    └────┬────────────────────┬────────────────────┘
         │                    │
       SÍ                    NO
         │                    │
         ↓                    ↓
    Paso 2                 ERROR
                           "Client not found"
                           │
         │                    │
         ↓                    ↓
    ┌──────────────────────────────────────────────┐
    │ Validación 2: ¿Existe el servicio?           │
    │ SELECT COUNT(*) FROM servicios               │
    │ WHERE id_servicio = @service                 │
    └────┬────────────────────┬────────────────────┘
         │                    │
       SÍ                    NO
         │                    │
         ↓                    ↓
    Paso 3                 ERROR
                           "Service not found"
                           │
         │                    │
         ↓                    ↓
    ┌──────────────────────────────────────────────┐
    │ Validación 3: Si technicianId → ¿Existe?    │
    │ SELECT COUNT(*) FROM tecnicos                │
    │ WHERE id_tecnico = @tech                     │
    └────┬────────────────────┬────────────────────┘
         │                    │
       SÍ                    NO
         │                    │
         ↓                    ↓
    Paso 4                 ERROR
                           "Technician not found"
                           │
         │                    │
         ↓                    ↓
    ┌────────────────────────────────────────┐
    │ INSERT INTO contrataciones (           │
    │   id_cliente, id_tecnico, id_servicio, │
    │   detalles, fecha_solicitud,           │
    │   fecha_programada, estado             │
    │ ) VALUES (...)                         │
    │                                        │
    │ SELECT LAST_INSERT_ID()                │
    └────┬─────────────────────────────────┘
         │
         ↓
    ┌────────────────────────────────────────┐
    │ return {                               │
    │   id_contratacion: 42,                 │
    │   estado: "Pendiente"                  │
    │ }                                      │
    └────────────────────────────────────────┘
```

---

## 📋 FLUJO DE VISUALIZACIÓN DE CONTRATACIONES

```
┌───────────────────────────────────────────────────────┐
│  CLIENTE ABRE PANTALLA "MIS SOLICITUDES"              │
└────────────────┬──────────────────────────────────────┘
                 │
                 ↓
    ┌─────────────────────────────────────────────┐
    │ OPERACIÓN 8: LISTAR CONTRATACIONES           │
    │ GET /api/contractions/client/1               │
    └────────┬────────────────────────────────────┘
             │
             ↓
    ┌─────────────────────────────────────────────────────┐
    │ SELECT c.*, s.nombre, t.nombre, t.email            │
    │ FROM contrataciones c                              │
    │ JOIN servicios s ON c.id_servicio = s.id_servicio  │
    │ LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico│
    │ WHERE c.id_cliente = @cliente                      │
    │ ORDER BY c.fecha_solicitud DESC                    │
    └────────┬────────────────────────────────────────────┘
             │
             ↓
    ┌──────────────────────────────────────────────────┐
    │ return [                                         │
    │   {                                              │
    │     id_contratacion: 42,                         │
    │     estado: "Pendiente",                         │
    │     service_name: "Reparación de AC",            │
    │     technician_name: null,  (sin asignar aún)   │
    │     fecha_solicitud: "2024-12-15T14:30:00",      │
    │     fecha_programada: "2024-12-20T10:00:00"      │
    │   },                                             │
    │   {                                              │
    │     id_contratacion: 41,                         │
    │     estado: "Completado",                        │
    │     service_name: "Limpieza de filtros",         │
    │     technician_name: "Carlos Técnico",           │
    │     technician_email: "carlos@example.com",      │
    │     fecha_solicitud: "2024-12-10T09:00:00",      │
    │     fecha_programada: "2024-12-12T15:00:00"      │
    │   }                                              │
    │ ]                                                │
    └──────────────────────────────────────────────────┘
```

---

## 🏗️ TABLA DE RELACIONES

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          MODELO ENTIDAD-RELACIÓN                         │
│                                                                          │
│  ┌─────────────────┐                     ┌─────────────────┐            │
│  │    clientes     │                     │    tecnicos     │            │
│  ├─────────────────┤                     ├─────────────────┤            │
│  │ id_cliente (PK) │                     │ id_tecnico (PK) │            │
│  │ nombre          │                     │ nombre          │            │
│  │ email (UNIQUE)  │                     │ email (UNIQUE)  │            │
│  │ password_hash   │                     │ password_hash   │            │
│  │ telefono        │                     │ telefono        │            │
│  │ ubicacion_text  │                     │ ubicacion_text  │            │
│  │ latitud         │                     │ latitud         │            │
│  │ longitud        │                     │ longitud        │            │
│  │ fecha_registro  │                     │ tarifa_hora     │            │
│  │ es_activo       │                     │ experiencia_yrs │            │
│  └────────┬────────┘                     │ calificacion    │            │
│           │                              │ fecha_registro  │            │
│           │                              │ es_activo       │            │
│           │                              └────────┬────────┘            │
│           │                                       │                    │
│           │    FK: id_cliente                     │ FK: id_tecnico   │
│           │         ↓                             │      ↓            │
│           └────────────┬──────────────────────────┘                    │
│                        │                                               │
│                        ↓                                               │
│           ┌─────────────────────────────┐                             │
│           │   contrataciones            │                             │
│           ├─────────────────────────────┤                             │
│           │ id_contratacion (PK)        │                             │
│           │ id_cliente (FK)─────────────┼──→ clientes                │
│           │ id_tecnico (FK)─────────────┼──→ tecnicos                │
│           │ id_servicio (FK)────────────┼──→ servicios               │
│           │ detalles                    │                             │
│           │ fecha_solicitud             │                             │
│           │ fecha_programada            │                             │
│           │ estado                      │                             │
│           └─────────────────────────────┘                             │
│                        ↑                                               │
│                        │                                               │
│           ┌─────────────────────────────┐                             │
│           │      servicios              │                             │
│           ├─────────────────────────────┤                             │
│           │ id_servicio (PK)            │                             │
│           │ nombre                      │                             │
│           │ descripcion                 │                             │
│           │ categoria                   │                             │
│           └──────────┬────────────────┬─┘                             │
│                      │                │                              │
│                      │ FK             │ FK                           │
│                      ↓                ↓                              │
│            ┌────────────────────────────────────┐                    │
│            │   tecnico_servicio (Relación M:N) │                    │
│            ├────────────────────────────────────┤                    │
│            │ id_tecnico (PK, FK)                │                    │
│            │ id_servicio (PK, FK)               │                    │
│            └────────────────────────────────────┘                    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 CICLO DE VIDA DE UNA CONTRATACIÓN

```
┌──────────────────────────────────────────────────────────────────────┐
│                  ESTADOS DE UNA CONTRATACIÓN                         │
└──────────────────────────────────────────────────────────────────────┘

1. PENDIENTE
   ├─ Cliente acaba de crear la solicitud
   ├─ ¿Técnico asignado? NO (id_tecnico = NULL o 0)
   └─ Técnicos pueden ver las solicitudes disponibles
           │
           ↓
2. ASIGNADO
   ├─ Un técnico aceptó la solicitud
   ├─ id_tecnico ≠ NULL/0
   └─ Cliente puede ver quién lo atenderá
           │
           ↓
3. EN PROGRESO
   ├─ Técnico llegó y comienza el trabajo
   └─ Cliente puede ver el progreso
           │
           ↓
4. COMPLETADO
   ├─ Trabajo terminado
   ├─ Cliente puede calificar al técnico
   └─ Se actualizan estadísticas
           │
           ↓
5. CANCELADO (Opcional)
   ├─ Cliente o técnico canceló
   └─ No afecta calificaciones

Estado en la BD:
estado VARCHAR(20): 'Pendiente', 'Asignado', 'En Progreso', 'Completado', 'Cancelado'
```

---

## 🎯 MAPA MENTAL DE LAS OPERACIONES

```
                            SERVITEC
                              │
                ┌─────────────────────┬──────────────────┐
                │                     │                  │
          CLIENTE              TÉCNICO              ADMIN
            (3 op)              (2 op)               (3 op)
            │                   │                      │
     ┌──────┴──────┐     ┌──────┴──────┐       ┌───────┴────────┐
     │      │      │     │      │      │       │       │        │
   OP1    OP6    OP3+OP5 OP2    OP6   (Futuro) OP4    (etc)    (etc)
   │      │      │       │      │
  REG    LOG    VIEW    REG    LOG
  CLI            EDIT    TEC
   │      │      │       │      │
   └──────┴──────┼───────┴──────┘
          ↓      │
       TOKEN    ┌─┴──────┐
               │         │
              OP4       OP7
              │         │
            LIST      CREATE
            TEC       CONTRACT
               │         │
               └─────┬───┘
                     ↓
                    OP8
                    │
                   LIST
                   CONTRACTS
```

---

Última actualización: Diciembre 2024  
Versión: 1.0 Completo
