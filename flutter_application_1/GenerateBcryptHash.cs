// Script de prueba para generar hashes BCrypt
using BCrypt.Net;

var password = "password123";
var hash = BCrypt.HashPassword(password);

Console.WriteLine($"Password: {password}");
Console.WriteLine($"Hash: {hash}");

// Insertar estos valores en la base de datos:
// Cliente: email = cliente@test.com, password_hash = {hash}
// Técnico: email = tecnico@test.com, password_hash = {hash}
