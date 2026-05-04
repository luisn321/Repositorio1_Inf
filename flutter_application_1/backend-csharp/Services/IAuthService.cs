using ServitecAPI.DTOs;
using ServitecAPI.Models;

namespace ServitecAPI.Services
{
    public interface IAuthService
    {
        Task<AuthResponse> LoginAsync(LoginRequest request);
        Task<AuthResponse> RegisterClientAsync(RegisterClientRequest request);
        Task<AuthResponse> RegisterTechnicianAsync(RegisterTechnicianRequest request);
        Task<bool> ValidateTokenAsync(string token);
        int? GetUserIdFromToken(string token);
        string? GetUserTypeFromToken(string token);
        Task<dynamic?> GetUserProfileAsync(int userId, string userType);
        Task<dynamic?> UpdateClientProfileAsync(UpdateProfileRequest request);
        Task<dynamic?> UpdateTechnicianProfileAsync(UpdateProfileRequest request);
        Task<bool> DeleteAccountAsync(int userId, string userType);
    }
}
