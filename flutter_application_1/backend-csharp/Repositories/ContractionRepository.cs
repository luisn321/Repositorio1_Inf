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
                    @"SELECT c.*, 
                        CONCAT(cl.nombre, ' ', IFNULL(cl.apellido,'')) AS nombre_cliente,
                        CONCAT(t.nombre, ' ', IFNULL(t.apellido,'')) AS nombre_tecnico,
                        cal.puntuacion AS puntuacion_cliente,
                        cal.comentario AS comentario_cliente,
                        cal.created_at AS fecha_calificacion,
                        cl.foto_perfil_url AS foto_cliente,
                        t.foto_perfil_url AS foto_tecnico
                      FROM contrataciones c
                      LEFT JOIN clientes cl ON c.id_cliente = cl.id_cliente
                      LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico
                      LEFT JOIN calificaciones cal ON c.id_contratacion = cal.id_contratacion
                      WHERE c.id_contratacion = @id",
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
                var data = await _db.ExecuteQueryAsync(
                    @"SELECT c.*, 
                        CONCAT(cl.nombre, ' ', IFNULL(cl.apellido,'')) AS nombre_cliente,
                        CONCAT(t.nombre, ' ', IFNULL(t.apellido,'')) AS nombre_tecnico,
                        cal.puntuacion AS puntuacion_cliente,
                        cal.comentario AS comentario_cliente,
                        cal.created_at AS fecha_calificacion,
                        cl.foto_perfil_url AS foto_cliente,
                        t.foto_perfil_url AS foto_tecnico
                      FROM contrataciones c
                      LEFT JOIN clientes cl ON c.id_cliente = cl.id_cliente
                      LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico
                      LEFT JOIN calificaciones cal ON c.id_contratacion = cal.id_contratacion
                      ORDER BY c.fecha_solicitud DESC");
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
                    @"SELECT c.*, 
                        CONCAT(cl.nombre, ' ', IFNULL(cl.apellido,'')) AS nombre_cliente,
                        CONCAT(t.nombre, ' ', IFNULL(t.apellido,'')) AS nombre_tecnico,
                        cal.puntuacion AS puntuacion_cliente,
                        cal.comentario AS comentario_cliente,
                        cal.created_at AS fecha_calificacion,
                        cl.foto_perfil_url AS foto_cliente,
                        t.foto_perfil_url AS foto_tecnico
                      FROM contrataciones c
                      LEFT JOIN clientes cl ON c.id_cliente = cl.id_cliente
                      LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico
                      LEFT JOIN calificaciones cal ON c.id_contratacion = cal.id_contratacion AND cal.id_tecnico = c.id_tecnico
                      WHERE c.id_cliente = @id
                      ORDER BY c.fecha_solicitud DESC",
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
                    @"SELECT c.*, 
                        CONCAT(cl.nombre, ' ', IFNULL(cl.apellido,'')) AS nombre_cliente,
                        CONCAT(t.nombre, ' ', IFNULL(t.apellido,'')) AS nombre_tecnico,
                        cal.puntuacion AS puntuacion_cliente,
                        cal.comentario AS comentario_cliente,
                        cal.created_at AS fecha_calificacion,
                        cl.foto_perfil_url AS foto_cliente,
                        t.foto_perfil_url AS foto_tecnico
                      FROM contrataciones c
                      LEFT JOIN clientes cl ON c.id_cliente = cl.id_cliente
                      LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico
                      LEFT JOIN calificaciones cal ON c.id_contratacion = cal.id_contratacion
                        AND cal.id_tecnico = c.id_tecnico
                      WHERE c.id_tecnico = @id
                      ORDER BY c.fecha_solicitud DESC",
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
                    @"SELECT c.*, 
                        CONCAT(cl.nombre, ' ', IFNULL(cl.apellido,'')) AS nombre_cliente,
                        CONCAT(t.nombre, ' ', IFNULL(t.apellido,'')) AS nombre_tecnico,
                        cal.puntuacion AS puntuacion_cliente,
                        cal.comentario AS comentario_cliente,
                        cal.created_at AS fecha_calificacion,
                        cl.foto_perfil_url AS foto_cliente,
                        t.foto_perfil_url AS foto_tecnico
                      FROM contrataciones c
                      LEFT JOIN clientes cl ON c.id_cliente = cl.id_cliente
                      LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico
                      LEFT JOIN calificaciones cal ON c.id_contratacion = cal.id_contratacion
                      WHERE c.estado = @status
                      ORDER BY c.fecha_solicitud DESC",
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
                // Solo solicitudes pendientes SIN técnico asignado (disponibles para todos)
                var data = await _db.ExecuteQueryAsync(
                    @"SELECT c.*, 
                        cl.foto_perfil_url AS foto_cliente,
                        NULL AS nombre_tecnico,
                        NULL AS foto_tecnico
                      FROM contrataciones c
                      LEFT JOIN clientes cl ON c.id_cliente = cl.id_cliente
                      WHERE c.estado = 'Pendiente' AND c.id_tecnico IS NULL
                      ORDER BY c.fecha_solicitud ASC"
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
                _logger.LogInformation($"💾 [ContractionRepository.CreateAsync] INICIANDO INSERT");
                _logger.LogInformation($"   ├─ IdCliente: {contraction.IdCliente}");
                _logger.LogInformation($"   ├─ IdServicio: {contraction.IdServicio}");
                _logger.LogInformation($"   ├─ Estado: {contraction.Estado}");
                _logger.LogInformation($"   ├─ FechaEstimada: {contraction.FechaEstimada}");
                _logger.LogInformation($"   └─ Descripcion: {contraction.Descripcion}");

                _logger.LogInformation($"→ Ejecutando: INSERT INTO contrataciones (id_cliente, id_servicio, estado, fecha_solicitud, fecha_programada, hora_solicitada, detalles, fotos_cliente_urls, ubicacion, created_at)");

                int contractionId = await _db.ExecuteScalarAsync<int>(
                    @"INSERT INTO contrataciones (id_cliente, id_tecnico, id_servicio, estado, fecha_solicitud, 
                      fecha_programada, hora_solicitada, detalles, fotos_cliente_urls, ubicacion)
                      VALUES (@cliente, @tecnico, @servicio, @estado, NOW(), @fecha_prog, @hora_sol, 
                      @detalles, @fotos, @ubicacion);
                      SELECT LAST_INSERT_ID();",
                    new Dictionary<string, object>
                    {
                        { "cliente", contraction.IdCliente },
                        { "tecnico", (object?)contraction.IdTecnico ?? DBNull.Value },  // ✨ id_tecnico
                        { "servicio", contraction.IdServicio },
                        { "estado", contraction.Estado },
                        { "fecha_prog", (object?)contraction.FechaEstimada ?? DBNull.Value },
                        { "hora_sol", string.IsNullOrEmpty(contraction.HoraSolicitada) ? (object)DBNull.Value : contraction.HoraSolicitada },
                        { "detalles", contraction.DetallesCliente ?? contraction.Descripcion ?? "" },
                        { "fotos", string.IsNullOrEmpty(contraction.FotosClienteUrls) ? (object)DBNull.Value : contraction.FotosClienteUrls },
                        { "ubicacion", string.IsNullOrEmpty(contraction.Ubicacion) ? (object)DBNull.Value : contraction.Ubicacion }
                    }
                );

                _logger.LogInformation($"✅ INSERT EXITOSO. ID generado: {contractionId}");
                _logger.LogInformation($"   └─ Registro insertado en tabla 'contrataciones' correctamente");
                
                return contractionId;
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ ERROR EN CreateAsync: {ex.GetType().Name}");
                _logger.LogError($"   ├─ Mensaje: {ex.Message}");
                _logger.LogError($"   ├─ InnerException: {ex.InnerException?.Message}");
                _logger.LogError($"   └─ Stack: {ex.StackTrace}");
                throw;
            }
        }

        public async Task<bool> UpdateAsync(ContractionModel contraction)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE contrataciones SET estado = @estado, id_tecnico = @tecnico, 
                      fecha_programada = @fecha_prog, detalles = @detalles, fotos_trabajo_urls = @fotos_trab,
                      monto_propuesto = @monto, estado_monto = @estado_monto,
                      motivo_cambio = @motivo_cambio,
                      fecha_propuesta_cambios = @fecha_prop_cambios,
                      fecha_propuesta_solicitada = @fecha_prop_solicitada,
                      hora_propuesta_solicitada = @hora_prop_solicitada,
                      fecha_pago = @fecha_pago,
                      monto_pagado = @monto_pagado,
                      updated_at = NOW() WHERE id_contratacion = @id",
                    new Dictionary<string, object>
                    {
                        { "estado", contraction.Estado },
                        { "tecnico", (object?)contraction.IdTecnico ?? DBNull.Value },
                        { "fecha_prog", (object?)contraction.FechaAsignacion ?? (object?)contraction.FechaEstimada ?? DBNull.Value },
                        { "detalles", contraction.DetallesCliente ?? contraction.Descripcion ?? "" },
                        { "fotos_trab", string.IsNullOrEmpty(contraction.FotosTrabajoUrls) ? (object)DBNull.Value : contraction.FotosTrabajoUrls },
                        { "monto", string.IsNullOrEmpty(contraction.MontoPropuesto) ? (object)DBNull.Value : contraction.MontoPropuesto },
                        { "estado_monto", string.IsNullOrEmpty(contraction.EstadoMonto) ? (object)DBNull.Value : contraction.EstadoMonto },
                        { "motivo_cambio", string.IsNullOrEmpty(contraction.MotivoCambio) ? (object)DBNull.Value : contraction.MotivoCambio },
                        { "fecha_prop_cambios", (object?)contraction.FechaPropuestaCambios ?? DBNull.Value },
                        { "fecha_prop_solicitada", (object?)contraction.FechaPropuestaSolicitada ?? DBNull.Value },
                        { "hora_prop_solicitada", string.IsNullOrEmpty(contraction.HoraPropuestaSolicitada) ? (object)DBNull.Value : contraction.HoraPropuestaSolicitada },
                        { "fecha_pago", (object?)contraction.FechaPago ?? DBNull.Value },
                        { "monto_pagado", contraction.MontoPagado.HasValue ? (object)contraction.MontoPagado.Value.ToString() : DBNull.Value },
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
                _logger.LogInformation($"⚡ [AssignTechnicianAsync] Asignando técnico {technicianId} a contratación {contractionId}");
                
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE contrataciones SET id_tecnico = @tecnico, estado = 'Aceptada', 
                      monto_propuesto = @monto, estado_monto = 'Propuesto',
                      updated_at = NOW() WHERE id_contratacion = @id",
                    new Dictionary<string, object>
                    {
                        { "tecnico", technicianId },
                        { "monto", montoPropuesto?.ToString() ?? "" },
                        { "id", contractionId }
                    }
                );

                if (result > 0)
                {
                    _logger.LogInformation($"✅ Técnico asignado exitosamente. Estado cambiado a 'Aceptada'");
                }
                else
                {
                    _logger.LogWarning($"⚠️  No se actualizó ningún registro. ¿Existe contractionId {contractionId}?");
                }

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ Error en AssignTechnicianAsync: {ex.Message}");
                _logger.LogError($"   Detalles: {ex.InnerException?.Message}");
                throw;
            }
        }

        public async Task<bool> CompleteAsync(int contractionId)
        {
            try
            {
                _logger.LogInformation($"🏁 [CompleteAsync] Marcando contratación {contractionId} como completada");
                
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE contrataciones SET estado = 'Completada',
                      updated_at = NOW() WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", contractionId } }
                );

                if (result > 0)
                {
                    _logger.LogInformation($"✅ Contratación marcada como 'Completada' exitosamente");
                }
                else
                {
                    _logger.LogWarning($"⚠️  No se actualizó ningún registro. ¿Existe contractionId {contractionId}?");
                }

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ Error en CompleteAsync: {ex.Message}");
                _logger.LogError($"   Detalles: {ex.InnerException?.Message}");
                throw;
            }
        }

        public async Task<bool> CancelAsync(int contractionId)
        {
            try
            {
                _logger.LogInformation($"🚫 [CancelAsync] Cancelando contratación {contractionId}");
                
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE contrataciones SET estado = 'Cancelada', updated_at = NOW() 
                      WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", contractionId } }
                );

                if (result > 0)
                {
                    _logger.LogInformation($"✅ Contratación cancelada exitosamente");
                }
                else
                {
                    _logger.LogWarning($"⚠️  No se actualizó ningún registro. ¿Existe contractionId {contractionId}?");
                }

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ Error en CancelAsync: {ex.Message}");
                _logger.LogError($"   Detalles: {ex.InnerException?.Message}");
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
                NombreCliente = data.ContainsKey("nombre_cliente") && data["nombre_cliente"] != DBNull.Value ? ((string)data["nombre_cliente"]).Trim() : null,
                IdTecnico = data.ContainsKey("id_tecnico") && data["id_tecnico"] != DBNull.Value ? (int?)data["id_tecnico"] : null,
                NombreTecnico = data.ContainsKey("nombre_tecnico") && data["nombre_tecnico"] != DBNull.Value ? ((string)data["nombre_tecnico"]).Trim() : null,
                IdServicio = (int)data["id_servicio"],
                Estado = data.ContainsKey("estado") && data["estado"] != DBNull.Value ? (string)data["estado"] : "Pendiente",
                FechaSolicitud = Convert.ToDateTime(data.GetValueOrDefault("fecha_solicitud", DateTime.Now)),
                FechaAsignacion = null,
                FechaEstimada = data.ContainsKey("fecha_programada") && data["fecha_programada"] != DBNull.Value ? Convert.ToDateTime(data["fecha_programada"]) : null,
                FechaCompletada = null,
                Descripcion = null,
                DetallesCliente = data.ContainsKey("detalles") && data["detalles"] != DBNull.Value ? (string)data["detalles"] : null,
                HorasSolicitadas = null,
                HoraSolicitada = data.ContainsKey("hora_solicitada") && data["hora_solicitada"] != DBNull.Value ? data["hora_solicitada"].ToString() : null,
                FotosClienteUrls = data.ContainsKey("fotos_cliente_urls") && data["fotos_cliente_urls"] != DBNull.Value ? (string)data["fotos_cliente_urls"] : null,
                FotosTrabajoUrls = data.ContainsKey("fotos_trabajo_urls") && data["fotos_trabajo_urls"] != DBNull.Value ? (string)data["fotos_trabajo_urls"] : null,
                MontoPropuesto = data.ContainsKey("monto_propuesto") && data["monto_propuesto"] != DBNull.Value ? data["monto_propuesto"].ToString() : null,
                EstadoMonto = data.ContainsKey("estado_monto") && data["estado_monto"] != DBNull.Value ? (string)data["estado_monto"] : "Sin Propuesta",
                Ubicacion = data.ContainsKey("ubicacion") && data["ubicacion"] != DBNull.Value ? (string)data["ubicacion"] : null,
                Comentarios = null,
                FechaActualizacion = data.ContainsKey("updated_at") && data["updated_at"] != DBNull.Value ? Convert.ToDateTime(data["updated_at"]) : null,
                FechaPropuestaCambios = data.ContainsKey("fecha_propuesta_cambios") && data["fecha_propuesta_cambios"] != DBNull.Value ? Convert.ToDateTime(data["fecha_propuesta_cambios"]) : null,
                FechaPropuestaSolicitada = data.ContainsKey("fecha_propuesta_solicitada") && data["fecha_propuesta_solicitada"] != DBNull.Value ? Convert.ToDateTime(data["fecha_propuesta_solicitada"]) : null,
                HoraPropuestaSolicitada = data.ContainsKey("hora_propuesta_solicitada") && data["hora_propuesta_solicitada"] != DBNull.Value ? data["hora_propuesta_solicitada"].ToString() : null,
                MotivoCambio = data.ContainsKey("motivo_cambio") && data["motivo_cambio"] != DBNull.Value ? (string)data["motivo_cambio"] : null,
                FechaPago = data.ContainsKey("fecha_pago") && data["fecha_pago"] != DBNull.Value ? Convert.ToDateTime(data["fecha_pago"]) : null,
                MontoPagado = data.ContainsKey("monto_pagado") && data["monto_pagado"] != DBNull.Value ? Convert.ToDecimal(data["monto_pagado"]) : null,
                PuntuacionCliente = data.ContainsKey("puntuacion_cliente") && data["puntuacion_cliente"] != DBNull.Value ? Convert.ToInt32(data["puntuacion_cliente"]) : null,
                ComentarioCliente = data.ContainsKey("comentario_cliente") && data["comentario_cliente"] != DBNull.Value ? (string)data["comentario_cliente"] : null,
                FechaCalificacion = data.ContainsKey("fecha_calificacion") && data["fecha_calificacion"] != DBNull.Value ? Convert.ToDateTime(data["fecha_calificacion"]) : null,
                FotoPerfilCliente = data.ContainsKey("foto_cliente") && data["foto_cliente"] != DBNull.Value ? (string)data["foto_cliente"] : null,
                FotoPerfilTecnico = data.ContainsKey("foto_tecnico") && data["foto_tecnico"] != DBNull.Value ? (string)data["foto_tecnico"] : null
            };
        }
    }
}
