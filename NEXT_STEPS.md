# NEXT STEPS (rápido) — Servitec

Pequeña guía con los pasos prioritarios para reanudar el trabajo cuando vuelvas.

1) Arrancar backend

   - Abrir PowerShell en `backend` y ejecutar:

     ```powershell
     cd "C:\Users\Luis Infante\Desktop\5TO SEMESTRE\Taller de base de datos\Unidad 6\AppServTrabajo\backend"
     npm run dev
     ```

   - Verificar en el navegador o con `curl`:

     ```powershell
     curl http://localhost:3000/api/health
     # Debe devolver: {"status":"API Servitec funcionando correctamente"}
     ```

2) Probar registro desde la app (web)

   - Ejecutar la app en Chrome:

     ```powershell
     cd "C:\Users\Luis Infante\Desktop\5TO SEMESTRE\Taller de base de datos\Unidad 6\AppServTrabajo\flutter_application_1"
     flutter run -d chrome
     ```

   - Abrir DevTools (F12) → pestaña Network. Intentar registrarse desde la pantalla de registro.
   - Endpoint esperado: `POST http://localhost:3000/api/auth/register/client` (o `/register/technician`).

3) Verificar en la base de datos

   - Abrir MySQL Workbench y ejecutar:

     ```sql
     SELECT id_cliente, nombre, email, password_hash
     FROM clientes
     ORDER BY id_cliente DESC
     LIMIT 5;
     ```

   - `password_hash` debe ser un hash (no texto plano). Para técnicos: tabla `tecnicos`.

4) Si algo falla

   - Revisar la consola del backend (terminal donde corre `npm run dev`) para ver el stack trace o errores SQL.
   - Si CORS da problemas en web, revisa `server.js` y confirma que `cors()` está habilitado.
   - Si la app no llega al backend desde el emulador Android, usa `10.0.2.2` como base URL.

5) Integraciones siguientes (prioritarias)

   - Integrar `RegisterScreen` → llamar a `ApiService.registerClient()` y usar `Navigator.pushReplacement` al crear la cuenta.
   - Integrar `RegisterTechnicianScreen` → cargar servicios desde API y enviar array de `service_ids`.
   - Reemplazar datos hardcode en `ServiceList`, `TechnicianList` y `TechnicianDetail` por llamadas a `ApiService`.

6) Comandos útiles y seguridad

   - Guardar cambios (git):

     ```powershell
     git add .
     git commit -m "Checkpoint: backend running; added NEXT_STEPS.md"
     git push origin main
     ```

   - Nunca subas `.env` con contraseñas al repo.

7) Cuando vuelvas

   - Revisa `NEXT_STEPS.md` y el `todo list` en la rama principal.
   - Si quieres, pídeme que implemente `RegisterScreen` con llamadas reales; puedo editarlo y probarlo.

-- Fin
