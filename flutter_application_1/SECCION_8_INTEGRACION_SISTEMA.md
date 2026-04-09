# 8. INTEGRACIÓN GENERAL DEL SISTEMA

## 8.1 Cómo Interactúan Arquitectura, Datos e Interfaz

### 8.1.1 Arquitectura Multinivel (Layered Architecture)

El proyecto **Servitec** implementa una arquitectura de capas estructurada en **dos dominios principales** que se relacionan mediante una API REST:

```
┌──────────────────────────────────────────────────────────────┐
│                    PRESENTACIÓN (Flutter)                      │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │ Pantalla     │ │ Pantalla     │ │ Pantalla     │ ...       │
│  │ Inicio       │ │ Técnicos     │ │ Solicitudes  │           │
│  │ Sesión       │ │ Disponibles  │ │ Cliente      │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
├──────────────────────────────────────────────────────────────┤
│                   SERVICIOS RED (Dart/HTTP)                    │
│  ┌──────────────────┐ ┌──────────────────┐                    │
│  │ ServicioAuth     │ │ ServicioContr.   │ ...                │
│  │ HTTP POST/GET    │ │ HTTP POST/GET    │                    │
│  └──────────────────┘ └──────────────────┘                    │
├──────────────────────────────────────────────────────────────┤
│         API REST (JSON over HTTPS/HTTP - Puerto 3000)         │
│              ↕↕↕ HTTP POST/GET ↕↕↕                           │
├──────────────────────────────────────────────────────────────┤
│                    APLICACIÓN (C# ASP.NET)                     │
│  ┌──────────────────────────────────────────────────────┐     │
│  │              Controllers REST                        │     │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐       │     │
│  │  │ Auth   │ │ Tech   │ │ Service│ │Payment │ ...   │     │
│  │  │ Ctrl   │ │ Ctrl   │ │ Ctrl   │ │ Ctrl   │       │     │
│  │  └────────┘ └────────┘ └────────┘ └────────┘       │     │
│  └──────────────────────────────────────────────────────┘     │
├──────────────────────────────────────────────────────────────┤
│                   SERVICIOS (Business Logic)                   │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │ AuthService  │ │ TechService  │ │PaymentService│ ...       │
│  │ [Interface]  │ │ [Interface]  │ │[Interface]   │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
├──────────────────────────────────────────────────────────────┤
│               REPOSITORIOS (Data Access Layer)                 │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │ UserRepo     │ │ TechRepo     │ │ PaymentRepo  │ ...       │
│  │ [Interface]  │ │ [Interface]  │ │[Interface]   │           │
│  └──────────────┘ └──────────────┘ └──────────────┘           │
├──────────────────────────────────────────────────────────────┤
│            DATABASE SERVICE (ADO.NET Queries)                  │
│              ↕↕↕ SQL Parameterizado ↕↕↕                       │
├──────────────────────────────────────────────────────────────┤
│                    MySQL 8.0+ Database                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│  │ usuarios │ │ tecnicos │ │ servicios│ │contratos │ ...      │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘          │
└──────────────────────────────────────────────────────────────┘
```

### 8.1.2 Interacción de Componentes Clave

#### **a) Interfaz ↔ Servicios**
- **Responsabilidad UI**: Capturar entrada del usuario, mostrar datos, manejar navegación
- **Responsabilidad Servicios Red**: Serializar/deserializar datos, gestionar HTTP, manejo de errores de red
- **Tipo de comunicación**: Llamadas asincrónicas (`async/await`)
- **Datos intermediary**: Modelos Dart (DTOs locales)

**Ejemplo Real - Pantalla Inicio Sesión:**
```dart
// 1. UI captura correo/contraseña
final usuario = await _servicioAutenticacion.iniciarSesion(
  correo: _controladorCorreo.text,
  contrasena: _controladorContrasena.text,
);

// 2. Servicio retorna modelo Dart
// 3. UI navega basado en tipoUsuario
if (usuario.tipoUsuario == 'Cliente') {
  Navigator.push(...HomeCliente(idCliente: usuario.id));
} else {
  Navigator.push(...HomeTecnico(idTecnico: usuario.id));
}
```

#### **b) Servicios Red ↔ Backend API**
- **Responsabilidad**: Traducir entre formatos Dart ↔ JSON
- **Protocolo**: HTTP REST (JSON payloads)
- **Autenticación**: JWT token en headers
- **Handling**: Parse de statusCode, excepciones, reintentos

**Ejemplo Real - Obtener Técnicos Cercanos:**
```dart
// Frontend environment
const String _urlBase = 'http://10.0.2.2:3000/api/tech';

final respuesta = await http.get(
  Uri.parse('$_urlBase/nearby?lat=$lat&lng=$lng'),
  headers: {'Authorization': 'Bearer $token'},
);

final datosSinProcesar = jsonDecode(respuesta.body);
final tecnicos = (datosSinProcesar as List)
  .map((t) => TecnicoModelo.desdeJson(t))
  .toList();
```

#### **c) Backend ↔ Repositorios**
- **Responsabilidad Controllers**: Validar request, invocar servicios, retornar respuestas HTTP
- **Responsabilidad Servicios**: Orquestar lógica de negocio, coordinar múltiples repos
- **Responsabilidad Repositorios**: Queries SQL, mapeo a objetos de dominio
- **Inyección de Dependencias (DI)**: Desacoplamiento total

**Ejemplo Real - Flujo Completo Autenticación:**
```csharp
// Startup (Program.cs) - Inyección de Dependencias
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<DatabaseService>();

// Controller recibe IAuthService (inyectada)
[HttpPost("login")]
public async Task<IActionResult> Login([FromBody] LoginRequest req)
{
  var usuario = await _authService.AuthenticateAsync(req.Email, req.Password);
  // ↓ AuthService internamente usa IUserRepository
  // ↓ IUserRepository internamente usa DatabaseService (ADO.NET)
  return Ok(new { token = GenerateJWT(usuario), usuario = usuario });
}
```

