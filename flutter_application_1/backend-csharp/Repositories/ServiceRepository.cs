using ServitecAPI.Models;
using ServitecAPI.Services;

namespace ServitecAPI.Repositories
{
    public class ServiceRepository : IServiceRepository
    {
        private readonly DatabaseService _db;
        private readonly ILogger<ServiceRepository> _logger;

        public ServiceRepository(DatabaseService db, ILogger<ServiceRepository> logger)
        {
            _db = db;
            _logger = logger;
        }

        public async Task<ServiceModel?> GetByIdAsync(int id)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM servicios WHERE id_servicio = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (data.Count == 0) return null;
                return MapToServiceModel(data[0]);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting service by id: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceModel>> GetAllAsync()
        {
            try
            {
                var data = await _db.ExecuteQueryAsync("SELECT * FROM servicios ORDER BY nombre");
                return data.Select(MapToServiceModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting all services: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceModel>> SearchAsync(string searchTerm)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM servicios WHERE nombre LIKE @search OR descripcion LIKE @search ORDER BY nombre",
                    new Dictionary<string, object> { { "search", $"%{searchTerm}%" } }
                );

                return data.Select(MapToServiceModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error searching services: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceModel>> GetActivesAsync()
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM servicios WHERE is_active = 1 ORDER BY nombre"
                );

                return data.Select(MapToServiceModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting active services: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceModel>> GetByCategoryAsync(string category)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM servicios WHERE categoria = @categoria ORDER BY nombre",
                    new Dictionary<string, object> { { "categoria", category } }
                );

                return data.Select(MapToServiceModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting services by category: {ex.Message}");
                throw;
            }
        }

        public async Task<int> CreateAsync(ServiceModel service)
        {
            try
            {
                int serviceId = await _db.ExecuteScalarAsync<int>(
                    @"INSERT INTO servicios (nombre, descripcion, categoria, tarifa_base, is_active, created_at)
                      VALUES (@nombre, @descripcion, @categoria, @tarifa, 1, NOW());
                      SELECT LAST_INSERT_ID();",
                    new Dictionary<string, object>
                    {
                        { "nombre", service.Nombre },
                        { "descripcion", service.Descripcion ?? "" },
                        { "categoria", service.Categoria ?? "" },
                        { "tarifa", service.TarifaBase ?? 0 }
                    }
                );

                _logger.LogInformation($"Service created with ID: {serviceId}");
                return serviceId;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating service: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateAsync(ServiceModel service)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE servicios SET nombre = @nombre, descripcion = @descripcion, 
                      categoria = @categoria, tarifa_base = @tarifa, is_active = @activo, 
                      updated_at = NOW() WHERE id_servicio = @id",
                    new Dictionary<string, object>
                    {
                        { "nombre", service.Nombre },
                        { "descripcion", service.Descripcion ?? "" },
                        { "categoria", service.Categoria ?? "" },
                        { "tarifa", service.TarifaBase ?? 0 },
                        { "activo", service.Activo ? 1 : 0 },
                        { "id", service.IdServicio }
                    }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating service: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> DeleteAsync(int id)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    "UPDATE servicios SET is_active = 0 WHERE id_servicio = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting service: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceModel>> GetWithTechniciansAsync()
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    @"SELECT s.*, COUNT(DISTINCT ts.id_tecnico) as tecnicos_count
                      FROM servicios s
                      LEFT JOIN tecnico_servicio ts ON s.id_servicio = ts.id_servicio
                      WHERE s.is_active = 1
                      GROUP BY s.id_servicio
                      ORDER BY s.nombre"
                );

                return data.Select(d =>
                {
                    var model = MapToServiceModel(d);
                    model.TecnicosDisponibles = d.ContainsKey("tecnicos_count") ? Convert.ToInt32(d["tecnicos_count"]) : 0;
                    return model;
                }).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting services with technicians: {ex.Message}");
                throw;
            }
        }

        private ServiceModel MapToServiceModel(Dictionary<string, object> data)
        {
            return new ServiceModel
            {
                IdServicio = (int)data["id_servicio"],
                Nombre = (string)data["nombre"],
                Descripcion = (string)data.GetValueOrDefault("descripcion", ""),
                Categoria = data.ContainsKey("categoria") ? (string?)data["categoria"] : null,
                TarifaBase = data.ContainsKey("tarifa_base") ? Convert.ToDouble(data["tarifa_base"]) : null,
                Activo = Convert.ToBoolean(data.GetValueOrDefault("is_active", true)),
                FechaRegistro = Convert.ToDateTime(data.GetValueOrDefault("created_at", DateTime.Now)),
                FechaActualizacion = data.ContainsKey("updated_at") ? Convert.ToDateTime(data["updated_at"]) : null,
                TecnicosDisponibles = data.ContainsKey("tecnicos_count") ? Convert.ToInt32(data["tecnicos_count"]) : 0
            };
        }
    }
}
