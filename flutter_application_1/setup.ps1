# Script de instalación automática para Servitec App
# Ejecutar con: powershell -ExecutionPolicy Bypass -File setup.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  INSTALADOR AUTOMÁTICO - SERVITEC APP  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si Flutter está instalado
Write-Host "[1/4] Verificando Flutter..." -ForegroundColor Yellow
$flutterCheck = flutter --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Flutter instalado: $($flutterCheck[0])" -ForegroundColor Green
} else {
    Write-Host "✗ Flutter no encontrado. Por favor instala Flutter desde https://flutter.dev" -ForegroundColor Red
    exit 1
}

# Instalar dependencias de Flutter
Write-Host "[2/4] Instalando dependencias de Flutter..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dependencias de Flutter instaladas" -ForegroundColor Green
} else {
    Write-Host "✗ Error al instalar dependencias de Flutter" -ForegroundColor Red
    exit 1
}

# Verificar si .NET está instalado
Write-Host "[3/4] Verificando .NET Core..." -ForegroundColor Yellow
$dotnetCheck = dotnet --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ .NET Core instalado: $dotnetCheck" -ForegroundColor Green
} else {
    Write-Host "✗ .NET Core no encontrado. Por favor instala desde https://dotnet.microsoft.com" -ForegroundColor Red
    exit 1
}

# Instalar dependencias del backend
Write-Host "[4/4] Instalando dependencias del backend (.NET)..." -ForegroundColor Yellow
if (Test-Path ".\backend-csharp\ServitecAPI.csproj") {
    cd backend-csharp
    dotnet restore
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Dependencias del backend instaladas" -ForegroundColor Green
    } else {
        Write-Host "✗ Error al instalar dependencias del backend" -ForegroundColor Red
        cd ..
        exit 1
    }
    cd ..
} else {
    Write-Host "⚠ Proyecto backend no encontrado en backend-csharp" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✓ INSTALACIÓN COMPLETADA EXITOSAMENTE " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Ejecutar backend: cd backend-csharp && dotnet run" -ForegroundColor White
Write-Host "2. En otra terminal, ejecutar app: flutter run" -ForegroundColor White
Write-Host ""
