using ServitecAPI.Models;
using ServitecAPI.DTOs;

namespace ServitecAPI.Repositories
{
    public interface ITechnicianRepository
    {
        Task<TechnicianModel?> GetByIdAsync(int id);
        Task<List<TechnicianModel>> GetAllAsync();
        Task<List<TechnicianModel>> GetByServiceAsync(int serviceId);
        Task<List<TechnicianModel>> SearchByNameAsync(string searchTerm);
        Task<List<TechnicianModel>> GetByLocationAsync(double latitude, double longitude, double radius);
        Task<int> CreateAsync(TechnicianModel technician, List<int> serviceIds);
        Task<bool> UpdateAsync(TechnicianModel technician);
        Task<bool> DeleteAsync(int id);
        Task<bool> UpdateRatingAsync(int id, double nuevoPromedio, int numCalificaciones);
        Task<List<ServiceDTO>> GetServicesAsync(int technicianId);
        Task<bool> UpdateServicesAsync(int technicianId, List<int> serviceIds);
    }
}
