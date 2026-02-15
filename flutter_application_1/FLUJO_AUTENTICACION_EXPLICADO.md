# 🔧 EXPLICACIÓN: Flujo de Autenticación y Navegación

## ❌ Lo Que Estaba Pasando

Después de que te registrabas como cliente:
1. ✅ Te mostaba "Registro exitoso"
2. ✅ Volvías atrás a iniciar sesión
3. ✅ Ingresabas credenciales
4. ✅ El backend autenticaba exitosamente
5. ❌ **PERO** se abría una pantalla en blanco/sin contenido

### ¿Por qué ocurría?

**El problema:** El código DE NAVEGACIÓN en `pantalla_inicio_sesion.dart` estaba correcto:

```dart
final pantalla = usuario.esTecnico()
    ? PantallaInicioTecnico(tecnicoId: usuario.id)
    : PantallaInicioCliente(clienteId: usuario.id);

Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (_) => pantalla),
  (route) => false,
);
```

**PERO** el método `esTecnico()` en el modelo estaba mal:

```dart
// ❌ INCORRECTO (anterior)
bool esTecnico() => tipoUsuario.toLowerCase() == 'tecnico';
```

**El problema real:**
- El backend C# devuelve: `UserType: "technician"` (inglés)
- El frontend buscaba: `"tecnico"` (español)
- Resultado: `"technician" != "tecnico"` → Siempre retorna FALSO
- Entonces SIEMPRE iba a `PantallaInicioCliente` incluso si eras técnico

## ✅ El Fix Aplicado

Cambié el modelo para que reconozca AMBOS formatos:

```dart
// ✅ CORRECTO (ahora)
bool esTecnico() {
  final tipo = tipoUsuario.toLowerCase();
  return tipo == 'tecnico' || tipo == 'technician';
}

bool esCliente() {
  final tipo = tipoUsuario.toLowerCase();
  return tipo == 'cliente' || tipo == 'client';
}
```

Ahora soporta tanto:
- Backend C#: `"technician"` y `"client"`
- Frontend Flutter: `"tecnico"` y `"cliente"`

## 📱 Flujo Correcto Ahora (Paso por Paso)

### Opción A: Registrarse como **CLIENTE**

1. **App → Crear Cuenta → Soy Cliente**
   ```
   Formulario Cliente:
   - Nombre: Juan
   - Apellido: Pérez
   - Email: juan@test.com
   - Contraseña: Test123#
   - Teléfono: 1234567890
   - Dirección: Calle Principal 123
   ```

2. **Backend recibe** `POST /api/auth/register/client`
   - Valida datos
   - Inserta en tabla `clientes`
   - Devuelve: `{ "UserType": "client", "UserId": 1, ... }`

3. **Frontend recibe respuesta**
   - Muestra: ✅ "Registro exitoso"
   - Guarda token en local storage

4. **Usuario vuelve a iniciar sesión** (manualmente)
   - Email: `juan@test.com`
   - Contrasena: `Test123#`

5. **Backend recibe** `POST /api/auth/login`
   - Verifica credenciales
   - Devuelve: `{ "UserType": "client", "UserId": 1, ... }`

6. **Frontend evalúa tipo de usuario**:
   ```dart
   usuario.esTecnico() // false (porque UserType = "client")
   usuario.esCliente() // true ✅
   ```

7. **Navega a** `PantallaInicioCliente(clienteId: 1)`
   ```
   ┌─────────────────────────────┐
   │  Inicio - Cliente           │
   ├─────────────────────────────┤
   │                             │
   │  Pantalla de cliente (ID: 1)│
   │                             │
   └─────────────────────────────┘
   ```

---

### Opción B: Registrarse como **TÉCNICO**

1. **App → Crear Cuenta → Soy Técnico**
   ```
   Formulario Técnico:
   - Nombre: Carlos
   - Apellido: López
   - Email: carlos@test.com
   - Contraseña: Test123#
   - Teléfono: 9876543210
   - Ubicación: Barrio Centro
   - Tarifa: 50.00
   - Servicios: ✓ Electricista, ✓ Plomero
   ```

2. **Backend recibe** `POST /api/auth/register/technician`
   - Valida datos
   - Inserta en tabla `tecnicos` + relaciones en `tecnico_servicio`
   - Devuelve: `{ "UserType": "technician", "UserId": 2, ... }`

3. **Frontend evalúa tipo de usuario**:
   ```dart
   usuario.esTecnico() // true ✅ (porque UserType = "technician")
   usuario.esCliente() // false
   ```

