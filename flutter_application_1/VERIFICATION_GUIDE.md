# Verification Guide - Registration & Data Flow

## Quick Overview

**Problem:** Registration data saved to database but not displaying in client app
**Solution:** Three fixes applied - response key extraction, dynamic categories, dynamic technicians

---

## Step-by-Step Verification

### Phase 1: Verify Backend is Running
```powershell
# Check if backend is running
tasklist | findstr "dotnet"

# Expected output:
# dotnet.exe                 [PID] Console  1  [Memory]

# If not running, start it:
cd "c:\Users\Luis Infante\Desktop\5TO SEMESTRE\Taller de base de datos\Unidad 6\AppServTrabajo\flutter_application_1\backend-csharp"
dotnet run
```

### Phase 2: Test Registration Endpoint Directly
```powershell
# Test client registration
$body = @{
    firstName = "Test"
    lastName = "User"
    email = "testuser@example.com"
    password = "TestPassword123!"
    telefono = "1234567890"
    direccionText = "Test Address"
    latitud = 0.0
    longitud = 0.0
} | ConvertTo-Json

curl.exe -X POST http://localhost:3000/auth/register/client `
  -H "Content-Type: application/json" `
  -d $body

# Expected response:
# {
#   "token": "eyJhbGc...",
#   "user_type": "client",
#   "id_user": 123,
#   "email": "testuser@example.com",
#   "nombre": "Test"
# }
```

### Phase 3: Verify Database Entry
```sql
-- Check in MySQL that client was created
SELECT id_cliente, nombre, email, fecha_registro 
FROM clientes 
WHERE email = 'testuser@example.com';

-- Should return one row with the new client
```

### Phase 4: Test Services Endpoint
```powershell
# Test getting services
curl.exe -X GET http://localhost:3000/services

# Expected response:
# [
#   {"id_servicio": 1, "nombre": "Electricista", ...},
#   {"id_servicio": 2, "nombre": "Plomero", ...},
#   ...
# ]
```

### Phase 5: Test Technicians Endpoint
```powershell
# Test getting technicians
curl.exe -X GET http://localhost:3000/technicians

# Expected response:
# [
#   {"id_tecnico": 1, "nombre": "Carlos Pérez", "calificacion_promedio": 4.8, ...},
#   {"id_tecnico": 2, "nombre": "Luis Gómez", "calificacion_promedio": 4.7, ...},
#   ...
# ]
```

### Phase 6: Run Flutter App
```powershell
# Build and run the Flutter app
cd "c:\Users\Luis Infante\Desktop\5TO SEMESTRE\Taller de base de datos\Unidad 6\AppServTrabajo\flutter_application_1"

# For development with logging
flutter run -v

# Or build APK for testing on device
flutter build apk --target-platform android-arm64
```

### Phase 7: Test Registration in App
1. **Launch app** and go to Register screen
2. **Fill registration form:**
   - Nombre: "Test"
   - Apellido: "User"
   - Email: "fluttertest@example.com"
   - Teléfono: "1234567890"
   - Dirección: "Test Address"
   - Password: "TestPassword123!"
   - Confirm Password: "TestPassword123!"
3. **Select location** on map
4. **Tap "Registrarse"** button
5. **Check Flutter debug console** for:
   ```
   🟠 Resultado completo del registro: {token, user_type, id_user, email, nombre}
   🟠 Cliente registrado con ID: 123
   ```

### Phase 8: Verify Data Loading
After successful registration, you should be on **ClientHomeScreen**:
1. **Check Categories section:**
   - Should display multiple category cards
   - Should be loading from `/services` endpoint (not hardcoded)
   - Categories should match database entries

2. **Check Technicians section:**
   - Should display list of technician cards
   - Should be loading from `/technicians` endpoint (not hardcoded)
   - Technicians should show real names, descriptions, ratings

3. **Check search functionality:**
   - Type technician name in search box
   - Results should filter in real-time
   - Tap result to view technician details

---

## Key Files to Reference

### Registration Logic
- **File:** `lib/Screens/RegisterScreen.dart`
- **Key Method:** `_handleRegister()` at line 267
- **Critical Line:** Line 330 - `final clientId = result['id_user'] as int?;`

### Data Loading Logic
- **File:** `lib/Screens/ClientHomeScreen.dart`
- **Categories:** Lines 224-269 (FutureBuilder for `getServices()`)
- **Technicians:** Lines 275-318 (FutureBuilder for `getTechnicians()`)

### API Service
- **File:** `lib/services/api.dart`
- **getServices():** Line 284
- **getTechnicians():** Line 304
- **searchTechnicians():** Line 334

---

## Debugging Tips

### If categories not loading:
1. Check network tab in Flutter DevTools
2. Verify `/services` endpoint returns data
3. Check database has services in `servicios` table
4. Look for error message in FutureBuilder

### If technicians not loading:
1. Check network tab in Flutter DevTools
2. Verify `/technicians` endpoint returns data
3. Check database has technicians in `tecnicos` table
4. Look for error message in FutureBuilder

### If registration fails:
1. Check backend is running: `tasklist | findstr dotnet`
2. Check backend logs for validation errors
3. Verify client response has `id_user` field
4. Check Flutter debug console for error message

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "No hay categorías disponibles" | Add services to `servicios` table in MySQL |
| "No hay técnicos disponibles" | Add technicians to `tecnicos` table in MySQL |
| Registration shows error | Check backend console logs, verify email doesn't exist |
| No navigation after registration | Check `id_user` field in response, verify response parsing |
| Blank screen after registration | Check FutureBuilder error state, look at Flutter logs |

---

## Test Checklist

- [ ] Backend server running on port 3000
- [ ] Database has test data (services, technicians)
- [ ] Register new client via app
- [ ] ClientHomeScreen displays with dynamic categories
- [ ] ClientHomeScreen displays with dynamic technicians
- [ ] Search functionality works
- [ ] Can tap category to filter technicians
- [ ] Can view technician details
- [ ] Can create service request
- [ ] Payment and rating flows work

---

## Expected Database State After Tests

### clientes table
```
id_cliente | nombre | apellido | email | telefono | direccion | latitud | longitud
-----------|--------|----------|-------|----------|-----------|---------|----------
1          | Test   | User     | fluttertest@example.com | 1234567890 | Test Address | 0.0 | 0.0
```

### servicios table (should have multiple entries)
```
id_servicio | nombre | descripcion
------------|--------|-------------
1           | Electricista | Servicios eléctricos
2           | Plomero | Servicios de plomería
3           | Carpintero | Servicios de carpintería
... (more services)
```

### tecnicos table (should have multiple entries)
```
id_tecnico | nombre | email | tarifa_hora | calificacion_promedio
-----------|--------|-------|-------------|----------------------
1          | Carlos Pérez | carlos@example.com | 25.50 | 4.8
2          | Luis Gómez | luis@example.com | 22.00 | 4.7
... (more technicians)
```

---

## Success Criteria

✅ **All tests passed if:**
1. New client is created in database after registration
2. ClientHomeScreen displays categories from API (not hardcoded)
3. ClientHomeScreen displays technicians from API (not hardcoded)
4. App navigation flows correctly through all screens
5. API endpoints respond with correct data format
6. No runtime errors in Flutter debug console
7. Search functionality filters results correctly

---

## Contact for Issues

If tests fail, check:
1. Backend logs: `backend-csharp/` folder
2. Flutter logs: VS Code Debug Console
3. Network inspector: Check API responses
4. Database logs: MySQL error logs
5. Verify endpoints: Use curl commands above
