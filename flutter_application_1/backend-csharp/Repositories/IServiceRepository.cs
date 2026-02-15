using ServitecAPI.Models;

namespace ServitecAPI.Repositories
{
    public interface IServiceRepository
    {
        Task<ServiceModel?> GetByIdAsync(int id);
        Task<List<ServiceModel>> GetAllAsync();
        Task<List<ServiceModel>> SearchAsync(string searchTerm);
        Task<List<ServiceModel>> GetActivesAsync();
        Task<List<ServiceModel>> GetByCategoryAsync(string category);
        Task<int> CreateAsync(ServiceModel service);
        Task<bool> UpdateAsync(ServiceModel service);
        Task<bool> DeleteAsync(int id);
        Task<List<ServiceModel>> GetWithTechniciansAsync();
    }
}
