using ServitecAPI.Models;
using ServitecAPI.DTOs;
using ServitecAPI.Services;

namespace ServitecAPI.Repositories
{
    public class PaymentRepository : IPaymentRepository
    {
        private readonly DatabaseService _db;
        private readonly ILogger<PaymentRepository> _logger;

        public PaymentRepository(DatabaseService db, ILogger<PaymentRepository> logger)
        {
            _db = db;
            _logger = logger;
        }

        public async Task<PaymentModel?> GetByIdAsync(int id)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM pagos WHERE id_pago = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (data.Count == 0) return null;
                return MapToPaymentModel(data[0]);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting payment by id: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentModel>> GetAllAsync()
        {
            try
            {
                var data = await _db.ExecuteQueryAsync("SELECT * FROM pagos ORDER BY created_at DESC");
                return data.Select(MapToPaymentModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting all payments: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentModel>> GetByContractionAsync(int contractionId)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM pagos WHERE id_contratacion = @id ORDER BY created_at DESC",
                    new Dictionary<string, object> { { "id", contractionId } }
                );

                return data.Select(MapToPaymentModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting payments by contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentModel>> GetByTechnicianAsync(int technicianId)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM pagos WHERE id_tecnico = @id ORDER BY created_at DESC",
                    new Dictionary<string, object> { { "id", technicianId } }
                );

                return data.Select(MapToPaymentModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting payments by technician: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentModel>> GetByClientAsync(int clientId)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM pagos WHERE id_cliente = @id ORDER BY created_at DESC",
                    new Dictionary<string, object> { { "id", clientId } }
                );

                return data.Select(MapToPaymentModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting payments by client: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentModel>> GetByStatusAsync(string status)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM pagos WHERE estatus_pago = @status ORDER BY created_at DESC",
                    new Dictionary<string, object> { { "status", status } }
                );

                return data.Select(MapToPaymentModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting payments by status: {ex.Message}");
                throw;
            }
        }

        public async Task<int> CreateAsync(PaymentModel payment)
        {
            try
            {
                int paymentId = await _db.ExecuteScalarAsync<int>(
                    @"INSERT INTO pagos (id_contratacion, monto, metodo_pago, transaction_ref, estado_pago)
                      VALUES (@contratacion, @monto, @metodo, @referencia, @estatus);
                      SELECT LAST_INSERT_ID();",
                    new Dictionary<string, object>
                    {
                        { "contratacion", payment.IdContratacion },
                        { "monto", payment.Monto },
                        { "metodo", payment.MetodoPago ?? "Tarjeta de Crédito" },
                        { "referencia", payment.ReferenciaPago ?? "" },
                        { "estatus", payment.EstatusPago ?? "Pendiente" }
                    }
                );

                _logger.LogInformation($"Payment created with ID: {paymentId}");
                return paymentId;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating payment: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateStatusAsync(int paymentId, string status, string? referencia)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE pagos SET estatus_pago = @estatus, referencia_pago = @referencia, 
                      fecha_pago = NOW(), updated_at = NOW() WHERE id_pago = @id",
                    new Dictionary<string, object>
                    {
                        { "estatus", status },
                        { "referencia", referencia ?? "" },
                        { "id", paymentId }
                    }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating payment status: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateAsync(PaymentModel payment)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE pagos SET estado_monto = @estado_monto, estatus_pago = @estatus,
                      descripcion_pago = @descripcion, updated_at = NOW() WHERE id_pago = @id",
                    new Dictionary<string, object>
                    {
                        { "estado_monto", payment.EstadoMonto },
                        { "estatus", payment.EstatusPago },
                        { "descripcion", payment.DescripcionPago ?? "" },
                        { "id", payment.IdPago }
                    }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating payment: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> DeleteAsync(int id)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    "DELETE FROM pagos WHERE id_pago = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting payment: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentModel>> GetPendingPaymentsAsync()
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM pagos WHERE estatus_pago = 'sin_pagar' ORDER BY fecha_vencimiento ASC"
                );

                return data.Select(MapToPaymentModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting pending payments: {ex.Message}");
                throw;
            }
        }

        public async Task<List<PaymentModel>> GetOverduePaymentsAsync()
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM pagos WHERE estatus_pago = 'sin_pagar' AND fecha_vencimiento < NOW() ORDER BY fecha_vencimiento ASC"
                );

                return data.Select(MapToPaymentModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting overdue payments: {ex.Message}");
                throw;
            }
        }

        private PaymentModel MapToPaymentModel(Dictionary<string, object> data)
        {
            return new PaymentModel
            {
                IdPago = (int)data["id_pago"],
                IdContratacion = (int)data["id_contratacion"],
                IdTecnico = 0,  // No existe en tabla pagos
                IdCliente = 0,  // No existe en tabla pagos
                Monto = Convert.ToDouble(data["monto"] ?? 0),
                MontoProyectado = 0,  // No existe en tabla pagos
                EstadoMonto = "pagado",  // No existe en tabla pagos
                MetodoPago = (string)data.GetValueOrDefault("metodo_pago", ""),
                EstatusPago = (string)data.GetValueOrDefault("estado_pago", "Pendiente"),
                FechaPago = Convert.ToDateTime(data.GetValueOrDefault("fecha_pago", DateTime.Now)),
                FechaVencimiento = DateTime.Now,  // No existe en tabla pagos
                DescripcionPago = null,  // No existe en tabla pagos
                ReferenciaPago = data.ContainsKey("transaction_ref") ? (string?)data["transaction_ref"] : null,
                FechaRegistro = Convert.ToDateTime(data.GetValueOrDefault("fecha_pago", DateTime.Now)),
                FechaActualizacion = null
            };
        }
    }
}
