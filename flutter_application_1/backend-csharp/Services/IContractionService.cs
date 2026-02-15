using ServitecAPI.DTOs;
using ServitecAPI.Models;

namespace ServitecAPI.Services
{
    public interface IContractionService
    {
        Task<ContractionResponse> GetContractionAsync(int id);
        Task<List<ContractionResponse>> GetAllAsync();
        Task<List<ContractionResponse>> GetByClientAsync(int clientId);
        Task<List<ContractionResponse>> GetByTechnicianAsync(int technicianId);
        Task<List<ContractionResponse>> GetByStatusAsync(string status);
        Task<List<ContractionResponse>> GetPendingAsync();
        Task<int> CreateContractionAsync(CreateContractionDto request);
        Task<bool> UpdateContractionAsync(int id, UpdateContractionDto request);
        Task<bool> AssignTechnicianAsync(int contractionId, AssignTechnicianDto request);
        Task<bool> CompleteContractionAsync(int contractionId);
        Task<bool> CancelContractionAsync(int contractionId);
    }
}
