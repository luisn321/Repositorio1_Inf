# 1.1 DRIVERS ADO.NET — Descarga, Instalación y Configuración

Documentación del driver ADO.NET (MySQL Connector/NET) para la conectividad a base de datos MySQL en el proyecto Servitec.

---

## Requisitos Previos (antes de instalar ADO.NET)

- ✅ **.NET SDK 10.0** instalado (Descarga: https://dotnet.microsoft.com/download/dotnet/10.0)
- ✅ **MySQL Server 8.0** instalado (Descarga: https://dev.mysql.com/downloads/mysql/)
- ✅ **Visual Studio Code** o **Visual Studio 2022** (Descarga: https://code.visualstudio.com/)

---

## DRIVER: ADO.NET (MySQL Connector/NET)

### 1.1.1 Descarga

**Nombre del driver**: MySQL Connector/NET (MySql.Data)  
**Versión**: 8.0.33 (o superior)  
**Sitio oficial**: https://dev.mysql.com/downloads/connector/net/

**Pasos**:
1. Abre https://dev.mysql.com/downloads/connector/net/
2. Descarga **"MySQL Connector/NET 8.0.33"** (.msi para Windows)
3. Guarda el archivo en tu carpeta de descargas

**CAPTURA 1.1**: Pantalla de descargas de MySQL Connector/NET mostrando la versión 8.0.33

---

### 1.1.2 Instalación

**Requisitos previos** (ya verificados arriba):
- .NET SDK 10.0 ✓
- Visual Studio o VS Code ✓

**Paso 1: Crear el proyecto C# (ServitecAPI)**

Abre PowerShell y ejecuta:

```powershell
cd "c:\Users\Luis Infante\Desktop\5TO SEMESTRE\Taller de base de datos\Unidad 6\AppServTrabajo\flutter_application_1"

# Crear proyecto ASP.NET Core web
dotnet new web -n backend-csharp -f net10.0

# Entrar a la carpeta del proyecto
cd backend-csharp
```

**CAPTURA 1.2a**: PowerShell mostrando la ejecución de `dotnet new web -n backend-csharp -f net10.0`

Salida esperada:
```
The template "ASP.NET Core Empty" was created successfully.
Processing post-creation actions...
Restoring C:\...\backend-csharp\backend-csharp.csproj...
  Determining projects to restore...
  Restored C:\...\backend-csharp\backend-csharp.csproj in 5.23 sec.
```

**CAPTURA 1.2b**: Carpeta `backend-csharp` creada mostrando el archivo `backend-csharp.csproj`

---

**Paso 2: Instalar el driver MySQL via NuGet**

Dentro de la carpeta `backend-csharp`, ejecuta:

```powershell
dotnet add package MySql.Data --version 8.0.33
```

**CAPTURA 1.2c**: PowerShell mostrando la instalación vía NuGet (salida completa del comando)

Salida esperada:
```
  Writing C:\...\backend-csharp.csproj
  info : Adding PackageReference for package 'MySql.Data' into project...
  info : Restoring packages for C:\...\backend-csharp\backend-csharp.csproj...
  info : Package 'MySql.Data' is compatible with all the frameworks...
  info : PackageReference for package 'MySql.Data' version '8.0.33' added to file 'backend-csharp.csproj'.
```

**CAPTURA 1.2d**: Archivo `backend-csharp.csproj` mostrando la línea:
```xml
<ItemGroup>
    <PackageReference Include="MySql.Data" Version="8.0.33" />
</ItemGroup>
```

---

**Paso 3: Restaurar las dependencias**

```powershell
dotnet restore
```

**CAPTURA 1.2e**: PowerShell mostrando `dotnet restore` completado exitosamente

Salida esperada:
```
  Determining projects to restore...
  Restored C:\...\backend-csharp.csproj in X.XX sec
```

---

### 1.1.3 Configuración

**Archivo de configuración**: `appsettings.json`  
**Ubicación**: `backend-csharp/appsettings.json`

**Estructura de la cadena de conexión** (Connection String):

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=servitec;Uid=root;Pwd=tu_password;Port=3306;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information"
    }
  }
}
```

**Parámetros**:
- `Server`: localhost (o IP del servidor MySQL)
- `Database`: servitec (nombre de la BD)
- `Uid`: root (usuario de MySQL)
- `Pwd`: tu_password (contraseña de root, configurada durante la instalación de MySQL)
- `Port`: 3306 (puerto por defecto de MySQL)

**CAPTURA 1.4**: Archivo `appsettings.json` mostrando la ConnectionString completa

**CAPTURA 1.5**: Archivo `DatabaseService.cs` mostrando la línea donde se lee la ConnectionString:
```csharp
private readonly string _connectionString;

