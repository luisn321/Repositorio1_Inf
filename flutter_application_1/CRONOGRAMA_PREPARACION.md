# ⏱️ CRONOGRAMA DE PREPARACIÓN PARA LA DEFENSA

**Proyecto:** SERVITEC  
**Materia:** Taller de Base de Datos  
**Duración total:** 4 semanas  
**Defensa prevista:** Fin de semestre

---

## 📅 SEMANA 1: COMPRENSIÓN DEL PROYECTO

### Objetivo
Entender QUÉ es SERVITEC y CÓMO funciona

### Lunes-Martes: Lectura Inicial
- [ ] Leer `RESUMEN_OPERACIONES_SQL.md` (ÍNDICE RÁPIDO) - 5 min
- [ ] Leer `RESUMEN_OPERACIONES_SQL.md` (OP 1: Registrar Cliente) - 5 min
- [ ] Leer `RESUMEN_OPERACIONES_SQL.md` (OP 2: Registrar Técnico) - 5 min
- [ ] **Tiempo total: 15 minutos**
- [ ] ✍️ Escribe: "¿Qué es SERVITEC en 2 líneas?"

### Miércoles-Jueves: Visualización
- [ ] Leer `DIAGRAMA_VISUAL_OPERACIONES.md` (FLUJO CLIENTE) - 10 min
- [ ] Leer `DIAGRAMA_VISUAL_OPERACIONES.md` (ARQUITECTURA) - 10 min
- [ ] Ver carpetas del proyecto: `backend-csharp/`, `lib/` - 5 min
- [ ] **Tiempo total: 25 minutos**
- [ ] ✍️ Dibuja: Un flujo simple (Cliente → Buscar Técnico → Contratar)

### Viernes: Práctica Inicial
- [ ] Abre `backend-csharp/Controllers/AuthService.cs`
- [ ] Busca la operación de registro (línea 25-60)
- [ ] Lee el código SQL comentado - 10 min
- [ ] Lee el código C# - 10 min
- [ ] **Tiempo total: 20 minutos**
- [ ] ✍️ Explica: ¿Qué hace la línea del HashPassword?

### Fin de semana: Repaso
- [ ] Releer el RESUMEN (15 min)
- [ ] Crear un mapa mental en papel (operaciones) - 20 min
- [ ] **Tiempo total: 35 minutos**

**TOTAL SEMANA 1: ~95 minutos (1.5 horas)**

---

## 📅 SEMANA 2: PROFUNDIZACIÓN TÉCNICA

### Objetivo
Entender CÓMO funcionan las operaciones SQL en detalle

### Lunes-Martes: Operaciones 1-3
- [ ] Leer `REPORTE_SCRIPT_CONEXION_ADONET.md` (OP 1: INSERT Cliente) - 15 min
- [ ] Leer código real en `AuthService.cs` línea 25-60 - 10 min
- [ ] Leer `REPORTE_SCRIPT_CONEXION_ADONET.md` (OP 2: INSERT Técnico) - 15 min
- [ ] Leer `REPORTE_SCRIPT_CONEXION_ADONET.md` (OP 6: SELECT Login) - 15 min
- [ ] **Tiempo total: 55 minutos**
- [ ] ✍️ Escribe: SQL puro de OP1, OP2 y OP6 de memoria

### Miércoles: Operaciones 4-5
- [ ] Leer `REPORTE_SCRIPT_CONEXION_ADONET.md` (OP 3: SELECT Perfil) - 10 min
- [ ] Leer `REPORTE_SCRIPT_CONEXION_ADONET.md` (OP 5: UPDATE Perfil) - 15 min
- [ ] Leer `REPORTE_SCRIPT_CONEXION_ADONET.md` (OP 4: SELECT Técnicos) - 15 min
- [ ] **Tiempo total: 40 minutos**
- [ ] ✍️ Escribe: ¿Por qué UPDATE es "selectiva"?

