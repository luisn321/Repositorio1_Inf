@echo off
REM Script de instalaci?n autom?tica para Servitec App - Batch (Windows CMD)
REM Hacer clic derecho "Ejecutar como administrador" para mejor compatibilidad

setlocal enabledelayedexpansion

echo ========================================
echo   INSTALADOR AUTOMATICO - SERVITEC APP
echo ========================================
echo.

REM Verificar Flutter
echo [1/4] Verificando Flutter...
flutter --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('flutter --version') do set FLUTTER_VERSION=%%i
    echo [OK] !FLUTTER_VERSION!
) else (
    echo [ERROR] Flutter no encontrado. Descarga desde https://flutter.dev
    pause
    exit /b 1
)

REM Instalar dependencias Flutter
echo [2/4] Instalando dependencias de Flutter...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Fallo al instalar dependencias de Flutter
    pause
    exit /b 1
)
echo [OK] Dependencias de Flutter instaladas

REM Verificar .NET
echo [3/4] Verificando .NET Core...
dotnet --version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%i in ('dotnet --version') do set DOTNET_VERSION=%%i
    echo [OK] .NET instalado: !DOTNET_VERSION!
) else (
    echo [ERROR] .NET Core no encontrado. Descarga desde https://dotnet.microsoft.com
    pause
    exit /b 1
)

REM Instalar dependencias backend
echo [4/4] Instalando dependencias del backend ...NET...
if exist backend-csharp\ServitecAPI.csproj (
    cd backend-csharp
    call dotnet restore
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Fallo al instalar dependencias del backend
        pause
        exit /b 1
    )
    cd ..
    echo [OK] Dependencias del backend instaladas
) else (
    echo [ADVERTENCIA] Proyecto backend no encontrado
)

echo.
echo ========================================
echo   [OK] INSTALACION COMPLETADA
echo ========================================
echo.
echo Proximos pasos:
echo 1. Backend: cd backend-csharp ^&^& dotnet run
echo 2. App:     flutter run
echo.
pause
