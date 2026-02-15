using ServitecAPI.Models;

namespace ServitecAPI.Repositories
{
    public interface IUserRepository
    {
        Task<UserModel?> GetByIdAsync(int id);
        Task<UserModel?> GetByEmailAsync(string email);
        Task<int> CreateClientAsync(UserModel user);
        Task<int> CreateTechnicianAsync(UserModel user, List<int> serviceIds);
        Task<bool> UpdateAsync(UserModel user);
        Task<bool> DeleteAsync(int id);
        Task<bool> ExistsAsync(string email);
    }
}
