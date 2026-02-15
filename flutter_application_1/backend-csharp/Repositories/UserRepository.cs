using ServitecAPI.Models;
using ServitecAPI.Services;

namespace ServitecAPI.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly DatabaseService _db;
        private readonly ILogger<UserRepository> _logger;

        public UserRepository(DatabaseService db, ILogger<UserRepository> logger)
        {
            _db = db;
            _logger = logger;
        }

        public async Task<UserModel?> GetByIdAsync(int id)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM usuarios WHERE id_usuario = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (data.Count == 0)
                    return null;

                return MapToUserModel(data[0]);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting user by id: {ex.Message}");
                throw;
            }
        }

        public async Task<UserModel?> GetByEmailAsync(string email)
        {
            try
            {
                var data = await _db.ExecuteQueryAsync(
                    "SELECT * FROM usuarios WHERE email = @email",
                    new Dictionary<string, object> { { "email", email } }
                );

                if (data.Count == 0)
                    return null;

                return MapToUserModel(data[0]);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error getting user by email: {ex.Message}");
                throw;
            }
        }

        public async Task<int> CreateClientAsync(UserModel user)
        {
            try
            {
                var userId = await _db.ExecuteScalarAsync<int>(
                    @"INSERT INTO usuarios (nombre, apellido, email, contrasena, telefono, tipo_usuario, 
                      direccion_text, latitud, longitud, foto_perfil_url, fecha_registro)
                      VALUES (@nombre, @apellido, @email, @contrasena, @telefono, @tipo, 
                      @direccion, @lat, @lng, @foto, NOW());
                      SELECT LAST_INSERT_ID();",
                    new Dictionary<string, object>
                    {
                        { "nombre", user.Nombre },
                        { "apellido", user.Apellido ?? "" },
                        { "email", user.Email },
                        { "contrasena", user.Contrasena },
                        { "telefono", user.Telefono ?? "" },
                        { "tipo", "client" },
                        { "direccion", user.DireccionText ?? "" },
                        { "lat", user.Latitud },
                        { "lng", user.Longitud },
                        { "foto", user.FotoPerfilUrl ?? "" }
                    }
                );

                _logger.LogInformation($"Client created with ID: {userId}");
                return userId;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating client: {ex.Message}");
                throw;
            }
        }

        public async Task<int> CreateTechnicianAsync(UserModel user, List<int> serviceIds)
        {
            try
            {
                int techId = await _db.ExecuteScalarAsync<int>(
                    @"INSERT INTO usuarios (nombre, email, contrasena, telefono, tipo_usuario, 
                      ubicacion_text, latitud, longitud, tarifa_hora, foto_perfil_url, fecha_registro)
                      VALUES (@nombre, @email, @contrasena, @telefono, @tipo, 
                      @ubicacion, @lat, @lng, @tarifa, @foto, NOW());
                      SELECT LAST_INSERT_ID();",
                    new Dictionary<string, object>
                    {
                        { "nombre", user.Nombre },
                        { "email", user.Email },
                        { "contrasena", user.Contrasena },
                        { "telefono", user.Telefono ?? "" },
                        { "tipo", "technician" },
                        { "ubicacion", user.UbicacionText ?? "" },
                        { "lat", user.Latitud },
                        { "lng", user.Longitud },
                        { "tarifa", user.TarifaHora ?? 0 },
                        { "foto", user.FotoPerfilUrl ?? "" }
                    }
                );

                // Insertar servicios
                foreach (var serviceId in serviceIds)
                {
                    await _db.ExecuteNonQueryAsync(
                        "INSERT INTO tecnico_servicio (id_tecnico, id_servicio) VALUES (@tech, @service)",
                        new Dictionary<string, object>
                        {
                            { "tech", techId },
                            { "service", serviceId }
                        }
                    );
                }

                _logger.LogInformation($"Technician created with ID: {techId}, Services: {serviceIds.Count}");
                return techId;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error creating technician: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> UpdateAsync(UserModel user)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    @"UPDATE usuarios SET nombre = @nombre, email = @email, telefono = @telefono, 
                      foto_perfil_url = @foto WHERE id_usuario = @id",
                    new Dictionary<string, object>
                    {
                        { "nombre", user.Nombre },
                        { "email", user.Email },
                        { "telefono", user.Telefono ?? "" },
                        { "foto", user.FotoPerfilUrl ?? "" },
                        { "id", user.IdUsuario }
                    }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error updating user: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> DeleteAsync(int id)
        {
            try
            {
                var result = await _db.ExecuteNonQueryAsync(
                    "DELETE FROM usuarios WHERE id_usuario = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error deleting user: {ex.Message}");
                throw;
            }
        }

        public async Task<bool> ExistsAsync(string email)
        {
            try
            {
                var result = await _db.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM usuarios WHERE email = @email",
                    new Dictionary<string, object> { { "email", email } }
                );

                return result > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error checking user existence: {ex.Message}");
                throw;
            }
        }

        private UserModel MapToUserModel(Dictionary<string, object> data)
        {
            return new UserModel
            {
                IdUsuario = Convert.ToInt32(data["id_usuario"]),
                Nombre = (string)data["nombre"],
                Apellido = data.ContainsKey("apellido") ? (string?)data["apellido"] : null,
                Email = (string)data["email"],
                Contrasena = (string)data["contrasena"],
                Telefono = data.ContainsKey("telefono") ? (string?)data["telefono"] : null,
                TipoUsuario = (string)data["tipo_usuario"],
                DireccionText = data.ContainsKey("direccion_text") ? (string?)data["direccion_text"] : null,
                UbicacionText = data.ContainsKey("ubicacion_text") ? (string?)data["ubicacion_text"] : null,
                Latitud = Convert.ToDouble(data.ContainsKey("latitud") ? data["latitud"] : 0),
                Longitud = Convert.ToDouble(data.ContainsKey("longitud") ? data["longitud"] : 0),
                TarifaHora = data.ContainsKey("tarifa_hora") ? Convert.ToDouble(data["tarifa_hora"]) : null,
                FotoPerfilUrl = data.ContainsKey("foto_perfil_url") ? (string?)data["foto_perfil_url"] : null,
                FechaRegistro = Convert.ToDateTime(data.ContainsKey("fecha_registro") ? data["fecha_registro"] : DateTime.Now)
            };
        }
    }
}