### Jueves: Operaciones 7-8
- [ ] Leer `REPORTE_SCRIPT_CONEXION_ADONET.md` (OP 7: INSERT Contratación) - 15 min
- [ ] Leer `REPORTE_SCRIPT_CONEXION_ADONET.md` (OP 8: SELECT Contrataciones) - 15 min
- [ ] Identificar los JOINs en ambas operaciones - 10 min
- [ ] **Tiempo total: 40 minutos**
- [ ] ✍️ Dibujar: Las 3 tablas y cómo se conectan

### Viernes: Seguridad
- [ ] Leer `REPORTE_SCRIPT_CONEXION_ADONET.md` (SEGURIDAD) - 20 min
- [ ] Entender parámetros vs concatenación - 10 min
- [ ] Entender BCrypt - 10 min
- [ ] Entender JWT - 10 min
- [ ] **Tiempo total: 50 minutos**
- [ ] ✍️ Escribe: "¿Por qué no concatenar strings en SQL?"

### Fin de semana: Integración
- [ ] Releer DIAGRAMA_VISUAL (completamente) - 30 min
- [ ] Hacer tu propio diagrama (ER) - 30 min
- [ ] Ver código en VS Code (~30 líneas) - 20 min
- [ ] **Tiempo total: 80 minutos**

**TOTAL SEMANA 2: ~305 minutos (5+ horas)**

---

## 📅 SEMANA 3: PRÁCTICA Y TESTING

### Objetivo
Verificar que TODO FUNCIONA en vivo

### Lunes-Miércoles: Configuración
- [ ] Verificar que MySQL esté corriendo
- [ ] Verificar que servidor esté corriendo: `dotnet run`
- [ ] Abrir Postman
- [ ] Leer `GUIA_PRUEBA_OPERACIONES.md` (CONFIGURACIÓN PREVIA) - 10 min

### Lunes: Operación 1 (Registrar Cliente)
- [ ] Seguir pasos en `GUIA_PRUEBA_OPERACIONES.md` (OP 1)
- [ ] Crear 3 clientes diferentes
- [ ] Verificar error cuando email existe
- [ ] Verificar en MySQL que se guardó
- [ ] **Tiempo: 45 minutos**
- [ ] ✅ Checklist: Completado

### Martes: Operación 2 (Registrar Técnico)
- [ ] Seguir pasos en `GUIA_PRUEBA_OPERACIONES.md` (OP 2)
- [ ] Crear 2 técnicos diferentes
- [ ] Verificar tarifa se guarda correctamente
- [ ] Verificar en MySQL
- [ ] **Tiempo: 30 minutos**
- [ ] ✅ Checklist: Completado

### Miércoles: Operación 6 (Login)
- [ ] Seguir pasos en `GUIA_PRUEBA_OPERACIONES.md` (OP 6)
- [ ] Login exitoso con cliente
- [ ] Copiar token a Postman environment
- [ ] Intentar login con password incorrecto
- [ ] Guardar token en variable `{{token}}`
- [ ] **Tiempo: 45 minutos**
- [ ] ✅ Checklist: Completado

### Jueves: Operaciones 3 + 5 (Perfil)
- [ ] Seguir pasos en `GUIA_PRUEBA_OPERACIONES.md` (OP 3)
- [ ] GET /api/clients/1 con token
- [ ] Guardar respuesta en archivo
- [ ] PUT /api/clients/1 (cambiar email)
- [ ] Verificar cambio con GET nuevamente
- [ ] **Tiempo: 45 minutos**
- [ ] ✅ Checklist: Completado

### Viernes: Operación 4 (Buscar Técnicos)
- [ ] Seguir pasos en `GUIA_PRUEBA_OPERACIONES.md` (OP 4)
- [ ] GET /api/technicians (sin filtro)
- [ ] GET /api/technicians?service=X (con filtro)
- [ ] Verificar orden (calificación desc, tarifa asc)
- [ ] **Tiempo: 30 minutos**
- [ ] ✅ Checklist: Completado

### Fin de semana: Operaciones 7 + 8
- [ ] Seguir pasos en `GUIA_PRUEBA_OPERACIONES.md` (OP 7)
- [ ] POST /api/contractions (crear solicitud)
- [ ] Verificar en MySQL
- [ ] GET /api/contractions/client/1 (ver solicitudes)
- [ ] Verificar los JOINs en la respuesta
- [ ] **Tiempo: 60 minutos**
- [ ] ✅ Checklist: Completado

