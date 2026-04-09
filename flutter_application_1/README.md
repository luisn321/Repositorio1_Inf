# 🔧 Servitec - Plataforma de Servicios Técnicos

**Estado del Proyecto**: ✅ PARTE 2 Completada (17 Marzo 2026)  
**Stack**: Flutter/Dart (Frontend) + C# ASP.NET Core (Backend) + MySQL (Base de Datos)

---

## 📱 Descripción General

**Servitec** es una aplicación móvil que conecta clientes con técnicos para solicitar servicios de reparación. 

### Usuarios
- **Clientes**: Solicitan servicios, ven propuestas, pagan y califican
- **Técnicos**: Aceptan solicitudes, proponen montos, completan trabajos

---

## ✅ Progreso PARTE 1, 2

| Parte | Descripción | Estado | Líneas código |
|-------|-------------|--------|--------------|
| **PARTE 1** | Solicitud + Accept/Reject | ✅ Completada | ~450 |
| **PARTE 2** | Propuesta de Monto | ✅ Completada | ~391 |
| **PARTE 3** | Pago + Calificaciones | ⏳ Pendiente | TBD |

---

## 🚀 PARTE 2: Propuesta de Monto (Recién Implementado)

### ¿Qué hace?
1. Técnico acepta una solicitud (PARTE 1)
2. En tab "✅ Mis Contratos" aparece botón **"💰 Proponer Monto"**
3. Técnico propone precio (`>$0` obligatorio)
4. Backend actualiza `monto_propuesto` y `estado_monto = "Pendiente"`
5. Cliente recibirá notificación (PARTE 3)

### Archivos Implementados
```
✅ Backend (4 archivos)
  ├── DTOs/ContractionDTOs.cs - ProposeMountDto
  ├── Services/IContractionService.cs - Interface
  ├── Services/ContractionService.cs - Lógica
  └── Controllers/ContractionController.cs - Endpoint POST /propose-amount

✅ Frontend (4 archivos)
  ├── modelos/solicitud_modelo.dart - Modelos Dart
  ├── servicios_red/servicio_contrataciones.dart - HTTP
  ├── Screens/dialogos_solicitudes.dart - UI Dialog
  └── Screens/PantallaSolicitudesTecnico.dart - Integración
```

### Flujo
```
Técnico: Tab "✅ Mis Contratos" 
    → Click "💰 Proponer Monto" 
    → Input monto ($50.000) 
    → Click "Proponer"
    → ✅ SnackBar: "Monto propuesto exitosamente"
    → Lista recarga

Backend: 
    → POST /contractions/{id}/propose-amount
    → Valida: monto > 0 y estado = "Aceptada"
    → Actualiza: monto_propuesto, estado_monto = "Pendiente"
    → Response 200 Ok
```

### Validaciones
| Validación | Lugar | Resultado |
|------------|-------|-----------|
| Monto > 0 | Cliente ✓ + Backend ✓ | Error si no cumple |
| Estado = "Aceptada" | Backend ✓ | Error 400 si no |
| Monto no vacío | Cliente ✓ | Campo bloqueado |
| Token JWT válido | Backend ✓ | Error 401 si falta |

---

## 🧪 Testing PARTE 2

```bash
# 1. Prerequisito: PARTE 1 debe estar funcional
#    (técnico puede aceptar solicitudes)

# 2. Run la app
flutter run

# 3. Test flow
# - Cliente: Crear solicitud
# - Técnico: Aceptar solicitud
# - Técnico: Tab "✅ Mis Contratos" → Ver botón naranja
# - Click "💰 Proponer Monto"
# - Input: 50000
# - Click "Proponer"
# - ✅ Verificar SnackBar y actualización en BD

# 4. SQL para verificar
SELECT id_contratacion, estado_monto, monto_propuesto 
FROM contrataciones 
WHERE id_tecnico = [ID_TECNICO];
```

---

## 🔗 PARTE 3: Próxima Fase (Pendiente)

### Tareas PARTE 3
1. **Cliente Response**: 
   - Backend: Endpoints para aceptar/rechazar propuesta
   - Frontend: Screen con propuestas de técnicos

2. **Payment Integration**:
   - Decisión: Mercado Pago / Stripe / Mock
   - Backend: PaymentService
   - Frontend: PantallaPago

3. **Ratings System**:
   - Frontend: Screen de calificación (⭐ + comentarios)
   - Backend: CalificacionesService

---

## 📦 Stack Técnico

### Frontend
```
Flutter 3.x / Dart 3.x
├── UI Framework: Flutter Material
├── Http: dio (manejar requests)
├── Auth: flutter_secure_storage (JWT tokens)
├── Storage: shared_preferences (local cache)
└── Icons: Material icons
```

### Backend
```
C# ASP.NET Core 6.0
├── Controllers: API REST endpoints
├── Services: Business logic
├── Repositories: BD access (Entity Framework)
├── DTOs: Request/Response contracts
└── JWT: Autenticación
```

### Database
```
MySQL 8.0+
├── Tabla: usuarios (clientes, técnicos)
├── Tabla: solicitudes_contratacion
│   ├── Campos agregados: monto_propuesto, estado_monto
│
└── Tabla: calificaciones (futura PARTE 3)
```

---

## 🎨 UI/UX Detalles

### Botón "💰 Proponer Monto"
- **Estado**: Visible solo cuando `disponible = false` (estado = "Aceptada")
- **Color**: Naranja (#FF9800) - para operaciones financieras
- **Icon**: `Icons.local_atm`
- **Texto**: "💰 Proponer Monto"

### Dialog DialogoProponerMonto
```
┌─────────────────────────┐
│ 💰 Proponer Monto       │
├─────────────────────────┤
│ Ingresa el monto...     │
│ ℹ️ Monto solicitado     │
│ $ Ej: 50000             │
│ [Cancelar] [Proponer]   │
└─────────────────────────┘
```

---

## 📋 Compilación & Errores

```
✅ Estado: CERO ERRORES en PARTE 2
⚠️ Warnings: 157 (pre-existentes en otros archivos, no blocking)
✅ flutter analyze: PASA correctamente
✅ Todas las operaciones CRUD: Funcionales
```

---

## 📚 Documentación Adicional

Para más detalles, ver:
- **[PARTE2_PROPUESTA_MONTO_COMPLETA.md](PARTE2_PROPUESTA_MONTO_COMPLETA.md)** - Documentación completa PARTE 2
- **[00_COMIENZA_AQUI.md](00_COMIENZA_AQUI.md)** - Guía de inicio rápido
- **[DDL_ACTUALIZADO.sql](DDL_ACTUALIZADO.sql)** - Schema de base de datos

---

## 🏃 Inicio Rápido

### 1. Clone y setup
```bash
cd flutter_application_1
flutter pub get
```

### 2. Backend
```bash
cd backend-csharp
dotnet run
```

### 3. Frontend
```bash
flutter run
```

### 4. Base de datos
```bash
mysql -u root -p < DDL_ACTUALIZADO.sql
```

---

## 📝 Notas

- ✅ PARTE 1: Aceptar/rechazar solicitudes
- ✅ PARTE 2: Propuesta de monto (recién completado)
- ⏳ PARTE 3: Pago + calificaciones (próximo)

**Última actualización**: 17 Marzo 2026
