using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace ServitecAPI.Services
{
    public class AuthService
    {
        private readonly IConfiguration _config;

        public AuthService(IConfiguration config)
        {
            _config = config;
        }

        public string GenerateToken(int userId, string email, string userType)
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
