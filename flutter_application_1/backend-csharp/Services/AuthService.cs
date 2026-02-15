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
                if (!EmailValidator.IsValid(request.Email))
                    throw new InvalidOperationException("Invalid email format");

                // Buscar usuario
                var user = await _userRepository.GetByEmailAsync(request.Email);
                if (user == null)
                    throw new InvalidOperationException("User not found");

                // Verificar contraseña
                if (!_db.VerifyPassword(request.Password, user.Contrasena))
                    throw new InvalidOperationException("Invalid password");

                // Generar token
                var token = GenerateToken(user.IdUsuario, user.Email, user.TipoUsuario);

                _logger.LogInformation($"User {user.Email} logged in successfully");

                return new AuthResponse
                {
                    Token = token,
                    UserType = user.TipoUsuario,
                    UserId = user.IdUsuario,
                    IdUser = user.IdUsuario,
                    Name = user.Nombre,
                    Email = user.Email,
                    Latitude = user.Latitud,
                    Longitude = user.Longitud
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($"Login error: {ex.Message}");
                throw;
            }
        }

        public async Task<AuthResponse> RegisterClientAsync(RegisterClientRequest request)
        {
            try
            {
                // Validaciones
                if (string.IsNullOrWhiteSpace(request.FirstName))
                    throw new InvalidOperationException("First name is required");

                if (!EmailValidator.IsValid(request.Email))
                    throw new InvalidOperationException("Invalid email format");

                if (!PasswordValidator.IsValid(request.Password))
                    throw new InvalidOperationException(PasswordValidator.GetValidationMessage());

                if (!PhoneValidator.IsValid(request.Phone))
                    throw new InvalidOperationException("Invalid phone format");

                // Verificar que el email no exista
                if (await _userRepository.ExistsAsync(request.Email))
                    throw new InvalidOperationException("Email already registered");

                // Crear usuario
                var user = new UserModel
                {
                    Nombre = request.FirstName,
                    Apellido = request.LastName,
                    Email = request.Email,
                    Contrasena = _db.HashPassword(request.Password),
                    Telefono = request.Phone,
                    TipoUsuario = "client",
                    DireccionText = request.AddressText,
                    Latitud = request.Latitude,
                    Longitud = request.Longitude
                };

                var userId = await _userRepository.CreateClientAsync(user);

                // Generar token
                var token = GenerateToken(userId, user.Email, "client");

                _logger.LogInformation($"Client registered: {request.Email}");

                return new AuthResponse
                {
                    Token = token,
                    UserType = "client",
                    UserId = userId,
                    IdUser = userId,
                    Name = request.FirstName,
                    Email = request.Email,
                    Latitude = request.Latitude,
                    Longitude = request.Longitude
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($"Client registration error: {ex.Message}");
                throw;
            }
        }

        public async Task<AuthResponse> RegisterTechnicianAsync(RegisterTechnicianRequest request)
        {
            try
            {
                // Validaciones
                if (string.IsNullOrWhiteSpace(request.Name))
                    throw new InvalidOperationException("Name is required");

                if (!EmailValidator.IsValid(request.Email))
                    throw new InvalidOperationException("Invalid email format");

                if (!PasswordValidator.IsValid(request.Password))
                    throw new InvalidOperationException(PasswordValidator.GetValidationMessage());

                if (!PhoneValidator.IsValid(request.Phone))
                    throw new InvalidOperationException("Invalid phone format");

                if (request.RatePerHour <= 0)
                    throw new InvalidOperationException("Hourly rate must be greater than 0");

                // Verificar que el email no exista
                if (await _userRepository.ExistsAsync(request.Email))
                    throw new InvalidOperationException("Email already registered");

                // Crear usuario
                var user = new UserModel
                {
                    Nombre = request.Name,
                    Email = request.Email,
                    Contrasena = _db.HashPassword(request.Password),
                    Telefono = request.Phone,
                    TipoUsuario = "technician",
                    UbicacionText = request.LocationText,
                    Latitud = request.Latitude,
                    Longitud = request.Longitude,
                    TarifaHora = request.RatePerHour
                };

                var techId = await _userRepository.CreateTechnicianAsync(user, request.ServiceIds);

                // Generar token
                var token = GenerateToken(techId, user.Email, "technician");

                _logger.LogInformation($"Technician registered: {request.Email}");

                return new AuthResponse
                {
                    Token = token,
                    UserType = "technician",
                    UserId = techId,
                    IdUser = techId,
                    Name = request.Name,
                    Email = request.Email,
                    Latitude = request.Latitude,
                    Longitude = request.Longitude
                };
            }
            catch (Exception ex)
            {
                _logger.LogError($"Technician registration error: {ex.Message}");
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
