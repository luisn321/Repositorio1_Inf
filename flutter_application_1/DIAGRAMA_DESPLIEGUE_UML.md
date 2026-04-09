# 📊 DIAGRAMA DE DESPLIEGUE UML - Proyecto Servitec

## 📋 Tabla de Contenidos
1. [Introducción](#introducción)
2. [Nodos del Sistema](#nodos-del-sistema)
3. [Artefactos Desplegados](#artefactos-desplegados)
4. [Conexiones de Red](#conexiones-de-red)
5. [Tecnologías Involucradas](#tecnologías-involucradas)
6. [Guía Paso a Paso](#guía-paso-a-paso)
7. [Ejemplos UML](#ejemplos-uml)
8. [Herramientas Recomendadas](#herramientas-recomendadas)

---

## 🎯 Introducción

Un **Diagrama de Despliegue UML** muestra cómo los componentes de software se distribuyen físicamente en hardware. Representa:

- **Nodos**: Servidores, computadoras, dispositivos móviles
- **Artefactos**: Archivos ejecutables, librerías, bases de datos
- **Conexiones**: Rutas de comunicación entre nodos
- **Protocolos**: Tecnologías de red (HTTP, TCP/IP, etc.)

### ¿Por qué es importante?
✅ Visualiza la arquitectura física  
✅ Identifica los puntos de fallo  
✅ Documenta el despliegue en producción  
✅ Facilita la escalabilidad  
✅ Comunica la infraestructura al equipo  

---

## 🖥️ Nodos del Sistema Servitec

### 1️⃣ **Smartphone Cliente** (Nodo Móvil)
```
Tipo: Mobile Device
SO: Android / iOS
Detalles:
  - Dispositivo del cliente que solicita servicios
  - Ejecuta aplicación Flutter
  - Se conecta vía WiFi o datos móviles
  - Almacenamiento seguro local (token JWT)
```

### 2️⃣ **Smartphone Técnico** (Nodo Móvil)
```
Tipo: Mobile Device
SO: Android / iOS
Detalles:
  - Dispositivo del técnico que ofrece servicios
  - Ejecuta misma aplicación Flutter que cliente
  - Se conecta vía WiFi o datos móviles
  - Recibe notificaciones de nuevos trabajos
```

### 3️⃣ **Servidor Backend** (Nodo Servidor)
```
Tipo: Application Server
SO: Windows Server / Linux
Detalles:
  - Ejecuta ASP.NET Core 6.0
  - Puerto: 3000 (desarrollo local)
  - Procesa lógica de negocio
  - Valida autenticación y autorizaciones
  - Orquesta operaciones de base de datos
```

### 4️⃣ **Servidor de Base de Datos** (Nodo Servidor)
```
Tipo: Database Server
SO: Windows / Linux
Detalles:
  - Ejecuta MySQL 8.0+
  - Puerto: 3306 (desarrollo local)
  - Almacena todos los datos persistentes
  - Índices y consultas optimizadas
  - Backup automático (en producción)
```

### 5️⃣ **Browser Web** (Nodo Opcional)
```
Tipo: Client Browser
SO: Windows / macOS / Linux
Detalles:
  - Panel administrativo (versión web de Flutter/Web)
  - Acceso a estadísticas y reportes
  - Gestión de base de datos si es necesario
```

---

## 📦 Artefactos Desplegados

### En Smartphone Cliente
```
📱 Artefactosdeployed:
├── flutter_app.apk (Android)
├── flutter_app.ipa (iOS)
├── Librerías:
│   ├── http.dart (comunicación)
│   ├── flutter_secure_storage (tokens)
│   ├── geocoding (mapas y ubicación)
│   └── provider (estado)
├── Assets:
│   ├── Iconos
│   ├── Imágenes
│   └── Fuentes
└── Local Storage:
    └── Tokens JWT + datos caché
```

### En Smartphone Técnico
```
📱 Artefactos desplegados:
├── flutter_app.apk (Android)
├── flutter_app.ipa (iOS)
├── Mismas librerías que cliente
├── Assets:
│   └── Mismo que cliente
└── Local Storage:
    └── Tokens JWT + caché de trabajos
```

### En Servidor Backend
```
🖥️ Artefactos desplegados:
├── ServitecAPI.dll (Aplicación compilada)
├── appsettings.json (Configuración)
├── Dependencias NuGet:
│   ├── EntityFramework (ORM)
│   ├── Serilog (Logging)
│   └── JWT (Autenticación)
├── Controllers:
│   ├── AuthController.dll
│   ├── TechnicianController.dll
│   ├── ContractionController.dll
│   ├── PaymentController.dll
│   └── ServiceController.dll
├── Services:
│   ├── AuthService.dll
│   ├── TechnicianService.dll
│   └── ContractionService.dll
└── Repositories:
    ├── TechnicianRepository.dll
    ├── ContractionRepository.dll
    └── PaymentRepository.dll
```

### En Servidor Base de Datos
```
🗄️ Artefactos desplegados:
├── Schemas:
│   └── servitec.sql (esquema completo)
├── Tablas (13):
│   ├── clientes
│   ├── tecnicos
│   ├── servicios
│   ├── tecnico_servicio
│   ├── contrataciones
│   ├── pagos
│   ├── calificaciones
│   └── ...otras
├── Índices (optimización)
├── Procedures (si existen)
└── Backups automáticos
```

---

## 🌐 Conexiones de Red

### Conexión 1: Cliente → Servidor Backend
```
Origen: Smartphone Cliente
Destino: Servidor Backend (localhost:3000)
Protocolo: HTTP/HTTPS
Método: REST API + JSON
Puertos: 80 (HTTP) o 443 (HTTPS)

Flujo:
┌──────────────────────────────────────────┐
│ 📱 Cliente Solicita Servicio             │
├──────────────────────────────────────────┤
│ POST /api/contractions                   │
│ Headers:                                 │
│   - Authorization: Bearer {JWT}          │
│   - Content-Type: application/json       │
│ Body:                                    │
│   {                                      │
│     "clientId": 1,                       │
│     "serviceId": 5,                      │
│     "description": "...",                │
│     "scheduledDate": "2026-03-15"        │
│   }                                      │
└──────────────────────────────────────────┘
         ⬇️ INTERNET ⬇️
┌──────────────────────────────────────────┐
│ 🖥️ Servidor Backend Procesa              │
├──────────────────────────────────────────┤
│ 1. Valida JWT                            │
│ 2. Ejecuta ContractionService            │
│ 3. Inserta en DB                         │
│ 4. Retorna Response (201 Created)        │
└──────────────────────────────────────────┘
```

### Conexión 2: Técnico → Servidor Backend
```
Origen: Smartphone Técnico
Destino: Servidor Backend (localhost:3000)
Protocolo: HTTP/HTTPS
Método: REST API + JSON

Flujo similar al cliente, pero con endpoints:
- GET /api/contractions/technician/{id}
- GET /api/contractions/pending
- POST /api/contractions/{id}/assign
```

### Conexión 3: Backend → Base de Datos
```
Origen: Servidor Backend (puerto variable)
Destino: Servidor BD (localhost:3306)
Protocolo: TCP/IP + MySQL Protocol
Autenticación: Usuario MySQL + Contraseña

Cadena de conexión:
Server=localhost;Database=servitec;User=root;Password=****;

Flujo:
┌──────────────────────────────────┐
│ Backend envía Query SQL           │
│ SELECT * FROM tecnicos WHERE ...  │
└──────────────────────────────────┘
         ⬇️ TCP/IP ⬇️
┌──────────────────────────────────┐
│ MySQL procesa y retorna resultado │
└──────────────────────────────────┘
```

### Conexión 4: Cliente ↔ Geolocalización (Opcional)
```
Origen: Smartphone
Destino: Google Maps API / Geocoding Service
Protocolo: HTTPS
Propósito: Ubicación en tiempo real

Usado en:
- Buscar técnicos cercanos
- Mostrar mapa de ubicación
- Calcular distancia
```

---

## 🛠️ Tecnologías Involucradas

| Componente | Tecnología | Versión | Detalles |
|---|---|---|---|
| **Frontend móvil** | Flutter | 3.0+ | Multiplataforma (Android/iOS) |
| **Lenguaje móvil** | Dart | 3.0+ | Lenguaje de Flutter |
| **Backend** | ASP.NET Core | 6.0 | API REST en C# |
| **Base de datos** | MySQL | 8.0+ | RDBMS relacional |
| **ORM** | Entity Framework | 6.0+ | Mapeo objeto-relacional |
| **Auth** | JWT | - | JSON Web Tokens |
| **Comunicación** | HTTP/HTTPS | 1.1/2.0 | Protocolo de red |
| **API Protocol** | REST | - | JSON sobre HTTP |
| **SO Backend** | Windows/Linux | - | Servidor de aplicación |
| **SO Móvil** | Android/iOS | 5.0+/12+ | Sistemas operativos |
| **Mapas** | Google Maps API | - | Geolocalización |
| **Storage local** | SQLite (Flutter) | - | Base de datos local |

---

## 📝 Guía Paso a Paso para Crear el Diagrama

### **Opción 1: Usar PlantUML** (Recomendado - Texto)

#### Paso 1: Instalar PlantUML
```bash
# Con Graphviz instalado
# Windows: descargar ejecutable
# o usar online: www.plantuml.com/plantuml/uml/

# VS Code: Extensión "PlantUML"
```

#### Paso 2: Crear archivo `.puml`
```bash
touch diagrama_despliegue.puml
```

#### Paso 3: Escribir el diagrama UML
```
@startuml Servitec_Deployment
!define TECHN_FONT_SIZE 10

' Nodos
node "📱 Smartphone Cliente\n[Android/iOS]" as ClientPhone {
    artifact "flutter_app.apk" as ClientApp
    component "Flutter UI\n- HomeCliente\n- PantallaListaTecnicos\n- PantallaCrearSolicitud" as ClientUI
    database "Local Storage\n(Tokens + Cache)" as ClientStorage
}

node "📱 Smartphone Técnico\n[Android/iOS]" as TechPhone {
    artifact "flutter_app.apk" as TechApp
    component "Flutter UI\n- HomeTecnico\n- Buscar Trabajos\n- Mis Contratos" as TechUI
    database "Local Storage\n(Tokens + Cache)" as TechStorage
}

node "🖥️ Servidor Backend\n[ASP.NET Core 6.0]" as Backend {
    component "Controllers" as Controllers
    component "Services" as Services
    component "Repositories" as Repositories
    artifact "ServitecAPI.dll" as BackendApp
}

node "🗄️ Servidor Base de Datos\n[MySQL 8.0]" as Database {
    database "servitec" as MainDB {
        table clientes
        table tecnicos
        table servicios
        table tecnico_servicio
        table contrataciones
        table pagos
        table calificaciones
    }
}

' Conexiones
ClientPhone ..> Backend: "HTTP/REST\nPOST/GET /api/\nJSON + JWT"
TechPhone ..> Backend: "HTTP/REST\nPOST/GET /api/\nJSON + JWT"
Backend --> Database: "TCP/IP\nMySQL Protocol\nPort 3306"

note on link : Conexión encriptada (HTTPS en prod)
note on link : Pool de conexiones

@enduml
```

### **Opción 2: Usar Draw.io** (Grafico - Arrastrar y soltar)

#### Paso 1: Abrir www.draw.io

#### Paso 2: Seleccionar plantilla UML > Deployment Diagram

#### Paso 3: Arrastrar elementos
```
1. Arrastra 2 nodos "Device" para clientes
2. Arrastra 1 nodo "Server" para backend
3. Arrastra 1 nodo "Database" para MySQL
4. Conecta con flechas etiquetadas
5. Añade detalles en cajas de texto
```

#### Paso 4: Exportar como PNG/SVG

### **Opción 3: Usar Visual Paradigm** (Profesional)

1. New Project → UML
2. Diagram > Deployment Diagram
3. Arrastrar nodos desde toolbox
4. Configurar propiedades
5. Generar reporte

### **Opción 4: Usar StarUML** (Gratuito)

1. Descargar desde www.staruml.io
2. File > New > Deployment Diagram
3. Añadir nodos y conexiones
4. Personalizar apariencia

---

## 🎨 Ejemplos UML

### Notación UML Estándar (Tabla)

| Símbolo | Significado | En Servitec |
|---|---|---|
| **Rectángulo grueso con <<device>>** | Dispositivo móvil | Smartphone cliente y técnico |
| **Rectángulo con <<artifact>>** | Componente software desplegable | flutter_app.apk, ServitecAPI.dll |
| **Cilindro** | Base de datos | MySQL servitec |
| **Línea sólida** | Conexión persistente | Backend ↔ MySQL |
| **Línea punteada** | Conexión temporal/opcional | Cliente ↔ API externa |
| **Etiqueta en línea** | Protocolo/Tecnología | HTTP/REST, TCP, JSON |

### Texto Plano (para documentación)

```
NODOS:
┌─────────────────────────────────────────────────────────────┐
│ 📱 PERSONA                                                  │
├─────────────────────────────────────────────────────────────┤
│ Smartphone Cliente (Android/iOS)                            │
│                                                              │
│ ├─ Flutter App (flutter_app.apk)                            │
│ ├─ Local Storage (JWT tokens)                               │
│ └─ Conexión: WiFi/Datos móviles                             │
└─────────────────────────────────────────────────────────────┘
          ⬇️ HTTP/REST (HTTPS en prod) ⬇️
┌─────────────────────────────────────────────────────────────┐
│ 🖥️ SERVIDOR BACKEND                                         │
├─────────────────────────────────────────────────────────────┤
│ ASP.NET Core 6.0 (puerto 3000)                              │
│                                                              │
│ ├─ Controllers (API endpoints)                              │
│ ├─ Services (lógica)                                        │
│ ├─ Repositories (acceso a datos)                            │
│ └─ ServitecAPI.dll (ejecutable)                             │
└─────────────────────────────────────────────────────────────┘
          ⬇️ TCP/IP (Puerto 3306) ⬇️
┌─────────────────────────────────────────────────────────────┐
│ 🗄️ SERVIDOR BASE DE DATOS                                  │
├─────────────────────────────────────────────────────────────┤
│ MySQL 8.0                                                   │
│                                                              │
│ ├─ Tabla: clientes                                          │
│ ├─ Tabla: tecnicos                                          │
│ ├─ Tabla: servicios                                         │
│ ├─ Tabla: contrataciones                                    │
│ ├─ Tabla: pagos                                             │
│ └─ Tabla: calificaciones                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Herramientas Recomendadas

### **1. PlantUML** (★★★★★ Recomendado)
```
✅ Ventajas:
  - Basado en texto (versionable en Git)
  - Integración con Markdown
  - Rápido de generar
  - Online sin instalar
  
❌ Desventajas:
  - Requiere aprender sintaxis
  
📥 Descarga: www.plantuml.com
📍 Online: www.plantuml.com/plantuml/uml/
```

### **2. Draw.io** (★★★★)
```
✅ Ventajas:
  - Interfaz gráfica intuitiva
  - Sin instalar (online)
  - Exporta múltiples formatos
  - Gratis
  
❌ Desventajas:
  - No versionable fácilmente
  - Archivo XML grande
  
📍 URL: www.draw.io
```

### **3. Lucidchart** (★★★)
```
✅ Ventajas:
  - Profesional
  - Colaborativo
  - Plantillas UML completas
  
❌ Desventajas:
  - De pago (plan gratis limitado)
  - Requiere cuenta
  
📍 URL: www.lucidchart.com
```

### **4. Visual Studio Code + PlantUML Extension**
```bash
# Instalar extensión
ext install PlantUML

# Crear archivo
touch diagrama.puml

# Ver preview con Ctrl+Shift+P > PlantUML: Preview

# Exportar PNG
PlantUML: Export Current Diagram
```

---

## 📊 Template PlantUML Completo para Servitec

Copia y modifica este template:

```plantuml
@startuml Servitec_Deployment_Diagram
!define TECH_COLOR #FF6B6B
!define DB_COLOR #4ECDC4
!define CLIENT_COLOR #95E1D3

skinparam backgroundColor #F8F9FA
skinparam component {
  BackgroundColor #FFEAA7
  BorderColor #DDA15E
}

' ========== NODOS CLIENTE ==========
node "📱 Cliente\n(Android/iOS)" as ClientNode {
    component [Flutter App UI] as ClientGUI
    database [Local Cache] as ClientCache
}

' ========== NODOS TÉCNICO ==========
node "📱 Técnico\n(Android/iOS)" as TechNode {
    component [Flutter App UI] as TechGUI
    database [Local Cache] as TechCache
}

' ========== NODO BACKEND ==========
node "🖥️ Backend Server\n(ASP.NET Core 6.0)" as ServerNode {
    component [AuthController] as AuthCtrl
    component [TechnicianController] as TechCtrl
    component [ContractionController] as ContCtrl
    component [PaymentController] as PayCtrl
    component [ServiceController] as ServCtrl
    
    component [AuthService] as AuthSvc
    component [TechnicianService] as TechSvc
    component [ContractionService] as ContSvc
    
    component [Repositories] as Repos
}

' ========== NODO BASE DE DATOS ==========
node "🗄️ Database Server\n(MySQL 8.0)" as DatabaseNode {
    database [servitec DB] {
        [clientes]
        [tecnicos]
        [servicios]
        [tecnico_servicio]
        [contrataciones]
        [pagos]
        [calificaciones]
    }
}

' ========== CONEXIONES ==========
ClientGUI --> AuthCtrl: HTTP/REST\nJSON + JWT\n(HTTPS en prod)
ClientGUI --> TechCtrl: GET /technicians
ClientGUI --> ContCtrl: POST /contractions

TechGUI --> AuthCtrl: HTTP/REST\nJSON + JWT
TechGUI --> ContCtrl: GET /contractions
TechGUI --> TechCtrl: GET /profile

AuthCtrl --> AuthSvc: Valida credenciales
TechCtrl --> TechSvc: Lógica de técnicos
ContCtrl --> ContSvc: Lógica de contrataciones

AuthSvc --> Repos: Acceso a datos
TechSvc --> Repos: Acceso a datos
ContSvc --> Repos: Acceso a datos

Repos --> DatabaseNode: TCP/IP\nMySQL Protocol\nPort 3306

' ========== NOTAS ==========
note on link between ClientGUI and AuthCtrl
  Protocolo: HTTP/REST
  Puerto: 3000 (desarrollo)
  Autenticación: JWT Bearer Token
end note

note on link between Repos and DatabaseNode
  Cadena conexión:
  Server=localhost;
  Database=servitec;
  User=root;Password=***
end note

note right of ClientNode
  Acceso desde cualquier lugar
  Internet o WiFi local
end note

note right of DatabaseNode
  Solo accesible desde Backend
  Restricción de IP
end note

@enduml
```

---

## 🚀 Pasos Finales

1. **Crear archivo `diagrama_despliegue.puml`** en la raíz del proyecto
2. **Usar PlantUML Online** para generar PNG
3. **Guardar imagen** en carpeta `docs/`
4. **Incluir en README.md** con explicación
5. **Versionar en Git** junto con el código
6. **Actualizar** cuando cambie la arquitectura

### Comando para exportar desde terminal:
```bash
# Si tienes PlantUML instalado localmente
plantuml diagrama_despliegue.puml -o ../docs/diagrama_despliegue.png

# O usar online: copiar contenido .puml
# a www.plantuml.com/plantuml y descargar PNG
```

---

## ✅ Checklist para tu Diagrama

- [ ] Incluye los 4 nodos principales (2 clientes, 1 backend, 1 BD)
- [ ] Muestra todos los artefactos principales (.apk, .dll, DB)
- [ ] Etiqueta las conexiones con protocolos (HTTP, TCP, REST)
- [ ] Incluye puertos en desarrollo (3000, 3306)
- [ ] Distingue entre conexión local y remota
- [ ] Documenta las tecnologías en cada nodo
- [ ] Es legible y profesional
- [ ] Está versionado en el repositorio
- [ ] Se incluye en la documentación del proyecto

---

## 📚 Referencias

- [UML Deployment Diagram - OMG](https://www.omg.org/spec/UML/)
- [PlantUML Documentation](https://plantuml.com/deployment-diagram)
- [Draw.io UML Guides](https://www.drawio.com/blog)
- [Visual Paradigm UML](https://www.visual-paradigm.com/)

