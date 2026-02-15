using ServitecAPI.DTOs;
using ServitecAPI.Models;
using ServitecAPI.Repositories;

namespace ServitecAPI.Services
{
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
                var contraction = new ContractionModel
                {
                    IdCliente = request.IdCliente,
                    IdServicio = request.IdServicio,
                    Estado = "solicitada",
                    Descripcion = request.Descripcion,
                    FechaEstimada = request.FechaEstimada,
                    DetallesCliente = request.DetallesCliente,
                    HorasSolicitadas = request.HorasSolicitadas,
                    HoraSolicitada = request.HoraSolicitada,
                    FotosClienteUrls = request.FotosClienteUrls,
                    Ubicacion = request.Ubicacion
                };

                return await _repo.CreateAsync(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating contraction: {ex.Message}");
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
                if (!string.IsNullOrWhiteSpace(request.MontoPropuesto))
                    contraction.MontoPropuesto = request.MontoPropuesto;
                if (!string.IsNullOrWhiteSpace(request.EstadoMonto))
                    contraction.EstadoMonto = request.EstadoMonto;
                if (!string.IsNullOrWhiteSpace(request.Comentarios))
                    contraction.Comentarios = request.Comentarios;

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

        private ContractionResponse MapToResponse(ContractionModel contraction)
        {
            return new ContractionResponse
            {
                IdContratacion = contraction.IdContratacion,
                IdCliente = contraction.IdCliente,
                IdTecnico = contraction.IdTecnico,
                IdServicio = contraction.IdServicio,
                Estado = contraction.Estado,
                FechaSolicitud = contraction.FechaSolicitud,
                FechaAsignacion = contraction.FechaAsignacion,
                FechaEstimada = contraction.FechaEstimada,
                FechaCompletada = contraction.FechaCompletada,
                Descripcion = contraction.Descripcion,
                DetallesCliente = contraction.DetallesCliente,
                HorasSolicitadas = contraction.HorasSolicitadas,
                HoraSolicitada = contraction.HoraSolicitada,
                FotosClienteUrls = contraction.FotosClienteUrls,
                FotosTrabajoUrls = contraction.FotosTrabajoUrls,
                MontoPropuesto = contraction.MontoPropuesto,
                EstadoMonto = contraction.EstadoMonto,
                Ubicacion = contraction.Ubicacion,
                Comentarios = contraction.Comentarios
            };
        }
    }
}
