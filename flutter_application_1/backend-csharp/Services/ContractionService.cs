using ServitecAPI.DTOs;
using ServitecAPI.Models;
using ServitecAPI.Repositories;

namespace ServitecAPI.Services {
    public class ContractionService : IContractionService
    {
        private readonly IContractionRepository _repo;
        private readonly ILogger<ContractionService> _logger;

        public ContractionService(IContractionRepository repo, ILogger<ContractionService> logger)
        {
            _repo = repo;
            _logger = logger;
        }

        public async Task<ContractionResponse> GetContractionAsync(int id)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(id);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                return MapToResponse(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ContractionResponse>> GetAllAsync()
        {
            try
            {
                var contractions = await _repo.GetAllAsync();
                return contractions.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting all contractions: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ContractionResponse>> GetByClientAsync(int clientId)
        {
            try
            {
                var contractions = await _repo.GetByClientAsync(clientId);
                return contractions.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting contractions by client: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ContractionResponse>> GetByTechnicianAsync(int technicianId)
        {
            try
            {
                var contractions = await _repo.GetByTechnicianAsync(technicianId);
                return contractions.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting contractions by technician: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ContractionResponse>> GetByStatusAsync(string status)
        {
            try
            {
                var validStatuses = new[] { "solicitada", "asignada", "en_proceso", "completada", "cancelada" };
                if (!validStatuses.Contains(status))
                    throw new ArgumentException("Invalid contraction status");

                var contractions = await _repo.GetByStatusAsync(status);
                return contractions.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting contractions by status: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ContractionResponse>> GetPendingAsync()
        {
            try
            {
                var contractions = await _repo.GetPendingAsync();
                return contractions.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting pending contractions: {ex.Message}");
                throw;
            }
        }

        public async Task<int> CreateContractionAsync(CreateContractionDto request)
        {
            try
            {
                _logger.LogInformation($" [ContractionService.CreateContractionAsync] INICIANDO");
                _logger.LogInformation($"   ├─ IdCliente: {request.IdCliente}");
                _logger.LogInformation($"   ├─ IdServicio: {request.IdServicio}");
                _logger.LogInformation($"   ├─ Descripcion: {request.Descripcion}");
                _logger.LogInformation($"   └─ FechaEstimada: {request.FechaEstimada}");

                var contraction = new ContractionModel
                {
                    IdCliente = request.IdCliente,
                    IdTecnico = request.IdTecnico,  
                    IdServicio = request.IdServicio,
                    Estado = "Pendiente",  
                    Descripcion = request.Descripcion,
                    FechaEstimada = request.FechaEstimada,
                    DetallesCliente = request.DetallesCliente ?? request.Descripcion,
                    HoraSolicitada = request.HoraSolicitada,
                    FotosClienteUrls = request.FotosClienteUrls,
                    Ubicacion = request.Ubicacion
                };

                _logger.LogInformation($"✓ ContractionModel creado. Estado={contraction.Estado}");
                _logger.LogInformation($"→ Llamando Repository.CreateAsync()...");

                var result = await _repo.CreateAsync(contraction);

                _logger.LogInformation($" ContractionService.CreateAsync retornó ID: {result}");
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError($" ERROR EN ContractionService.CreateContractionAsync: {ex.GetType().Name}");
                _logger.LogError($"   └─ Mensaje: {ex.Message}");
                _logger.LogError($"   └─ Stack: {ex.StackTrace}");
                throw;
            }
        }

        public async Task<bool> UpdateContractionAsync(int id, UpdateContractionDto request)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(id);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                if (!string.IsNullOrWhiteSpace(request.Estado))
                    contraction.Estado = request.Estado;
                if (request.IdTecnico.HasValue)
                    contraction.IdTecnico = request.IdTecnico;
                if (request.FechaEstimada.HasValue)
                    contraction.FechaEstimada = request.FechaEstimada;
                if (!string.IsNullOrWhiteSpace(request.Descripcion))
                    contraction.Descripcion = request.Descripcion;
                if (!string.IsNullOrWhiteSpace(request.FotosTrabajoUrls))
                    contraction.FotosTrabajoUrls = request.FotosTrabajoUrls;
                if (request.MontoPropuesto.HasValue && request.MontoPropuesto > 0)
                    contraction.MontoPropuesto = request.MontoPropuesto;
                if (!string.IsNullOrWhiteSpace(request.EstadoMonto))
                    contraction.EstadoMonto = request.EstadoMonto;
                if (!string.IsNullOrWhiteSpace(request.Comentarios))
                    contraction.Comentarios = request.Comentarios;
                if (request.MontoPagado.HasValue)
                    contraction.MontoPagado = request.MontoPagado;
                if (request.FechaPago.HasValue)
                    contraction.FechaPago = request.FechaPago;
                if (!string.IsNullOrWhiteSpace(request.PaymentIntentId))
                    contraction.PaymentIntentId = request.PaymentIntentId;
                if (!string.IsNullOrWhiteSpace(request.MotivoCambio))
                    contraction.MotivoCambio = request.MotivoCambio;

                return await _repo.UpdateAsync(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> AssignTechnicianAsync(int contractionId, AssignTechnicianDto request)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                return await _repo.AssignTechnicianAsync(contractionId, request.IdTecnico, request.MontoPropuesto);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error assigning technician: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> CompleteContractionAsync(int contractionId)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                return await _repo.CompleteAsync(contractionId);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error completing contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> CancelContractionAsync(int contractionId)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                return await _repo.CancelAsync(contractionId);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error canceling contraction: {ex.Message}");
                throw;
            }
        }

        // ✨ NUEVOS: Para flujo de aceptación/rechazo
        public async Task<bool> RejectContractionAsync(int contractionId, RejectContractionDto request)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                if (contraction.Estado != "Pendiente")
                    throw new InvalidOperationException("Solo se pueden rechazar solicitudes pendientes");

                // ✨ 'Cancelada' es el estado válido en la BD para solicitudes rechazadas
                contraction.Estado = "Cancelada";
                contraction.MotivoCambio = request.Motivo ?? "Sin motivo especificado";
                contraction.FechaActualizacion = DateTime.UtcNow;

                return await _repo.UpdateAsync(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error rejecting contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> AcceptContractionAsync(int contractionId, AcceptContractionDto request)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                if (contraction.Estado != "Pendiente")
                    throw new InvalidOperationException("Solo se pueden aceptar solicitudes pendientes");

                // Asignar técnico y marcar como Aceptada
                contraction.IdTecnico = request.IdTecnico;
                contraction.Estado = "Aceptada";
                contraction.FechaActualizacion = DateTime.UtcNow;

                return await _repo.UpdateAsync(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error accepting contraction: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> ProposePropuestaAsync(int contractionId, ProposeAlternativeDto request)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                if (contraction.Estado != "Pendiente")
                    throw new InvalidOperationException("Solo se puede proponer alternativa en solicitudes pendientes");

                // Técnico es quien propone la alternativa → mantiene 'Pendiente' pero guarda propuesta en BD
                // (Campo estado_monto podría usarse para tracking, pero lo importante es los datos de propuesta)
                contraction.FechaPropuestaCambios = DateTime.UtcNow;
                contraction.FechaPropuestaSolicitada = request.FechaPropuestaSolicitada;
                contraction.HoraPropuestaSolicitada = request.HoraPropuestaSolicitada;
                contraction.MotivoCambio = request.MotivoCambio;
                contraction.FechaActualizacion = DateTime.UtcNow;

                _logger.LogInformation($"Alternative proposal created for contraction {contractionId}: {request.MotivoCambio}");
                return await _repo.UpdateAsync(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error proposing alternative: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> AcceptPropuestaAsync(int contractionId)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                if (contraction.Estado != "Pendiente" || contraction.FechaPropuestaSolicitada == null)
                    throw new InvalidOperationException("No hay propuesta alternativa para aceptar");

                // ✨ Aplicar los cambios de la propuesta al registro principal
                contraction.FechaEstimada = contraction.FechaPropuestaSolicitada;
                contraction.HoraSolicitada = contraction.HoraPropuestaSolicitada;
                
                // ✨ Limpiar campos de propuesta para que no aparezcan más en la UI de seguimiento activo
                contraction.FechaPropuestaCambios = null;
                contraction.FechaPropuestaSolicitada = null;
                contraction.HoraPropuestaSolicitada = null;
                contraction.MotivoCambio = null;

                // Marcar como 'Aceptada'
                contraction.Estado = "Aceptada";
                contraction.FechaActualizacion = DateTime.UtcNow;

                _logger.LogInformation($"✅ Propuesta aceptada para solicitud {contractionId}. Nueva fecha: {contraction.FechaEstimada}");
                return await _repo.UpdateAsync(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error accepting alternative proposal: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> RejectPropuestaAsync(int contractionId)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                if (contraction.Estado != "Pendiente" || contraction.FechaPropuestaSolicitada == null)
                    throw new InvalidOperationException("No hay propuesta alternativa para rechazar");

                // ✨ Si el cliente rechaza la propuesta del técnico, la solicitud se CANCELA
                contraction.Estado = "Cancelada";
                contraction.FechaActualizacion = DateTime.UtcNow;

                _logger.LogInformation($"❌ Propuesta rechazada para solicitud {contractionId}. Solicitud cancelada.");
                return await _repo.UpdateAsync(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error rejecting alternative proposal: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> ProposeMountAsync(int contractionId, ProposeMountDto request)
        {
            try
            {
                if (request.Monto <= 0)
                    throw new InvalidOperationException("El monto debe ser mayor a 0");

                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                if (contraction.Estado != "Aceptada")
                    throw new InvalidOperationException("Solo se puede proponer monto en solicitudes aceptadas");

                contraction.MontoPropuesto = (decimal)request.Monto;
                contraction.EstadoMonto = "Propuesto";
                contraction.ClabeTecnico = request.ClabeTecnico; // ✨ Guardar la CLABE / Tarjeta
                contraction.FechaActualizacion = DateTime.UtcNow;

                var success = await _repo.UpdateAsync(contraction);
                
                _logger.LogInformation($"✅ Mount proposed for contraction {contractionId}: ${request.Monto}, EstadoMonto set to 'Propuesto'");
                
                if (success)
                {
                    // Verificar que se guardó correctamente
                    var verificacion = await _repo.GetByIdAsync(contractionId);
                    _logger.LogInformation($"🔍 Verificación: EstadoMonto en BD = '{verificacion?.EstadoMonto}'");
                }

                return success;
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ Error proposing mount: {ex.Message}");
                throw;
            }
        }

        // ✨ NUEVO: Cliente acepta el monto propuesto
        public async Task<bool> AcceptAmountAsync(int contractionId)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                if (contraction.EstadoMonto != "Propuesto" && contraction.EstadoMonto != "Aceptado")
                    throw new InvalidOperationException("No hay monto propuesto válido para aceptar");

                if (contraction.EstadoMonto == "Aceptado")
                {
                    _logger.LogInformation($"La solicitud {contractionId} ya estaba aceptada. Continuando...");
                    return true;
                }

                contraction.EstadoMonto = "Aceptado";
                // contraction.Estado = "En Progreso";  // 🚫 ELIMINADO: Ya no avanza aquí, sino hasta que pague.
                contraction.FechaActualizacion = DateTime.UtcNow;

                _logger.LogInformation($"Amount accepted for contraction {contractionId}");
                return await _repo.UpdateAsync(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error accepting amount: {ex.Message}");
                throw;
            }
        }

        // ✨ NUEVO: Cliente rechaza el monto propuesto
        public async Task<bool> RejectAmountAsync(int contractionId, RejectAmountDto request)
        {
            try
            {
                var contraction = await _repo.GetByIdAsync(contractionId);
                if (contraction == null)
                    throw new KeyNotFoundException("Contraction not found");

                if (contraction.EstadoMonto != "Propuesto" && contraction.EstadoMonto != "Aceptado")
                    throw new InvalidOperationException("No hay monto propuesto para rechazar");

                // ✨ Cuando el cliente rechaza el monto, la solicitud se cancela (como rechazo sin propuesta)
                contraction.Estado = "Cancelada";
                contraction.EstadoMonto = "Rechazado";
                contraction.MotivoCambio = request.Motivo ?? "Monto rechazado por el cliente";
                contraction.FechaActualizacion = DateTime.UtcNow;

                _logger.LogInformation($"Amount rejected for contraction {contractionId}: solicitud cancelada");
                return await _repo.UpdateAsync(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error rejecting amount: {ex.Message}");
                throw;
            }
        }

        private ContractionResponse MapToResponse(ContractionModel contraction)
        {
            return new ContractionResponse
            {
                IdContratacion = contraction.IdContratacion,
                IdCliente = contraction.IdCliente,
                NombreCliente = contraction.NombreCliente,
                IdTecnico = contraction.IdTecnico,
                NombreTecnico = contraction.NombreTecnico,
                FotoPerfilCliente = contraction.FotoPerfilCliente,
                FotoPerfilTecnico = contraction.FotoPerfilTecnico,
                IdServicio = contraction.IdServicio,
                Estado = contraction.Estado,
                FechaSolicitud = contraction.FechaSolicitud,
                FechaAsignacion = contraction.FechaAsignacion,
                FechaEstimada = contraction.FechaEstimada,
                FechaCompletada = contraction.FechaCompletada,
                Descripcion = contraction.DetallesCliente ?? contraction.Descripcion,
                DetallesCliente = contraction.DetallesCliente,
                HorasSolicitadas = contraction.HorasSolicitadas,
                HoraSolicitada = contraction.HoraSolicitada,
                FotosClienteUrls = contraction.FotosClienteUrls,
                FotosTrabajoUrls = contraction.FotosTrabajoUrls,
                MontoPropuesto = contraction.MontoPropuesto,
                EstadoMonto = contraction.EstadoMonto ?? "Sin Propuesta",
                Ubicacion = contraction.Ubicacion,
                Comentarios = contraction.Comentarios,
                FechaPropuestaCambios = contraction.FechaPropuestaCambios,
                FechaPropuestaSolicitada = contraction.FechaPropuestaSolicitada,
                HoraPropuestaSolicitada = contraction.HoraPropuestaSolicitada,
                MotivoCambio = contraction.MotivoCambio,
                FechaPago = contraction.FechaPago,
                MontoPagado = contraction.MontoPagado,
                PuntuacionCliente = contraction.PuntuacionCliente,
                ComentarioCliente = contraction.ComentarioCliente,
                FechaCalificacion = contraction.FechaCalificacion,
                PaymentIntentId = contraction.PaymentIntentId, // ✨
                ClabeTecnico = contraction.ClabeTecnico        // ✨
            };
        }
    }
}
