# 2.1 SCRIPTS — Script de Conexión ADO.NET

Documentación del módulo de conexión a la base de datos MySQL usando ADO.NET en C#.

---

## ¿Qué explicar en esta sección?

Esta sección documenta cómo se realiza la **conectividad a la base de datos** desde C#. Debes explicar:

1. **Clase DatabaseService.cs**: Módulo centralizado para todas las operaciones de base de datos
2. **Métodos principales**: Cómo se conecta, cómo se ejecutan consultas SELECT/INSERT/UPDATE/DELETE
3. **Manejo de parámetros**: Cómo se previene SQL injection usando parámetros nombrados
4. **Ejemplos de uso**: Consultas reales del proyecto (CRUD operations)

---

## Archivo Principal: DatabaseService.cs

**Ubicación**: `backend-csharp/Services/DatabaseService.cs`

**Propósito**: Centralizar toda la lógica de conexión y ejecución de consultas a MySQL.

### Estructura completa de DatabaseService.cs

```csharp
using MySql.Data.MySqlClient;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;

namespace ServitecAPI.Services
{
    public class ServicioBaseDatos
    {
        private readonly string _cadenaConexion;

        // Constructor: Lee la cadena de conexión desde appsettings.json
        public ServicioBaseDatos(IConfiguration configuracion)
        {
            _cadenaConexion = configuracion.GetConnectionString("ConexionPrincipal")
                ?? throw new InvalidOperationException("No se encontró la cadena de conexión ConexionPrincipal");
        }

        // Método 1: Obtener una conexión abierta a la base de datos
        public MySqlConnection ObtenerConexion()
        {
            return new MySqlConnection(_cadenaConexion);
        }

        // Método 2: Ejecutar una consulta SELECT (retorna lista de registros)
        public async Task<List<Dictionary<string, object>>> EjecutarConsultaAsync(
            string consulta, 
            Dictionary<string, object>? parametros = null)
        {
            var resultados = new List<Dictionary<string, object>>();
            
            using (var conexion = ObtenerConexion())
            {
                await conexion.OpenAsync();
                using (var comando = new MySqlCommand(consulta, conexion))
                {
                    // Añadir parámetros si existen (previene inyección SQL)
                    if (parametros != null)
                    {
                        foreach (var param in parametros)
                        {
                            comando.Parameters.AddWithValue($"@{param.Key}", param.Value ?? DBNull.Value);
                        }
                    }

                    using (var lector = await comando.ExecuteReaderAsync())
                    {
                        while (await lector.ReadAsync())
                        {
                            var fila = new Dictionary<string, object>();
                            for (int i = 0; i < lector.FieldCount; i++)
                            {
                                fila[lector.GetName(i)] = lector.GetValue(i);
                            }
                            resultados.Add(fila);
                        }
                    }
                }
            }
            
            return resultados;
        }

        // Método 3: Ejecutar INSERT/UPDATE/DELETE (retorna número de filas afectadas)
        public async Task<int> EjecutarNoConsultaAsync(
            string consulta, 
            Dictionary<string, object>? parametros = null)
        {
            using (var conexion = ObtenerConexion())
            {
                await conexion.OpenAsync();
                using (var comando = new MySqlCommand(consulta, conexion))
                {
                    // Añadir parámetros
                    if (parametros != null)
                    {
                        foreach (var param in parametros)
                        {
                            comando.Parameters.AddWithValue($"@{param.Key}", param.Value ?? DBNull.Value);
                        }
                    }

                    return await comando.ExecuteNonQueryAsync();
                }
            }
        }

        // Método 4: Ejecutar una consulta que retorna un solo valor (ej: COUNT, LAST_INSERT_ID)
        public async Task<T?> EjecutarEscalarAsync<T>(
            string consulta, 
            Dictionary<string, object>? parametros = null)
        {
            using (var conexion = ObtenerConexion())
            {
                await conexion.OpenAsync();
                using (var comando = new MySqlCommand(consulta, conexion))
                {
                    // Añadir parámetros
                    if (parametros != null)
                    {
                        foreach (var param in parametros)
                        {
                            comando.Parameters.AddWithValue($"@{param.Key}", param.Value ?? DBNull.Value);
                        }
                    }

                    var resultado = await comando.ExecuteScalarAsync();
                    
                    if (resultado == null || resultado == DBNull.Value)
                        return default;

                    return (T?)Convert.ChangeType(resultado, typeof(T));
                }
            }
        }
    }
}
```

---

## Explicación de cada método

### Método 1: ObtenerConexion()

```csharp
public MySqlConnection ObtenerConexion()
{
    return new MySqlConnection(_cadenaConexion);
}
```

**Qué hace**: Retorna una nueva conexión a la base de datos.

**Cuándo se usa**: Internamente en los otros métodos. No se usa directamente en los controllers.

**Ventaja**: Centraliza la cadena de conexión en un solo lugar (appsettings.json).

---

### Método 2: EjecutarConsultaAsync() — SELECT

```csharp
public async Task<List<Dictionary<string, object>>> EjecutarConsultaAsync(
    string consulta, 
    Dictionary<string, object>? parametros = null)
```

