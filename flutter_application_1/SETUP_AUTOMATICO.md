#  INSTALACIÓN AUTOMÁTICA - SERVITEC APP

Cuando descargues este repositorio, puedes instalar todas las dependencias automáticamente con los scripts de setup.

##  Requisitos Previos

Antes de usar los scripts, asegúrate de tener instalados:

- **Flutter** (3.0+): https://flutter.dev/docs/get-started/install
- **.NET 9+**: https://dotnet.microsoft.com/download
- **Git**: https://git-scm.com/

##  Instrucciones por Sistema Operativo

### Windows (PowerShell)

``powershell
# Opción 1: PowerShell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
.\setup.ps1
``

### Windows (Símbolo del sistema - CMD)

``ash
# Opción 2: Doble clic en setup.bat
# O ejecutar desde CMD:
setup.bat

# Si tienes permisos de administrador, es recomendable
``

### Linux / macOS

``ash
# Dale permisos de ejecución
chmod +x setup.sh

# Ejecuta el script
./setup.sh
``

##  Qué Hace el Script de Instalación

El script realiza automáticamente:

1.  Verifica que Flutter esté instalado
2.  Instala dependencias de Flutter (\lutter pub get\)
3.  Verifica que .NET Core esté instalado
4.  Restaura dependencias del backend (.NET)

##  Ejecutar la Aplicación Después

Una vez completada la instalación:

### Terminal 1 - Backend (C#)
``ash
cd backend-csharp
dotnet run
``

### Terminal 2 - App Flutter
``ash
flutter run
``

##  Troubleshooting

Si encuentras problemas:

### Fatal: operation not permitted
``powershell
# En PowerShell, cambia la política de ejecución
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
``

### Flutter/Dotnet no encontrado
- Instala desde los links oficiales
- Reinicia el terminal después de instalar
- Verifica que estén en el PATH

### Fallo de conexión a base de datos
- Verifica que MySQL esté corriendo
- Revisa \ppsettings.json\ en \ackend-csharp/\
- Consulta la documentación completa en \DOCUMENTACION_COMPLETA.md\

##  Documentación Completa

Para más información sobre el proyecto, consulta:
- [DOCUMENTACION_COMPLETA.md](./DOCUMENTACION_COMPLETA.md)
- [GUIA_DEFENSA.md](./GUIA_DEFENSA.md)
- [README.md](./README.md)

---

**¡Listo!**  Tu aplicación Servitec debería estar completamente configurada.
