using ServitecAPI.Models;
using ServitecAPI.Services;

namespace ServitecAPI.Repositories
{
    public class ContractionRepository : IContractionRepository
    {
        private readonly DatabaseService _db;
        private readonly ILogger<ContractionRepository> _logger;

        public ContractionRepository(DatabaseService db, ILogger<ContractionRepository> logger)
        {
            _db = db;
            _logger = logger;
        }

        public async Task<ContractionModel?> GetByIdAsync(int id)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM contrataciones WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (data.Count == 0) return null;
                return MapToContractionModel(data[0]);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting contraction by id: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ContractionModel>> GetAllAsync()
        {
            try
            {
                var data = await _db.ExecuteQueryAsync("SELECT * FROM contrataciones ORDER BY fecha_solicitud DESC");
                return data.Select(MapToContractionModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting all contractions: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ContractionModel>> GetByClientAsync(int clientId)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM contrataciones WHERE id_cliente = @id ORDER BY fecha_solicitud DESC",
                    new Dictionary<string, object> { { "id", clientId } }
                );

                return data.Select(MapToContractionModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting contractions by client: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ContractionModel>> GetByTechnicianAsync(int technicianId)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM contrataciones WHERE id_tecnico = @id ORDER BY fecha_solicitud DESC",
                    new Dictionary<string, object> { { "id", technicianId } }
                );

                return data.Select(MapToContractionModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting contractions by technician: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ContractionModel>> GetByStatusAsync(string status)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM contrataciones WHERE estado = @status ORDER BY fecha_solicitud DESC",
                    new Dictionary<string, object> { { "status", status } }
                );

                return data.Select(MapToContractionModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting contractions by status: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ContractionModel>> GetPendingAsync()
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM contrataciones WHERE estado IN ('solicitada', 'asignada') ORDER BY fecha_solicitud ASC"
                );

                return data.Select(MapToContractionModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting pending contractions: {ex.Message}");
                throw;
            }
        }

        public async Task<int> CreateAsync(ContractionModel contraction)
        {
            try
            {
                int contractionId = await _db.ExecuteScalarAsync<int>(
                    @"INSERT INTO contrataciones (id_cliente, id_servicio, estado, fecha_solicitud, 
                      fecha_estimada, descripcion, detalles_cliente, horas_solicitadas, 
                      hora_solicitada, fotos_cliente_urls, ubicacion, created_at)
                      VALUES (@cliente, @servicio, @estado, NOW(), @fecha_estimada, @descripcion, 
                      @detalles, @horas, @hora_sol, @fotos, @ubicacion, NOW());
                      SELECT LAST_INSERT_ID();",
                    new Dictionary<string, object>
                    {
                        { "cliente", contraction.IdCliente },
                        { "servicio", contraction.IdServicio },
                        { "estado", contraction.Estado },
                        { "fecha_estimada", (object?)contraction.FechaEstimada ?? DBNull.Value },
                        { "descripcion", contraction.Descripcion ?? "" },
                        { "detalles", contraction.DetallesCliente ?? "" },
                        { "horas", (object?)contraction.HorasSolicitadas ?? DBNull.Value },
                        { "hora_sol", contraction.HoraSolicitada ?? "" },
                        { "fotos", contraction.FotosClienteUrls ?? "" },
                        { "ubicacion", contraction.Ubicacion ?? "" }
                    }
                );

                _logger.LogInformation($"Contraction created with ID: {contractionId}");
                return contractionId;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateAsync(ContractionModel contraction)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE contrataciones SET estado = @estado, id_tecnico = @tecnico, 
                      fecha_estimada = @fecha_est, descripcion = @desc, fotos_trabajo_urls = @fotos_trab,
                      monto_propuesto = @monto, estado_monto = @estado_monto, comentarios = @comentarios,
                      updated_at = NOW() WHERE id_contratacion = @id",
                    new Dictionary<string, object>
                    {
                        { "estado", contraction.Estado },
                        { "tecnico", (object?)contraction.IdTecnico ?? DBNull.Value },
                        { "fecha_est", (object?)contraction.FechaEstimada ?? DBNull.Value },
                        { "desc", contraction.Descripcion ?? "" },
                        { "fotos_trab", contraction.FotosTrabajoUrls ?? "" },
                        { "monto", contraction.MontoPropuesto ?? "" },
                        { "estado_monto", contraction.EstadoMonto ?? "" },
                        { "comentarios", contraction.Comentarios ?? "" },
                        { "id", contraction.IdContratacion }
                    }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateStatusAsync(int contractionId, string newStatus)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    "UPDATE contrataciones SET estado = @estado, updated_at = NOW() WHERE id_contratacion = @id",
                    new Dictionary<string, object>
                    {
                        { "estado", newStatus },
                        { "id", contractionId }
                    }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating contraction status: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> AssignTechnicianAsync(int contractionId, int technicianId, double? montoPropuesto)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE contrataciones SET id_tecnico = @tecnico, estado = 'asignada', 
                      fecha_asignacion = NOW(), monto_propuesto = @monto, estado_monto = 'pendiente',
                      updated_at = NOW() WHERE id_contratacion = @id",
                    new Dictionary<string, object>
                    {
                        { "tecnico", technicianId },
                        { "monto", montoPropuesto?.ToString() ?? "" },
                        { "id", contractionId }
                    }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error assigning technician: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> CompleteAsync(int contractionId)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE contrataciones SET estado = 'completada', fecha_completada = NOW(),
                      updated_at = NOW() WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", contractionId } }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error completing contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> CancelAsync(int contractionId)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE contrataciones SET estado = 'cancelada', updated_at = NOW() 
                      WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", contractionId } }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error canceling contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> DeleteAsync(int id)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    "DELETE FROM contrataciones WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting contraction: {ex.Message}");
                throw;
            }
        }

