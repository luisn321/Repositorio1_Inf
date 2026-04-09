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
        
        // ✨ NUEVOS: Para flujo de solicitudes
        Task<bool> RejectContractionAsync(int contractionId, RejectContractionDto request);
        Task<bool> AcceptContractionAsync(int contractionId, AcceptContractionDto request);
        Task<bool> ProposePropuestaAsync(int contractionId, ProposeAlternativeDto request);
        Task<bool> AcceptPropuestaAsync(int contractionId);
        Task<bool> RejectPropuestaAsync(int contractionId);
        Task<bool> ProposeMountAsync(int contractionId, ProposeMountDto request);
        
        // ✨ NUEVOS: Para aceptar/rechazar montos propuestos
        Task<bool> AcceptAmountAsync(int contractionId);
        Task<bool> RejectAmountAsync(int contractionId, RejectAmountDto request);
    }
}