**TOTAL SEMANA 3: ~295 minutos (5 horas)**

---

## 📅 SEMANA 4: PREPARACIÓN PARA DEFENSA

### Objetivo
Estar 100% listo para presentar

### Lunes-Martes: Preparación Teórica
- [ ] Leer `GUIA_DEFENSA.md` (INTRODUCCIÓN) - 20 min
- [ ] Leer `GUIA_DEFENSA.md` (PARTES 1-3) - 45 min
- [ ] Leer `GUIA_DEFENSA.md` (PARTES 4-8) - 60 min
- [ ] Leer `GUIA_DEFENSA.md` (PREGUNTAS COMUNES) - 30 min
- [ ] **Tiempo total: 155 minutos (~2.5 horas)**
- [ ] ✅ Aprendiste las respuestas sugeridas

### Miércoles: Practicar Presentación
- [ ] Grabar tu presentación (15 min) - primero intento
- [ ] Ver el video y anotar errores
- [ ] Practicar nuevamente (15 min) - segundo intento
- [ ] Ver el video (más fluido)
- [ ] Practicar una tercera vez (15 min) - final
- [ ] **Tiempo total: 60 minutos**
- [ ] ✅ Ya la presentas con fluidez

### Jueves: Demo en Vivo
- [ ] Preparar Postman con 5 requests clave
- [ ] Preparar terminal con servidor corriendo
- [ ] Preparar MySQL Workbench
- [ ] Hacer una "defensa en seco" (tú solo, grabado)
- [ ] Ver el video y mejorar
- [ ] **Tiempo total: 75 minutos**
- [ ] ✅ La demo funciona perfectamente

### Viernes: Últimas Preparaciones
- [ ] Revisar RESUMEN_OPERACIONES_SQL.md (repaso rápido) - 15 min
- [ ] Revisar las 5 preguntas más comunes - 15 min
- [ ] Preparar laptop/proyecto (limpiar pantalla, fondos) - 15 min
- [ ] Preparar presentación visual (si aún no la tienes) - 45 min
- [ ] Verificar que todo esté en la USB - 10 min
- [ ] Dormir temprano - 8 horas 😴
- [ ] **Tiempo total: 100 minutos**
- [ ] ✅ Estás 100% listo

### Fin de semana antes de la defensa
- [ ] Lunes: Último repaso rápido (30 min)
- [ ] Martes: Descansar, no estudiar
- [ ] Miércoles: DEFENSA 🎤
- [ ] **Tiempo total: 30 minutos**

**TOTAL SEMANA 4: ~420 minutos (7 horas)**

---

## 📊 RESUMEN POR SEMANA

| Semana | Objetivo | Horas |
|--------|----------|-------|
| 1 | Comprensión | 1.5 |
| 2 | Profundización | 5+ |
| 3 | Práctica | 5 |
| 4 | Defensa | 7 |
| **TOTAL** | **Estar Listo** | **~19 horas** |

---

## 🎯 CHECKLIST DIARIO

### Plantilla para cada día:

```
📅 LUNES [SEMANA X]
━━━━━━━━━━━━━━━━━

Objetivo: [Especificar]

✅ Tarea 1: ___________
   Tiempo: ___ min
   Completada: [ ]

✅ Tarea 2: ___________
   Tiempo: ___ min
   Completada: [ ]

✅ Tarea 3: ___________
   Tiempo: ___ min
   Completada: [ ]

Nota personal:
_____________________

Total hoy: ___ minutos
```

---

## 📈 PROGRESO ESPERADO

### Semana 1
- [ ] Entiendes qué es SERVITEC
- [ ] Conoces las 8 operaciones por nombre
- [ ] Reconoces las tablas principales
- **Meta: Comprensión 40%**

### Semana 2
- [ ] Entiendes cómo funciona cada operación
- [ ] Reconoces el código SQL en los archivos
- [ ] Comprendes la seguridad
- **Meta: Comprensión 80%**

