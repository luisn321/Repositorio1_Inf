using ServitecAPI.DTOs;
using ServitecAPI.Models;
using ServitecAPI.Repositories;

namespace ServitecAPI.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly IPaymentRepository _repo;
        private readonly ILogger<PaymentService> _logger;

        public PaymentService(IPaymentRepository repo, ILogger<PaymentService> logger)
        {
            _repo = repo;
            _logger = logger;
        }

        public async Task<PaymentResponse> GetPaymentAsync(int id)
        {
            try
            {
                var payment = await _repo.GetByIdAsync(id);
                if (payment == null)
                    throw new KeyNotFoundException("Payment not found");

                return MapToResponse(payment);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting payment: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentResponse>> GetAllPaymentsAsync()
        {
            try
            {
                var payments = await _repo.GetAllAsync();
                return payments.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting all payments: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentResponse>> GetByContractionAsync(int contractionId)
        {
            try
            {
                var payments = await _repo.GetByContractionAsync(contractionId);
                return payments.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting payments by contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentResponse>> GetByTechnicianAsync(int technicianId)
        {
            try
            {
                var payments = await _repo.GetByTechnicianAsync(technicianId);
                return payments.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting payments by technician: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentResponse>> GetByClientAsync(int clientId)
        {
            try
            {
                var payments = await _repo.GetByClientAsync(clientId);
                return payments.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting payments by client: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentResponse>> GetByStatusAsync(string status)
        {
            try
            {
                var validStatuses = new[] { "sin_pagar", "pagado", "reembolsado" };
                if (!validStatuses.Contains(status))
                    throw new ArgumentException("Invalid payment status");

                var payments = await _repo.GetByStatusAsync(status);
                return payments.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting payments by status: {ex.Message}");
                throw;
            }
        }

        public async Task<int> CreatePaymentAsync(CreatePaymentRequest request)
        {
            try
            {
                if (request.Monto <= 0)
                    throw new ArgumentException("Payment amount must be positive");

                var payment = new PaymentModel
                {
                    IdContratacion = request.IdContratacion,
                    Monto = request.Monto,
                    MontoProyectado = request.MontoProyectado ?? request.Monto,
                    MetodoPago = request.MetodoPago ?? "",
                    EstatusPago = "sin_pagar",
                    EstadoMonto = "pendiente",
                    FechaVencimiento = DateTime.Now.AddDays(7),
                    DescripcionPago = request.DescripcionPago
                };

                return await _repo.CreateAsync(payment);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating payment: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdatePaymentStatusAsync(int paymentId, UpdatePaymentStatusRequest request)
        {
            try
            {
                var payment = await _repo.GetByIdAsync(paymentId);
                if (payment == null)
                    throw new KeyNotFoundException("Payment not found");

                return await _repo.UpdateStatusAsync(paymentId, request.EstatusPago, request.ReferenciaPago);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating payment status: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentResponse>> GetPendingPaymentsAsync()
        {
            try
            {
                var payments = await _repo.GetPendingPaymentsAsync();
                return payments.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting pending payments: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentResponse>> GetOverduePaymentsAsync()
        {
            try
            {
                var payments = await _repo.GetOverduePaymentsAsync();
                return payments.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting overdue payments: {ex.Message}");
                throw;
            }
        }

        private PaymentResponse MapToResponse(PaymentModel payment)
        {
            return new PaymentResponse
            {
                IdPago = payment.IdPago,
                IdContratacion = payment.IdContratacion,
                IdTecnico = payment.IdTecnico,
                IdCliente = payment.IdCliente,
                Monto = payment.Monto,
                MontoProyectado = payment.MontoProyectado,
                EstadoMonto = payment.EstadoMonto,
                MetodoPago = payment.MetodoPago,
                EstatusPago = payment.EstatusPago,
                FechaPago = payment.FechaPago,
                FechaVencimiento = payment.FechaVencimiento,
                DescripcionPago = payment.DescripcionPago,
                ReferenciaPago = payment.ReferenciaPago
            };
        }
    }
}
