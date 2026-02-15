using ServitecAPI.Models;

namespace ServitecAPI.Repositories
{
    public interface IContractionRepository
    {
        Task<ContractionModel?> GetByIdAsync(int id);
        Task<List<ContractionModel>> GetAllAsync();
        Task<List<ContractionModel>> GetByClientAsync(int clientId);
        Task<List<ContractionModel>> GetByTechnicianAsync(int technicianId);
        Task<List<ContractionModel>> GetByStatusAsync(string status);
        Task<List<ContractionModel>> GetPendingAsync();
        Task<int> CreateAsync(ContractionModel contraction);
        Task<bool> UpdateAsync(ContractionModel contraction);
        Task<bool> UpdateStatusAsync(int contractionId, string newStatus);
        Task<bool> AssignTechnicianAsync(int contractionId, int technicianId, double? montoPropuesto);
        Task<bool> CompleteAsync(int contractionId);
        Task<bool> CancelAsync(int contractionId);
        Task<bool> DeleteAsync(int id);
    }
}
