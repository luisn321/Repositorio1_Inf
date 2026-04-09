# 🔍 FLUJO DE BÚSQUEDA Y CONTRATACIÓN - CLIENTE

## ✅ IMPLEMENTACIÓN COMPLETADA

### 📋 Componentes Implementados

#### 1. **HomeCliente.dart** (Pantalla de Inicio)
- ✅ Buscador por nombre de técnico con validación
- ✅ Botón de búsqueda dinámico
- ✅ 6 Categorías de servicios con iconos
- ✅ BottomNavBar con 3 tabs: Buscar, Solicitudes, Perfil
- ✅ Pase de `idCliente` a todas las pantallas

**Cambios realizados:**
- Agregado `clienteId` al constructor
- Implementado método `_buscarPorNombre()` con navegación
- Actualizado `_construirTarjetaServicio()` para pasar `idCliente`
- Mejorado UX del buscador con botón limpiar

---

#### 2. **PantallaListaTecnicos.dart** (Lista Filtrada de Técnicos)
- ✅ Recibe 3 parámetros: `idServicio`, `nombreBusqueda`, `idCliente`
- ✅ Carga dinámica según filtro (nombre > servicio > todos)
- ✅ Búsqueda local en tiempo real
- ✅ Título dinámico del AppBar
- ✅ Navegación a PantallaCrearSolicitud al hacer clic

**Cambios realizados:**
- Agregados parámetros `nombreBusqueda` e `idCliente`
- Actualizado `_cargarTecnicos()` con lógica de prioridad
- Mejorado título del AppBar (muestra qué se está buscando)
- Convertido `_construirTarjetaTecnico()` a `GestureDetector` con navegación

---

#### 3. **PantallaCrearSolicitud.dart** (Crear Solicitud)
- ✅ Recibe `idCliente`, `idTecnico`, `idServicio`
- ✅ Puede pre-llenar datos del técnico y servicio
- ✅ Preparado para guardar solicitud con datos completos

**Cambios realizados:**
- Agregados parámetros `idTecnico` e `idServicio` al constructor
- Listos para recibir datos pre-seleccionados

---

#### 4. **servicio_tecnicos.dart** (Backend API)
- ✅ Corregida URL de búsqueda: ahora usa `?q=` en lugar de `?name=`

---

## 🔄 FLUJO DE USUARIO

```
HomeCliente (Pantalla Principal)
    ├─ Opción 1: BUSCAR POR NOMBRE
    │   └─ Usuario escribe nombre
    │       └─ Presiona "Buscar"
    │           └─ PantallaListaTecnicos (filtered by nombre)
    │               └─ Al hacer clic en técnico
    │                   └─ PantallaCrearSolicitud
    │
    ├─ Opción 2: FILTRAR POR CATEGORÍA
    │   └─ Usuario hace clic en categoría (ej: Electricista)
    │       └─ PantallaListaTecnicos (filtered by servicio)
    │           └─ Búsqueda local
    │               └─ Al hacer clic en técnico
    │                   └─ PantallaCrearSolicitud
    │
    └─ Opción 3: Ver Solicitudes o Perfil (tabs inferiores)
```

---

## 📊 PARÁMETROS PASADOS

### HomeCliente → PantallaListaTecnicos
```dart
PantallaListaTecnicos(
  nombreBusqueda: "Juan",        // Búsqueda por nombre
  idCliente: 1,                  // ID del cliente autenticado
  // O bien:
  idServicio: 1,                 // ID de la categoría
  idCliente: 1,                  // ID del cliente autenticado
)
```

### PantallaListaTecnicos → PantallaCrearSolicitud
```dart
PantallaCrearSolicitud(
  idCliente: 1,                  // Cliente autenticado
  idTecnico: 5,                  // Técnico seleccionado
  idServicio: 1,                 // Servicio seleccionado
)
```

---

## 🎯 LÓGICA DE CARGA EN PantallaListaTecnicos

```dart
if (nombreBusqueda != null && nombreBusqueda.isNotEmpty) {
  // PRIORIDAD 1: Búsqueda por nombre
  buscarTecnicosPorNombre(nombreBusqueda)
} else if (idServicio != null) {
  // PRIORIDAD 2: Filtro por categoría/servicio
  obtenerTecnicosPorServicio(idServicio)
} else {
  // PRIORIDAD 3: Todos los técnicos
  obtenerTodosTecnicos()
}
```

---

## 🔧 ENDPOINTS BACKEND USADOS

```
GET /api/technicians                      → Todos los técnicos
GET /api/technicians?serviceId=1          → Técnicos por servicio
GET /api/technicians/search?q=Juan        → Búsqueda por nombre
POST /api/contractions                    → Crear solicitud (próximo)
```

---

## ✨ CARACTERÍSTICAS ADICIONALES

1. **Búsqueda en tiempo real**: `onChanged` en TextField de PantallaListaTecnicos
2. **Botón limpiar dinámico**: Solo visible cuando hay texto en el buscador
3. **Título dinámico**: Muestra "Resultados: Juan" o "Electricistas"
4. **Validación**: No permite búsqueda vacía
5. **Error handling**: Captura excepciones de red

---

## 🚀 PRÓXIMOS PASOS

1. **Implementar PantallaCrearSolicitud completamente**
   - Usar `idTecnico` e `idServicio` recibidos
   - Mostrar detalles del técnico seleccionado
   - Pre-llenar servicio

2. **Agregar endpoint POST en backend**
   - `/api/contractions` para crear solicitud

3. **Conectar servicio de contrataciones**
   - `servicio_contrataciones.dart` ya existe

4. **Validar flujo completo end-to-end**

---

## 📝 NOTAS TÉCNICAS

- **AppIcons.darkGreen**: Verde del tema (usado en lugar de Color.fromARGB)
- **URI.encodeComponent()**: Escapa caracteres especiales en búsqueda
- **FutureBuilder**: Mantiene estado reactivo con cambios
- **Navegación**: Usa `Navigator.push()` para mantener el back
- **BuildContext**: Pasado correctamente a métodos de construcción