**Qué hace**: Ejecuta una consulta SELECT y retorna una lista de registros.

**Parámetros**:
- `consulta`: La consulta SQL (ej: `"SELECT * FROM tecnicos WHERE id_tecnico = @id"`)
- `parametros`: Diccionario con valores (ej: `new Dictionary<string, object> { { "id", 5 } }`)

**Retorna**: `List<Dictionary<string, object>>` — cada diccionario es un registro con columna → valor

**Ejemplo de uso**:

```csharp
// Obtener todos los técnicos
var consulta = "SELECT id_tecnico, nombre, email, calificacion_promedio FROM tecnicos";
var tecnicos = await _bd.EjecutarConsultaAsync(consulta);

foreach (var tecnico in tecnicos)
{
    Console.WriteLine($"ID: {tecnico["id_tecnico"]}, Nombre: {tecnico["nombre"]}");
}
```

**Con parámetros (previene inyección SQL)**:

```csharp
// Obtener un técnico específico
var consulta = "SELECT * FROM tecnicos WHERE id_tecnico = @id";
var parametros = new Dictionary<string, object> { { "id", 5 } };
var resultado = await _bd.EjecutarConsultaAsync(consulta, parametros);

if (resultado.Count > 0)
{
    var tecnico = resultado[0];
    Console.WriteLine($"Técnico encontrado: {tecnico["nombre"]}");
}
```

---

### Método 3: EjecutarNoConsultaAsync() — INSERT/UPDATE/DELETE

```csharp
public async Task<int> EjecutarNoConsultaAsync(
    string consulta, 
    Dictionary<string, object>? parametros = null)
```

**Qué hace**: Ejecuta INSERT, UPDATE o DELETE. Retorna el número de filas afectadas.

**Parámetros**:
- `consulta`: La consulta SQL
- `parametros`: Valores para los placeholders

**Retorna**: `int` — número de filas modificadas

**Ejemplo: INSERT**

```csharp
var consulta = @"
    INSERT INTO tecnicos (nombre, email, tarifa_hora, calificacion_promedio, latitud, longitud)
    VALUES (@nombre, @email, @tarifa, @calificacion, @lat, @lon)
";

var parametros = new Dictionary<string, object>
{
    { "nombre", "Juan Pérez" },
    { "email", "juan@example.com" },
    { "tarifa", 50.0 },
    { "calificacion", 0.0 },
    { "lat", -12.0464 },
    { "lon", -77.0428 }
};

int filasAfectadas = await _bd.EjecutarNoConsultaAsync(consulta, parametros);
Console.WriteLine($"Registros insertados: {filasAfectadas}");
```

**Ejemplo: UPDATE**

```csharp
var consulta = "UPDATE tecnicos SET calificacion_promedio = @calificacion WHERE id_tecnico = @id";

var parametros = new Dictionary<string, object>
{
    { "calificacion", 4.8 },
    { "id", 5 }
};

int filasAfectadas = await _bd.EjecutarNoConsultaAsync(consulta, parametros);
Console.WriteLine($"Registros actualizados: {filasAfectadas}");
```

**Ejemplo: DELETE**

```csharp
var consulta = "DELETE FROM tecnicos WHERE id_tecnico = @id";

var parametros = new Dictionary<string, object> { { "id", 5 } };

int filasAfectadas = await _bd.EjecutarNoConsultaAsync(consulta, parametros);
Console.WriteLine($"Registros eliminados: {filasAfectadas}");
```

---

### Método 4: EjecutarEscalarAsync<T>() — SELECT de un solo valor

```csharp
public async Task<T?> EjecutarEscalarAsync<T>(
    string consulta, 
    Dictionary<string, object>? parametros = null)
```

**Qué hace**: Ejecuta una consulta que retorna un solo valor (número, texto, fecha, etc.).

**Parámetros**:
- `consulta`: La consulta SQL
- `parametros`: Valores para placeholders

**Retorna**: `T?` — el valor en el tipo genérico especificado

**Ejemplo: Obtener el ID del último registro insertado**

```csharp
var consulta = "SELECT LAST_INSERT_ID()";
int ultimoId = await _bd.EjecutarEscalarAsync<int>(consulta);
Console.WriteLine($"Último ID insertado: {ultimoId}");
```

**Ejemplo: Contar registros**

```csharp
var consulta = "SELECT COUNT(*) FROM tecnicos WHERE calificacion_promedio > @calificacion";

var parametros = new Dictionary<string, object> { { "calificacion", 4.0 } };

int cantidad = await _bd.EjecutarEscalarAsync<int>(consulta, parametros);
Console.WriteLine($"Técnicos con calificación > 4.0: {cantidad}");
```

**Ejemplo: Obtener el email de un técnico**

```csharp
var consulta = "SELECT email FROM tecnicos WHERE id_tecnico = @id";

var parametros = new Dictionary<string, object> { { "id", 5 } };

string? correo = await _bd.EjecutarEscalarAsync<string>(consulta, parametros);
Console.WriteLine($"Correo: {correo}");
```

---

## Integración en Program.cs

