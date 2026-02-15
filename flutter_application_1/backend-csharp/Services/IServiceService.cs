using ServitecAPI.DTOs;
using ServitecAPI.Models;

namespace ServitecAPI.Services
{
    public interface IServiceService
    {
        Task<ServiceResponse> GetServiceAsync(int id);
        Task<List<ServiceResponse>> GetAllServicesAsync();
        Task<List<ServiceResponse>> SearchServicesAsync(string searchTerm);
        Task<List<ServiceResponse>> GetActivesAsync();
        Task<List<ServiceResponse>> GetByCategoryAsync(string category);
        Task<int> CreateServiceAsync(CreateServiceRequest request);
        Task<bool> UpdateServiceAsync(int id, UpdateServiceRequest request);
        Task<bool> DeleteServiceAsync(int id);
        Task<List<ServiceResponse>> GetWithTechniciansAsync();
    }
}
