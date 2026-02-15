using ServitecAPI.DTOs;
using ServitecAPI.Models;
using ServitecAPI.Repositories;

namespace ServitecAPI.Services
{
    public class TechnicianService : ITechnicianService
    {
        private readonly ITechnicianRepository _repo;
        private readonly ILogger<TechnicianService> _logger;

        public TechnicianService(ITechnicianRepository repo, ILogger<TechnicianService> logger)
        {
            _repo = repo;
            _logger = logger;
        }

        public async Task<TechnicianResponse> GetTechnicianAsync(int id)
        {
            try
            {
                var technician = await _repo.GetByIdAsync(id);
                if (technician == null)
                    throw new KeyNotFoundException("Technician not found");

                var services = await _repo.GetServicesAsync(id);
                return MapToResponse(technician, services);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting technician: {ex.Message}");
                throw;
            }
        }

        public async Task<List<TechnicianResponse>> GetAllTechniciansAsync()
        {
            try
            {
                var technicians = await _repo.GetAllAsync();
                var responses = new List<TechnicianResponse>();

                foreach (var tech in technicians)
                {
                    var services = await _repo.GetServicesAsync(tech.IdTecnico);
                    responses.Add(MapToResponse(tech, services));
                }

                return responses;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting all technicians: {ex.Message}");
                throw;
            }
        }

        public async Task<List<TechnicianResponse>> GetByServiceAsync(int serviceId)
        {
            try
            {
                var technicians = await _repo.GetByServiceAsync(serviceId);
                var responses = new List<TechnicianResponse>();

                foreach (var tech in technicians)
                {
                    var services = await _repo.GetServicesAsync(tech.IdTecnico);
                    responses.Add(MapToResponse(tech, services));
                }

                return responses;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting technicians by service: {ex.Message}");
                throw;
            }
        }

        public async Task<List<TechnicianResponse>> SearchTechniciansAsync(string searchTerm)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(searchTerm))
                    return await GetAllTechniciansAsync();

                var technicians = await _repo.SearchByNameAsync(searchTerm);
                var responses = new List<TechnicianResponse>();

                foreach (var tech in technicians)
                {
                    var services = await _repo.GetServicesAsync(tech.IdTecnico);
                    responses.Add(MapToResponse(tech, services));
                }

                return responses;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error searching technicians: {ex.Message}");
                throw;
            }
        }

        public async Task<List<TechnicianResponse>> GetByLocationAsync(double latitude, double longitude, double radius)
        {
            try
            {
                if (radius <= 0)
                    radius = 5; // Default 5 km

                var technicians = await _repo.GetByLocationAsync(latitude, longitude, radius);
                var responses = new List<TechnicianResponse>();

                foreach (var tech in technicians)
                {
                    var services = await _repo.GetServicesAsync(tech.IdTecnico);
                    responses.Add(MapToResponse(tech, services));
                }

                return responses;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting technicians by location: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateTechnicianAsync(int id, UpdateTechnicianRequest request)
        {
            try
            {
                var technician = await _repo.GetByIdAsync(id);
                if (technician == null)
                    throw new KeyNotFoundException("Technician not found");

                if (!string.IsNullOrWhiteSpace(request.Nombre))
                    technician.Nombre = request.Nombre;
                if (!string.IsNullOrWhiteSpace(request.Email))
                    technician.Email = request.Email;
                if (!string.IsNullOrWhiteSpace(request.Telefono))
                    technician.Telefono = request.Telefono;
                if (!string.IsNullOrWhiteSpace(request.UbicacionText))
                    technician.UbicacionText = request.UbicacionText;
                if (request.Latitud.HasValue)
                    technician.Latitud = request.Latitud.Value;
                if (request.Longitud.HasValue)
                    technician.Longitud = request.Longitud.Value;
                if (request.TarifaHora.HasValue)
                    technician.TarifaHora = request.TarifaHora.Value;
                if (request.ExperienciaYears.HasValue)
                    technician.ExperienciaYears = request.ExperienciaYears.Value;
                if (!string.IsNullOrWhiteSpace(request.Descripcion))
                    technician.Descripcion = request.Descripcion;
                if (!string.IsNullOrWhiteSpace(request.FotoPerfilUrl))
                    technician.FotoPerfilUrl = request.FotoPerfilUrl;

                return await _repo.UpdateAsync(technician);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating technician: {ex.Message}");
                throw;
            }
        }

        private TechnicianResponse MapToResponse(TechnicianModel technician, List<ServiceDTO> services)
        {
            return new TechnicianResponse
            {
                IdTecnico = technician.IdTecnico,
                Nombre = technician.Nombre,
                Email = technician.Email,
                Telefono = technician.Telefono,
                UbicacionText = technician.UbicacionText,
                Latitud = technician.Latitud,
                Longitud = technician.Longitud,
                TarifaHora = technician.TarifaHora,
                CalificacionPromedio = technician.CalificacionPromedio,
                NumCalificaciones = technician.NumCalificaciones,
                FotoPerfilUrl = technician.FotoPerfilUrl,
                Servicios = services
            };
        }
    }
}
