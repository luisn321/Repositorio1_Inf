using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using ServitecAPI.DTOs;
using ServitecAPI.Models;
using ServitecAPI.Repositories;
using ServitecAPI.Validators;

namespace ServitecAPI.Services
{
    public class AuthService : IAuthService
    {
        private readonly IConfiguration _config;
        private readonly IUserRepository _userRepository;
        private readonly DatabaseService _db;
        private readonly ILogger<AuthService> _logger;

        public AuthService(
            IConfiguration config,
            IUserRepository userRepository,
            DatabaseService db,
            ILogger<AuthService> logger)
        {
            _config = config;
            _userRepository = userRepository;
            _db = db;
            _logger = logger;
        }

        public async Task<AuthResponse> LoginAsync(LoginRequest request)
        {
            try
            {
                // Validar email
                if (!EmailValidator.IsValid(request.Correo))
                    throw new InvalidOperationException("Correo inválido");

                // Buscar usuario
                var user = await _userRepository.GetByEmailAsync(request.Correo);
                if (user == null)
                    throw new InvalidOperationException("Usuario no encontrado");

                // Verificar contraseña
                if (!_db.VerifyPassword(request.Contrasena, user.Contrasena))
                    throw new InvalidOperationException("Contraseña incorrecta");

                // Generar token
                var token = GenerateToken(user.IdUsuario, user.Email, user.TipoUsuario);

                _logger.LogInformation($" Usuario {user.Email} inició sesión correctamente");
                _logger.LogInformation($"   ├─ IdUsuario: {user.IdUsuario}");
                _logger.LogInformation($"   ├─ TipoUsuario: {user.TipoUsuario}");
                _logger.LogInformation($"   └─ Nombre: {user.Nombre}");

                return new AuthResponse
                {
                    Token = token,
                    TipoUsuario = user.TipoUsuario,
                    IdUsuario = user.IdUsuario,
                    Nombre = user.Nombre,
                    Correo = user.Email,
                    Latitud = user.Latitud,
                    Longitud = user.Longitud
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($" Error en inicio de sesión: {ex.Message}");
                throw;
            }
        }

        public async Task<AuthResponse> RegisterClientAsync(RegisterClientRequest request)
        {
            try
            {
                // Validaciones
                if (string.IsNullOrWhiteSpace(request.Nombre))
                    throw new InvalidOperationException("Nombre es requerido");

                if (!EmailValidator.IsValid(request.Correo))
                    throw new InvalidOperationException("Correo inválido");

                if (!PasswordValidator.IsValid(request.Contrasena))
                    throw new InvalidOperationException(PasswordValidator.GetValidationMessage());

                if (!string.IsNullOrEmpty(request.Telefono) && !PhoneValidator.IsValid(request.Telefono))
                    throw new InvalidOperationException("Teléfono inválido");

                // Verificar que el email no exista
                if (await _userRepository.ExistsAsync(request.Correo))
                    throw new InvalidOperationException("Correo ya registrado");

                // Crear usuario
                var user = new UserModel
                {
                    Nombre = request.Nombre,
                    Apellido = request.Apellido,
                    Email = request.Correo,
                    Contrasena = _db.HashPassword(request.Contrasena),
                    Telefono = request.Telefono,
                    TipoUsuario = "cliente",
                    DireccionText = request.DireccionTexto,
                    Latitud = request.Latitud,
                    Longitud = request.Longitud
                };

                var userId = await _userRepository.CreateClientAsync(user);

                // Generar token
                var token = GenerateToken(userId, user.Email, "cliente");

                _logger.LogInformation($" Cliente registrado: {request.Correo}");

                return new AuthResponse
                {
                    Token = token,
                    TipoUsuario = "cliente",
                    IdUsuario = userId,
                    Nombre = request.Nombre,
                    Correo = request.Correo,
                    Latitud = request.Latitud,
                    Longitud = request.Longitud
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($" Error registrando cliente: {ex.Message}");
                throw;
            }
        }

        public async Task<AuthResponse> RegisterTechnicianAsync(RegisterTechnicianRequest request)
        {
            try
            {
                // Validaciones
                if (string.IsNullOrWhiteSpace(request.Nombre))
                    throw new InvalidOperationException("Nombre es requerido");

                if (string.IsNullOrWhiteSpace(request.Apellido))
                    throw new InvalidOperationException("Apellido es requerido");

                if (!EmailValidator.IsValid(request.Correo))
                    throw new InvalidOperationException("Correo inválido");

                if (!PasswordValidator.IsValid(request.Contrasena))
                    throw new InvalidOperationException(PasswordValidator.GetValidationMessage());

                if (!string.IsNullOrEmpty(request.Telefono) && !PhoneValidator.IsValid(request.Telefono))
                    throw new InvalidOperationException("Teléfono inválido");

                if (request.TarifaHora <= 0)
                    throw new InvalidOperationException("La tarifa debe ser mayor a 0");

                // Verificar que el email no exista
                if (await _userRepository.ExistsAsync(request.Correo))
                    throw new InvalidOperationException("Correo ya registrado");

                // Crear usuario
                var user = new UserModel
                {
                    Nombre = request.Nombre,
                    Apellido = request.Apellido,
                    Email = request.Correo,
                    Contrasena = _db.HashPassword(request.Contrasena),
                    Telefono = request.Telefono,
                    TipoUsuario = "tecnico",
                    UbicacionText = request.UbicacionTexto,
                    Latitud = request.Latitud,
                    Longitud = request.Longitud,
                    TarifaHora = request.TarifaHora,
                    AnosExperiencia = request.AnosExperiencia,
                    Descripcion = request.Descripcion
                };

                var techId = await _userRepository.CreateTechnicianAsync(user, request.IdServicios);

                // Generar token
                var token = GenerateToken(techId, user.Email, "tecnico");

                _logger.LogInformation($" Técnico registrado: {request.Correo}");

                return new AuthResponse
                {
                    Token = token,
                    TipoUsuario = "tecnico",
                    IdUsuario = techId,
                    Nombre = request.Nombre,
                    Correo = request.Correo,
                    Latitud = request.Latitud,
                    Longitud = request.Longitud
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($" Error registrando técnico: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> ValidateTokenAsync(string token)
        {
            try
            {
                var jwtSecret = _config["JWT:Secret"];
                var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret ?? ""));

                var handler = new JwtSecurityTokenHandler();
                handler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = key,
                    ValidateIssuer = true,
                    ValidIssuer = "Servitec",
                    ValidateAudience = true,
                    ValidAudience = "ServitecApp",
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                }, out SecurityToken validatedToken);

                return validatedToken is JwtSecurityToken;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Token validation error: {ex.Message}");
                return false;
            }
        }

        public int? GetUserIdFromToken(string token)
        {
            try
            {
                var handler = new JwtSecurityTokenHandler();
                var jwtToken = handler.ReadJwtToken(token);
                var userIdClaim = jwtToken.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);

                return userIdClaim != null && int.TryParse(userIdClaim.Value, out var userId)
                    ? userId
                    : null;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error extracting user ID from token: {ex.Message}");
                return null;
            }
        }

        public string? GetUserTypeFromToken(string token)
        {
            try
            {
                var handler = new JwtSecurityTokenHandler();
                var jwtToken = handler.ReadJwtToken(token);
                var userTypeClaim = jwtToken.Claims.FirstOrDefault(c => c.Type == "user_type");

                return userTypeClaim?.Value;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error extracting user type from token: {ex.Message}");
                return null;
            }
        }

        public async Task<dynamic?> UpdateClientProfileAsync(UpdateProfileRequest request)
        {
            try
            {
                _logger.LogInformation($"Updating client profile for ID: {request.Id}");

                // Obtener cliente actual
                var clienteParams = new Dictionary<string, object> { { "@id", request.Id } };
                var cliente = await _db.ExecuteQueryAsync(
                    "SELECT * FROM clientes WHERE id_cliente = @id",
                    clienteParams
                );

                if (cliente == null || cliente.Count == 0)
                    return null;

              
                if (!string.IsNullOrEmpty(request.ContrasenaNueva))
                {
                    if (string.IsNullOrEmpty(request.ContrasenaActual))
                        throw new InvalidOperationException("Se requiere contraseña actual para cambiar la contraseña");

                    var currentPassword = cliente[0]["password_hash"]?.ToString();
                    if (string.IsNullOrEmpty(currentPassword) || !_db.VerifyPassword(request.ContrasenaActual, currentPassword))
                        throw new InvalidOperationException("Contraseña actual incorrecta");
                }

               
                var updates = new List<string>();
                var parameters = new Dictionary<string, object> { { "@id", request.Id } };

                if (!string.IsNullOrEmpty(request.Nombre))
                {
                    updates.Add("nombre = @nombre");
                    parameters["@nombre"] = request.Nombre;
                }

                if (!string.IsNullOrEmpty(request.Apellido))
                {
                    updates.Add("apellido = @apellido");
                    parameters["@apellido"] = request.Apellido;
                }

                if (!string.IsNullOrEmpty(request.Correo))
                {
                    updates.Add("email = @correo");
                    parameters["@correo"] = request.Correo;
                }

                if (!string.IsNullOrEmpty(request.Telefono))
                {
                    updates.Add("telefono = @telefono");
                    parameters["@telefono"] = request.Telefono;
                }

                if (!string.IsNullOrEmpty(request.Ubicacion))
                {
                    updates.Add("direccion_text = @ubicacion");
                    parameters["@ubicacion"] = request.Ubicacion;
                }

                if (!string.IsNullOrEmpty(request.ContrasenaNueva))
                {
                    var passwordHash = _db.HashPassword(request.ContrasenaNueva);
                    updates.Add("password_hash = @password");
                    parameters["@password"] = passwordHash;
                }

                if (!string.IsNullOrEmpty(request.FotoPerfilUrl))
                {
                    updates.Add("foto_perfil_url = @foto");
                    parameters["@foto"] = request.FotoPerfilUrl;
                }

                if (updates.Count > 0)
                {
                    var query = $"UPDATE clientes SET {string.Join(", ", updates)} WHERE id_cliente = @id";
                    await _db.ExecuteNonQueryAsync(query, parameters);
                    _logger.LogInformation($"Client profile updated successfully: {request.Id}");
                }

                
                var clienteActualizadoParams = new Dictionary<string, object> { { "@id", request.Id } };
                var clienteActualizado = await _db.ExecuteQueryAsync(
                    @"SELECT 
                        id_cliente as IdUsuario,
                        nombre as Nombre,
                        apellido as Apellido,
                        email as Correo,
                        'cliente' as TipoUsuario,
                        telefono as Telefono,
                        direccion_text as DireccionTexto,
                        latitud as Latitud,
                        longitud as Longitud,
                        foto_perfil_url as FotoPerfilUrl
                    FROM clientes
                    WHERE id_cliente = @id",
                    clienteActualizadoParams
                );

                return clienteActualizado?.FirstOrDefault();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating client profile: {ex.Message}");
                throw;
            }
        }

        public async Task<dynamic?> UpdateTechnicianProfileAsync(UpdateProfileRequest request)
        {
            try
            {
                _logger.LogInformation($"Updating technician profile for ID: {request.Id}");

               
                var tecnicoParams = new Dictionary<string, object> { { "@id", request.Id } };
                var tecnico = await _db.ExecuteQueryAsync(
                    "SELECT * FROM tecnicos WHERE id_tecnico = @id",
                    tecnicoParams
                );

                if (tecnico == null || tecnico.Count == 0)
                    return null;

                
                if (!string.IsNullOrEmpty(request.ContrasenaNueva))
                {
                    if (string.IsNullOrEmpty(request.ContrasenaActual))
                        throw new InvalidOperationException("Se requiere contraseña actual para cambiar la contraseña");

                    var currentPassword = tecnico[0]["password_hash"]?.ToString();
                    if (string.IsNullOrEmpty(currentPassword) || !_db.VerifyPassword(request.ContrasenaActual, currentPassword))
                        throw new InvalidOperationException("Contraseña actual incorrecta");
                }

               
                var updates = new List<string>();
                var parameters = new Dictionary<string, object> { { "@id", request.Id } };

                if (!string.IsNullOrEmpty(request.Nombre))
                {
                    updates.Add("nombre = @nombre");
                    parameters["@nombre"] = request.Nombre;
                }

                if (!string.IsNullOrEmpty(request.Apellido))
                {
                    updates.Add("apellido = @apellido");
                    parameters["@apellido"] = request.Apellido;
                }

                if (!string.IsNullOrEmpty(request.Correo))
                {
                    updates.Add("email = @correo");
                    parameters["@correo"] = request.Correo;
                }

                if (!string.IsNullOrEmpty(request.Telefono))
                {
                    updates.Add("telefono = @telefono");
                    parameters["@telefono"] = request.Telefono;
                }

                if (!string.IsNullOrEmpty(request.Ubicacion))
                {
                    updates.Add("ubicacion_text = @ubicacion");
                    parameters["@ubicacion"] = request.Ubicacion;
                }

                if (request.TarifaHora.HasValue)
                {
                    updates.Add("tarifa_hora = @tarifa");
                    parameters["@tarifa"] = request.TarifaHora.Value;
                }

                if (!string.IsNullOrEmpty(request.Descripcion))
                {
                    updates.Add("descripcion = @descripcion");
                    parameters["@descripcion"] = request.Descripcion;
                }

                if (request.AnosExperiencia.HasValue)
                {
                    updates.Add("experiencia_years = @anos");
                    parameters["@anos"] = request.AnosExperiencia.Value;
                }

                if (!string.IsNullOrEmpty(request.ContrasenaNueva))
                {
                    var passwordHash = _db.HashPassword(request.ContrasenaNueva);
                    updates.Add("password_hash = @password");
                    parameters["@password"] = passwordHash;
                }

                if (!string.IsNullOrEmpty(request.FotoPerfilUrl))
                {
                    updates.Add("foto_perfil_url = @foto");
                    parameters["@foto"] = request.FotoPerfilUrl;
                }

                if (updates.Count > 0)
                {
                    var query = $"UPDATE tecnicos SET {string.Join(", ", updates)} WHERE id_tecnico = @id";
                    await _db.ExecuteNonQueryAsync(query, parameters);
                    _logger.LogInformation($"✅ Perfil de técnico actualizado: {request.Id}");
                }

                // Obtener datos actualizados
                var tecnicoActualizadoParams = new Dictionary<string, object> { { "@id", request.Id } };
                var tecnicoActualizado = await _db.ExecuteQueryAsync(
                    @"SELECT 
                        id_tecnico as IdUsuario,
                        nombre as Nombre,
                        apellido as Apellido,
                        email as Correo,
                        'tecnico' as TipoUsuario,
                        telefono as Telefono,
                        ubicacion_text as UbicacionTexto,
                        latitud as Latitud,
                        longitud as Longitud,
                        tarifa_hora as TarifaHora,
                        descripcion as Descripcion,
                        experiencia_years as AnosExperiencia,
                        calificacion_promedio as CalificacionPromedio,
                        foto_perfil_url as FotoPerfilUrl
                    FROM tecnicos
                    WHERE id_tecnico = @id",
                    tecnicoActualizadoParams
                );

                return tecnicoActualizado?.FirstOrDefault();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating technician profile: {ex.Message}");
                throw;
            }
        }

        public async Task<dynamic?> GetUserProfileAsync(int userId, string userType)
        {
            try
            {
                _logger.LogInformation($"Getting user profile for ID: {userId}, Type: {userType}");

                // Normalizar userType para comparación
                string normalizedType = userType.ToLower();
                
                // Determinar si es técnico o cliente basado en el userType del JWT
                if (normalizedType == "tecnico" || normalizedType == "technician") 
                {
                    // Obtener datos del técnico
                    var tecnicoParams = new Dictionary<string, object> { { "@id", userId } };
                    var tecnico = await _db.ExecuteQueryAsync(
                        @"SELECT 
                            id_tecnico as IdUsuario,
                            nombre as Nombre,
                            apellido as Apellido,
                            email as Correo,
                            'tecnico' as TipoUsuario,
                            telefono as Telefono,
                            ubicacion_text as UbicacionTexto,
                            latitud as Latitud,
                            longitud as Longitud,
                            tarifa_hora as TarifaHora,
                            descripcion as Descripcion,
                            experiencia_years as AnosExperiencia,
                            calificacion_promedio as CalificacionPromedio,
                            foto_perfil_url as FotoPerfilUrl
                        FROM tecnicos
                        WHERE id_tecnico = @id",
                        tecnicoParams
                    );

                    if (tecnico != null && tecnico.Count > 0)
                    {
                        _logger.LogInformation($"Perfil de técnico encontrado para ID: {userId}");
                        return tecnico.FirstOrDefault();
                    }
                }
                else
                {
                    // Obtener datos del cliente
                    var clienteParams = new Dictionary<string, object> { { "@id", userId } };
                    var cliente = await _db.ExecuteQueryAsync(
                        @"SELECT 
                            id_cliente as IdUsuario,
                            nombre as Nombre,
                            apellido as Apellido,
                            email as Correo,
                            'cliente' as TipoUsuario,
                            telefono as Telefono,
                            direccion_text as DireccionTexto,
                            latitud as Latitud,
                            longitud as Longitud,
                            foto_perfil_url as FotoPerfilUrl
                        FROM clientes
                        WHERE id_cliente = @id",
                        clienteParams
                    );

                    if (cliente != null && cliente.Count > 0)
                    {
                        _logger.LogInformation($" Perfil de cliente encontrado para ID: {userId}");
                        return cliente.FirstOrDefault();
                    }
                }

                _logger.LogWarning($"User profile not found for ID: {userId}");
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting user profile: {ex.Message}");
                throw;
            }
        }

        private string GenerateToken(int userId, string email, string userType)
        {
            var jwtSecret = _config["JWT:Secret"] ?? throw new InvalidOperationException("JWT Secret not configured");
            var jwtExpiry = int.TryParse(_config["JWT:ExpiryDays"], out var days) ? days : 30;

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecret));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
                new Claim(ClaimTypes.Email, email),
                new Claim("user_type", userType)
            };

            var token = new JwtSecurityToken(
                issuer: "Servitec",
                audience: "ServitecApp",
                claims: claims,
                expires: DateTime.UtcNow.AddDays(jwtExpiry),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