Para que `ServicioBaseDatos` esté disponible en los controllers, debes registrarlo como servicio:

**Archivo**: `backend-csharp/Program.cs`

```csharp
using ServitecAPI.Services;

var constructor = WebApplicationBuilder.CreateBuilder(args);

// Registrar ServicioBaseDatos como singleton
constructor.Services.AddSingleton<ServicioBaseDatos>();

var aplicacion = constructor.Build();

aplicacion.MapGet("/api/salud", async (ServicioBaseDatos bd) =>
{
    try
    {
        // Verificar que la conexión a la BD funciona
        var resultado = await bd.EjecutarEscalarAsync<string>("SELECT 'OK'");
        return Results.Ok(new { estado = "API Servitec funcionando correctamente" });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { error = ex.Message });
    }
});

aplicacion.Run();
```

---

## Flujo completo: Ejemplo práctico

### Caso de uso: Registrar un nuevo técnico

**Paso 1: Crear un DTO (Data Transfer Object)**

```csharp
public class CreateTechnicianRequest
{
    public string Nombre { get; set; }
    public string Email { get; set; }
    public double TarifaHora { get; set; }
    public double Latitud { get; set; }
    public double Longitud { get; set; }
}
```

**Paso 2: Crear un endpoint (Controller)**

```csharp
app.MapPost("/api/technicians", async (CreateTechnicianRequest req, DatabaseService db) =>
{
    try
    {
        // 1. Validar datos
        if (string.IsNullOrEmpty(req.Nombre) || string.IsNullOrEmpty(req.Email))
            return Results.BadRequest("Nombre y email son requeridos");

        // 2. Insertar en la BD
        var query = @"
            INSERT INTO tecnicos (nombre, email, tarifa_hora, calificacion_promedio, latitud, longitud)
            VALUES (@nombre, @email, @tarifa, @calificacion, @lat, @lon)
        ";

        var parameters = new Dictionary<string, object>
        {
            { "nombre", req.Nombre },
            { "email", req.Email },
            { "tarifa", req.TarifaHora },
            { "calificacion", 0.0 },
            { "lat", req.Latitud },
            { "lon", req.Longitud }
        };

        await db.ExecuteNonQueryAsync(query, parameters);

        // 3. Obtener el ID del técnico creado
        int technicianId = await db.ExecuteScalarAsync<int>("SELECT LAST_INSERT_ID()");

        // 4. Retornar respuesta
        return Results.Created($"/api/technicians/{technicianId}", 
            new { id_tecnico = technicianId, nombre = req.Nombre });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { error = ex.Message });
    }
});
```

---

## Tabla de métodos disponibles

| Método | Propósito | Retorna | Ejemplo |
|--------|-----------|---------|---------|
| `GetConnection()` | Obtener conexión | `MySqlConnection` | `var conn = db.GetConnection();` |
| `ExecuteQueryAsync()` | SELECT (múltiples registros) | `List<Dictionary<string, object>>` | `var rows = await db.ExecuteQueryAsync("SELECT * FROM tecnicos");` |
| `ExecuteNonQueryAsync()` | INSERT/UPDATE/DELETE | `int` (filas afectadas) | `await db.ExecuteNonQueryAsync("DELETE FROM tecnicos WHERE id = @id");` |
| `ExecuteScalarAsync<T>()` | SELECT (un solo valor) | `T?` | `var count = await db.ExecuteScalarAsync<int>("SELECT COUNT(*) FROM tecnicos");` |

---

## Ventajas de este diseño (ADO.NET)

✅ **Centralizado**: Toda la lógica de BD en una clase
✅ **Parametrizado**: Usa `@paramName` para prevenir SQL injection
✅ **Asincrónico**: Usa `async/await` para no bloquear la aplicación
✅ **Flexible**: Acepta cualquier consulta SQL
✅ **Tipos genéricos**: `ExecuteScalarAsync<T>()` retorna el tipo correcto
✅ **Inyección de dependencias**: Se registra en `Program.cs` y se inyecta en controllers

---

## Checklist para la documentación

- [ ] Incluir la clase completa `DatabaseService.cs`
- [ ] Explicar cada uno de los 4 métodos principales
- [ ] Mostrar ejemplos de uso de cada método (SELECT, INSERT, UPDATE, DELETE)
- [ ] Incluir fragmento de `Program.cs` registrando el servicio
- [ ] Mostrar un flujo completo (ejemplo: crear un técnico)
- [ ] Incluir tabla de resumen de métodos
- [ ] Captura: Contenido de `DatabaseService.cs` en el editor
- [ ] Captura: Contenido de `Program.cs` mostrando el registro del servicio

---

## Siguiente paso

Una vez documentado **2.1 SCRIPTS (ADO.NET)**, pasamos a:
- **2.2 SCRIPTS (JDBC)** — Script de conexión en Java
- **2.3 SCRIPTS (ODBC)** — Script de conexión con Python/pyodbc
- **3. INTERFAZ** — Capturas de la UI del aplicativo funcionando
- **4. OPERACIONES** — Ejemplos de CRUD en acción (capturas de INSERT, UPDATE, DELETE, SELECT)