### 8.1.3 Separación de Responsabilidades

| Capa | Responsabilidad | Tecnología | Ejemplo |
|------|-----------------|-----------|---------|
| **UI (Flutter)** | Presentación, eventos usuario, validación visible | Flutter Widgets | `PantallaListaTecnicos`, `PantallaCrearSolicitud` |
| **Servicios Red** | Comunicación HTTP, serialización JSON | `http` package, `dart:convert` | `ServicioTecnicos`, `ServicioContrataciones` |
| **API (Controllers)** | Routing HTTP, deserialization request, serialization response | ASP.NET Controllers | `[HttpGet] GetNearbyTechs()` |
| **Servicios (C#)** | Lógica negocio, validaciones, orquestación | Service interfaces | `TechnicianService.FilterByLocation()` |
| **Repositorios** | Acceso datos, SQL queries | ADO.NET, parameterized queries | `UserRepository.FindByEmailAsync()` |
| **Database** | Persistencia, integridad referencial, índices | MySQL 8.0+ | Técnicos FK → Servicios, índice geolocalización |

---

## 8.2 Cómo Fluye la Información desde el Usuario hasta la Base de Datos

### 8.2.1 Flujo End-to-End: Caso de Uso "Crear Solicitud de Servicio"

Este caso ilustra el viaje COMPLETO de datos desde que el usuario toca un botón hasta que se persiste en la BD:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    FRONTED: USUARIO INTERACTÚA                      │
│                                                                     │
│ Usuario en PantallaCrearSolicitud selecciona:                       │
│ • Descripción: "Reparar aire acondicionado"                         │
│ • Fecha: "15/03/2026"                                               │
│ • Hora: "14:30"                                                     │
│ • Ubicación: "Calle Principal 123, Quito"                           │
│ • Monto: "$50"                                                      │
│ • Toca botón "ENVIAR SOLICITUD"                                     │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│              PASO 1: VALIDACIÓN LOCAL (Flutter)                     │
│                                                                     │
│ El formulario valida usando ValidadoresServicios:                   │
│ ├─ ¿Descripción no vacía? validarDescripcion() → ✅                │
│ ├─ ¿Fecha en futuro? validarFechaFutura() → ✅                     │
│ ├─ ¿Formato fecha DD/MM/YYYY? → ✅ Parseada a DateTime              │
│ ├─ ¿Hora válida? validarHora() → ✅                                │
│ ├─ ¿Ubicación geocodificada? → ✅ lat=(-0.2298), lng=(-78.5249)    │
│ └─ ¿Token activo? → ✅ Recuperado de almacenamiento seguro         │
│                                                                     │
│ Si alguna falla → Mostrar SnackBar rojo (sin ir a backend)         │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│           PASO 2: SERIALIZACION A MODELO (Dart DTO)                │
│                                                                     │
│ El SolicitudRequest se construye:                                   │
│                                                                     │
│ {                                                                   │
│   "id_cliente": 5,                                                  │
│   "id_tecnico": null,  // Aún no asignado                           │
│   "id_servicio": 2,    // "Aire Acondicionado"                      │
│   "detalles": "Reparar aire acondicionado",                         │
│   "fecha_programada": "2026-03-15",  // ISO format                  │
│   "hora_solicitada": "14:30",                                       │
│   "ubicacion_text": "Calle Principal 123, Quito",                   │
│   "ubicacion_lat": -0.2298,                                         │
│   "ubicacion_lng": -78.5249,                                        │
│   "monto_propuesto": 50.00                                          │
│ }                                                                   │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│        PASO 3: ENVÍO HTTP al BACKEND (Dart via http package)       │
│                                                                     │
│ POST http://10.0.2.2:3000/api/contractions/create                  │
│                                                                     │
│ Headers:                                                            │
│ ├─ 'Content-Type' : 'application/json'                             │
│ ├─ 'Authorization' : 'Bearer eyJhbGciOiJIUzI1NiIs...'              │
│ └─ 'Accept' : 'application/json'                                   │
│                                                                     │
│ Body: JSON serializado del objeto anterior                         │
│                                                                     │
│ Respuesta esperada (200 OK):                                        │
│ {                                                                   │
│   "success": true,                                                 │
│   "idSolicitud": 47,                                               │
│   "mensaje": "Solicitud creada. Técnicos verificando..."           │
│ }                                                                   │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│         PASO 4: RECEPCIÓN en CONTROLLER (C# ASP.NET)               │
│                                                                     │
│ [HttpPost("create")]                                                │
│ public async Task<IActionResult> CreateContraction(                │
│     [FromBody] ContractionCreateRequest dto)                        │
│ {                                                                   │
│    // ASP.NET automáticamente DESERIALIZA JSON → Objeto C#          │
│    // Convierte JSON a ContractionCreateRequest por property names  │
│                                                                     │
│    // AUTENTICACIÓN: El token JWT se verifica en el middleware     │
│    if (!User.GetClaimValue("id", out int clientId))                │
│        return Unauthorized("Token inválido o expiró");             │
│                                                                     │
│    // AUTORIZACIÓN: ¿El cliente del token coincide con dto?        │
│    if (dto.id_cliente != clientId)                                 │
│        return Forbid("No puedes crear solicitudes para otros");    │
│ }                                                                   │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│      PASO 5: INVOCACIÓN SERVICIO (Inyección Dependencias)          │
│                                                                     │
│ // Servicio es inyectado por el DI container                        │
│ private readonly IContractionService _service;                      │
│                                                                     │
│ // El controller delega toda la lógica                              │
│ var idNuevaSolicitud = await _service.CreateContractionAsync(      │
│     clientId,                                                       │
│     dto.id_servicio,                                               │
│     dto.detalles,                                                  │
│     dto.fecha_programada,                                          │
│     dto.hora_solicitada,                                           │
│     dto.ubicacion_text,                                            │
│     (dto.ubicacion_lat, dto.ubicacion_lng),                        │
│     dto.monto_propuesto                                            │
│ );                                                                  │
│                                                                     │
│ // El servicio hace varias cosas antes de acceder a BD:            │
│ // 1. Validar reglas negocio (ej: cliente activo, fecha válida)   │
│ // 2. Verificar disponibilidad servicio                            │
│ // 3. Calcular distancia a técnicos para notificaciones            │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│         PASO 6: REPOSITORIO (Data Access Layer)                    │
│                                                                     │
│ ContractionService internamente usa:                                │
│ private readonly IContractionRepository _repo;                      │
│                                                                     │
│ // Delegación al repositorio                                        │
│ int idNuevo = await _repo.CreateAsync(                             │
│    new Contraction {                                               │
│        IdCliente = clientId,                                       │
│        IdServicio = serviceId,                                     │
│        Detalles = detalles,                                        │
│        FechaProgramada = dateTime,                                 │
│        HoraSolicitada = timeSpan,                                  │
│        UbicacionText = location,                                   │
│        Latitude = lat,                                             │
│        Longitude = lng,                                            │
│        MontoPropuesto = amount,                                    │
│        Estado = "PENDIENTE",                                       │
│        FechaCreacion = DateTime.UtcNow                             │
│    }                                                                │
│ );                                                                  │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│    PASO 7: QUERY SQL PARAMETERIZADA (ADO.NET)                      │
│                                                                     │
│ ContractionRepository.CreateAsync():                                │
│                                                                     │
│ INSERT INTO contratos (                                             │
│     id_cliente,                                                     │
│     id_servicio,                                                    │
│     detalles,                                                       │
│     fecha_programada,                                               │
│     hora_solicitada,                                                │
│     ubicacion_text,                                                 │
│     ubicacion_lat,                                                  │
│     ubicacion_lng,                                                  │
│     monto_propuesto,                                                │
│     estado,                                                         │
│     fecha_creacion                                                  │
│ ) VALUES (                                                          │
│     @id_cliente,      -- Parameter 1 = 5                            │
│     @id_servicio,     -- Parameter 2 = 2                            │
│     @detalles,        -- Parameter 3 = "Reparar aire..."           │
│     @fecha_prog,      -- Parameter 4 = 2026-03-15                   │
│     @hora_sol,        -- Parameter 5 = 14:30:00                     │
│     @ub_text,         -- Parameter 6 = "Calle Principal..."        │
│     @ub_lat,          -- Parameter 7 = -0.2298                      │
│     @ub_lng,          -- Parameter 8 = -78.5249                     │
│     @monto,           -- Parameter 9 = 50.00                        │
│     @estado,          -- Parameter 10 = 'PENDIENTE'                 │
│     @fecha_creacion   -- Parameter 11 = GETUTCDATE()                │
│ );                                                                  │
│                                                                     │
│ SELECT SCOPE_IDENTITY() AS id;  -- Retorna ID generado             │
│                                                                     │
│ ✅ Todas las queries son PARAMETERIZADAS                           │
│ ✅ Protege contra SQL injection                                    │
│ ✅ Mejor performance (prepared statements)                         │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│         PASO 8: EJECUCIÓN en BASE DE DATOS (MySQL)                 │
│                                                                     │
│ Tabla: contratos                                                    │
│ ┌──────┬───────────┬──────────┬──────────┬────────┬────────────┐   │
│ │ id   │ id_cliente│ id_svc   │ detalles │ estado │ fecha_prog │   │
│ ├──────┼───────────┼──────────┼──────────┼────────┼────────────┤   │
│ │ 46   │    4      │   1      │ ...      │ ACTIVO │ 2026-03-14 │   │
│ │ 47   │    5      │   2      │ Reparar  │PENDIEN │ 2026-03-15 │ ← │
│ │      │           │          │ aire...  │ TE     │            │   │
│ └──────┴───────────┴──────────┴──────────┴────────┴────────────┘   │
│                                                                     │
│ También crea registros en otras tablas por la lógica negocio:      │
│ • notificaciones: Nueva solicitud → técnicos cercanos              │
│ • auditoría: Log del evento (fecha, usuario, acción)              │
│                                                                     │
│ ✅ ACID Properties garantizados                                    │
│ ✅ Constraints triggering (Ej: si id_servicio no existe → error)  │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│         PASO 9: RESPUESTA AL BACKEND (MySQL → C#)                  │
│                                                                     │
│ Repository retorna:                                                 │
│ int idNuevaSolicitud = 47;  // SCOPE_IDENTITY()                    │
│                                                                     │
│ Service retorna:                                                    │
│ return new ContractionResponse {                                    │
│     Id = 47,                                                       │
│     Status = "PENDIENTE",                                          │
│     CreatedAt = DateTime.UtcNow                                    │
│ };                                                                  │
│                                                                     │
│ Controller serializa a JSON y retorna:                              │
│ {                                                                   │
│     "success": true,                                               │
│     "idSolicitud": 47,                                             │
│     "mensaje": "Solicitud creada. Notificando técnicos..."         │
│ }                                                                   │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│      PASO 10: RESPUESTA HTTP (C# → Dart/Flutter)                   │
│                                                                     │
│ HTTP 200 OK                                                         │
│ Content-Type: application/json                                      │
│                                                                     │
│ {                                                                   │
│   "success": true,                                                 │
│   "idSolicitud": 47,                                               │
│   "mensaje": "Solicitud creada. Notificando técnicos..."           │
│ }                                                                   │
│                                                                     │
│ Dart http package recibe y parsea                                   │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│      PASO 11: DESERIALIZACION (JSON → Objeto Dart)                 │
│                                                                     │
│ final datoRespuesta = jsonDecode(respuesta.body);                   │
│ final nuevoId = datoRespuesta['idSolicitud'];  // 47               │
│                                                                     │
│ Servicio retorna:                                                   │
│ SolicitudResponse(                                                  │
│     exitoso: true,                                                 │
│     idNuevaSolicitud: 47,                                          │
│     mensaje: "Solicitud creada..."                                 │
│ )                                                                   │
└─────────────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────────────┐
│         PASO 12: ACTUALIZACIÓN UI (Flutter)                        │
│                                                                     │
│ En PantallaCrearSolicitud._manejarEnvio():                          │
│                                                                     │
│ try {                                                               │
│   final respuesta = await _servicio.crearSolicitud(...);          │
│   if (respuesta.exitoso) {                                         │
│     // ✅ Mostrar éxito                                            │
│     ScaffoldMessenger.of(context).showSnackBar(                   │
│       SnackBar(content: Text("Solicitud #${respuesta.idNuevo}    │
│                              creada exitosamente"))                │
│     );                                                             │
│     // ✅ Navegar a PantallaSolicitudesCliente                     │
│     Navigator.pushReplacementNamed(                                │
│       context,                                                     │
│       '/mis-solicitudes'                                           │
│     );                                                             │
│     // ✅ Refrescar lista local                                    │
│     _cargarMisSolicitudes();                                       │
│   }                                                                 │
│ } catch (e) {                                                      │
│   // ❌ Mostrar error                                              │
│   ScaffoldMessenger.of(context).showSnackBar(                     │
│     SnackBar(content: Text("Error: $e"))                          │
│   );                                                               │
│ }                                                                   │
│                                                                     │
│ ✅ USUARIO VE: SnackBar verde + navega a lista actualizada         │
└─────────────────────────────────────────────────────────────────────┘
```

### 8.2.2 Resumen del Flujo de Información

| Paso | Ubicación | Transformación | Tecnología |
|------|-----------|-----------------|-----------|
| 1 | Flutter UI | Usuario → Strings en campos | Text input + validators |
| 2 | Flutter Dart | Strings → Objeto Dart (DTO) | ModeloSolicitud.desdeUI() |
| 3 | HTTP Layer | Objeto Dart → JSON + Headers | http.post() + jsonEncode() |
| 4 | HTTP Network | JSON binario | TCP/IP, HTTPS (TLS) |
| 5 | C# Controller | JSON → Objeto C# (DTO) | [FromBody] deserializer |
| 6 | C# Service | Objeto DTO → Domain object + validations | Business logic |
| 7 | C# Repository | Domain object → SQL + Parameters | ADO.NET parameterized queries |
| 8 | MySQL | SQL INSERT | Database engine executes |
| 9 | MySQL | SCOPE_IDENTITY() → int | Database returns new ID |
| 10 | C# Repository | int → Domain object | Object hydration |
| 11 | C# Service | Domain object → Response DTO | Business translation |
| 12 | C# Controller | Response DTO → JSON | JsonSerializer |
| 13 | HTTP Network | JSON binario | TCP/IP response |
| 14 | HTTP Layer | JSON → Objeto Dart | jsonDecode() + fromJson() |
| 15 | Flutter Service | Objeto Dart → UI models | Response handling |
| 16 | Flutter UI | UI models → Widgets rebuild | setState() + Navigator |

---

## 8.3 Cómo los Patrones Apoyan la Arquitectura

### 8.3.1 Repository Pattern (Acceso a Datos)

**Propósito**: Abstraer la lógica de acceso a datos, permitiendo cambiar la fuente de datos sin affecting business logic.

**Implementación en Servitec:**

```csharp
// ─ Interfaz (contrato) ─────────────────────────────────
public interface IUserRepository
{
    Task<User> FindByEmailAsync(string email);
    Task<int> CreateAsync(User user);
    Task<bool> UpdateAsync(User user);
    Task<bool> DeleteAsync(int userId);
}

// ─ Implementación ────────────────────────────────────
public class UserRepository : IUserRepository
{
    private readonly DatabaseService _db;
    
    public UserRepository(DatabaseService db) => _db = db;
    
    // Cada método encapsula SQL parameterizado
    public async Task<User> FindByEmailAsync(string email)
    {
        const string sql = @"
            SELECT id_usuario, nombre, correo, contrasena, tipo_usuario, 
                   activo, fecha_creacion
            FROM usuarios
            WHERE correo = @email AND activo = 1
        ";
        
        var result = await _db.ExecuteQueryAsync(sql, 
            new[] { new SqlParameter("@email", email) });
        
        if (result.Count == 0) return null;
        
        // Mapeo de DataRow → Domain Object
        var row = result[0];
        return new User 
        {
            Id = (int)row["id_usuario"],
            Email = row["correo"].ToString(),
            Name = row["nombre"].ToString(),
            // ... resto de propiedades
        };
    }
}

// ─ Uso en Servicio ────────────────────────────────────
public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepo;
    
    public AuthService(IUserRepository userRepo) => _userRepo = userRepo;
    
    public async Task<User> AuthenticateAsync(string email, string password)
    {
        // El servicio NO sabe ni le importa cómo se obtiene el usuario
        // Solo sabe que IUserRepository lo proporciona
        var user = await _userRepo.FindByEmailAsync(email);
        if (user == null) throw new UnauthorizedAccessException();
        
        // Validar contraseña, generar JWT, etc.
        if (!VerifyPassword(password, user.PasswordHash))
            throw new UnauthorizedAccessException();
        
        return user;
    }
}

// ─ Beneficios ─────────────────────────────────────────
// ✅ Una sola responsabilidad: cada clase hace una cosa
// ✅ Testeable: puedo mockear IUserRepository en tests
// ✅ Flexible: cambiar de MySQL a PostgreSQL solo afecta repository
// ✅ Reutilizable: AuthService puede usarse con cualquier implementación
```

**Ventajas en el proyecto:**
- **Aislamiento de cambios**: Si la schema de BD cambia, solo cambio el repository
- **Testabilidad**: Puedo crear mock repositories para tests unitarios
- **Mantenibilidad**: Lógica de acceso centralizada en una clase

### 8.3.2 Dependency Injection (DI) Pattern

**Propósito**: Desacoplar componentes permitiendo que las dependencias se "inyecten" en lugar de ser creadas internamente.

**Implementación en Servitec (C# ASP.NET):**

```csharp
// ─ Configuración en Program.cs ────────────────────────
var builder = WebApplication.CreateBuilder(args);

// ✅ Todo está inyectado - No hay "new" keywords
builder.Services.AddScoped<DatabaseService>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<ITechnicianRepository, TechnicianRepository>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ITechnicianService, TechnicianService>();

// ─ Ciclo de vida (Scoped = por request HTTP) ──────────
// Requestexample 1:
//   ├─ AuthService creado
//   ├─ IUserRepository inyectado a AuthService
//   ├─ DatabaseService inyectado a UserRepository
//   └─ Después de response → todos disposed

// ─ Controller recibe dependencias (NO las crea) ──────
[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    
    // ✅ DI automáticamente inyecta IAuthService
    //    que necesita IUserRepository,
    //    que necesita DatabaseService
    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }
    
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest req)
    {
        // El controller solo usa la interfaz, no conoce detalles
        var user = await _authService.AuthenticateAsync(req.Email, req.Password);
        var token = GenerateJWT(user);
        return Ok(new { token, user });
    }
}
```

**Ventajas en el proyecto:**
- **Loosely coupled**: Controllers no saben cómo se implementa AuthService
- **Testeable**: Puedo inyectar mock AuthService en tests
- **Flexible**: Cambiar IAuthService por otra implementación sin touching controllers
- **Lifecycle management**: ASP.NET automáticamente crea/destruye instancias

### 8.3.3 DTO (Data Transfer Object) Pattern

**Propósito**: Separar los datos transmitidos en red del dominio de negocio.

**Implementación en Servitec:**

```csharp
// ─ DTO (Lo que el cliente envía) ────────────────────
public class LoginRequest
{
    public string Email { get; set; }
    public string Password { get; set; }
}

// ─ DTO (Lo que el servidor retorna) ────────────────
public class AuthResponse
{
    public int UserId { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
    public string UserType { get; set; }  // "Cliente" o "Técnico"
    public string Token { get; set; }
}

// ─ Domain Model (Lo que el negocio usa internamente) ─
public class User
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }
    public string PasswordHash { get; set; }  // ⚠️ NUNCA en DTO/response
    public string UserType { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsActive { get; set; }
}

// ─ Beneficios ──────────────────────────────────────
// ✅ Seguridad: No expongo campos sensibles (passwordHash)
// ✅ Versioning: Puedo cambiar domain model sin affecting clients
// ✅ Validación: DTOs incluyen DataAnnotations
// ✅ Contrato: DTOs definen el API contract explícitamente

// ─ Mapeo: Domain → DTO ────────────────────────────
public AuthResponse MapToResponse(User user, string token)
{
    return new AuthResponse
    {
        UserId = user.Id,
        Name = user.Name,
        Email = user.Email,
        UserType = user.UserType,
        Token = token
        // ⚠️ Nota: NO incluyo PasswordHash
    };
}
```

### 8.3.4 Service Layer Pattern

**Propósito**: Encapsular lógica de negocio, manteniendo Controllers delgados y Repositories enfocados en datos.

**Implementación en Servitec:**

```csharp
public interface IContractionService
{
    Task<ContractionResponse> CreateAsync(ContractionCreateRequest request);
    Task<List<ContractionResponse>> GetClientContractionsAsync(int clientId);
    Task<bool> AssignTechnicianAsync(int contractionId, int technicianId);
}

public class ContractionService : IContractionService
{
    private readonly IContractionRepository _contractionRepo;
    private readonly ITechnicianRepository _techRepo;
    private readonly IServiceRepository _serviceRepo;
    
    public ContractionService(
        IContractionRepository contractionRepo,
        ITechnicianRepository techRepo,
        IServiceRepository serviceRepo)
    {
        _contractionRepo = contractionRepo;
        _techRepo = techRepo;
        _serviceRepo = serviceRepo;
    }
    
    public async Task<ContractionResponse> CreateAsync(ContractionCreateRequest request)
    {
        // ✅ Validaciones de negocio (no solo datos)
        var service = await _serviceRepo.FindByIdAsync(request.IdService);
        if (service == null) 
            throw new BusinessException("Servicio no existe");
        
        if (request.ProposedAmount < service.MinimumPrice)
            throw new BusinessException(
                $"Monto mínimo: ${service.MinimumPrice}");
        
        if (request.ScheduledDate < DateTime.UtcNow.AddHours(1))
            throw new BusinessException(
                "La solicitud debe ser para mañana o después");
        
        // ✅ Lógica de creación
        var contraction = new Contraction
        {
            IdCliente = request.IdClient,
            IdServicio = request.IdService,
            Detalles = request.Details,
            FechaProgramada = request.ScheduledDate,
            Estado = "PENDIENTE",
            FechaCreacion = DateTime.UtcNow
        };
        
        int newId = await _contractionRepo.CreateAsync(contraction);
        
        // ✅ Efectos secundarios
        // Notificar técnicos cercanos
        await NotifyNearbyTechnicians(request.Latitude, request.Longitude);
        
        // Registrar en auditoría
        await LogAuditEvent("CONTRACTION_CREATED", request.IdClient, newId);
        
        // Retornar respuesta
        var response = new ContractionResponse
        {
            Id = newId,
            Status = "PENDIENTE",
            CreatedAt = DateTime.UtcNow
        };
        
        return response;
    }
    
    // ... más métodos
    
    // ✅ Métodos privados para lógica compleja
    private async Task NotifyNearbyTechnicians(double lat, double lng)
    {
        var nearby = await _techRepo.FindNearby(lat, lng, radiusKm: 5);
        // Enviar notificaciones push a cada técnico
    }
    
    private async Task LogAuditEvent(string action, int userId, int resourceId)
    {
        // Crear registro de auditoría para compliance
    }
}
```

**Ventajas:**
- **Negocio centralizado**: toda la lógica en un lugar
- **Controllers delgados**: solo routing + HTTP concerns
- **Reutilizable**: múltiples controllers pueden usar el mismo servicio
- **Testeable**: fácil mockear las dependencias

### 8.3.5 Adapter Pattern (Frontend-Backend Communication)

**Propósito**: Adaptar JSON responses del backend a modelos Dart esperados por el frontend.

```dart
// ─ Modelo Backend (JSON) ────────────────────────────
{
  "id": 5,
  "id_cliente": 1,
  "detalles": "Reparar aire",
  "estado": "PENDIENTE",
  "fecha_creacion": "2026-03-16T10:30:00Z"
}

// ─ DTO Dart (Adapter) ──────────────────────────────
class SolicitudModelo {
  final int id;
  final int idCliente;
  final String detalles;
  final String estado;
  final DateTime fechaCreacion;
  
  SolicitudModelo({
    required this.id,
    required this.idCliente,
    required this.detalles,
    required this.estado,
    required this.fechaCreacion,
  });
  
  // Conversión: JSON → Objeto Dart
  factory SolicitudModelo.desdeJson(Map<String, dynamic> json) {
    return SolicitudModelo(
      id: json['id'] as int,
      idCliente: json['id_cliente'] as int,
      detalles: json['detalles'] as String,
      estado: json['estado'] as String,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
    );
  }
  
  // Representación amigable para UI
  String get estadoVisible {
    switch (estado) {
      case 'PENDIENTE': return '⏳ En busca de técnico';
      case 'EN_CURSO': return '🔧 En reparación';
      case 'COMPLETADA': return '✅ Completada';
      default: return estado;
    }
  }
}

// ─ Uso en Servicio ────────────────────────────────
Future<List<SolicitudModelo>> obtenerMisSolicitudes(int idCliente) async {
  try {
    final respuesta = await http.get(
      Uri.parse('$_urlBase/client/$idCliente'),
      headers: _buildHeaders(token),
    );
    
    if (respuesta.statusCode == 200) {
      final json = jsonDecode(respuesta.body);
      final lista = (json['data'] as List)
        .map((item) => SolicitudModelo.desdeJson(item))
        .toList();
      return lista;
    } else {
      throw Exception('Error: ${respuesta.statusCode}');
    }
  } catch (e) {
    print('Error obteniendo solicitudes: $e');
    rethrow;
  }
}
```

---

## 8.4 Cómo los Atributos de Calidad Están Reflejados en el Diseño

### 8.4.1 Matriz de Trazabilidad: Atributos → Implementación

| Atributo | Requisito | Implementación Arquitectónica |
|----------|-----------|-------------------------------|
| **SEGURIDAD** | Proteger datos sensibles | |
| | Autenticación robusta | JWT (24h expiration) en Backend + Secure Storage en Flutter |
| | Autorización por rol | RBAC en Controllers: `[Authorize(Roles="Cliente,Tecnico")]` |
| | Encriptación contraseñas | BCrypt (12 rounds = 4,096 iterations) en UserRepository |
| | Prevención SQL injection | Queries parameterizadas ADO.NET (`@parameterName`) |
| | HTTPS en producción | CORS policy + UseHttpsRedirection() en Program.cs |
| | Tokens seguros | HTTP-only headers en mobile via flutter_secure_storage |
| **RENDIMIENTO** | <2s para búsquedas | |
| | QueriesOptimas | 8 índices MySQL (geolocalización, FK, estado, etc.) |
| | Lazy loading | ListView.builder en Flutter, paginación en backend |
| | Caché de datos | Modelo local en Flutter refresh cada 30 minutos |
| | Async/await | Todas las operaciones no-bloqueantes (async Task en C#) |
| | Connection pooling | DatabaseService maneja pool de conexiones |
| | Compresión | Gzip en HTTP responses (efecto automático con .NET) |
| **ESCALABILIDAD** | Soportar 100+ usuarios | |
| | Arquitectura multi-capa | Desacoplamiento total entre capas |
| | Stateless services | Controllers/Services no mantienen estado |
| | Horizontal scaling ready | Controllers sin sesión → carga balanceada fácil |
| | Database replication ready | Queries parameterizadas + Repository pattern |
| | API REST | Stateless, horizontal escalable |
| **MANTENIBILIDAD** | Código limpio | |
| | SRP (Single Resp.) | Cada clase tiene UN responsabilidad |
| | DRY (Don't Repeat) | Servicios compartidos, helpers reutilizables |
| | Bajo acoplamiento | Inyección de dependencias, interfaces, repos |
| | Alto cohesión | Agrupación lógica: Controllers, Services, Repos |
| | Documentación | XML comments en C# `/// <summary>` |
| | Testing | Servicios/Repos mockeable vía interfaces |

### 8.4.2 Seguridad Reflejada en Capas

```
┌─ CAPA PRESENTACIÓN (Flutter) ──────────┐
│ ✅ Validación visual de entrada        │
│ ✅ Almacenamiento seguro de token      │
│ ✅ No exponer datos sensibles en logs  │
│ └─────────────────────────────────────┘
           ↓↓↓ HTTPS/TLS ↓↓↓
┌─ CAPA API (ASP.NET Controllers) ───────┐
│ ✅ [Authorize] decorador para endpoints│
│ ✅ Validación JWT en middleware        │
│ ✅ RBAC: solo técnicos acceden tech-ep │
│ └─────────────────────────────────────┘
           ↓↓↓ DI Container ↓↓↓
┌─ CAPA SERVICIOS (Business Logic) ──────┐
│ ✅ Validaciones reglas negocio         │
│ ✅ Chequeos de autorización            │
│ ├─ ¿Cliente puede editar su perfil?   │
│ ├─ ¿Técnico puede asignar su horario? │
│ └─────────────────────────────────────┘
           ↓↓↓ Interfaces ↓↓↓
┌─ CAPA REPOSITORIOS (Data Access) ──────┐
│ ✅ Queries parameterizadas             │
│ ├─ SELECT * FROM users WHERE id=@id   │
│ ├─ ^ Sin concatenación de strings      │
│ ✅ Hasheo de contraseñas NUNCA plain   │
│ └─────────────────────────────────────┘
           ↓↓↓ ADO.NET ↓↓↓
┌─ BASE DE DATOS (MySQL) ────────────────┐
│ ✅ Constraints de integridad           │
│ ✅ Triggers para auditoría             │
│ ✅ Backups automáticos                 │
│ ✅ Encriptación en reposo (opcional)   │
│ └─────────────────────────────────────┘
```

### 8.4.3 Rendimiento Reflejado en Capas

```
FRONTEND (Flutter)
│
├─ Caché local
│  └─ Tecnicos list: refrescar c/ 30 min
│  └─ Perfil usuario: en memoria mientras sesión activa
│
├─ Lazy loading
│  └─ ListView.builder en lugar de ListView
│  └─ Solo renderiza widgets visibles en pantalla
│
└─ Paginación
   └─ Solicitudes traen de 10 en 10

           ↓↓↓ HTTP (compressión automática) ↓↓↓

BACKEND (C# ASP.NET)
│
├─ Async/Await
│  └─ Todas las operaciones I/O async → threads reutilizables
│
├─ Connection Pooling
│  └─ DatabaseService mantiene pool de 5-100 conexiones
│  └─ Reutiliza conexiones: sin overhead de creación
│
└─ Queries optimizadas
   └─ Índices en WHERE clauses principales

           ↓↓↓ ADO.NET (prepared statements in-memory cache) ↓↓↓

DATABASE (MySQL)
│
├─ 8 Índices estratégicos
│  ├─ SPATIAL INDEX: ubicacion_lat/lng (búsqueda cercana)
│  ├─ UNIQUE INDEX: correo (login rápido)
│  ├─ INDEX: id_cliente (historiales)
│  └─ INDEX: estado (filtrados)
│
├─ Query execution plan optimization
│  └─ Analyzer elige índices automáticamente
│
└─ Caché interna MySQL
   └─ Query cache (key buffer)
```

### 8.4.4 Escalabilidad Reflejada en Diseño

```
PRESENTE (1-100 usuarios)
┌────────────────────────────────────────┐
│  Flutter App (Android/iOS)             │
└───────────┬────────────────────────────┘
            │ HTTP/REST
┌───────────▼────────────────────────────┐
│  ASP.NET Core (1 servidor, puerto 3000)│
├────────────────────────────────────────┤
│  Controllers (stateless)               │
│  Services (DI injected)                │
│  Repositories (interface-based)        │
└───────────┬────────────────────────────┘
            │ SQL Parameterizado
┌───────────▼────────────────────────────┐
│  MySQL 8.0+ (1 instancia)              │
└────────────────────────────────────────┘

FUTURO (1000+ usuarios - Sin cambiar diseño actual)
┌────────────────────────────────────────┐
│  Flutter App (Android/iOS)             │
└───────────┬────────────────────────────┘
            │ HTTP/REST
┌───────────▼────────────────────────────┐
│  Load Balancer (nginx/haproxy)         │
├─────────────┬─────────────┬────────────┤
│ ASP.NET Core├ ASP.NET Core├ASP.NET Core│
│ (Port 3000) │ (Port 3000) │(Port 3000) │
│ [stateless] │ [stateless] │[stateless] │
└─────────────┴─────────────┴────┬───────┘
                                  │ SQL
                        ┌─────────▼────────┐
                        │ MySQL Master     │
                        │ (write)          │
                        └────────┬─────────┘
                                 │ Replication
                    ┌────────────┴────────────┐
                    │                         │
              ┌─────▼────────┐        ┌──────▼────────┐
              │ MySQL Slave  │        │ MySQL Slave   │
              │ (read)       │        │ (read)        │
              └──────────────┘        │               │
                                      └───────────────┘

✅ Sin cambiar nada en el código:
   • Controllers siguen siendo stateless
   • Repositories retornan los mismos objetos
   • Servicios ejecutan la misma lógica
   • Solo config de infrastructure cambia
```

### 8.4.5 Mantenibilidad Reflejada en Organización

```
backend-csharp/
├─ Controllers/           ← Thin! Solo HTTP concerns
│  ├─ AuthController        (1 responsabilidad: desereializar + HTTPresponse)
│  ├─ TechnicianController
│  └─ ContractionController
│
├─ Services/             ← Complex! Business logic aquí
│  ├─ IAuthService + AuthService.cs
│  ├─ ITechnicianService + TechnicianService.cs
│  └─ IContractionService + ContractionService.cs
│
├─ Repositories/         ← Data access! SQL aquí
│  ├─ IUserRepository + UserRepository.cs
│  ├─ ITechnicianRepository + TechnicianRepository.cs
│  └─ IContractionRepository + ContractionRepository.cs
│
├─ Models/              ← Domain objects
│  ├─ User.cs
│  ├─ Technician.cs
│  └─ Contraction.cs
│
├─ DTOs/                ← Request/Response contracts
│  ├─ LoginRequest.cs
│  ├─ AuthResponse.cs
│  └─ ContractionCreateRequest.cs
│
├─ Services/
│  └─ DatabaseService.cs    ← Centralizado! SQL params + pool
│
├─ Validators/          ← Reglas validación
│  └─ AuthValidators.cs
│
└─ Program.cs           ← DI configuration central

✅ Cambios futuros:
   • Nuevo requisito autenticación → Solo AuthService + AuthController
   • Cambiar a PostgreSQL → Solo DatabaseService + Repositories
   • Agregar logs → Solo Program.cs (agregar logging middleware)
   • Nueva tabla de auditoría → Solo un nuevo Repository
```

### 8.4.6 Cómo cada Patrón Contribuye a Atributos

```
Patrón                 Seguridad    Rendimiento    Escalabilidad    Mantenibilidad
─────────────────────  ──────────   ────────────   ──────────────   ─────────────
Repository Pattern     ✅ DRY SQL   ✅ Índices     ✅ Swap BD        ✅ Cambios locales
                       (no inyect)   centralizados                   
                       
Dependency Injection   ✅ Fácil     ✅ Async       ✅ Stateless      ✅ Testeable
                       mock autz     contexto                        
                       
DTO Pattern            ✅ No        ✅ Payload     ✅ Versioning     ✅ Contrato
                       exposo sens  optimizado                       explícito
                       
Service Layer          ✅ Reglas    ✅ Orquesta    ✅ Reutilizar     ✅ Lógica
                       negocio      llamadas BD                      centralizada
                       
Layered Arch           ✅ Validar   ✅ Caché cada ✅ Cada capa      ✅ Fácil
                       múltiples    capa           escalable         navegar
                       puntos                      indep.
```

---

## 8.5 Conclusión: Visión Integrada

### Resumen Ejecutivo

El proyecto **Servitec** implementa una arquitectura **multinivel fuertemente desacoplada** donde:

1. **Capas están claramente separadas** con responsabilidades distintas
2. **La información fluye bidireccionalentemente** de forma predecible y segura
3. **Los patrones de diseño implementados** (Repository, DI, DTO, Service) soportan cada atributo de calidad
4. **Cada decisión arquitectónica** tiene un propósito claro y beneficios mensurables

### Diagrama de Integración Final

```
┌─────────────────────────────────────────────────────────────────┐
│                         USUARIO FINAL                            │
│              (Toca botón, escribe texto, navega)                │
└─────────────────────────────────┬───────────────────────────────┘
                                  │ Input
┌─────────────────────────────────▼───────────────────────────────┐
│                        FLUTTER UI (Dart)                         │
│  • Validación Local (Validadores)                              │
│  • Almacenamiento Seguro (JWT token)                           │
│  • Caché Local (modelos Dart)                                  │
├─────────────────────────────────────────────────────────────────┤
│                   SERVICIOS RED (HTTP/JSON)                     │
│  • Serialización/Deserialización                               │
│  • Manejo de errores de red                                    │
│  • Reintentos automáticos                                      │
└─────────────────────────────────┬───────────────────────────────┘
                                  │ HTTP POST/GET + JWT
                    ┌─────────────┴──────────────┐
                    │   INTERNET / HTTPS/TLS    │
                    │  (Encriptación en tránsito)│
                    └─────────────┬──────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────────┐
│                  ASP.NET CORE CONTROLLERS                        │
│  • Deserializar JSON → DTO                                     │
│  • Validar JWT (autenticación)                                 │
│  • Comprobar RBAC (autorización)                               │
├─────────────────────────────────────────────────────────────────┤
│                   SERVICIOS (Business Logic)                    │
│  • Validar reglas de negocio                                   │
│  • Orquestar llamadas repositorio                              │
│  • Efectos secundarios (notificaciones, auditoría)            │
├─────────────────────────────────────────────────────────────────┤
│                    REPOSITORIOS (Data Access)                   │
│  • Queries SQL parameterizadas ← Protege SQL injection        │
│  • Mapeo DataRow → Domain objects                              │
│  • Caché de prepared statements                                │
└─────────────────────────────────┬───────────────────────────────┘
                                  │ SQL Parameterizado
┌─────────────────────────────────▼───────────────────────────────┐
│                      MYSQL DATABASE (8.0+)                       │
│  • Transacciones ACID                                           │
│  • 8 Índices estratégicos (rendimiento)                         │
│  • Constraints integridad referencial (seguridad)              │
│  • Triggers auditoría (compliance)                              │
│  • Replicación master-slave (escalabilidad)                     │
│                                                                  │
│ [Tabla usuarios] [Tabla técnicos] [Tabla servicios] [Tabla      │
│  [Tabla contratos] [Tabla pagos] [Tabla calificaciones] ...    │
└──────────────────────────────────────────────────────────────────┘

🔄 FLUJO DE RETORNO: Idéntico pero inverso (JSON → Dart → UI → Usuario)
```

### Impacto de la Arquitectura en cada Atributo de Calidad

| Atributo | Impacto | Evidencia en Código |
|----------|--------|-------------------|
| **Seguridad** | 🟢 MÁXIMA | JWT + BCrypt + Params + HTTPS + DI |
| **Rendimiento** | 🟢 EXCELENTE | Índices + Async + Caché + Lazy loading |
| **Escalabilidad** | 🟢 MUY BUENA | Stateless + DI + Horizontal ready |
| **Mantenibilidad** | 🟢 EXCELENTE | SRP + Bajo acoplamiento + Tests |

Esta arquitectura permitirá que el proyecto escale desde unos pocos usuarios locales hasta miles de usuarios en diferentes ciudades, TODO sin cambios fundamentales en el código de negocio.

---

**Documento preparado para presentación en defensa de Proyecto Final - Sistema Servitec**
