using ServitecAPI.DTOs;
using ServitecAPI.Models;
using ServitecAPI.Repositories;

namespace ServitecAPI.Services
{
    public class ServiceService : IServiceService
    {
        private readonly IServiceRepository _repo;
        private readonly ILogger<ServiceService> _logger;

        public ServiceService(IServiceRepository repo, ILogger<ServiceService> logger)
        {
            _repo = repo;
            _logger = logger;
        }

        public async Task<ServiceResponse> GetServiceAsync(int id)
        {
            try
            {
                var service = await _repo.GetByIdAsync(id);
                if (service == null)
                    throw new KeyNotFoundException("Service not found");

                return MapToResponse(service);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting service: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceResponse>> GetAllServicesAsync()
        {
            try
            {
                var services = await _repo.GetAllAsync();
                return services.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting all services: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceResponse>> SearchServicesAsync(string searchTerm)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(searchTerm))
                    return await GetAllServicesAsync();

                var services = await _repo.SearchAsync(searchTerm);
                return services.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error searching services: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceResponse>> GetActivesAsync()
        {
            try
            {
                var services = await _repo.GetActivesAsync();
                return services.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting active services: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceResponse>> GetByCategoryAsync(string category)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(category))
                    return await GetAllServicesAsync();

                var services = await _repo.GetByCategoryAsync(category);
                return services.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting services by category: {ex.Message}");
                throw;
            }
        }

        public async Task<int> CreateServiceAsync(CreateServiceRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.Nombre))
                    throw new ArgumentException("Service name is required");

                var service = new ServiceModel
                {
                    Nombre = request.Nombre,
                    Descripcion = request.Descripcion ?? "",
                    Categoria = request.Categoria,
                    TarifaBase = request.TarifaBase
                };

                return await _repo.CreateAsync(service);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating service: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateServiceAsync(int id, UpdateServiceRequest request)
        {
            try
            {
                var service = await _repo.GetByIdAsync(id);
                if (service == null)
                    throw new KeyNotFoundException("Service not found");

                if (!string.IsNullOrWhiteSpace(request.Nombre))
                    service.Nombre = request.Nombre;
                if (!string.IsNullOrWhiteSpace(request.Descripcion))
                    service.Descripcion = request.Descripcion;
                if (!string.IsNullOrWhiteSpace(request.Categoria))
                    service.Categoria = request.Categoria;
                if (request.TarifaBase.HasValue)
                    service.TarifaBase = request.TarifaBase;
                if (request.Activo.HasValue)
                    service.Activo = request.Activo.Value;

                return await _repo.UpdateAsync(service);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating service: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> DeleteServiceAsync(int id)
        {
            try
            {
                var service = await _repo.GetByIdAsync(id);
                if (service == null)
                    throw new KeyNotFoundException("Service not found");

                return await _repo.DeleteAsync(id);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting service: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceResponse>> GetWithTechniciansAsync()
        {
            try
            {
                var services = await _repo.GetWithTechniciansAsync();
                return services.Select(MapToResponse).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting services with technicians: {ex.Message}");
                throw;
            }
        }

        private ServiceResponse MapToResponse(ServiceModel service)
        {
            return new ServiceResponse
            {
                IdServicio = service.IdServicio,
                Nombre = service.Nombre,
                Descripcion = service.Descripcion,
                Categoria = service.Categoria,
                TarifaBase = service.TarifaBase,
                Activo = service.Activo,
                TecnicosDisponibles = service.TecnicosDisponibles
            };
        }
    }
}
