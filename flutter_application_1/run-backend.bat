@echo off
cd backend-csharp
echo ========================================
echo Iniciando servidor Servitec (C# API)
echo ========================================
dotnet run --urls "http://0.0.0.0:3000" --no-restore
