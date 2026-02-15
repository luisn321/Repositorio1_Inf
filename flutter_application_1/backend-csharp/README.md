# Backend Servitec - C# ADO.NET

Backend REST API en **C# .NET 6+** con **ADO.NET** para conectar a **MySQL**. Reemplaza el backend Node.js anterior.

## 📋 Requisitos

- **.NET 6.0 SDK** (descarga desde https://dotnet.microsoft.com/download)
- **MySQL Server** corriendo (con BD `servitec` creada)
- **Visual Studio Code** o **Visual Studio**

## 🚀 Instalación y Uso

### 1) Restaurar dependencias

```bash
cd backend-csharp
dotnet restore
```

### 2) Configurar conexión MySQL

Edita `appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost;Database=servitec;Uid=root;Pwd=tu_password;Port=3306;"
}
```

Reemplaza `tu_password` con tu contraseña de MySQL.

### 3) Ejecutar el servidor

```bash
dotnet run
```

Verás:

```
🚀 Servidor Servitec (C# ADO.NET) corriendo en puerto 3000
📍 URL: http://localhost:3000
🔗 Health check: http://localhost:3000/api/health
```

### 4) Probar endpoint de salud

```powershell
curl http://localhost:3000/api/health
```

Respuesta esperada:

```json
{"status":"API Servitec funcionando correctamente"}
```

## 📡 Endpoints

Todos los endpoints son **idénticos al backend Node.js**:

| Método | Endpoint | Descripción |
|--------|----------|------------|
| POST | `/api/auth/register/client` | Registrar cliente |
| POST | `/api/auth/register/technician` | Registrar técnico |
| POST | `/api/auth/login` | Login (cliente o técnico) |
| GET | `/api/services` | Listar servicios |
| GET | `/api/technicians` | Listar técnicos |
| GET | `/api/technicians/:id` | Detalle de técnico |
| POST | `/api/contractations` | Crear contratación |
| GET | `/api/contractations/:id` | Detalle de contratación |
| POST | `/api/payments` | Registrar pago |
| POST | `/api/ratings` | Registrar calificación |

## 🔗 Conexión desde Flutter

La app Flutter ya está configurada con `API_BASE_URL = "http://localhost:3000/api"` (web) o `"http://10.0.2.2:3000/api"` (emulador Android).

No necesita cambios — funciona igual que con Node.js.

## 🛠️ Tecnologías Usadas

- **Framework:** ASP.NET Core 6.0
- **Base de datos:** MySQL con ADO.NET (MySql.Data)
- **Autenticación:** JWT (System.IdentityModel.Tokens.Jwt)
- **Hash de contraseñas:** BCrypt.Net-Next

## ⚙️ Configuración Avanzada

### Cambiar puerto

En `Program.cs`, línea final:

```csharp
app.Run("http://localhost:5000"); // Cambiar 3000 a otro puerto
```

### Secreto JWT

Edita `appsettings.json`:

```json
"JWT": {
  "Secret": "tu_clave_secreta_muy_larga_y_segura",
  "ExpiryDays": 30
}
```

## 📝 Ejemplo de Registro

```bash
curl -X POST http://localhost:3000/api/auth/register/client \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan@example.com",
    "password": "password123",
    "telefono": "3001234567",
    "direccionText": "Calle 1, Apartado",
    "lat": 4.7110,
    "lng": -74.0087
  }'
```

Respuesta:

```json
{
  "token": "eyJhbGc...",
  "user_type": "client",
  "id_cliente": 1,
  "email": "juan@example.com",
  "nombre": "Juan"
}
```

## ✅ Ventajas de ADO.NET

- ✅ **Seguridad:** Queries parametrizadas previenen SQL injection
- ✅ **Rendimiento:** Conexiones eficientes a MySQL
- ✅ **Tipado:** Compilación en tiempo de compilación
- ✅ **Mantenibilidad:** Código estructurado y escalable

## 📚 Referencias

- [ADO.NET Docs](https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/)
- [MySql.Data NuGet](https://www.nuget.org/packages/MySql.Data/)
- [ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/)