### Semana 3
- [ ] PRUEBAS todas las operaciones
- [ ] Ves funcionar el sistema completo
- [ ] Identificas dónde está cada parte
- **Meta: Comprensión 100% + Confianza 60%**

### Semana 4
- [ ] Presentas con confianza
- [ ] Responde preguntas sin dudas
- [ ] Demuestras en vivo
- **Meta: Confianza 100% + Éxito ✅**

---

## 🚨 SEÑALES DE ALERTA

### Si tienes problemas, ajusta:

**"No entiendo el SQL"**
- [ ] Releer REPORTE_SCRIPT_CONEXION_ADONET.md lentamente
- [ ] Ver tutorial en YouTube de "MySQL SELECT statement"
- [ ] Pregunta al profesor en clase

**"No entiendo C#"**
- [ ] Focus en DIAGRAMA_VISUAL_OPERACIONES.md
- [ ] No necesitas entender C# perfectamente
- [ ] Entiende la lógica (validaciones, encriptación)

**"No funciona el servidor"**
- [ ] Verificar MySQL está corriendo
- [ ] Verificar connection string en appsettings.json
- [ ] Ver logs de error en terminal
- [ ] Pedir ayuda al profesor

**"No sé qué preguntar"**
- [ ] Leer GUIA_DEFENSA.md (Preguntas Comunes)
- [ ] Practicar las respuestas sugeridas
- [ ] Grabar un video respondiendo

---

## 💪 TIPS MOTIVACIONALES

### Semana 1
> "Solo es información. Tómatelo con calma."

### Semana 2
> "Ya entiendes la mayoría. Ahora es detalles."

### Semana 3
> "¡Lo más emocionante! Ver tu proyecto funcionar."

### Semana 4
> "Ya casi terminas. Una más y habrás completado todo."

### Día de la defensa
> "Preparaste esto durante 4 semanas. Vas a estar excelente. 💯"

---

## 🎁 BONUS: DOCUMENTOS PARA IMPRIMIR

Recomendado tener impresos:

- [ ] RESUMEN_OPERACIONES_SQL.md (llevar a la defensa)
- [ ] GUIA_DEFENSA.md (para practicar)
- [ ] Tu mapa mental de las 8 operaciones
- [ ] Diagrama ER en A4
- [ ] Checklist de pruebas (marcar cuando completes)

---

## 📱 RECORDATORIOS

Envíate estos recordatorios a ti mismo:

**Semana 1, Lunes:**
> Hoy comienzan 4 semanas de preparación. ¡Vamos! 💪

**Semana 2, Lunes:**
> Ya entiendes qué es. Ahora entra el código. You got this! 🚀

**Semana 3, Lunes:**
> Esta es la semana más emocionante. ¡Prueba todo! ✨

**Semana 4, Lunes:**
> Última recta. Vamos a pulir detalles. 🎯

**Día de la defensa:**
> 4 semanas de preparación llegaron a este momento. 
> Respira profundo. Vas a estar increíble. 🌟

---

## ✅ CHECKLIST FINAL

**Antes de presentar, verifica:**

- [ ] Completaste TODAS las tareas de las 4 semanas
- [ ] Practicaste la presentación mínimo 3 veces
- [ ] Ejecutaste TODOS los tests (8 operaciones)
- [ ] Respondiste las 10 preguntas comunes
- [ ] Tienen acceso a todos los documentos (USB + nube)
- [ ] Laptop con código limpio y compilado
- [ ] Postman con 5 requests preparadas
- [ ] MySQL con datos de prueba
- [ ] Grabación de tu presentación (para practicar)
- [ ] Traje limpio y profesional

**Si checkeas todo: ✅ ESTÁS LISTO**

---

**Cronograma creado:** Diciembre 2024  
**Versión:** 1.0  
**Estado:** ✅ LISTO PARA SEGUIR

---

🎓 **ÉXITO EN TU PREPARACIÓN** 🎓

*Recuerda: 4 semanas de dedicación = una defensa excelente*
