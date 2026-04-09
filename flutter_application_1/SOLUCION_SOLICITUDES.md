# 📋 ESTRUCTURA DE SOLICITUDES (CONTRATOS)

## ✨ Análisis y Decisiones

Según el DDL `contrataciones`, la tabla tiene:
- **id_cliente**: Quién solicita el servicio
- **id_tecnico**: Quién lo acepta (puede ser NULL inicialmente)
- **estado**: 'Pendiente', 'Aceptada', 'En Progreso', 'Completada', 'Cancelada'
- **estado_monto**: 'Sin Propuesta', 'Propuesto', 'Aceptado', 'Rechazado'
- **monto_propuesto**: Lo que el técnico propone cobrar

## 🎯 Decisión: DOS PANTALLAS SEPARADAS

### 1️⃣ PantallaSolicitudesCliente
**Ubicación**: `lib/Screens/PantallaSolicitudesCliente.dart`

**Propósito**: Cliente ve sus solicitudes creadas

**Tabs**:
- 📋 **Todas** - Todas sus solicitudes
- ⏳ **Pendientes** - Esperando técnico (id_tecnico = NULL)
- 🔄 **En Curso** - Técnico aceptó (id_tecnico != NULL, estado = 'En Progreso')
- ✅ **Completadas** - Trabajo terminado (estado = 'Completada')

**Campos mostrados**:
- ID, descripción, estado
- 👤 Técnico asignado (si hay)
- 💰 Monto propuesto + estado_monto
- 📍 Ubicación

**Flujo del cliente**:
```
1. Crea solicitud en PantallaCrearSolicitud
2. Ve estado en PantallaSolicitudesCliente
3. Cuando técnico propone monto, lo ve en "Pendientes" o "En Curso"
4. Puede aceptar/rechazar la propuesta (TODO: UI)
5. Cuando completada, pasa a "Completadas"
```

### 2️⃣ PantallaSolicitudesTecnico
**Ubicación**: `lib/Screens/PantallaSolicitudesTecnico.dart`

**Propósito**: Técnico ve solicitudes disponibles y sus contratos

**Tabs**:
- 🔍 **Disponibles** - Solicitudes sin técnico (id_tecnico = NULL)
  - Técnico ve y puede hacer "Aceptar Trabajar" (propone monto)
- 🎯 **Mis Contratos** - Asignadas a este técnico
  - Muestra progreso y puede "Marcar Completado"

**Campos mostrados**:
- ID, descripción, estado
- 📍 Ubicación
- 👤 Cliente ID
- 💰 Monto propuesto (si existe)

**Flujo del técnico**:
```
1. En "Disponibles" busca trabajos que le interesan
2. Click "Aceptar Trabajar" → Se asigna a sí mismo + propone monto
3. El cliente ve la propuesta y acepta/rechaza
4. Si acepta: Pasa a "Mis Contratos" en estado "En Progreso"
5. Técnico marca "Marcar Completado"
6. Trabajo completado, ambos ven estado "Completada"
```

## 🔌 Backend Endpoints

El backend **YA SOPORTA** todo esto:

```
GET /api/contractions/client/{clientId}
  → Todas las solicitudes del cliente

GET /api/contractions/technician/{technicianId}
  → Todos los contratos asignados al técnico

GET /api/contractions/pending
  → Solicitudes SIN técnico asignado (disponibles para buscar)

POST /api/contractions/{id}/assign
  → Técnico se asigna a sí mismo

POST /api/contractions/{id}/complete
  → Marcar trabajo como completado

PUT /api/contractions/{id}
  → Actualizar estado general
```

## 📱 Integración con Frontend

### ServicioContrataciones - Métodos NUEVOS

```dart
// Cliente
obtenerMisSolicitudes(int idCliente) 
  → GET /api/contractions/client/{idCliente}

// Técnico
obtenerMisContratos(int idTecnico)
  → GET /api/contractions/technician/{idTecnico}

obtenerContratacionesPendientes()
  → GET /api/contractions/pending
```

## 🔄 Flujo de Estados

```
CREACIÓN POR CLIENTE:
┌─────────────────┐
│   PantallaCrear │ → POST /api/contractions → estado = "Pendiente"
│    Solicitud    │
└─────────────────┘
                ↓
            ┌──────────────────────┐
            │ Cliente ve en        │
            │ PantallaSolicitudes  │
            │ tab: "Pendientes"    │
            └──────────────────────┘

BÚSQUEDA POR TÉCNICO:
┌──────────────────────────────────┐
│ Técnico en PantallaSolicitudes   │
│ tab: "Disponibles"               │
│ Ve solicitudes sin técnico +      │
│ Click "Aceptar Trabajar"  →      │
│ POST /contractions/{id}/assign   │
└──────────────────────────────────┘
                ↓
            id_tecnico se asigna
            estado_monto = "Propuesto"
                ↓
            Client ve monto en su pantalla
            (TODO: UI para aceptar/rechazar)
                ↓
            Si acepta: estado pasa a "Aceptada" → "En Progreso"
            Si rechaza: id_tecnico = NULL, vuelve a "Disponibles"
                ↓
        Técnico en "Mis Contratos" ve el trabajo
        Click "Marcar Completado" →
        POST /contractions/{id}/complete
```

## 📊 Modelos afectados

- **ContratacionModelo**: Ya tiene todos los campos necesarios
  - idCliente, idTecnico, estado, estadoMonto, montoPropuesto
  - descripcion, ubicacion, fechaSolicitud, horaSolicitud

## 🚀 Siguientes pasos para completar

1. ✅ Crear PantallaSolicitudesCliente
2. ✅ Crear PantallaSolicitudesTecnico
3. ✅ Actualizar ServicioContrataciones con métodos específicos
4. ⏳ Integrar en HomeCliente (botón "Mis Solicitudes" → PantallaSolicitudesCliente)
5. ⏳ Integrar en HomeTecnico (botón "Buscar Trabajo" → PantallaSolicitudesTecnico)
6. ⏳ Backend: Implementar lógica de asignación técnico
7. ⏳ Frontend: UI para aceptar/rechazar monto propuesto
8. ⏳ Frontend: Proponer monto cuando técnico acepta trabajo

## 💡 Recomendaciones

1. **Separación clara**: Cliente y técnico nunca ven la misma pantalla
2. **Estados visuales**: Color diferente para cada estado
3. **Acciones**: Cada rol solo puede hacer lo que le corresponde
4. **Backend**: Consultas optimizadas por índices en contrataciones
