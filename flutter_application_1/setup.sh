#!/bin/bash
# Script de instalación automática para Servitec App - Linux/macOS
# Ejecutar con: bash setup.sh

set -e  # Salir si hay algún error

echo "========================================"
echo "  INSTALADOR AUTOMÁTICO - SERVITEC APP  "
echo "========================================"
echo ""

# Verificar Flutter
echo "[1/4] Verificando Flutter..."
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION= setup.bat creado(flutter --version | head -n 1)
    echo "  setup.bat creadoFLUTTER_VERSION"
else
    echo " Flutter no encontrado. Descarga desde https://flutter.dev"
    exit 1
fi

# Instalar dependencias Flutter
echo "[2/4] Instalando dependencias de Flutter..."
flutter pub get
echo " Dependencias de Flutter instaladas"

# Verificar .NET
echo "[3/4] Verificando .NET Core..."
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION= setup.bat creado(dotnet --version)
    echo " .NET Core instalado:  setup.bat creadoDOTNET_VERSION"
else
    echo " .NET Core no encontrado. Descarga desde https://dotnet.microsoft.com"
    exit 1
fi

# Instalar dependencias del backend
echo "[4/4] Instalando dependencias del backend (.NET)..."
if [ -f "backend-csharp/ServitecAPI.csproj" ]; then
    cd backend-csharp
    dotnet restore
    cd ..
    echo " Dependencias del backend instaladas"
else
    echo " Proyecto backend no encontrado en backend-csharp"
fi

echo ""
echo "========================================"
echo "   INSTALACIÓN COMPLETADA EXITOSAMENTE "
echo "========================================"
echo ""
echo "Próximos pasos:"
echo "1. Ejecutar backend: cd backend-csharp && dotnet run"
echo "2. En otra terminal, ejecutar app: flutter run"
echo ""