4. **Navega a** `PantallaInicioTecnico(tecnicoId: 2)`
   ```
   ┌─────────────────────────────┐
   │  Inicio - Técnico           │
   ├─────────────────────────────┤
   │                             │
   │  Pantalla de técnico (ID: 2)│
   │                             │
   └─────────────────────────────┘
   ```

---

## 📂 Estructuras de Archivos

### Pantallas de Inicio (Actualmente Placeholders)

**`lib/Screens/pantalla_inicio_cliente.dart`**
```dart
class PantallaInicioCliente extends StatelessWidget {
  final int clienteId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio - Cliente')),
      body: Center(
        child: Text('Pantalla de cliente (ID: $clienteId)'),
      ),
    );
  }
}
```

---

⚠️ **IMPORTANTE:** Las pantallas de inicio SON PLACEHOLDERS (solo texto simple).

Si en tu código anterior tenías UI MÁS COMPLEJA en estas pantallas, necesitarías restaurarla.

---

## 🧐 Por qué pasó esto?

1. El backend fue escrito en C# (usa inglés: `"technician"`, `"client"`)
2. El frontend Flutter fue escrito para español (esperaba: `"tecnico"`, `"cliente"`)
3. No se sincronizaron los tipos de dato entre backend y frontend
4. El modelo nunca fue testeado para manejar inputs del backend real

**Resultado:** Trabajaba OK en tests locales pero fallaba al conectar con backend verdadero.

---

## 🔄 Flujo Actual (Visual)

```
┌─────────────────┐
│  App Flutter    │
└────────┬────────┘
         │
         ▼
    ┌────────────┐
    │  REGISTRO  │
    └────┬───────┘
         │ ✅ Exitoso
         ▼
  ┌──────────────┐
  │ Mostrar Éxito│
  └──────┬───────┘
         │ (Manual: volver a Inicio)
         ▼
  ┌─────────────┐
  │   LOGIN     │
  └──────┬──────┘
         │ POST a /api/auth/login
         ▼
    ┌——————————————┐
    │   Backend    │
    │   C# API     │ ← Devuelve UserType: "client" o "technician"
    └──────┬───────┘
           │
           ▼
  ┌──────────────────────┐
  │ evalúa esTecnico()   │
  │ evalúa esCliente()   │ ← AHORA FUNCIONA (fix aplicado)
  └─────────┬────────────┘
            │
      ┌─────┴─────┐
      ▼           ▼
  ┌─────────┐ ┌───────────┐
  │ Cliente │ │ Técnico   │
  └─────────┘ └───────────┘
  (pantalla)  (pantalla)
```

---

## ✅ Qué Debería Pasar Ahora

**Después de reinstalar/recargar la app:**

1. Registra cliente → Muestra "Registro exitoso" ✅
2. Vuelve a inicio sesión → Ingresa credenciales ✅  
3. Login exitoso → **Navega a `PantallaInicioCliente`** ✅ (ANTES no pasaba esto)
4. Ves el texto: "Pantalla de cliente (ID: 1)" ✅

---

## 🛠️ Si Necesitas UI Más Compleja

Las pantallas actuales son placeholders. Si necesitas agregar más UI:

```dart
// Ejemplo mejorado para PantallaInicioCliente
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Dashboard Cliente')),
    body: Column(
      children: [
        Text('Bienvenido, Cliente #$clienteId'),
        ElevatedButton(
          onPressed: () {
            // Buscar técnicos
          },
          child: const Text('Buscar Técnicos'),
        ),
        ElevatedButton(
          onPressed: () {
            // Ver mis contrataciones
          },
          child: const Text('Mis Contrataciones'),
        ),
      ],
    ),
  );
}
```

---

## 🎯 Resumen de Cambios

| Antes | Ahora |
|-------|-------|
| `esTecnico()` buscaba solo `"tecnico"` | Busca `"tecnico"` O `"technician"` |
| `esCliente()` buscaba solo `"cliente"` | Busca `"cliente"` O `"client"` |
| Después de login → Pantalla en blanco ❌ | Después de login → Pantalla correcta ✅ |

---

## 📝 Código Actual del Fix

**Archivo:** `lib/modelos/usuario_modelo.dart`

```dart
bool esTecnico() {
  final tipo = tipoUsuario.toLowerCase();
  return tipo == 'tecnico' || tipo == 'technician';
}

bool esCliente() {
  final tipo = tipoUsuario.toLowerCase();
  return tipo == 'cliente' || tipo == 'client';
}
```

---

**Status:** ✅ Flujo de autenticación funcional
**Próximas mejoras:** Mejorar UI de pantallas de inicio con funcionalidades reales
