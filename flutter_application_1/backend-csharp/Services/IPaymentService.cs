using ServitecAPI.DTOs;
using ServitecAPI.Models;

namespace ServitecAPI.Services
{
    public interface IPaymentService
    {
        Task<PaymentResponse> GetPaymentAsync(int id);
        Task<List<PaymentResponse>> GetAllPaymentsAsync();
        Task<List<PaymentResponse>> GetByContractionAsync(int contractionId);
        Task<List<PaymentResponse>> GetByTechnicianAsync(int technicianId);
        Task<List<PaymentResponse>> GetByClientAsync(int clientId);
        Task<List<PaymentResponse>> GetByStatusAsync(string status);
        Task<int> CreatePaymentAsync(CreatePaymentRequest request);
        Task<bool> UpdatePaymentStatusAsync(int paymentId, UpdatePaymentStatusRequest request);
        Task<List<PaymentResponse>> GetPendingPaymentsAsync();
        Task<List<PaymentResponse>> GetOverduePaymentsAsync();
    }
}