        private ContractionModel MapToContractionModel(Dictionary<string, object> data)
        {
            return new ContractionModel
            {
                IdContratacion = (int)data["id_contratacion"],
                IdCliente = (int)data["id_cliente"],
                IdTecnico = data.ContainsKey("id_tecnico") && data["id_tecnico"] != DBNull.Value ? (int?)data["id_tecnico"] : null,
                IdServicio = (int)data["id_servicio"],
                Estado = (string)data.GetValueOrDefault("estado", "solicitada"),
                FechaSolicitud = Convert.ToDateTime(data.GetValueOrDefault("fecha_solicitud", DateTime.Now)),
                FechaAsignacion = data.ContainsKey("fecha_asignacion") && data["fecha_asignacion"] != DBNull.Value ? Convert.ToDateTime(data["fecha_asignacion"]) : null,
                FechaEstimada = data.ContainsKey("fecha_estimada") && data["fecha_estimada"] != DBNull.Value ? Convert.ToDateTime(data["fecha_estimada"]) : null,
                FechaCompletada = data.ContainsKey("fecha_completada") && data["fecha_completada"] != DBNull.Value ? Convert.ToDateTime(data["fecha_completada"]) : null,
                Descripcion = data.ContainsKey("descripcion") ? (string?)data["descripcion"] : null,
                DetallesCliente = data.ContainsKey("detalles_cliente") ? (string?)data["detalles_cliente"] : null,
                HorasSolicitadas = data.ContainsKey("horas_solicitadas") && data["horas_solicitadas"] != DBNull.Value ? Convert.ToDouble(data["horas_solicitadas"]) : null,
                HoraSolicitada = data.ContainsKey("hora_solicitada") ? (string?)data["hora_solicitada"] : null,
                FotosClienteUrls = data.ContainsKey("fotos_cliente_urls") ? (string?)data["fotos_cliente_urls"] : null,
                FotosTrabajoUrls = data.ContainsKey("fotos_trabajo_urls") ? (string?)data["fotos_trabajo_urls"] : null,
                MontoPropuesto = data.ContainsKey("monto_propuesto") ? (string?)data["monto_propuesto"] : null,
                EstadoMonto = data.ContainsKey("estado_monto") ? (string?)data["estado_monto"] : null,
                Ubicacion = data.ContainsKey("ubicacion") ? (string?)data["ubicacion"] : null,
                Comentarios = data.ContainsKey("comentarios") ? (string?)data["comentarios"] : null,
                FechaActualizacion = data.ContainsKey("updated_at") && data["updated_at"] != DBNull.Value ? Convert.ToDateTime(data["updated_at"]) : null
            };
        }
    }
}
