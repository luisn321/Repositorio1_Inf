using ServitecAPI.Models;

namespace ServitecAPI.Repositories
{
    public interface IPaymentRepository
    {
        Task<PaymentModel?> GetByIdAsync(int id);
        Task<List<PaymentModel>> GetAllAsync();
        Task<List<PaymentModel>> GetByContractionAsync(int contractionId);
        Task<List<PaymentModel>> GetByTechnicianAsync(int technicianId);
        Task<List<PaymentModel>> GetByClientAsync(int clientId);
        Task<List<PaymentModel>> GetByStatusAsync(string status);
        Task<int> CreateAsync(PaymentModel payment);
        Task<bool> UpdateStatusAsync(int paymentId, string status, string? referencia);
        Task<bool> UpdateAsync(PaymentModel payment);
        Task<bool> DeleteAsync(int id);
        Task<List<PaymentModel>> GetPendingPaymentsAsync();
        Task<List<PaymentModel>> GetOverduePaymentsAsync();
    }
}
