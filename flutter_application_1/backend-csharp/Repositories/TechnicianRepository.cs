using ServitecAPI.Models;
using ServitecAPI.DTOs;
using ServitecAPI.Services;

namespace ServitecAPI.Repositories
{
    public class TechnicianRepository : ITechnicianRepository
    {
        private readonly DatabaseService _db;
        private readonly ILogger<TechnicianRepository> _logger;

        public TechnicianRepository(DatabaseService db, ILogger<TechnicianRepository> logger)
        {
            _db = db;
            _logger = logger;
        }

        public async Task<TechnicianModel?> GetByIdAsync(int id)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM tecnicos WHERE id_tecnico = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (data.Count == 0) return null;
                return MapToTechnicianModel(data[0]);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting technician by id: {ex.Message}");
                throw;
            }
        }

        public async Task<List<TechnicianModel>> GetAllAsync()
        {
            try
            {
                var data = await _db.ExecuteQueryAsync("SELECT * FROM tecnicos WHERE is_active = 1");
                return data.Select(MapToTechnicianModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting all technicians: {ex.Message}");
                throw;
            }
        }

        public async Task<List<TechnicianModel>> GetByServiceAsync(int serviceId)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    @"SELECT DISTINCT t.* FROM tecnicos t
                      INNER JOIN tecnico_servicio ts ON t.id_tecnico = ts.id_tecnico
                      WHERE ts.id_servicio = @serviceId AND t.is_active = 1",
                    new Dictionary<string, object> { { "serviceId", serviceId } }
                );

                return data.Select(MapToTechnicianModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting technicians by service: {ex.Message}");
                throw;
            }
        }

        public async Task<List<TechnicianModel>> SearchByNameAsync(string searchTerm)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM tecnicos WHERE nombre LIKE @search AND is_active = 1",
                    new Dictionary<string, object> { { "search", $"%{searchTerm}%" } }
                );

                return data.Select(MapToTechnicianModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error searching technicians: {ex.Message}");
                throw;
            }
        }

        public async Task<List<TechnicianModel>> GetByLocationAsync(double latitude, double longitude, double radius)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    @"SELECT * FROM tecnicos 
                      WHERE is_active = 1
                      AND (6371 * ACOS(COS(RADIANS(@lat)) * COS(RADIANS(latitud)) * COS(RADIANS(longitud) - RADIANS(@lng)) + SIN(RADIANS(@lat)) * SIN(RADIANS(latitud)))) <= @radius",
                    new Dictionary<string, object>
                    {
                        { "lat", latitude },
                        { "lng", longitude },
                        { "radius", radius }
                    }
                );

                return data.Select(MapToTechnicianModel).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting technicians by location: {ex.Message}");
                throw;
            }
        }

        public async Task<int> CreateAsync(TechnicianModel technician, List<int> serviceIds)
        {
            try
            {
                int techId = await _db.ExecuteScalarAsync<int>(
                    @"INSERT INTO tecnicos (nombre, email, password_hash, telefono, ubicacion_text, 
                      latitud, longitud, tarifa_hora, experiencia_years, descripcion, foto_perfil_url, 
                      created_at, is_active)
                      VALUES (@nombre, @email, @contrasena, @telefono, @ubicacion, @lat, @lng, @tarifa, 
                      @experiencia, @descripcion, @foto, NOW(), 1);
                      SELECT LAST_INSERT_ID();",
                    new Dictionary<string, object>
                    {
                        { "nombre", technician.Nombre },
                        { "email", technician.Email },
                        { "contrasena", technician.Contrasena },
                        { "telefono", technician.Telefono ?? "" },
                        { "ubicacion", technician.UbicacionText ?? "" },
                        { "lat", technician.Latitud },
                        { "lng", technician.Longitud },
                        { "tarifa", technician.TarifaHora ?? 0 },
                        { "experiencia", technician.ExperienciaYears ?? 0 },
                        { "descripcion", technician.Descripcion ?? "" },
                        { "foto", technician.FotoPerfilUrl ?? "" }
                    }
                );

                foreach (var serviceId in serviceIds)
                {
                    await _db.ExecuteNonQueryAsync(
                        "INSERT INTO tecnico_servicio (id_tecnico, id_servicio) VALUES (@tech, @service)",
                        new Dictionary<string, object> { { "tech", techId }, { "service", serviceId } }
                    );
                }

                _logger.LogInformation($"Technician created with ID: {techId}");
                return techId;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating technician: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateAsync(TechnicianModel technician)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE tecnicos SET nombre = @nombre, email = @email, telefono = @telefono, 
                      ubicacion_text = @ubicacion, latitud = @lat, longitud = @lng, tarifa_hora = @tarifa,
                      experiencia_years = @experiencia, descripcion = @descripcion, 
                      foto_perfil_url = @foto, updated_at = NOW() WHERE id_tecnico = @id",
                    new Dictionary<string, object>
                    {
                        { "nombre", technician.Nombre },
                        { "email", technician.Email },
                        { "telefono", technician.Telefono ?? "" },
                        { "ubicacion", technician.UbicacionText ?? "" },
                        { "lat", technician.Latitud },
                        { "lng", technician.Longitud },
                        { "tarifa", technician.TarifaHora ?? 0 },
                        { "experiencia", technician.ExperienciaYears ?? 0 },
                        { "descripcion", technician.Descripcion ?? "" },
                        { "foto", technician.FotoPerfilUrl ?? "" },
                        { "id", technician.IdTecnico }
                    }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating technician: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> DeleteAsync(int id)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    "UPDATE tecnicos SET is_active = 0 WHERE id_tecnico = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting technician: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateRatingAsync(int id, double nuevoPromedio, int numCalificaciones)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    "UPDATE tecnicos SET calificacion_promedio = @promedio, num_calificaciones = @num WHERE id_tecnico = @id",
                    new Dictionary<string, object>
                    {
                        { "promedio", nuevoPromedio },
                        { "num", numCalificaciones },
                        { "id", id }
                    }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating rating: {ex.Message}");
                throw;
            }
        }

        public async Task<List<ServiceDTO>> GetServicesAsync(int technicianId)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    @"SELECT s.id_servicio, s.nombre FROM servicios s
                      INNER JOIN tecnico_servicio ts ON s.id_servicio = ts.id_servicio
                      WHERE ts.id_tecnico = @tech",
                    new Dictionary<string, object> { { "tech", technicianId } }
                );

                return data.Select(d => new ServiceDTO
                {
                    IdServicio = (int)d["id_servicio"],
                    Nombre = (string)d["nombre"]
                }).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting technician services: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateServicesAsync(int technicianId, List<int> serviceIds)
        {
            try
            {
                // 1. Eliminar asociaciones actuales
                await _db.ExecuteNonQueryAsync(
                    "DELETE FROM tecnico_servicio WHERE id_tecnico = @id",
                    new Dictionary<string, object> { { "id", technicianId } }
                );

                // 2. Insertar nuevas asociaciones
                if (serviceIds != null && serviceIds.Count > 0)
                {
                    foreach (var serviceId in serviceIds)
                    {
                        await _db.ExecuteNonQueryAsync(
                            "INSERT INTO tecnico_servicio (id_tecnico, id_servicio) VALUES (@tech, @service)",
                            new Dictionary<string, object> { { "tech", technicianId }, { "service", serviceId } }
                        );
                    }
                }

                _logger.LogInformation($"Servicios actualizados para técnico {technicianId}. Total: {serviceIds?.Count ?? 0}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error actualizando servicios del técnico {technicianId}: {ex.Message}");
                return false;
            }
        }

        private TechnicianModel MapToTechnicianModel(Dictionary<string, object> data)
        {
            return new TechnicianModel
            {
                IdTecnico = (int)data["id_tecnico"],
                Nombre = data["nombre"] != DBNull.Value ? (string)data["nombre"] : "",
                Apellido = data.ContainsKey("apellido") && data["apellido"] != DBNull.Value ? (string)data["apellido"] : null,
                Email = data.ContainsKey("email") && data["email"] != DBNull.Value ? (string)data["email"] : "",
                Contrasena = data.ContainsKey("password_hash") && data["password_hash"] != DBNull.Value ? (string)data["password_hash"] : "",
                Telefono = data.ContainsKey("telefono") && data["telefono"] != DBNull.Value ? (string)data["telefono"] : null,
                UbicacionText = data.ContainsKey("ubicacion_text") && data["ubicacion_text"] != DBNull.Value ? (string)data["ubicacion_text"] : null,
                Latitud = data.ContainsKey("latitud") && data["latitud"] != DBNull.Value ? Convert.ToDouble(data["latitud"]) : 0,
                Longitud = data.ContainsKey("longitud") && data["longitud"] != DBNull.Value ? Convert.ToDouble(data["longitud"]) : 0,
                TarifaHora = data.ContainsKey("tarifa_hora") && data["tarifa_hora"] != DBNull.Value ? Convert.ToDouble(data["tarifa_hora"]) : null,
                ExperienciaYears = data.ContainsKey("experiencia_years") && data["experiencia_years"] != DBNull.Value ? (int?)data["experiencia_years"] : null,
                Descripcion = data.ContainsKey("descripcion") && data["descripcion"] != DBNull.Value ? (string)data["descripcion"] : null,
                FotoPerfilUrl = data.ContainsKey("foto_perfil_url") && data["foto_perfil_url"] != DBNull.Value ? (string)data["foto_perfil_url"] : null,
                CalificacionPromedio = data.ContainsKey("calificacion_promedio") && data["calificacion_promedio"] != DBNull.Value ? Convert.ToDouble(data["calificacion_promedio"]) : 0,
                NumCalificaciones = data.ContainsKey("num_calificaciones") && data["num_calificaciones"] != DBNull.Value ? (int)data["num_calificaciones"] : 0,
                FechaRegistro = data.ContainsKey("created_at") && data["created_at"] != DBNull.Value ? Convert.ToDateTime(data["created_at"]) : DateTime.Now
            };
        }
    }
}
