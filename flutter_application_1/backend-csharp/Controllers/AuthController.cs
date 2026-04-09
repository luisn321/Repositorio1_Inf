using Microsoft.AspNetCore.Mvc;
using ServitecAPI.DTOs;
using ServitecAPI.Services;

namespace ServitecAPI.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            try
            {
                _logger.LogInformation($"Intento de inicio de sesión para correo: {request.Correo}");

                var response = await _authService.LoginAsync(request);

                _logger.LogInformation($"Inicio de sesión exitoso para usuario: {request.Correo}");

                return Ok(response);
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"Error de validación en inicio de sesión: {ex.Message}");
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en inicio de sesión: {ex.Message}");
                return StatusCode(500, new { error = "Ocurrió un error durante el inicio de sesión" });
            }
        }

        [HttpPost("register/client")]
        public async Task<IActionResult> RegisterClient([FromBody] RegisterClientRequest request)
        {
            try
            {
                _logger.LogInformation($"Intento de registro de cliente para correo: {request.Correo}");

                var response = await _authService.RegisterClientAsync(request);

                _logger.LogInformation($"Cliente registrado exitosamente: {request.Correo}");

                return Ok(response);
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"Error de validación en registro: {ex.Message}");
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en registro: {ex.Message}");
                return StatusCode(500, new { error = "Ocurrió un error durante el registro" });
            }
        }

        [HttpPost("register/technician")]
        public async Task<IActionResult> RegisterTechnician([FromBody] RegisterTechnicianRequest request)
        {
            try
            {
                _logger.LogInformation($"Intento de registro de técnico para correo: {request.Correo}");

                var response = await _authService.RegisterTechnicianAsync(request);

                _logger.LogInformation($"Técnico registrado exitosamente: {request.Correo}");

                return Ok(response);
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"Error de validación en registro: {ex.Message}");
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en registro: {ex.Message}");
                return StatusCode(500, new { error = "Ocurrió un error durante el registro" });
            }
        }

        [HttpGet("validate-token")]
        public async Task<IActionResult> ValidateToken()
        {
            try
            {
                var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");

                if (string.IsNullOrEmpty(token))
                    return Unauthorized(new { error = "Token not provided" });

                var isValid = await _authService.ValidateTokenAsync(token);

                if (!isValid)
                    return Unauthorized(new { error = "Invalid token" });

                var userId = _authService.GetUserIdFromToken(token);

                return Ok(new { valid = true, userId = userId });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Token validation error: {ex.Message}");
                return StatusCode(500, new { error = "An error occurred during token validation" });
            }
        }

        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");

                if (string.IsNullOrEmpty(token))
                    return Unauthorized(new { error = "Token not provided" });

                var userId = _authService.GetUserIdFromToken(token);
                if (!userId.HasValue)
                    return Unauthorized(new { error = "Invalid token" });

                var userType = _authService.GetUserTypeFromToken(token);
                if (string.IsNullOrEmpty(userType))
                    return Unauthorized(new { error = "Invalid user type in token" });

                _logger.LogInformation($"Getting profile for user ID: {userId}, Type: {userType}");

                var profile = await _authService.GetUserProfileAsync(userId.Value, userType);

                if (profile == null)
                    return NotFound(new { error = "User not found" });

                return Ok(profile);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Get profile error: {ex.Message}");
                return StatusCode(500, new { error = "An error occurred while retrieving profile" });
            }
        }

        [HttpPut("update-profile/client")]
        public async Task<IActionResult> UpdateClientProfile([FromBody] UpdateProfileRequest request)
        {
            try
            {
                _logger.LogInformation($"Updating client profile for ID: {request.Id}");

                var response = await _authService.UpdateClientProfileAsync(request);

                if (response == null)
                    return NotFound(new { error = "Client not found" });

                _logger.LogInformation($"Client profile updated successfully: {request.Id}");

                return Ok(new { success = true, data = response });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"Update profile validation error: {ex.Message}");
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Update profile error: {ex.Message}");
                return StatusCode(500, new { error = "An error occurred during profile update" });
            }
        }

        [HttpPut("update-profile/technician")]
        public async Task<IActionResult> UpdateTechnicianProfile([FromBody] UpdateProfileRequest request)
        {
            try
            {
                _logger.LogInformation($"Updating technician profile for ID: {request.Id}");

                var response = await _authService.UpdateTechnicianProfileAsync(request);

                if (response == null)
                    return NotFound(new { error = "Technician not found" });

                _logger.LogInformation($"Technician profile updated successfully: {request.Id}");

                return Ok(new { success = true, data = response });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"Update profile validation error: {ex.Message}");
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Update profile error: {ex.Message}");
                return StatusCode(500, new { error = "An error occurred during profile update" });
            }
        }
    }
}