public DatabaseService(IConfiguration configuration)
{
    _connectionString = configuration.GetConnectionString("DefaultConnection")
        ?? throw new InvalidOperationException("No se encontró la cadena de conexión DefaultConnection");
}
```

---

### 1.1.4 Verificación

Ejecuta el backend y verifica que se conecta:

```powershell
cd backend-csharp
dotnet run
```

**CAPTURA 1.6**: PowerShell mostrando el backend ejecutándose con mensaje de éxito:
```
🚀 Servidor Servitec (C# ADO.NET) corriendo en puerto 3000
📍 URL: http://localhost:3000
🔗 Health check: http://localhost:3000/api/health
```

---

## CHECKLIST — Capturas a entregar (Sección 1.1 ADO.NET)

- [ ] **CAPTURA 1.1**: Descarga de MySQL Connector/NET 8.0.33
- [ ] **CAPTURA 1.2a**: PowerShell ejecutando `dotnet new web -n backend-csharp -f net10.0`
- [ ] **CAPTURA 1.2b**: Carpeta `backend-csharp` creada mostrando `backend-csharp.csproj`
- [ ] **CAPTURA 1.2c**: PowerShell ejecutando `dotnet add package MySql.Data --version 8.0.33`
- [ ] **CAPTURA 1.2d**: Archivo `backend-csharp.csproj` mostrando la línea `<PackageReference Include="MySql.Data"...`
- [ ] **CAPTURA 1.2e**: PowerShell ejecutando `dotnet restore`
- [ ] **CAPTURA 1.3**: Archivo `appsettings.json` mostrando la ConnectionString completa
- [ ] **CAPTURA 1.4**: Archivo `DatabaseService.cs` mostrando el constructor que lee la ConnectionString
- [ ] **CAPTURA 1.5**: PowerShell con el backend ejecutándose mostrando "🚀 Servidor Servitec..."

**Total para 1.1: 9 capturas**

---

## Estructura para el informe

```
1. DRIVERS
1.1 Driver ADO.NET (MySQL Connector/NET)

1.1.1 Descarga
- Sitio: https://dev.mysql.com/downloads/connector/net/
- Versión: MySQL Connector/NET 8.0.33
- [PEGA CAPTURA 1.1]

1.1.2 Instalación
  a) Crear el proyecto C#:
     - Comando: dotnet new web -n backend-csharp -f net10.0
     - [PEGA CAPTURA 1.2a]
     - [PEGA CAPTURA 1.2b]
  
  b) Instalar MySql.Data:
     - Comando: dotnet add package MySql.Data --version 8.0.33
     - [PEGA CAPTURA 1.2c]
     - [PEGA CAPTURA 1.2d]
  
  c) Restaurar dependencias:
     - Comando: dotnet restore
     - [PEGA CAPTURA 1.2e]

1.1.3 Configuración
- Archivo: appsettings.json
- [PEGA CAPTURA 1.3]
- Clase: DatabaseService.cs
- [PEGA CAPTURA 1.4]

1.1.4 Verificación
- Comando: dotnet run
- [PEGA CAPTURA 1.5]
```

---

**Siguiente paso**: Una vez tengas las 6 capturas del ADO.NET, pasamos a la sección **2. SCRIPTS** (módulos de conexión y ejemplos CRUD).
