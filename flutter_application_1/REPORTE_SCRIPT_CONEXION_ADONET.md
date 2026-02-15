# REPORTE: SCRIPT DE CONEXIÓN ADO.NET - SERVITEC

**Aplicación:** SERVITEC - Sistema de Conexión entre Clientes y Técnicos  
**Materia:** Taller de Base de Datos  
**Semestre:** 5to Semestre - Ingeniería en Sistemas  
**Fecha:** Diciembre 2024  
**Profesor:** [Nombre del Profesor]  

---

## TABLA DE CONTENIDOS

1. [Introducción](#introducción)
2. [¿Qué es ADO.NET?](#qué-es-adonet)
3. [Clase ServicioDatos - Módulos](#clase-serviciodatos---módulos)
4. [Configuración: appsettings.json](#configuración-appsettingsjson)
5. [Inyección de Dependencias](#inyección-de-dependencias)
6. [Diagrama de Flujo](#diagrama-de-flujo)
7. [Ejemplos de Uso Real](#ejemplos-de-uso-real)
8. [Operaciones y Consultas Reales](#operaciones-y-consultas-reales-del-proyecto)
9. [Seguridad](#seguridad)

---

## INTRODUCCIÓN

El presente reporte documenta la implementación del **script de conexión ADO.NET** en la aplicación SERVITEC. Este script es fundamental para la comunicación entre la aplicación backend (ASP.NET Core) y la base de datos MySQL.

**Objetivo:**
Explicar cómo funciona la clase `ServicioDatos`, que es la responsable de todas las operaciones de base de datos en el backend de SERVITEC.

**Ubicación del archivo:**
```
backend-csharp/Services/DatabaseService.cs
(Traducido al español como: ServicioDatos.cs)
```

---

## ¿QUÉ ES ADO.NET?

**ADO.NET** (ActiveX Data Objects .NET) es la tecnología de Microsoft que permite que las aplicaciones .NET se comuniquen con bases de datos. En nuestro caso, usamos:

- **Motor de BD:** MySQL
- **Proveedor:** MySql.Data.MySqlClient (Connector/NET)
- **Patrón:** Programación Asincrónica (async/await)

**Ventajas de ADO.NET:**
1. ✅ Conexión segura a la BD
2. ✅ Uso de parámetros (previene inyecciones SQL)
3. ✅ Operaciones asincrónicas (no bloquea la aplicación)
4. ✅ Gestión automática de recursos (using statements)

**Arquitectura General:**

```
┌─────────────────────────────────┐
│  APLICACIÓN FLUTTER (Cliente)   │
│  (Interfaz de usuario)          │
└──────────────┬──────────────────┘
               │ HTTP Requests
               ↓
┌─────────────────────────────────┐
│  ASP.NET CORE API (Backend)     │
│  - Controllers                  │
│  - ServicioDatos (DAO)          │
└──────────────┬──────────────────┘
               │ ADO.NET
               ↓
┌─────────────────────────────────┐
│  MySQL DATABASE                 │
│  - Tablas                       │
│  - Datos                        │
└─────────────────────────────────┘
```

---

# CLASE SERVICIODATOS - MÓDULOS

La clase `ServicioDatos` está compuesta por 8 módulos principales. Cada módulo cumple una función específica. A continuación se explica cada uno.

---

## MÓDULO 1: DIRECTIVAS Y NAMESPACE

### Explicación del Módulo 1

Las **directivas using** al inicio del archivo permiten usar clases y métodos de espacios de nombres externos sin escribir el nombre completo cada vez. El **namespace** organiza la clase dentro del proyecto.

En este módulo necesitamos:
- **`MySql.Data.MySqlClient`** → Para clases de conexión MySQL
- **`System.Security.Cryptography`** → Para encriptación de contraseñas
- **`System.Text`** → Para manejo de cadenas
- **`Microsoft.Extensions.Configuration`** → Para leer appsettings.json

El namespace `ServitecAPI.Services` organiza todas las clases de acceso a datos en una carpeta lógica.

### Código del Módulo 1

```csharp
using MySql.Data.MySqlClient;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Configuration;

namespace ServitecAPI.Services
{
    public class ServicioDatos
    {
        // El resto de la clase va aquí
    }
}
```

---

## MÓDULO 2: VARIABLE DE CADENA DE CONEXIÓN

### Explicación del Módulo 2

La variable `_cadenaConexion` almacena la cadena de conexión a la base de datos. El modificador `readonly` indica que **solo se puede asignar una vez** (en el constructor) y no puede cambiar después. Esto es una medida de seguridad.

**¿Qué es una cadena de conexión?**

Es una cadena de texto con información para conectarse a la BD:
- `Server` → Dirección del servidor MySQL
- `Database` → Nombre de la base de datos
- `Uid` → Usuario de MySQL
- `Pwd` → Contraseña de MySQL
- `Port` → Puerto de conexión

**¿Por qué `readonly`?**

Evita cambios accidentales de la configuración de conexión durante la ejecución.

### Código del Módulo 2

```csharp
public class ServicioDatos
{
    // Variable privada para almacenar la cadena de conexión
    // readonly = solo se asigna una vez (en el constructor)
    private readonly string _cadenaConexion;
}
```

---

## MÓDULO 3: CONSTRUCTOR

### Explicación del Módulo 3

El **constructor** es un método especial que se ejecuta **cuando se crea una instancia de la clase**. En este caso, recibe un objeto `IConfiguration` (inyectado por ASP.NET Core) que contiene toda la configuración del proyecto, incluyendo la cadena de conexión del archivo `appsettings.json`.

El operador `??` (null coalescing) devuelve el valor de la izquierda si no es nulo; si es nulo, ejecuta lo de la derecha (lanza excepción).

**Flujo del constructor:**
1. ASP.NET Core llama al constructor
2. Pasa la configuración (IConfiguration)
3. Se busca la cadena de conexión en `appsettings.json`
4. Si existe, se guarda en `_cadenaConexion`
5. Si no existe, lanza una excepción

### Código del Módulo 3

```csharp
public class ServicioDatos
{
    private readonly string _cadenaConexion;

    // Constructor que recibe la configuración del proyecto
    public ServicioDatos(IConfiguration config)
    {
        // Obtiene la cadena de conexión de appsettings.json
        // Si no existe, lanza una excepción (obliga a tenerla configurada)
        _cadenaConexion = config.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException(
                "Cadena de conexión 'DefaultConnection' no encontrada en appsettings.json");
    }
}
```

---

## MÓDULO 4: MÉTODO ObtenerConexion()

### Explicación del Módulo 4

El método `ObtenerConexion()` crea una **nueva instancia de conexión MySQL** cada vez que es llamado. 

**¿Por qué separar este método?**
- **Encapsulación** → La lógica de crear conexiones está en un solo lugar
- **Reutilización** → Todos los otros métodos lo usan
- **Mantenimiento** → Si cambia la forma de conectar, solo cambiamos aquí
- **Testing** → Facilita hacer pruebas unitarias

### Código del Módulo 4

```csharp
public class ServicioDatos
{
    private readonly string _cadenaConexion;

    public ServicioDatos(IConfiguration config)
    {
        _cadenaConexion = config.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Cadena de conexión no encontrada.");
    }

    // Método que crea una nueva conexión a la BD
    // Se llama desde los otros métodos cada vez que se necesita conectar
    public MySqlConnection ObtenerConexion()
    {
        return new MySqlConnection(_cadenaConexion);
    }
}
```

---

## MÓDULO 5: MÉTODOS DE ENCRIPTACIÓN

### Explicación del Módulo 5

Las contraseñas **jamás deben almacenarse en texto plano** en la base de datos. Se deben encriptar usando un algoritmo seguro como **BCrypt**.

Este módulo proporciona dos métodos:

1. **`CifrarContraseña()`** 
   - Recibe una contraseña en texto plano
   - La encripta usando BCrypt
   - Devuelve el hash (irreversible)
   - Se usa cuando un usuario se registra

2. **`VerificarContraseña()`**
   - Recibe una contraseña ingresada por el usuario
   - Recibe el hash almacenado en la BD
   - Verifica si coinciden
   - Se usa cuando el usuario intenta login

**Ejemplo de flujo:**

```
Registro:
usuario ingresa: "MiPassword123"
↓
CifrarContraseña("MiPassword123")
↓
Devuelve: "$2a$11$N9qo8uLOickgx2ZMRZoMy...."
↓
Se guarda en la BD

Login:
usuario ingresa: "MiPassword123"
hash en BD: "$2a$11$N9qo8uLOickgx2ZMRZoMy...."
↓
VerificarContraseña("MiPassword123", "$2a$11$...")
↓
Devuelve: true o false
```

### Código del Módulo 5

```csharp
public class ServicioDatos
{
    private readonly string _cadenaConexion;

    public ServicioDatos(IConfiguration config)
    {
        _cadenaConexion = config.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Cadena de conexión no encontrada.");
    }

    public MySqlConnection ObtenerConexion()
    {
        return new MySqlConnection(_cadenaConexion);
    }

    // Encripta una contraseña usando BCrypt
    // Se usa cuando un usuario se registra
    public string CifrarContraseña(string contraseña)
    {
        // BCrypt.HashPassword encripta la contraseña de forma irreversible
        return BCrypt.Net.BCrypt.HashPassword(contraseña);
    }

    // Verifica si una contraseña ingresada coincide con su hash
    // Se usa cuando el usuario intenta hacer login
    public bool VerificarContraseña(string contraseña, string hash)
    {
        // BCrypt.Verify compara la contraseña ingresada con el hash almacenado
        return BCrypt.Net.BCrypt.Verify(contraseña, hash);
    }
}
```

---

## MÓDULO 6: EjecutarScalarAsync() - VALOR ÚNICO

### Explicación del Módulo 6

Este método ejecuta consultas **SELECT que devuelven UN SOLO VALOR**. Es decir, una celda individual de la base de datos.

**Características:**
- **Genérico (`<T>`)** → Puede devolver `int`, `string`, `double`, etc.
- **Asincrónico (`async`)** → No bloquea el hilo de ejecución
- **Parámetrizadas** → Usa diccionario de parámetros (seguridad)

**Casos de uso:**
- Contar registros: `SELECT COUNT(*) FROM clientes`
- Obtener un email: `SELECT email FROM clientes WHERE id = @id`
- Obtener un precio: `SELECT precio FROM servicios WHERE id = @id`

**Pasos del método:**
1. Obtiene una conexión
2. La abre de forma asincrónica
3. Crea un comando SQL
4. Agrega los parámetros de forma segura
5. Ejecuta el comando
6. Devuelve el resultado convertido al tipo `T`
7. Cierra automáticamente la conexión (using)

### Código del Módulo 6

```csharp
public class ServicioDatos
{
    // ... módulos anteriores ...

    // Ejecuta una consulta que devuelve UN SOLO VALOR
    // Genérico <T> permite devolver int, string, double, etc.
    public async Task<T?> EjecutarScalarAsync<T>(
        string consulta, 
        Dictionary<string, object>? parametros = null)
    {
        // Obtiene una nueva conexión (se cierra automáticamente al salir del using)
        using (var conexion = ObtenerConexion())
        {
            // Abre la conexión de forma asincrónica
            await conexion.OpenAsync();

            // Crea un comando SQL con la conexión
            using (var comando = new MySqlCommand(consulta, conexion))
            {
                // Si hay parámetros, los agrega de forma segura
                if (parametros != null)
                {
                    foreach (var param in parametros)
                    {
                        // Los parámetros previenen inyecciones SQL
                        comando.Parameters.AddWithValue($"@{param.Key}", param.Value);
                    }
                }

                // Ejecuta la consulta y obtiene el resultado
                var resultado = await comando.ExecuteScalarAsync();

                // Convierte el resultado al tipo genérico T (int, string, etc.)
                // Si el resultado es null, devuelve el valor por defecto de T
                return resultado != null 
                    ? (T)Convert.ChangeType(resultado, typeof(T)) 
                    : default;
            }
        }
    }
}
```

---

## MÓDULO 7: EjecutarComandoAsync() - INSERT, UPDATE, DELETE

### Explicación del Módulo 7

Este método ejecuta comandos que **modifican datos en la base de datos** pero **no devuelven filas**. Se usa para:
- **INSERT** → Agregar nuevos registros
- **UPDATE** → Modificar registros existentes
- **DELETE** → Eliminar registros

**Retorna:** Un `int` con el **número de filas afectadas**.
- 0 = No se modificó nada
- 1+ = Se modificó esa cantidad de filas

**Pasos del método:**
1. Obtiene una conexión
2. La abre de forma asincrónica
3. Crea un comando SQL
4. Agrega los parámetros de forma segura
5. Ejecuta el comando
6. Devuelve el número de filas modificadas
7. Cierra automáticamente la conexión

### Código del Módulo 7

```csharp
public class ServicioDatos
{
    // ... módulos anteriores ...

    // Ejecuta comandos que modifican datos (INSERT, UPDATE, DELETE)
    // Devuelve el número de filas afectadas
    public async Task<int> EjecutarComandoAsync(
        string consulta, 
        Dictionary<string, object>? parametros = null)
    {
        // Obtiene una nueva conexión
        using (var conexion = ObtenerConexion())
        {
            // Abre la conexión de forma asincrónica
            await conexion.OpenAsync();

            // Crea el comando SQL
            using (var comando = new MySqlCommand(consulta, conexion))
            {
                // Agrega los parámetros de forma segura
                if (parametros != null)
                {
                    foreach (var param in parametros)
                    {
                        // Previene inyecciones SQL usando parámetros
                        comando.Parameters.AddWithValue($"@{param.Key}", param.Value);
                    }
                }

                // Ejecuta el comando y devuelve el número de filas afectadas
                return await comando.ExecuteNonQueryAsync();
            }
        }
    }
}
```

---

## MÓDULO 8: EjecutarConsultaAsync() - SELECT MÚLTIPLES FILAS

### Explicación del Módulo 8

Este es el método más versátil. Ejecuta consultas **SELECT que devuelven múltiples filas** y las convierte en una estructura flexible: `List<Dictionary<string, object>>`.

**Estructura devuelta:**
- Cada diccionario representa **una fila**
- La clave del diccionario es el **nombre de la columna**
- El valor es el **contenido de la celda**

**Ventaja:**
No necesita saber de antemano qué columnas devuelve la consulta. Funciona con cualquier SELECT.

**Pasos del método:**
1. Crea una lista para guardar resultados
2. Obtiene y abre una conexión
3. Crea un comando SQL
4. Agrega los parámetros de forma segura
5. Ejecuta la consulta y obtiene un `MySqlDataReader`
6. Lee cada fila una por una
7. Para cada fila, crea un diccionario con columnas y valores
8. Agrega el diccionario a la lista
9. Retorna la lista completa
10. Cierra automáticamente recursos

### Código del Módulo 8

```csharp
public class ServicioDatos
{
    // ... módulos anteriores ...

    // Ejecuta una consulta SELECT que devuelve múltiples filas
    // Devuelve una lista de diccionarios (cada diccionario es una fila)
    public async Task<List<Dictionary<string, object>>> EjecutarConsultaAsync(
        string consulta, 
        Dictionary<string, object>? parametros = null)
    {
        // Crea una lista para almacenar todas las filas
        var resultados = new List<Dictionary<string, object>>();

        // Obtiene una nueva conexión
        using (var conexion = ObtenerConexion())
        {
            // Abre la conexión de forma asincrónica
            await conexion.OpenAsync();

            // Crea el comando SQL
            using (var comando = new MySqlCommand(consulta, conexion))
            {
                // Agrega los parámetros de forma segura
                if (parametros != null)
                {
                    foreach (var param in parametros)
                    {
                        // Previene inyecciones SQL usando parámetros
                        comando.Parameters.AddWithValue($"@{param.Key}", param.Value);
                    }
                }

                // Ejecuta la consulta y obtiene un DataReader
                using (var lector = await comando.ExecuteReaderAsync())
                {
                    // Lee cada fila una por una
                    while (await lector.ReadAsync())
                    {
                        // Crea un diccionario para esta fila
                        var fila = new Dictionary<string, object>();

                        // Recorre todas las columnas de la fila actual
                        for (int i = 0; i < lector.FieldCount; i++)
                        {
                            // Obtiene el nombre de la columna
                            string nombreColumna = lector.GetName(i);
                            
                            // Obtiene el valor de la columna
                            object valor = lector.GetValue(i);
                            
                            // Agrega al diccionario: nombre_columna = valor
                            fila[nombreColumna] = valor;
                        }

                        // Agrega esta fila a la lista de resultados
                        resultados.Add(fila);
                    }
                }
            }
        }

        // Devuelve la lista completa de filas
        return resultados;
    }
}
```

---

## CONFIGURACIÓN: APPSETTINGS.JSON

### Explicación

El archivo `appsettings.json` contiene la configuración de la aplicación, incluyendo la **cadena de conexión** a la base de datos. ASP.NET Core lee este archivo automáticamente al iniciar la aplicación.

**Ubicación:**
```
backend-csharp/
└── appsettings.json
```

**¿Por qué usar appsettings.json?**
- Mantiene los datos sensibles (contraseñas) fuera del código
- Permite cambiar la configuración sin recompilar el código
- Diferente configuración por ambiente (desarrollo, producción, testing)

### Código del appsettings.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=servitec;Uid=root;Pwd=LU2040#G;Port=3306;"
  },
  "JWT": {
    "Secret": "tu_clave_secreta_super_segura_aqui_1234567890",
    "ExpiryDays": 30
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Explicación de cada parte:**

| Sección | Contenido | Uso |
|---------|-----------|-----|
| `ConnectionStrings.DefaultConnection` | Cadena de conexión a MySQL | Usada por `ServicioDatos` |
| `JWT.Secret` | Clave para firmar tokens JWT | Autenticación de usuarios |
| `JWT.ExpiryDays` | Días que dura un token | Control de sesiones |
| `Logging` | Niveles de log | Debug y monitoreo |
| `AllowedHosts` | Hosts permitidos | Seguridad CORS |

---

## INYECCIÓN DE DEPENDENCIAS

### Explicación

La **Inyección de Dependencias** es un patrón que permite que ASP.NET Core cree automáticamente instancias de `ServicioDatos` y las "inyecte" en los controladores.

Así, en lugar de crear la clase manualmente en cada controlador:
```csharp
// Forma antigua (mala)
var servicioDatos = new ServicioDatos(config);
```

ASP.NET Core lo hace automáticamente:
```csharp
// Forma moderna (buena - Inyección de Dependencias)
public MiControlador(ServicioDatos servicioDatos)
{
    _servicioDatos = servicioDatos;
}
```

### Configuración en Program.cs

**Ubicación:**
```
backend-csharp/
└── Program.cs
```

**Código de configuración:**

```csharp
using ServitecAPI.Services;

var builder = WebApplication.CreateBuilder(args);

// Cargar configuración desde appsettings.json
builder.Configuration
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddEnvironmentVariables();

// Registrar los servicios (Inyección de Dependencias)
builder.Services.AddControllers();

// Registrar ServicioDatos como servicio Scoped
// Scoped = Una nueva instancia por cada HTTP request
builder.Services.AddScoped<ServicioDatos>();

// Registrar ServicioAutenticacion
builder.Services.AddScoped<ServicioAutenticacion>();

// Agregar Swagger para documentación de API
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configurar CORS para permitir solicitudes desde el frontend
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Usar Swagger en desarrollo
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();

app.Run();
```

---

## DIAGRAMA DE FLUJO

### Flujo completo de una solicitud HTTP

```
1. CLIENTE FLUTTER
   ↓ Envía HTTP GET/POST/PUT/DELETE
   ↓
2. ASP.NET CORE API
   ↓ Recibe en un Controller
   ↓
3. CONTROLLER
   ↓ Usa métodos de ServicioDatos
   ↓
4. SERVICIODATOS
   ├─ Si es SELECT único (COUNT, MAX, etc.)
   │  ↓ Usa: EjecutarScalarAsync<T>()
   │  ↓
   │
   ├─ Si es INSERT, UPDATE, DELETE
   │  ↓ Usa: EjecutarComandoAsync()
   │  ↓
   │
   └─ Si es SELECT múltiples filas
      ↓ Usa: EjecutarConsultaAsync()
      ↓
5. MYSQL DATABASE
   ↓ Ejecuta la consulta
   ↓ Devuelve resultados
   ↓
6. SERVICIODATOS
   ↓ Procesa los resultados
   ↓ Devuelve datos al Controller
   ↓
7. CONTROLLER
   ↓ Transforma datos a JSON
   ↓ Devuelve HTTP Response
   ↓
8. CLIENTE FLUTTER
   ↓ Recibe JSON
   ↓ Actualiza la interfaz
```

---

## EJEMPLOS DE USO REAL

### Ejemplo 1: Contar clientes (EjecutarScalarAsync)

```csharp
// En el Controller
public async Task<IActionResult> ObtenerTotalClientes()
{
    // Usa EjecutarScalarAsync porque devuelve UN valor
    int total = await _servicioDatos.EjecutarScalarAsync<int>(
        "SELECT COUNT(*) FROM clientes"
    );
    
    return Ok(new { totalClientes = total });
}
```

### Ejemplo 2: Insertar un nuevo cliente (EjecutarComandoAsync)

```csharp
// En el Controller
public async Task<IActionResult> CrearCliente(string nombre, string email)
{
    // Usa EjecutarComandoAsync porque modifica datos
    int filasInsertadas = await _servicioDatos.EjecutarComandoAsync(
        @"INSERT INTO clientes (nombre, email, fecha_registro) 
          VALUES (@nombre, @email, @fecha)",
        new Dictionary<string, object>
        {
            { "nombre", nombre },
            { "email", email },
            { "fecha", DateTime.Now }
        }
    );

    if (filasInsertadas > 0)
        return Ok(new { mensaje = "Cliente creado exitosamente" });
    else
        return BadRequest(new { error = "No se pudo crear el cliente" });
}
```

### Ejemplo 3: Obtener lista de técnicos (EjecutarConsultaAsync)

```csharp
// En el Controller
public async Task<IActionResult> ObtenerTecnicos()
{
    // Usa EjecutarConsultaAsync porque devuelve múltiples filas
    var tecnicos = await _servicioDatos.EjecutarConsultaAsync(
        @"SELECT id_tecnico, nombre, email, calificacion_promedio 
          FROM tecnicos 
          WHERE activo = true 
          ORDER BY calificacion_promedio DESC"
    );

    // Transforma el List<Dictionary> a JSON
    return Ok(tecnicos);
}
```

### Ejemplo 4: Login de usuario (CifrarContraseña y VerificarContraseña)

```csharp
// En el servicio de autenticación
public async Task<bool> LoginAsync(string email, string contraseña)
{
    // Obtener el hash de la contraseña de la BD
    var hashAlmacenado = await _servicioDatos.EjecutarScalarAsync<string>(
        "SELECT contraseña FROM usuarios WHERE email = @email",
        new Dictionary<string, object> { { "email", email } }
    );

    if (hashAlmacenado == null)
        return false; // Usuario no existe

    // Verificar que la contraseña ingresada coincida con el hash
    bool esValida = _servicioDatos.VerificarContraseña(contraseña, hashAlmacenado);

    return esValida;
}
```

### Ejemplo 5: Consulta con parámetros (Prevención de inyección SQL)

```csharp
// En el Controller - Buscar clientes por nombre
public async Task<IActionResult> BuscarClientes(string nombre)
{
    var clientes = await _servicioDatos.EjecutarConsultaAsync(
        @"SELECT id_cliente, nombre, email, telefono 
          FROM clientes 
          WHERE nombre LIKE @nombre",
        new Dictionary<string, object>
        {
            { "nombre", $"%{nombre}%" } // Búsqueda con comodín
        }
    );

    return Ok(clientes);
}
```

---

## SEGURIDAD

### 1. Parámetros en Consultas (Prevención de Inyección SQL)

**❌ MALO - Vulnerable a inyección SQL:**
```csharp
// NO HACER ESTO
string consulta = "SELECT * FROM clientes WHERE nombre = '" + nombre + "'";
var resultado = await _servicioDatos.EjecutarConsultaAsync(consulta);
```

**¿Por qué es malo?**
Si un usuario ingresa: `' OR '1'='1`, la consulta se vuelve:
```sql
SELECT * FROM clientes WHERE nombre = '' OR '1'='1'
```
Esto devuelve TODOS los clientes, sin validación.

**✅ BUENO - Usando parámetros:**
```csharp
// HACER ESTO
var resultado = await _servicioDatos.EjecutarConsultaAsync(
    "SELECT * FROM clientes WHERE nombre = @nombre",
    new Dictionary<string, object> { { "nombre", nombre } }
);
```

Los parámetros (`@nombre`) son tratados como datos, no como código SQL. Así los valores especiales se escapan automáticamente.

### 2. Encriptación de Contraseñas

**❌ MALO - Contraseñas en texto plano:**
```csharp
// NO HACER ESTO
string sql = $"INSERT INTO usuarios (email, contraseña) VALUES (@email, '{contraseña}')";
// La contraseña se guarda sin encriptar. Si alguien accede a la BD, ve todas las contraseñas
```

**✅ BUENO - Usando BCrypt:**
```csharp
// HACER ESTO
string contraseñaCifrada = _servicioDatos.CifrarContraseña(contraseña);
var resultado = await _servicioDatos.EjecutarComandoAsync(
    "INSERT INTO usuarios (email, contraseña) VALUES (@email, @contraseña)",
    new Dictionary<string, object>
    {
        { "email", email },
        { "contraseña", contraseñaCifrada }
    }
);
// Incluso si alguien accede a la BD, no puede saber las contraseñas
```

### 3. Using Statements (Liberación de Recursos)

**Beneficio:**
Los `using` statements garantizan que las conexiones a la BD se cierren automáticamente, incluso si hay una excepción. Esto previene fugas de conexiones.

```csharp
// Automáticamente cierra la conexión al salir del using
using (var conexion = ObtenerConexion())
{
    // Usa la conexión
    // ...
} // Aquí se cierra automáticamente
```

---

## CONCLUSIÓN

La clase `ServicioDatos` es el **corazón del acceso a datos** en la aplicación SERVITEC. Proporciona una forma segura, asincrónica y eficiente de:

✅ Conectarse a MySQL  
✅ Ejecutar consultas SELECT  
✅ Ejecutar comandos INSERT, UPDATE, DELETE  
✅ Encriptar contraseñas  
✅ Prevenir inyecciones SQL  

**Puntos clave a recordar:**
1. Todos los parámetros deben ir en el diccionario, no en la cadena
2. Siempre usar `await` para métodos asincronicos
3. Las contraseñas siempre se encriptan con `CifrarContraseña()`
4. Los `using` statements cierran automáticamente las conexiones
5. La inyección de dependencias permite que ASP.NET Core maneje las instancias

---

**Fin del Reporte**

Fecha de elaboración: Diciembre 2024  
Autor: [Tu Nombre]  
Materia: Taller de Base de Datos  
Semestre: 5to Semestre

### Arquitectura General

```
┌─────────────────────────────────────────────────────────┐
│         APLICACIÓN FLUTTER (Cliente)                     │
│  (Solicita datos a través de HTTP)                       │
└──────────────────┬──────────────────────────────────────┘
                   │ HTTP Requests
                   ↓
┌─────────────────────────────────────────────────────────┐
│    ASP.NET CORE API (Servidor Backend)                   │
│  - Controllers                                            │
│  - Services (DatabaseService, AuthService)               │
└──────────────────┬──────────────────────────────────────┘
                   │ ADO.NET
                   ↓
┌─────────────────────────────────────────────────────────┐
│     MYSQL DATABASE (Base de Datos)                        │
│  - Tabla clientes                                         │
│  - Tabla técnicos                                         │
│  - Tabla servicios                                        │
│  - Tabla contrataciones                                   │
│  - Tabla pagos                                            │
│  - Tabla calificaciones                                   │
│  - Tabla tecnico_servicio                                │
└─────────────────────────────────────────────────────────┘
```

---

## COMPONENTES PRINCIPALES

### 1. Archivo de Configuración: appsettings.json

**Ubicación del archivo:**
```
backend-csharp/
└── appsettings.json
```

**Contenido completo:**

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=servitec;Uid=root;Pwd=LU2040#G;Port=3306;"
  },
  "JWT": {
    "Secret": "tu_clave_secreta_super_segura_aqui_1234567890",
    "ExpiryDays": 30
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Explicación de cada sección:**

| Sección | Explicación |
|---------|------------|
| `ConnectionStrings.DefaultConnection` | Cadena de conexión a la base de datos MySQL |
| `Server=localhost` | Servidor donde está MySQL (en este caso, máquina local) |
| `Database=servitec` | Nombre de la base de datos |
| `Uid=root` | Usuario de MySQL |
| `Pwd=LU2040#G` | Contraseña del usuario root |
| `Port=3306` | Puerto donde escucha MySQL (por defecto 3306) |
| `JWT.Secret` | Clave secreta para firmar tokens de autenticación |
| `JWT.ExpiryDays` | Días de validez del token (30 días) |

---

## CONFIGURACIÓN DEL ARCHIVO APPSETTINGS.JSON

### ¿Por qué se usa appsettings.json?

Este archivo permite:
1. **Separación de configuración y código** - No mezclar datos sensibles con lógica
2. **Fácil cambio de configuración** - Sin recompilar la aplicación
3. **Diferentes configuraciones por entorno** - Desarrollo, prueba, producción
4. **Mayor seguridad** - Credenciales en archivo de configuración, no en código

### Estructura de la Cadena de Conexión

```
Server=localhost;Database=servitec;Uid=root;Pwd=LU2040#G;Port=3306;
```

Desglose de parámetros:

```
┌─ Parámetro: "Server"     ─ Valor: "localhost"      → Ubicación del servidor
├─ Parámetro: "Database"   ─ Valor: "servitec"       → Nombre de BD
├─ Parámetro: "Uid"        ─ Valor: "root"           → Usuario (User ID)
├─ Parámetro: "Pwd"        ─ Valor: "LU2040#G"       → Contraseña
└─ Parámetro: "Port"       ─ Valor: "3306"           → Puerto de conexión
```

---

## CLASE SERVICIODATOS - LA CLASE PRINCIPAL DE CONEXIÓN

### Ubicación y propósito

**Ubicación del archivo:**
```
backend-csharp/
└── Services/
    └── DatabaseService.cs (Traducido como: ServicioDatos.cs)
```

**Propósito de la clase:**

La clase `ServicioDatos` es el **Servicio de Acceso a Datos (DAL - Data Access Layer)** que encapsula toda la lógica de conexión y ejecución de consultas a la base de datos MySQL. Es la clase puente entre los controladores (Controllers) de la API y la base de datos, garantizando que todas las operaciones de BD se realicen de forma segura, asincrónica y mediante parámetros.

---

### 1. Directivas de uso (Using Statements)

**Explicación:**

Las directivas `using` al inicio del archivo permiten acceder a espacios de nombres externos sin necesidad de escribir el nombre completo cada vez. En el caso de `ServicioDatos`, necesitamos:

- **`MySql.Data.MySqlClient`**: Proporciona las clases necesarias para conectarse a MySQL (ConexionMySQL, ComandoMySQL, etc.)
- **`System.Security.Cryptography`**: Necesario para funciones de encriptación de contraseñas
- **`System.Text`**: Para manipulación de strings/textos
- **`Microsoft.Extensions.Configuration`**: Para acceder al archivo appsettings.json

```csharp
using MySql.Data.MySqlClient;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Configuration;
```

---

### 2. Espacio de nombres y declaración de la clase

**Explicación:**

El espacio de nombres (namespace) `ServitecAPI.Services` organiza la clase dentro del proyecto. Esto evita conflictos de nombres si hay otras clases con el mismo nombre en otros proyectos. La clase es declarada como `public` para que pueda ser accesible desde cualquier controlador o servicio que la necesite.

```csharp
namespace ServitecAPI.Services
{
    public class ServicioDatos
    {
        // Contenido de la clase aquí
    }
}
```

**Beneficios:**
- **Organización**: Todas las clases de acceso a datos están en la carpeta `Services`
- **Reutilización**: La clase puede ser usada desde múltiples controladores
- **Inyección de Dependencias**: Facilita la integración con el contenedor de servicios de ASP.NET Core

---

### 3. Variable privada de cadena de conexión

**Explicación:**

La variable `_cadenaConexion` almacena de forma segura la cadena de conexión a la base de datos. El modificador `readonly` indica que solo puede ser asignada una sola vez (en el constructor) y no puede ser modificada después. Esto es una medida de seguridad para evitar cambios accidentales en la configuración de la conexión.

```csharp
private readonly string _cadenaConexion;
```

**¿Por qué `readonly`?**

| Característica | Beneficio |
|---|---|
| **Seguridad** | Impide que se cambie accidentalmente la cadena de conexión |
| **Consistencia** | Garantiza que siempre se usa la misma conexión |
| **Privacidad** | Solo la clase interna puede acceder a ella (private) |

---

### 4. Constructor de la clase

**Explicación:**

El constructor es el método que se ejecuta cuando se crea una instancia de la clase. Recibe un objeto `IConfiguration` (inyectado por el contenedor de servicios) que contiene toda la configuración del proyecto incluyendo la cadena de conexión almacenada en `appsettings.json`.

```csharp
public ServicioDatos(IConfiguration config)
{
    _cadenaConexion = config.GetConnectionString("DefaultConnection")
        ?? throw new InvalidOperationException("Cadena de conexión no encontrada.");
}
```

**Desglose línea por línea:**

| Línea | Explicación |
|---|---|
| `public ServicioDatos(IConfiguration config)` | Constructor público que recibe la configuración del proyecto |
| `_cadenaConexion = ...` | Asigna el valor a la variable privada |
| `config.GetConnectionString("DefaultConnection")` | Obtiene la cadena de conexión de appsettings.json |
| `?? throw new InvalidOperationException(...)` | Si es null, lanza una excepción (no permite continuar sin conexión) |

**¿Por qué usar `??` (null coalescing operator)?**

Este operador devuelve el valor de la izquierda si no es nulo, de lo contrario devuelve el de la derecha. Es una forma segura de manejar valores que podrían no existir.

---

### 5. Método ObtenerConexion()

**Explicación:**

Este método privado crea una nueva instancia de conexión MySQL cada vez que es llamado. Devuelve un objeto `ConexionMySQL` que está lista para ser usada. El método encapsula la lógica de creación de la conexión, lo que significa que si en el futuro cambia la forma de crear conexiones, solo hay que modificar este método.

```csharp
public ConexionMySQL ObtenerConexion()
{
    return new ConexionMySQL(_cadenaConexion);
}
```

**¿Por qué es importante tener este método aparte?**

| Razón | Explicación |
|---|---|
| **Encapsulación** | La lógica de conexión está centralizada |
| **Reutilización** | Todos los otros métodos lo usan |
| **Mantenimiento** | Si cambia la forma de conectar, solo hay un lugar para cambiar |
| **Testing** | Facilita hacer testing unitario |

---

### 6. Métodos de encriptación de contraseñas

**Explicación:**

La seguridad es crítica. Las contraseñas jamás deben almacenarse en texto plano en la base de datos. Por eso, antes de guardar una contraseña, se encripta usando BCrypt (un algoritmo de hash seguro). Estos dos métodos implementan la encriptación y verificación:

- **`CifrarContraseña()`**: Convierte una contraseña en texto plano a un hash irreversible
- **`VerificarContraseña()`**: Compara una contraseña ingresada con su hash almacenado

```csharp
public string CifrarContraseña(string contraseña)
{
    return BCrypt.Net.BCrypt.HashPassword(contraseña);
}

public bool VerificarContraseña(string contraseña, string hash)
{
    return BCrypt.Net.BCrypt.Verify(contraseña, hash);
}
```

**Ejemplo de uso:**

```csharp
// Al registrarse un nuevo técnico
var contraseñaPlana = "MiContraseña123";
var contraseñaCifrada = _servicioDatos.CifrarContraseña(contraseñaPlana);
// Guardar contraseñaCifrada en la base de datos, NO contraseñaPlana

// Al iniciar sesión
var contraseñaIngresada = "MiContraseña123";
var hashAlmacenado = "...valor de la BD...";
bool esValida = _servicioDatos.VerificarContraseña(contraseñaIngresada, hashAlmacenado);
// Si esValida es true, el login es correcto
```

**Tabla de comparación con otros métodos:**

| Método | Seguridad | Reversible | Uso |
|---|---|---|---|
| **Texto plano** | ❌ Muy mala | ✅ Sí | ❌ NUNCA |
| **MD5/SHA1** | ❌ Mala | ❌ No | ❌ No recomendado |
| **BCrypt** | ✅ Excelente | ❌ No | ✅ Recomendado |

---

### 7. Método EjecutarScalarAsync<T>() - Para obtener UN SOLO VALOR

**Explicación:**

Este método ejecuta una consulta SELECT que devuelve **un único valor** (un número, una cadena, etc.). Es genérico (usa `<T>`) lo que significa que puede devolver cualquier tipo de dato: `int`, `string`, `double`, etc.

El método es asincrónico (`async`/`await`) para que no bloquee el hilo de ejecución mientras se espera la respuesta de la base de datos.

```csharp
public async Task<T?> EjecutarScalarAsync<T>(
    string consulta, 
    Dictionary<string, object>? parametros = null)
{
    using (var conexion = ObtenerConexion())
    {
        await conexion.AbrirAsync();
        using (var comando = new ComandoMySQL(consulta, conexion))
        {
            if (parametros != null)
            {
                foreach (var param in parametros)
                {
                    comando.Parametros.AgregarConValor($"@{param.Key}", param.Value);
                }
            }
            var resultado = await comando.EjecutarScalarAsync();
            return resultado != null ? (T)Convert.ChangeType(resultado, typeof(T)) : default;
        }
    }
}
```

**Desglose del flujo:**

1. `using (var conexion = ObtenerConexion())` → Obtiene una nueva conexión
2. `await conexion.AbrirAsync()` → La abre de forma asincrónica
3. `new ComandoMySQL(consulta, conexion)` → Crea un comando SQL con la consulta
4. `foreach (var param in parametros)` → Agrega los parámetros de forma segura
5. `await comando.EjecutarScalarAsync()` → Ejecuta la consulta
6. `Convert.ChangeType(resultado, typeof(T))` → Convierte el resultado al tipo genérico T
7. `return resultado != null ? ... : default` → Devuelve el resultado o null si no existe

**Casos de uso:**

```csharp
// Contar cuántos clientes hay
var totalClientes = await _servicioDatos.EjecutarScalarAsync<int>(
    "SELECT COUNT(*) FROM clientes"
);

// Obtener el email de un cliente específico
var email = await _servicioDatos.EjecutarScalarAsync<string>(
    "SELECT email FROM clientes WHERE id_cliente = @id",
    new Dictionary<string, object> { { "id", 5 } }
);

// Obtener el saldo de un cliente
var saldo = await _servicioDatos.EjecutarScalarAsync<double>(
    "SELECT saldo FROM clientes WHERE id_cliente = @id",
    new Dictionary<string, object> { { "id", 5 } }
);
```

---

### 8. Método EjecutarComandoAsync() - Para INSERT, UPDATE, DELETE

**Explicación:**

Este método ejecuta comandos SQL que **modifican datos** en la base de datos pero **no devuelven filas de resultado**. Se usa para:
- `INSERT` → Agregar nuevos registros
- `UPDATE` → Modificar registros existentes
- `DELETE` → Eliminar registros

Retorna un `int` con el número de filas afectadas (0 si no se modificó nada, 1+ si se modificó algo).

```csharp
public async Task<int> EjecutarComandoAsync(
    string consulta, 
    Dictionary<string, object>? parametros = null)
{
    using (var conexion = ObtenerConexion())
    {
        await conexion.AbrirAsync();
        using (var comando = new ComandoMySQL(consulta, conexion))
        {
            if (parametros != null)
            {
                foreach (var param in parametros)
                {
                    comando.Parametros.AgregarConValor($"@{param.Key}", param.Value);
                }
            }
            return await comando.EjecutarAsync();
        }
    }
}
```

**Desglose del flujo:**

| Paso | Código | Explicación |
|---|---|---|
| 1 | `using (var conexion = ...)` | Obtiene y abre una conexión |
| 2 | `new ComandoMySQL(consulta, conexion)` | Crea el comando |
| 3 | `foreach (var param...)` | Agrega parámetros de forma segura |
| 4 | `await comando.EjecutarAsync()` | Ejecuta y devuelve filas afectadas |
| 5 | `return ...` | Retorna el número de filas modificadas |

**Casos de uso:**

```csharp
// INSERT: Agregar un nuevo cliente
int filasInsertadas = await _servicioDatos.EjecutarComandoAsync(
    @"INSERT INTO clientes (nombre, email, telefono) 
      VALUES (@nombre, @email, @telefono)",
    new Dictionary<string, object>
    {
        { "nombre", "Juan Pérez" },
        { "email", "juan@example.com" },
        { "telefono", "1234567890" }
    }
);

// UPDATE: Actualizar teléfono de un cliente
int filasActualizadas = await _servicioDatos.EjecutarComandoAsync(
    "UPDATE clientes SET telefono = @tel WHERE id_cliente = @id",
    new Dictionary<string, object>
    {
        { "tel", "9876543210" },
        { "id", 5 }
    }
);

// DELETE: Eliminar un cliente
int filasEliminadas = await _servicioDatos.EjecutarComandoAsync(
    "DELETE FROM clientes WHERE id_cliente = @id",
    new Dictionary<string, object> { { "id", 5 } }
);
```

---

### 9. Método EjecutarConsultaAsync() - Para SELECT con MÚLTIPLES FILAS

**Explicación:**

Este es el método más versátil. Ejecuta consultas SELECT que devuelven **múltiples filas** y las convierte en una estructura flexible: una lista de diccionarios (`List<Dictionary<string, object>>`).

Cada diccionario representa una fila, donde:
- **Clave** = Nombre de la columna
- **Valor** = Valor de la celda

Este enfoque es flexible porque no necesita saber de antemano qué columnas devuelve la consulta.

```csharp
public async Task<List<Dictionary<string, object>>> EjecutarConsultaAsync(
    string consulta, 
    Dictionary<string, object>? parametros = null)
{
    var resultados = new List<Dictionary<string, object>>();
    using (var conexion = ObtenerConexion())
    {
        await conexion.AbrirAsync();
        using (var comando = new ComandoMySQL(consulta, conexion))
        {
            if (parametros != null)
            {
                foreach (var param in parametros)
                {
                    comando.Parametros.AgregarConValor($"@{param.Key}", param.Value);
                }
            }
            using (var lector = await comando.EjecutarLectorAsync())
            {
                while (await lector.LeerAsync())
                {
                    var fila = new Dictionary<string, object>();
                    for (int i = 0; i < lector.ConteoColumnas; i++)
                    {
                        fila[lector.ObtenerNombre(i)] = lector.ObtenerValor(i);
                    }
                    resultados.Add(fila);
                }
            }
        }
    }
    return resultados;
}
```

**Desglose del flujo:**

1. `var resultados = new List<Dictionary<...>>()` → Crea una lista para almacenar todas las filas
2. `using (var conexion...)` → Obtiene y abre una conexión
3. `new ComandoMySQL(consulta, conexion)` → Crea el comando
4. `comando.EjecutarLectorAsync()` → Ejecuta la consulta y obtiene un lector
5. `while (await lector.LeerAsync())` → Lee cada fila una por una
6. `for (int i = 0; i < lector.ConteoColumnas; i++)` → Itera sobre cada columna
7. `fila[lector.ObtenerNombre(i)] = lector.ObtenerValor(i)` → Agrega el valor a la fila
8. `resultados.Add(fila)` → Agrega la fila a la lista
9. `return resultados` → Retorna todas las filas

**Casos de uso:**

```csharp
// Obtener todos los clientes
var clientes = await _servicioDatos.EjecutarConsultaAsync(
    "SELECT id_cliente, nombre, email FROM clientes"
);

foreach (var cliente in clientes)
{
    var id = cliente["id_cliente"];
    var nombre = cliente["nombre"];
    var email = cliente["email"];
    Console.WriteLine($"{id}: {nombre} ({email})");
}

// Obtener clientes con filtro
var clientesActivos = await _servicioDatos.EjecutarConsultaAsync(
    @"SELECT id_cliente, nombre, estado FROM clientes 
      WHERE estado = @estado",
    new Dictionary<string, object> { { "estado", "activo" } }
);

// Obtener técnicos con sus calificaciones
var tecnicos = await _servicioDatos.EjecutarConsultaAsync(
    @"SELECT id_tecnico, nombre, calificacion_promedio 
      FROM tecnicos 
      WHERE calificacion_promedio > @minimo 
      ORDER BY calificacion_promedio DESC",
    new Dictionary<string, object> { { "minimo", 4.0 } }
);
```

---

## Componentes Clave de la Clase ServicioDatos

### Componente 1: Directivas de Uso (Using Statements)

**Explicación:**

Las directivas `using` importan espacios de nombres (namespaces) que contienen las clases y funciones que necesita la clase ServicioDatos. Cada una cumple una función específica:

```csharp
using MySql.Data.MySqlClient;
using System.Security.Cryptography;
using System.Text;
```

- **`MySql.Data.MySqlClient`**: Proporciona las clases `MySqlConnection`, `MySqlCommand` y `MySqlDataReader` necesarias para conectarse y manipular la base de datos MySQL. Sin esta librería, no sería posible comunicarse con MySQL.
- **`System.Security.Cryptography`**: Proporciona funciones de encriptación. En nuestro caso, usamos BCrypt para cifrar contraseñas de manera segura e irreversible.
- **`System.Text`**: Proporciona utilidades para manipular cadenas de texto. Es parte del framework estándar de .NET.

---

### Componente 2: Espacio de Nombres (Namespace)

**Explicación:**

El espacio de nombres es como una carpeta virtual que organiza el código. Evita conflictos de nombres y agrupa código relacionado. En nuestro caso, todas las clases de servicios de acceso a datos están en `ServitecAPI.Services`.

```csharp
namespace ServitecAPI.Services
{
    public class ServicioDatos
    {
        // Todo el código de la clase va aquí
    }
}
```

**Ventajas:**
- **Organización**: Agrupa servicios de base de datos junto
- **Claridad**: Al ver `ServitecAPI.Services.ServicioDatos`, sabes exactamente dónde está
- **Evita conflictos**: Puedes tener dos clases con el mismo nombre en diferentes namespaces

---

### Componente 3: Variable Privada de Cadena de Conexión

**Explicación:**

Esta variable almacena la cadena de conexión a la base de datos. Es `private` (privada) porque solo la clase puede acceder a ella, y `readonly` (solo lectura) porque una vez asignada, no puede cambiar. Esto previene modificaciones accidentales.

```csharp
private readonly string _cadenaConexion;
```

**Desglose:**
- **`private`**: Solo accesible dentro de esta clase
- **`readonly`**: Se asigna una sola vez (en el constructor) y no puede modificarse después
- **`string`**: Es una cadena de texto
- **`_cadenaConexion`**: Nombre descriptivo con convención de naming privado (guion bajo al inicio)

**¿Por qué es importante?**
La cadena de conexión contiene información sensible (usuario, contraseña, servidor). Hacerla privada garantiza que solo los métodos internos de la clase puedan usarla.

---

### Componente 4: Constructor de la Clase

**Explicación:**

El constructor se ejecuta automáticamente cuando se crea una instancia de la clase. Su responsabilidad es inicializar la variable `_cadenaConexion` desde el archivo de configuración `appsettings.json`.

```csharp
public ServicioDatos(IConfiguration config)
{
    _cadenaConexion = config.GetConnectionString("DefaultConnection")
        ?? throw new InvalidOperationException("Cadena de conexión no encontrada.");
}
```

**Análisis línea por línea:**

| Parte | Explicación |
|-------|-------------|
| `public ServicioDatos(IConfiguration config)` | Método constructor público que recibe un parámetro `IConfiguration` (inyectado por ASP.NET Core) |
| `config.GetConnectionString("DefaultConnection")` | Lee la configuración del archivo appsettings.json buscando una clave llamada "DefaultConnection" |
| `??` | Operador "null-coalescing" - si el lado izquierdo es null, usa el lado derecho |
| `throw new InvalidOperationException(...)` | Lanza una excepción (error) si la cadena de conexión no existe |
| Resultado | Si todo está bien, `_cadenaConexion` queda guardada; si no, la aplicación se detiene |

**Flujo en tiempo de ejecución:**
1. ASP.NET Core crea una instancia de ServicioDatos
2. Automáticamente llama al constructor
3. El constructor intenta leer "DefaultConnection" de appsettings.json
4. Si existe: guarda la cadena en `_cadenaConexion`
5. Si no existe: la aplicación explota con un error claro

---

### Componente 5: Método ObtenerConexion()

**Explicación:**

Este método crea y retorna una nueva conexión a la base de datos cada vez que se llama. No abre la conexión (eso lo hace cada método que la necesita), solo la instancia y la retorna.

```csharp
public ConexionMySQL ObtenerConexion()
{
    return new ConexionMySQL(_cadenaConexion);
}
```

**¿Por qué existe este método?**

Podríamos crear la conexión directamente en cada método, pero encapsularla en un método dedicado tiene ventajas:

| Ventaja | Explicación |
|---------|-------------|
| **Reutilización** | Todos los métodos usan este mismo método en lugar de duplicar código |
| **Mantenimiento** | Si cambiamos cómo se crea la conexión, solo editamos un lugar |
| **Encapsulación** | Los detalles de cómo se crea la conexión están ocultos |

**Patrón de uso:**
```csharp
using (var conexion = ObtenerConexion())
{
    // Usar la conexión
}
// La conexión se cierra automáticamente gracias a 'using'
```

---

### Componente 6: Métodos de Encriptación de Contraseñas

**Explicación:**

Las contraseñas nunca deben almacenarse en texto plano en la base de datos. En su lugar, se cifran usando BCrypt, que es un algoritmo de hash de una sola dirección (no se puede descifrar).

```csharp
public string CifrarContraseña(string contraseña)
{
    return BCrypt.Net.BCrypt.HashPassword(contraseña);
}

public bool VerificarContraseña(string contraseña, string hash)
{
    return BCrypt.Net.BCrypt.Verify(contraseña, hash);
}
```

**¿Cómo funciona BCrypt?**

| Operación | Código | Resultado | ¿Reversible? |
|-----------|--------|-----------|--------------|
| **Cifrar** | `CifrarContraseña("mi123")` | `$2a$11$N9qo8uLO...` (hash aleatorio) | ❌ No |
| **Verificar** | `VerificarContraseña("mi123", hash)` | `true` o `false` | N/A |

**Ejemplo de uso en registro:**
```csharp
// Usuario ingresa: "MiContraseña123"
var contraseniaEncriptada = _servicioDatos.CifrarContraseña("MiContraseña123");
// Se guarda en BD: $2a$11$N9qo8uLO... (nunca se ve la contraseña real)

// Usuario intenta login con: "MiContraseña123"
bool esValida = _servicioDatos.VerificarContraseña("MiContraseña123", hashGuardado);
// Retorna: true (coinciden)
```

---

### Componente 7: Método EjecutarScalarAsync<T>() - Valores Únicos

**Explicación:**

Este método ejecuta una consulta SQL que devuelve UN SOLO valor (un número, una cadena, etc.). Es asincrónico (async) porque no bloquea el thread mientras espera la respuesta de la base de datos.

```csharp
public async Task<T?> EjecutarScalarAsync<T>(
    string consulta, 
    Dictionary<string, object>? parametros = null)
{
    using (var conexion = ObtenerConexion())
    {
        await conexion.AbrirAsync();
        using (var comando = new ComandoMySQL(consulta, conexion))
        {
            if (parametros != null)
            {
                foreach (var param in parametros)
                {
                    comando.Parametros.AgregarConValor($"@{param.Key}", param.Value);
                }
            }
            var resultado = await comando.EjecutarScalarAsync();
            return resultado != null ? (T)Convert.ChangeType(resultado, typeof(T)) : default;
        }
    }
}
```

**Análisis del flujo:**

```
1. Obtener conexión
   └─ ObtenerConexion() crea nueva instancia MySqlConnection
   
2. Abrir conexión
   └─ await conexion.AbrirAsync() (espera a que se abra)
   
3. Crear comando SQL
   └─ new ComandoMySQL(consulta, conexion)
   
4. Agregar parámetros (si existen)
   └─ Para cada parámetro: comando.Parametros.AgregarConValor("@nombre", valor)
   
5. Ejecutar consulta
   └─ await comando.EjecutarScalarAsync() (obtiene el valor)
   
6. Convertir resultado
   └─ Convierte al tipo genérico T (int, string, double, etc.)
   
7. Retornar resultado
   └─ Si es null, retorna valor por defecto de T
```

**Ejemplo de uso:**
```csharp
// ¿Cuántos clientes hay?
var total = await _servicioDatos.EjecutarScalarAsync<int>(
    "SELECT COUNT(*) FROM clientes"
);
// Retorna: 42 (entero)

// ¿Cuál es el email del cliente 5?
var email = await _servicioDatos.EjecutarScalarAsync<string>(
    "SELECT email FROM clientes WHERE id_cliente = @id",
    new Dictionary<string, object> { { "id", 5 } }
);
// Retorna: "luis@example.com" (string)
```

---

### Componente 8: Método EjecutarComandoAsync() - Modificar Datos

**Explicación:**

Este método ejecuta comandos que **modifican** datos (INSERT, UPDATE, DELETE) sin devolver filas. Retorna el número de filas afectadas.

```csharp
public async Task<int> EjecutarComandoAsync(
    string consulta, 
    Dictionary<string, object>? parametros = null)
{
    using (var conexion = ObtenerConexion())
    {
        await conexion.AbrirAsync();
        using (var comando = new ComandoMySQL(consulta, conexion))
        {
            if (parametros != null)
            {
                foreach (var param in parametros)
                {
                    comando.Parametros.AgregarConValor($"@{param.Key}", param.Value);
                }
            }
            return await comando.EjecutarAsync();
        }
    }
}
```

**¿Qué retorna?**

| Comando | Resultado | Significado |
|---------|-----------|------------|
| `INSERT INTO clientes (...)` | `1` | Se insertó 1 fila |
| `UPDATE clientes SET ... WHERE id = 5` | `1` | Se actualizó 1 fila |
| `UPDATE clientes SET ... WHERE edad > 50` | `12` | Se actualizaron 12 filas |
| `DELETE FROM clientes WHERE id = 5` | `1` | Se eliminó 1 fila |
| `UPDATE clientes SET ... WHERE id = 999` | `0` | No se actualizó nada (no existe) |

**Ejemplo de uso:**
```csharp
// Insertar nuevo técnico
int insertadas = await _servicioDatos.EjecutarComandoAsync(
    @"INSERT INTO tecnicos (nombre, email, tarifa_hora)
      VALUES (@nombre, @email, @tarifa)",
    new Dictionary<string, object>
    {
        { "nombre", "Carlos Pérez" },
        { "email", "carlos@example.com" },
        { "tarifa", 25.50 }
    }
);
// Retorna: 1 (se insertó 1 fila)

// Actualizar teléfono
int actualizadas = await _servicioDatos.EjecutarComandoAsync(
    "UPDATE clientes SET telefono = @tel WHERE id_cliente = @id",
    new Dictionary<string, object> { { "tel", "3001234567" }, { "id", 5 } }
);
// Retorna: 1 (se actualizó 1 fila)
```

---

### Componente 9: Método EjecutarConsultaAsync() - Obtener Múltiples Filas

**Explicación:**

Este es el método más complejo. Ejecuta consultas SELECT que devuelven **múltiples filas** y las convierte en una estructura flexible: una lista de diccionarios (List<Dictionary>).

```csharp
public async Task<List<Dictionary<string, object>>> EjecutarConsultaAsync(
    string consulta, 
    Dictionary<string, object>? parametros = null)
{
    var resultados = new List<Dictionary<string, object>>();
    using (var conexion = ObtenerConexion())
    {
        await conexion.AbrirAsync();
        using (var comando = new ComandoMySQL(consulta, conexion))
        {
            if (parametros != null)
            {
                foreach (var param in parametros)
                {
                    comando.Parametros.AgregarConValor($"@{param.Key}", param.Value);
                }
            }
            using (var lector = await comando.EjecutarLectorAsync())
            {
                while (await lector.LeerAsync())
                {
                    var fila = new Dictionary<string, object>();
                    for (int i = 0; i < lector.ConteoColumnas; i++)
                    {
                        fila[lector.ObtenerNombre(i)] = lector.ObtenerValor(i);
                    }
                    resultados.Add(fila);
                }
            }
        }
    }
    return resultados;
}
```

**¿Por qué usar Dictionary<string, object>?**

Es flexible. No sabemos qué columnas devuelve la consulta, así que usamos diccionarios:

| Ventaja | Ejemplo |
|---------|---------|
| **Sin tipos** | Funciona con cualquier consulta (SELECT * FROM clientes, SELECT id, nombre, etc.) |
| **Acceso por nombre** | `cliente["nombre"]` es más legible que `cliente[1]` |
| **Dinámico** | Si el schema de la BD cambia, el código sigue funcionando |

**Flujo de lectura de resultados:**

```
Consulta: SELECT id_cliente, nombre, email FROM clientes

MySqlDataReader devuelve:
┌─────────────────┬───────────────┬──────────────────────┐
│ id_cliente      │ nombre        │ email                │
├─────────────────┼───────────────┼──────────────────────┤
│ 1               │ Juan Pérez    │ juan@example.com     │
│ 2               │ María García  │ maria@example.com    │
│ 3               │ Luis López    │ luis@example.com     │
└─────────────────┴───────────────┴──────────────────────┘

Se convierte a List<Dictionary>:
[
    { "id_cliente": 1, "nombre": "Juan Pérez", "email": "juan@example.com" },
    { "id_cliente": 2, "nombre": "María García", "email": "maria@example.com" },
    { "id_cliente": 3, "nombre": "Luis López", "email": "luis@example.com" }
]
```

**Ejemplo de uso:**
```csharp
// Obtener todos los clientes
var clientes = await _servicioDatos.EjecutarConsultaAsync(
    "SELECT id_cliente, nombre, email, telefono FROM clientes"
);

// Procesar resultados
foreach (var cliente in clientes)
{
    var id = cliente["id_cliente"];           // 1, 2, 3, etc.
    var nombre = cliente["nombre"];           // Juan, María, Luis, etc.
    var email = cliente["email"];             // juan@example.com, etc.
    
    Console.WriteLine($"ID: {id}, Nombre: {nombre}, Email: {email}");
}

// O acceder a un cliente específico
var primerCliente = clientes[0];
var nombrePrimero = primerCliente["nombre"];  // "Juan Pérez"
```

---

## INYECCIÓN DE DEPENDENCIAS

### ¿Qué es la Inyección de Dependencias?

Es un patrón de diseño que permite:
- Desacoplar clases
- Facilitar pruebas
- Centralizar la configuración

### Configuración en Program.cs

**Ubicación:**
```
backend-csharp/
└── Program.cs
```

**Código relevante:**

```csharp
using ServitecAPI.Services;

var constructor = WebApplication.CreateBuilder(args);

// ======== CARGAR CONFIGURACIÓN ========
constructor.Configuration
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddEnvironmentVariables();

// ======== REGISTRAR SERVICIOS (Inyección de Dependencias) ========
constructor.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
    });

// Registrar ServicioDatos como servicio de alcance (Scoped)
// "Agregar ServicioDatos al contenedor de servicios"
constructor.Services.AddScoped<ServicioDatos>();

// Registrar ServicioAutenticacion
constructor.Services.AddScoped<ServicioAutenticacion>();

// Swagger para documentación de API
constructor.Services.AddEndpointsApiExplorer();
constructor.Services.AddSwaggerGen();

// ======== CONFIGURAR CORS ========
// Permitir solicitudes desde cualquier origen
constructor.Services.AddCors(options =>
{
    options.AddPolicy("PermitirTodo", b =>
    {
        b.AllowAnyOrigin()   // Permitir cualquier origen
         .AllowAnyMethod()   // Permitir cualquier método HTTP
         .AllowAnyHeader();  // Permitir cualquier encabezado
    });
});

var aplicacion = constructor.Build();

// ======== CONFIGURAR MIDDLEWARE ========
if (aplicacion.Environment.IsDevelopment())
{
    aplicacion.UseSwagger();
    aplicacion.UseSwaggerUI();
}

aplicacion.UseHttpsRedirection();
aplicacion.UseCors("PermitirTodo");
aplicacion.UseAuthorization();
aplicacion.MapControllers();

// ======== INICIAR SERVIDOR ========
Console.WriteLine("Servidor Servitec (C# ADO.NET) corriendo en puerto 3000");
Console.WriteLine("URL: http://localhost:3000");
Console.WriteLine("Verificación de salud: http://localhost:3000/api/health");

aplicacion.Run("http://0.0.0.0:3000");
```

### Explicación de `AddScoped<ServicioDatos>()`

```csharp
constructor.Services.AddScoped<ServicioDatos>();
```

- **AddScoped**: Crear una nueva instancia de ServicioDatos por cada solicitud HTTP
- **<ServicioDatos>**: La clase que se registra como servicio

**Ciclo de vida:**
1. Cliente hace solicitud HTTP
2. Framework crea instancia de ServicioDatos
3. Se inyecta en Controladores que lo necesitan
4. Después de procesar la solicitud, se descarta

---

## DIAGRAMA DE FLUJO

### Flujo completo de una solicitud HTTP

```
1. CLIENTE FLUTTER
   │
   └─→ Realiza solicitud HTTP
       Ejemplo: GET /api/clientes

2. SERVIDOR ASP.NET CORE
   │
   ├─→ Recibe solicitud en ControladorClientes
   │
   ├─→ Inyecta ServicioDatos automáticamente
   │
   ├─→ Controlador llama a método de ServicioDatos
   │   Ejemplo: _servicioDatos.EjecutarConsultaAsync(...)
   │
   └─→ ServicioDatos procesa la solicitud
       │
       ├─→ Lee cadena de conexión de appsettings.json
       │
       ├─→ Crea nueva conexión ConexionMySQL
       │
       ├─→ Abre conexión a MySQL
       │
       ├─→ Crea comando SQL (ComandoMySQL)
       │
       ├─→ Agrega parámetros de forma segura
       │
       ├─→ Ejecuta comando en BD
       │
       ├─→ Lee resultados
       │
       ├─→ Convierte a List<Dictionary<string, object>>
       │
       └─→ Retorna resultados

3. RESPUESTA HTTP
   │
   └─→ Convierte resultados a JSON
       │
       └─→ Envía al cliente Flutter
```

---

## EJEMPLOS DE USO

### Ejemplo 1: Registrar un nuevo cliente

**En Controlador:**

```csharp
// En ServicioAutenticacion.cs (que usa ServicioDatos)
public async Task<IActionResult> RegistrarCliente([FromBody] SolicitudRegistroCliente solicitud)
{
    try
    {
        // Validar que el email no exista
        var clienteExistente = await _servicioDatos.EjecutarScalarAsync<int>(
            "SELECT COUNT(*) FROM clientes WHERE email = @email",
            new Dictionary<string, object> { { "email", solicitud.Email } }
        );

        if (clienteExistente > 0)
            return Conflict(new { error = "El correo ya está registrado" });

        // Encriptar contraseña
        var contraseniaEncriptada = _servicioDatos.CifrarContraseña(solicitud.Contraseña);

        // Insertar nuevo cliente
        var consulta = @"
            INSERT INTO clientes (nombre, apellido, email, password_hash, telefono, direccion_text, latitud, longitud)
            VALUES (@nombre, @apellido, @email, @hash, @tel, @direccion, @lat, @lng);
            SELECT LAST_INSERT_ID();
        ";

        var parametros = new Dictionary<string, object>
        {
            { "nombre", solicitud.Nombre },
            { "apellido", solicitud.Apellido },
            { "email", solicitud.Email },
            { "hash", contraseniaEncriptada },
            { "tel", solicitud.Telefono },
            { "direccion", solicitud.TextoDireccion },
            { "lat", solicitud.Latitud },
            { "lng", solicitud.Longitud }
        };

        var idClienteNuevo = await _servicioDatos.EjecutarScalarAsync<int>(consulta, parametros);
        
        return Ok(new { 
            id_usuario = idClienteNuevo,
            mensaje = "Cliente registrado exitosamente"
        });
    }
    catch (Exception ex)
    {
        return StatusCode(500, new { error = ex.Message });
    }
}
```

**Explicación de la lógica:**

```
1. Verificar si el email ya existe
2. Si existe → Retornar error "Email duplicado"
3. Si no existe:
   a) Encriptar la contraseña
   b) Crear comando INSERT con parámetros seguros
   c) Ejecutar inserción en BD
   d) Obtener ID del nuevo cliente
   e) Retornar ID al cliente
```

### Ejemplo 2: Obtener lista de técnicos con filtros

**En Controlador:**

```csharp
// En ControladorTecnicos
public async Task<IActionResult> ObtenerTecnicos([FromQuery] int? idServicio)
{
    try
    {
        string consulta;
        Dictionary<string, object> parametros;

        if (idServicio.HasValue)
        {
            // Si hay filtro por servicio
            consulta = @"
                SELECT DISTINCT t.id_tecnico, t.nombre, t.email, 
                       t.tarifa_hora, t.calificacion_promedio
                FROM tecnicos t
                INNER JOIN tecnico_servicio ts ON t.id_tecnico = ts.id_tecnico
                WHERE ts.id_servicio = @idServicio
                ORDER BY t.calificacion_promedio DESC
            ";
            parametros = new Dictionary<string, object> { { "idServicio", idServicio } };
        }
        else
        {
            // Sin filtro: obtener todos
            consulta = "SELECT * FROM tecnicos ORDER BY calificacion_promedio DESC";
            parametros = null;
        }

        var tecnicos = await _servicioDatos.EjecutarConsultaAsync(consulta, parametros);
        return Ok(tecnicos);
    }
    catch (Exception ex)
    {
        return StatusCode(500, new { error = ex.Message });
    }
}
```

**Explicación:**

```
1. Si se proporciona filtro de servicio:
   a) Buscar técnicos que ofrecen ese servicio
   b) Usar INNER JOIN con tabla tecnico_servicio
   c) Ordenar por calificación descendente
2. Si no hay filtro:
   a) Obtener todos los técnicos
   b) Ordenar por calificación descendente
3. Retornar lista al cliente
```

### Ejemplo 3: Crear una calificación

**En Controlador:**

```csharp
// En ControladorCalificaciones
public async Task<IActionResult> CrearCalificacion([FromBody] SolicitudCrearCalificacion solicitud)
{
    try
    {
        // Validar que la contratación existe
        var contratacionExistente = await _servicioDatos.EjecutarConsultaAsync(
            "SELECT id_contratacion, id_tecnico FROM contrataciones WHERE id_contratacion = @id",
            new Dictionary<string, object> { { "id", solicitud.IdContratacion } }
        );

        if (contratacionExistente.Count == 0)
            return BadRequest(new { error = "Contratación no encontrada" });

        // Validar que no tenga calificación previa
        var yaCalificado = await _servicioDatos.EjecutarScalarAsync<int>(
            "SELECT COUNT(*) FROM calificaciones WHERE id_contratacion = @id",
            new Dictionary<string, object> { { "id", solicitud.IdContratacion } }
        );

        if (yaCalificado > 0)
            return BadRequest(new { error = "Esta contratación ya fue calificada" });

        // Insertar calificación
        var consultaInsertar = @"
            INSERT INTO calificaciones (id_contratacion, id_tecnico, puntuacion, comentario)
            VALUES (@idContratacion, @idTecnico, @puntuacion, @comentario);
            SELECT LAST_INSERT_ID();
        ";

        var parametros = new Dictionary<string, object>
        {
            { "idContratacion", solicitud.IdContratacion },
            { "idTecnico", solicitud.IdTecnico },
            { "puntuacion", solicitud.Puntuacion },
            { "comentario", solicitud.Comentario ?? "Sin comentarios" }
        };

        var idCalificacion = await _servicioDatos.EjecutarScalarAsync<int>(consultaInsertar, parametros);

        // Actualizar promedio del técnico
        await _servicioDatos.EjecutarComandoAsync(
            @"UPDATE tecnicos SET 
              calificacion_promedio = (SELECT AVG(puntuacion) FROM calificaciones WHERE id_tecnico = @idTecnico),
              num_calificaciones = (SELECT COUNT(*) FROM calificaciones WHERE id_tecnico = @idTecnico)
              WHERE id_tecnico = @idTecnico",
            new Dictionary<string, object> { { "idTecnico", solicitud.IdTecnico } }
        );

        return Ok(new { id_calificacion = idCalificacion });
    }
    catch (Exception ex)
    {
        return StatusCode(500, new { error = ex.Message });
    }
}
```

**Explicación:**

```
1. Validar que la contratación exista
2. Verificar que no haya sido calificada antes
3. Si paso las validaciones:
   a) Insertar registro en tabla calificaciones
   b) Obtener ID de la nueva calificación
   c) Actualizar promedio de calificación del técnico
   d) Recalcular número de calificaciones
4. Retornar ID de la calificación creada
```

---

## MEDIDAS DE SEGURIDAD

### 1. Parámetros en Consultas

**❌ INSEGURO (Inyección SQL):**

```csharp
string consulta = "SELECT * FROM clientes WHERE email = '" + email + "'";
```

Un usuario malintencionado podría usar: `email = "' OR '1'='1`

**✅ SEGURO (Parámetros):**

```csharp
string consulta = "SELECT * FROM clientes WHERE email = @email";
parametros = new Dictionary<string, object> { { "email", email } };
```

### 2. Encriptación de Contraseñas

```csharp
// Cifrar antes de guardar
var contraseniaEncriptada = BCrypt.Net.BCrypt.HashPassword(contraseniaPlana);

// Verificar al hacer inicio de sesión
bool esValido = BCrypt.Net.BCrypt.Verify(contraseniaIngresada, contraseniaEncriptada);
```

### 3. Usando Statements (Liberación de recursos)

```csharp
using (var conexion = ObtenerConexion())
{
    // Garantiza que la conexión se cierre
}
// Aquí la conexión se cerró automáticamente
```

---

# OPERACIONES Y CONSULTAS REALES DEL PROYECTO

Este capítulo documenta las 8 operaciones SQL más importantes que se usan actualmente en SERVITEC, con código real extraído del proyecto.

## OPERACIÓN 1: INSERT - Registrar Cliente (Signup)

**Ubicación:** `backend-csharp/Controllers/AuthService.cs` - Líneas 25-60  
**Tabla:** `clientes`  
**Usuarios afectados:** Cliente (nuevo usuario)  
**Rol requerido:** Público (sin autenticación)

### SQL Puro

```sql
INSERT INTO clientes 
(nombre, email, password_hash, telefono, fecha_registro, es_activo, ubicacion_text, latitud, longitud)
VALUES 
(@nombre, @email, @password_hash, @telefono, NOW(), 1, @ubicacion_text, @latitud, @longitud);
SELECT LAST_INSERT_ID() as id_cliente;
```

### Código C# Real del Proyecto

```csharp
// De: AuthService.cs - RegisterClientAsync()
var query = @"
    INSERT INTO clientes 
    (nombre, email, password_hash, telefono, fecha_registro, es_activo, ubicacion_text, latitud, longitud)
    VALUES 
    (@nombre, @email, @password_hash, @telefono, NOW(), 1, @ubicacion_text, @latitud, @longitud);
    SELECT LAST_INSERT_ID();
";

var parameters = new Dictionary<string, object>
{
    { "nombre", request.FirstName + " " + request.LastName },
    { "email", request.Email },
    { "password_hash", HashPassword(request.Password) },
    { "telefono", request.Phone ?? "" },
    { "ubicacion_text", request.Location ?? "" },
    { "latitud", request.Latitude ?? (object)DBNull.Value },
    { "longitud", request.Longitude ?? (object)DBNull.Value }
};

int clientId = await ExecuteScalarAsync<int>(query, parameters);
```

### Tabla de Parámetros

| Parámetro | Tipo | Obligatorio | Descripción | Ejemplo |
|-----------|------|----------|-------------|---------|
| `@nombre` | VARCHAR(100) | ✅ Sí | Nombre completo | "Juan Pérez" |
| `@email` | VARCHAR(100) | ✅ Sí | Email único | "juan@example.com" |
| `@password_hash` | VARCHAR(255) | ✅ Sí | Contraseña encriptada | BCrypt hash |
| `@telefono` | VARCHAR(15) | ❌ No | Teléfono de contacto | "0987654321" |
| `@ubicacion_text` | VARCHAR(255) | ❌ No | Dirección de texto | "Calle Principal 123" |
| `@latitud` | DECIMAL(10,8) | ❌ No | Coordenada Y | -0.2255 |
| `@longitud` | DECIMAL(11,8) | ❌ No | Coordenada X | -78.5249 |

### Valores que se Insertan Automáticamente

| Campo | Función | Ejemplo |
|-------|---------|---------|
| `fecha_registro` | `NOW()` | 2024-12-15 10:30:45 |
| `es_activo` | `1` | Cliente activo por defecto |
| `id_cliente` | `LAST_INSERT_ID()` | Retorna el ID generado |

### Casos Especiales

```csharp
// ✅ CORRECTO: Email único (hay validación previa)
if (emailYaExiste) 
    return "Error: Email ya registrado";

// ✅ CORRECTO: Contraseña encriptada antes de guardar
string passwordHash = BCrypt.Net.BCrypt.HashPassword(plainPassword);

// ✅ CORRECTO: Ubicación opcional (puede ser NULL)
{ "latitud", latitud ?? (object)DBNull.Value }
```

---

## OPERACIÓN 2: INSERT - Registrar Técnico

**Ubicación:** `backend-csharp/Controllers/AuthService.cs` - Líneas 76-130  
**Tabla:** `tecnicos`  
**Usuarios afectados:** Técnico (nuevo usuario)  
**Rol requerido:** Público (sin autenticación)

### SQL Puro

```sql
INSERT INTO tecnicos 
(nombre, email, password_hash, telefono, tarifa_hora, calificacion_promedio, 
 experiencia_years, ubicacion_text, latitud, longitud, fecha_registro, es_activo)
VALUES 
(@nombre, @email, @password_hash, @telefono, @tarifa_hora, 0, 
 @experiencia_years, @ubicacion_text, @latitud, @longitud, NOW(), 1);
SELECT LAST_INSERT_ID() as id_tecnico;
```

### Código C# Real del Proyecto

```csharp
// De: AuthService.cs - RegisterTechnicianAsync()
var query = @"
    INSERT INTO tecnicos 
    (nombre, email, password_hash, telefono, tarifa_hora, calificacion_promedio, 
     experiencia_years, ubicacion_text, latitud, longitud, fecha_registro, es_activo)
    VALUES 
    (@nombre, @email, @password_hash, @telefono, @tarifa_hora, 0, 
     @experiencia_years, @ubicacion_text, @latitud, @longitud, NOW(), 1);
    SELECT LAST_INSERT_ID();
";

var parameters = new Dictionary<string, object>
{
    { "nombre", request.FirstName + " " + request.LastName },
    { "email", request.Email },
    { "password_hash", HashPassword(request.Password) },
    { "telefono", request.Phone ?? "" },
    { "tarifa_hora", request.HourlyRate },
    { "experiencia_years", request.ExperienceYears },
    { "ubicacion_text", request.Location ?? "" },
    { "latitud", request.Latitude ?? (object)DBNull.Value },
    { "longitud", request.Longitude ?? (object)DBNull.Value }
};

int technicianId = await ExecuteScalarAsync<int>(query, parameters);
```

### Tabla de Parámetros

| Parámetro | Tipo | Obligatorio | Descripción | Ejemplo |
|-----------|------|----------|-------------|---------|
| `@nombre` | VARCHAR(100) | ✅ Sí | Nombre completo | "Carlos Técnico" |
| `@email` | VARCHAR(100) | ✅ Sí | Email único | "carlos@example.com" |
| `@password_hash` | VARCHAR(255) | ✅ Sí | Contraseña encriptada | BCrypt hash |
| `@telefono` | VARCHAR(15) | ❌ No | Teléfono de contacto | "0987654321" |
| `@tarifa_hora` | DECIMAL(8,2) | ✅ Sí | Precio por hora | 25.50 |
| `@experiencia_years` | INT | ✅ Sí | Años de experiencia | 5 |
| `@ubicacion_text` | VARCHAR(255) | ❌ No | Dirección de texto | "Avenida Siete 456" |
| `@latitud` | DECIMAL(10,8) | ❌ No | Coordenada Y | -0.2255 |
| `@longitud` | DECIMAL(11,8) | ❌ No | Coordenada X | -78.5249 |

### Valores que se Insertan Automáticamente

| Campo | Función | Razón |
|-------|---------|-------|
| `calificacion_promedio` | `0` | Técnico nuevo sin calificaciones |
| `fecha_registro` | `NOW()` | Timestamp del registro |
| `es_activo` | `1` | Técnico activo por defecto |
| `id_tecnico` | `LAST_INSERT_ID()` | ID generado automáticamente |

---

## OPERACIÓN 3: SELECT - Obtener Perfil de Cliente

**Ubicación:** `backend-csharp/Controllers/ApiController.cs` - Líneas 88-101  
**Tabla:** `clientes`  
**Usuarios afectados:** Cliente (su propio perfil)  
**Rol requerido:** Cliente autenticado

### SQL Puro

```sql
SELECT 
    id_cliente, nombre, email, telefono, 
    ubicacion_text, latitud, longitud, 
    fecha_registro, es_activo
FROM clientes 
WHERE id_cliente = @id;
```

### Código C# Real del Proyecto

```csharp
// De: ApiController.cs - GetClientProfile()
var results = await _db.ExecuteQueryAsync(
    @"SELECT id_cliente, nombre, email, telefono, 
             ubicacion_text, latitud, longitud, 
             fecha_registro, es_activo
      FROM clientes 
      WHERE id_cliente = @id",
    new Dictionary<string, object> { { "id", clientId } }
);

if (results.Count == 0)
    return NotFound();

var clientProfile = results[0];
return Ok(clientProfile);
```

### Campos Retornados

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id_cliente` | INT | ID único del cliente |
| `nombre` | VARCHAR(100) | Nombre completo |
| `email` | VARCHAR(100) | Email registrado |
| `telefono` | VARCHAR(15) | Teléfono de contacto |
| `ubicacion_text` | VARCHAR(255) | Dirección en texto |
| `latitud` | DECIMAL(10,8) | Coordenada Y |
| `longitud` | DECIMAL(11,8) | Coordenada X |
| `fecha_registro` | DATETIME | Cuándo se registró |
| `es_activo` | TINYINT | 1=Activo, 0=Inactivo |

### Respuesta JSON Ejemplo

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

## OPERACIÓN 4: SELECT - Listar Técnicos con Filtro

**Ubicación:** `backend-csharp/Controllers/ApiController.cs` - Líneas 182-207  
**Tabla:** `tecnicos`, `tecnico_servicio`, `servicios`  
**Usuarios afectados:** Cliente (para buscar técnicos)  
**Rol requerido:** Cliente autenticado

### SQL Puro

```sql
SELECT 
    t.id_tecnico, t.nombre, t.email, t.tarifa_hora, 
    t.calificacion_promedio, t.latitud, t.longitud, 
    t.experiencia_years, t.ubicacion_text
FROM tecnicos t
WHERE es_activo = 1
  AND (
    @latitud IS NULL 
    OR SQRT(POW(latitud - @latitud, 2) + POW(longitud - @longitud, 2)) <= @radio
  )
  AND (@servicio IS NULL 
    OR EXISTS (
      SELECT 1 FROM tecnico_servicio ts 
      INNER JOIN servicios s ON ts.id_servicio = s.id_servicio
      WHERE ts.id_tecnico = t.id_tecnico 
      AND s.id_servicio = @servicio
    )
  )
ORDER BY t.calificacion_promedio DESC, t.tarifa_hora ASC
LIMIT @limit OFFSET @offset;
```

### Código C# Real del Proyecto

```csharp
// De: ApiController.cs - GetTechnicians()
string query = @"
    SELECT t.id_tecnico, t.nombre, t.email, t.tarifa_hora, 
           t.calificacion_promedio, t.latitud, t.longitud, 
           t.experiencia_years, t.ubicacion_text
    FROM tecnicos t
    WHERE es_activo = 1
";

var parameters = new Dictionary<string, object>();

// Filtro por servicio
if (serviceId.HasValue)
{
    query += @"
        AND EXISTS (
            SELECT 1 FROM tecnico_servicio ts 
            INNER JOIN servicios s ON ts.id_servicio = s.id_servicio
            WHERE ts.id_tecnico = t.id_tecnico 
            AND s.id_servicio = @servicio
        )
    ";
    parameters["servicio"] = serviceId.Value;
}

// Ordenar por calificación y tarifa
query += @"
    ORDER BY t.calificacion_promedio DESC, t.tarifa_hora ASC
    LIMIT @limit OFFSET @offset
";

parameters["limit"] = limit ?? 10;
parameters["offset"] = offset ?? 0;

var results = await _db.ExecuteQueryAsync(query, parameters);
return Ok(results);
```

### Parámetros de Filtro

| Parámetro | Tipo | Obligatorio | Descripción |
|-----------|------|----------|-------------|
| `@servicio` | INT | ❌ No | Filtrar por ID de servicio |
| `@limit` | INT | ❌ No (Default: 10) | Cantidad de registros |
| `@offset` | INT | ❌ No (Default: 0) | Página de resultados |

### Campos Retornados

| Campo | Descripción |
|-------|-------------|
| `id_tecnico` | ID único del técnico |
| `nombre` | Nombre completo |
| `email` | Email de contacto |
| `tarifa_hora` | Precio por hora de trabajo |
| `calificacion_promedio` | Rating 1-5 (promedio) |
| `latitud` | Coordenada Y |
| `longitud` | Coordenada X |
| `experiencia_years` | Años de experiencia |
| `ubicacion_text` | Dirección en texto |

### Respuesta JSON Ejemplo

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

## OPERACIÓN 5: UPDATE - Actualizar Perfil de Cliente

**Ubicación:** `backend-csharp/Controllers/ApiController.cs` - Líneas 104-157  
**Tabla:** `clientes`  
**Usuarios afectados:** Cliente (su propio perfil)  
**Rol requerido:** Cliente autenticado

### SQL Puro (Ejemplo con todos los campos)

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

### Código C# Real del Proyecto

```csharp
// De: ApiController.cs - UpdateClientProfile()
var updates = new List<string>();
var parameters = new Dictionary<string, object> { { "id", clientId } };

if (!string.IsNullOrEmpty(req.FirstName))
{
    updates.Add("nombre = @nombre");
    parameters["nombre"] = req.FirstName;
}
if (!string.IsNullOrEmpty(req.Email))
{
    updates.Add("email = @email");
    parameters["email"] = req.Email;
}
if (!string.IsNullOrEmpty(req.Phone))
{
    updates.Add("telefono = @telefono");
    parameters["telefono"] = req.Phone;
}
if (req.Latitude.HasValue)
{
    updates.Add("latitud = @latitud");
    parameters["latitud"] = req.Latitude;
}
if (req.Longitude.HasValue)
{
    updates.Add("longitud = @longitud");
    parameters["longitud"] = req.Longitude;
}
if (!string.IsNullOrEmpty(req.Password))
{
    updates.Add("password_hash = @password_hash");
    parameters["password_hash"] = HashPassword(req.Password);
}

if (updates.Count == 0)
    return BadRequest(new { error = "No fields to update" });

updates.Add("updated_at = NOW()");

var query = $"UPDATE clientes SET {string.Join(", ", updates)} WHERE id_cliente = @id";
await _db.ExecuteNonQueryAsync(query, parameters);
```

### Característica: Actualización Selectiva

Este UPDATE es inteligente: **solo actualiza los campos que se envían en la solicitud**.

```csharp
// Si el cliente solo envía:
{ "email": "nuevo@example.com" }

// Se ejecuta:
UPDATE clientes 
SET email = @email, updated_at = NOW() 
WHERE id_cliente = @id;

// ✅ Los otros campos NO cambian
```

### Ejemplo de Solicitud y Respuesta

**Request (PUT /api/clients/1):**
```json
{
  "firstName": "Juan Carlos",
  "email": "juancarlos@example.com",
  "phone": "0999999999",
  "latitude": -0.2255,
  "longitude": -78.5249
}
```

**Response:**
```json
{
  "message": "Client updated successfully"
}
```

---

## OPERACIÓN 6: SELECT - Login (Obtener Datos Usuario)

**Ubicación:** `backend-csharp/Controllers/AuthService.cs` - Líneas 185-205  
**Tabla:** `clientes` o `tecnicos`  
**Usuarios afectados:** Cualquier usuario (login)  
**Rol requerido:** Sin autenticación (login público)

### SQL Puro

```sql
-- Para Cliente:
SELECT id_cliente, nombre, email, password_hash, rol
FROM clientes 
WHERE email = @email AND es_activo = 1;

-- Para Técnico:
SELECT id_tecnico, nombre, email, password_hash, rol
FROM tecnicos 
WHERE email = @email AND es_activo = 1;
```

### Código C# Real del Proyecto

```csharp
// De: AuthService.cs - LoginAsync()
public async Task<object?> LoginAsync(string email, string password, string userType)
{
    try
    {
        string query = userType == "technician"
            ? @"SELECT id_tecnico as id, nombre, email, password_hash, 'technician' as rol
               FROM tecnicos 
               WHERE email = @email AND es_activo = 1"
            : @"SELECT id_cliente as id, nombre, email, password_hash, 'client' as rol
               FROM clientes 
               WHERE email = @email AND es_activo = 1";

        var parameters = new Dictionary<string, object> { { "email", email } };
        var results = await ExecuteQueryAsync(query, parameters);

        if (results.Count == 0)
            return null; // Usuario no encontrado

        var user = results[0];
        string storedHash = user["password_hash"].ToString() ?? "";

        // Verificar contraseña
        if (!VerifyPassword(password, storedHash))
            return null; // Contraseña incorrecta

        return new
        {
            id = user["id"],
            nombre = user["nombre"],
            email = user["email"],
            rol = user["rol"]
        };
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error in Login: {ex.Message}");
        return null;
    }
}
```

### Flujo de Validación

```
1. Usuario envía email y contraseña
   ↓
2. SELECT busca usuario con ese email y es_activo = 1
   ↓
3. Si NO existe → return null (Credenciales inválidas)
   ↓
4. Si existe → Verifica BCrypt.Verify(inputPassword, passwordHash)
   ↓
5. Si NO coincide → return null (Credenciales inválidas)
   ↓
6. Si coincide → return { id, nombre, email, rol }
```

### Respuesta JSON Exitosa

```json
{
  "id": 1,
  "nombre": "Juan Pérez",
  "email": "juan@example.com",
  "rol": "client"
}
```

---

## OPERACIÓN 7: INSERT - Crear Contratación

**Ubicación:** `backend-csharp/Controllers/ApiController.cs` - Líneas 395-451  
**Tabla:** `contrataciones`  
**Usuarios afectados:** Cliente (crea la solicitud), Técnico (recibe la solicitud)  
**Rol requerido:** Cliente autenticado

### SQL Puro

```sql
INSERT INTO contrataciones 
(id_cliente, id_tecnico, id_servicio, detalles, fecha_solicitud, fecha_programada, estado)
VALUES 
(@client, @tech, @service, @desc, NOW(), @fecha_programada, 'Pendiente');

SELECT LAST_INSERT_ID() as id_contratacion;
```

### Código C# Real del Proyecto

```csharp
// De: ContractionsController - CreateContraction()
var query = @"
    INSERT INTO contrataciones 
    (id_cliente, id_tecnico, id_servicio, detalles, fecha_solicitud, fecha_programada, estado)
    VALUES 
    (@client, @tech, @service, @desc, NOW(), @fecha_programada, 'Pendiente');
    SELECT LAST_INSERT_ID();
";

var parameters = new Dictionary<string, object>
{
    { "client", req.ClientId },
    { "tech", req.TechnicianId ?? 0 },
    { "service", req.ServiceId },
    { "desc", req.Description ?? "" },
    { "fecha_programada", req.ScheduledDate ?? (object)DBNull.Value }
};

// Validaciones previas
if (clientNotExists) return BadRequest("Client does not exist");
if (serviceNotExists) return BadRequest("Service does not exist");
if (technicianId.HasValue && technicianNotExists) 
    return BadRequest("Technician does not exist");

int id = await _db.ExecuteScalarAsync<int>(query, parameters);
return Ok(new { id_contratacion = id, estado = "Pendiente" });
```

### Tabla de Parámetros

| Parámetro | Tipo | Obligatorio | Descripción |
|-----------|------|----------|-------------|
| `@client` | INT | ✅ Sí | ID del cliente (FK) |
| `@tech` | INT | ❌ No | ID del técnico (0 si no especifica) |
| `@service` | INT | ✅ Sí | ID del servicio (FK) |
| `@desc` | VARCHAR(500) | ❌ No | Descripción de la solicitud |
| `@fecha_programada` | DATETIME | ❌ No | Cuándo se desea el servicio |

### Ejemplo de Solicitud

```json
{
  "clientId": 1,
  "technicianId": 5,
  "serviceId": 3,
  "description": "Reparación de aire acondicionado",
  "scheduledDate": "2024-12-20T10:00:00"
}
```

### Respuesta

```json
{
  "id_contratacion": 42,
  "estado": "Pendiente"
}
```

---

## OPERACIÓN 8: SELECT - Listar Contrataciones de Cliente

**Ubicación:** `backend-csharp/Controllers/ApiController.cs` - Líneas 454-471  
**Tabla:** `contrataciones`, `servicios`, `tecnicos`  
**Usuarios afectados:** Cliente (ve sus propias contrataciones)  
**Rol requerido:** Cliente autenticado

### SQL Puro

```sql
SELECT 
    c.id_contratacion, c.id_cliente, c.id_tecnico, c.id_servicio,
    c.detalles, c.fecha_solicitud, c.fecha_programada, c.estado,
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

### Código C# Real del Proyecto

```csharp
// De: ContractionsController - GetContractionsByClient()
var query = @"
    SELECT c.*, s.nombre as service_name, t.nombre as technician_name, 
           t.email as technician_email, t.id_tecnico
    FROM contrataciones c
    JOIN servicios s ON c.id_servicio = s.id_servicio
    LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico
    WHERE c.id_cliente = @cliente
    ORDER BY c.fecha_solicitud DESC
";

var results = await _db.ExecuteQueryAsync(query, 
    new Dictionary<string, object> { { "cliente", clientId } });

return Ok(results);
```

### Campos Retornados

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id_contratacion` | INT | ID única de la contratación |
| `id_cliente` | INT | Cliente que solicita |
| `id_tecnico` | INT | Técnico asignado (puede ser NULL) |
| `id_servicio` | INT | Servicio solicitado |
| `detalles` | VARCHAR(500) | Descripción de la solicitud |
| `fecha_solicitud` | DATETIME | Cuándo se creó |
| `fecha_programada` | DATETIME | Cuándo se desea (puede ser NULL) |
| `estado` | VARCHAR(20) | "Pendiente", "Asignado", "En Progreso", "Completado" |
| `service_name` | VARCHAR(100) | Nombre del servicio (JOIN) |
| `technician_name` | VARCHAR(100) | Nombre del técnico (LEFT JOIN) |
| `technician_email` | VARCHAR(100) | Email del técnico (LEFT JOIN) |

### Respuesta JSON Ejemplo

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
    "technician_email": "carlos@example.com",
    "id_tecnico": 5
  }
]
```

---

## TABLA COMPARATIVA: LAS 8 OPERACIONES

| # | Operación | SQL | Tabla | Retorna | Línea |
|---|-----------|-----|-------|---------|-------|
| 1 | INSERT Cliente | `INSERT` | `clientes` | `id_cliente` | AuthService 25-60 |
| 2 | INSERT Técnico | `INSERT` | `tecnicos` | `id_tecnico` | AuthService 76-130 |
| 3 | SELECT Perfil Cliente | `SELECT` | `clientes` | Datos usuario | ApiController 88-101 |
| 4 | SELECT Técnicos | `SELECT` | `tecnicos` + JOIN | Lista técnicos | ApiController 182-207 |
| 5 | UPDATE Perfil Cliente | `UPDATE` | `clientes` | OK message | ApiController 104-157 |
| 6 | SELECT Login | `SELECT` | `clientes`/`tecnicos` | Auth token data | AuthService 185-205 |
| 7 | INSERT Contratación | `INSERT` | `contrataciones` | `id_contratacion` | ContractionsController 395 |
| 8 | SELECT Contrataciones | `SELECT` + JOIN | `contrataciones`+`servicios`+`tecnicos` | Lista contratos | ContractionsController 454 |

---

## CONCLUSIÓN

El script de conexión ADO.NET en SERVITEC proporciona:

✅ **Seguridad**: Parámetros previenen inyecciones SQL  
✅ **Eficiencia**: Reutilización de conexiones  
✅ **Mantenibilidad**: Centralización de lógica de acceso a datos  
✅ **Escalabilidad**: Fácil agregar nuevas operaciones  
✅ **Confiabilidad**: Manejo de excepciones y recursos  

El sistema está listo para producción con todas las mejores prácticas de seguridad e implementación de ADO.NET.
