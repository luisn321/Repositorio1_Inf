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
                _logger.LogInformation($"Login attempt for email: {request.Email}");

                var response = await _authService.LoginAsync(request);

                _logger.LogInformation($"Login successful for user: {request.Email}");

                return Ok(response);
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"Login validation error: {ex.Message}");
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Login error: {ex.Message}");
                return StatusCode(500, new { error = "An error occurred during login" });
            }
        }

        [HttpPost("register/client")]
        public async Task<IActionResult> RegisterClient([FromBody] RegisterClientRequest request)
        {
            try
            {
                _logger.LogInformation($"Client registration attempt for email: {request.Email}");

                var response = await _authService.RegisterClientAsync(request);

                _logger.LogInformation($"Client registered successfully: {request.Email}");

                return Ok(response);
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"Registration validation error: {ex.Message}");
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Registration error: {ex.Message}");
                return StatusCode(500, new { error = "An error occurred during registration" });
            }
        }

        [HttpPost("register/technician")]
        public async Task<IActionResult> RegisterTechnician([FromBody] RegisterTechnicianRequest request)
        {
            try
            {
                _logger.LogInformation($"Technician registration attempt for email: {request.Email}");

                var response = await _authService.RegisterTechnicianAsync(request);

                _logger.LogInformation($"Technician registered successfully: {request.Email}");

                return Ok(response);
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"Registration validation error: {ex.Message}");
                return BadRequest(new { error = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Registration error: {ex.Message}");
                return StatusCode(500, new { error = "An error occurred during registration" });
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
    }
}
