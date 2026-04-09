using ServitecAPI.DTOs;
using ServitecAPI.Models;

namespace ServitecAPI.Services
{
    public interface ITechnicianService
    {
        Task<TechnicianResponse> GetTechnicianAsync(int id);
        Task<List<TechnicianResponse>> GetAllTechniciansAsync();
        Task<List<TechnicianResponse>> GetByServiceAsync(int serviceId);
        Task<List<TechnicianResponse>> SearchTechniciansAsync(string searchTerm);
        Task<List<TechnicianResponse>> GetByLocationAsync(double latitude, double longitude, double radius);
        Task<bool> UpdateTechnicianAsync(int id, UpdateTechnicianRequest request);
        Task<bool> UpdateServicesAsync(int technicianId, List<int> serviceIds);
    }
}
