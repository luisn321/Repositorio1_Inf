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
                // Primero buscar en clientes
                var clienteData = await _db.ExecuteQueryAsync(
                    "SELECT * FROM clientes WHERE id_cliente = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (clienteData.Count > 0)
                {
                    return MapClienteToUserModel(clienteData[0], id);
                }

                // Luego buscar en técnicos
                var tecnicoData = await _db.ExecuteQueryAsync(
                    "SELECT * FROM tecnicos WHERE id_tecnico = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (tecnicoData.Count > 0)
                {
                    return MapTecnicoToUserModel(tecnicoData[0], id);
                }

                return null;
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
                // Primero buscar en clientes
                var clienteData = await _db.ExecuteQueryAsync(
                    "SELECT * FROM clientes WHERE email = @email",
                    new Dictionary<string, object> { { "email", email } }
                );

                if (clienteData.Count > 0)
                {
                    var cliente = clienteData[0];
                    int clienteId = Convert.ToInt32(cliente["id_cliente"]);
                    return MapClienteToUserModel(cliente, clienteId);
                }

                // Luego buscar en técnicos
                var tecnicoData = await _db.ExecuteQueryAsync(
                    "SELECT * FROM tecnicos WHERE email = @email",
                    new Dictionary<string, object> { { "email", email } }
                );

                if (tecnicoData.Count > 0)
                {
                    var tecnico = tecnicoData[0];
                    int tecnicoId = Convert.ToInt32(tecnico["id_tecnico"]);
                    return MapTecnicoToUserModel(tecnico, tecnicoId);
                }

                return null;
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
                var clienteId = await _db.ExecuteScalarAsync<int>(
                    @"INSERT INTO clientes (nombre, apellido, email, password_hash, telefono, 
                      direccion_text, latitud, longitud, foto_perfil_url, is_active)
                      VALUES (@nombre, @apellido, @email, @password, @telefono, 
                      @direccion, @lat, @lng, @foto, 1);
                      SELECT LAST_INSERT_ID();",
                    new Dictionary<string, object>
                    {
                        { "nombre", user.Nombre },
                        { "apellido", user.Apellido ?? "" },
                        { "email", user.Email },
                        { "password", user.Contrasena },
                        { "telefono", user.Telefono ?? "" },
                        { "direccion", user.DireccionText ?? "" },
                        { "lat", user.Latitud },
                        { "lng", user.Longitud },
                        { "foto", user.FotoPerfilUrl ?? "" }
                    }
                );

                _logger.LogInformation($"Client created with ID: {clienteId}");
                return clienteId;
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
                int tecnicoId = await _db.ExecuteScalarAsync<int>(
                    @"INSERT INTO tecnicos (nombre, apellido, email, password_hash, telefono, 
                      ubicacion_text, latitud, longitud, tarifa_hora, foto_perfil_url, is_active)
                      VALUES (@nombre, @apellido, @email, @password, @telefono, 
                      @ubicacion, @lat, @lng, @tarifa, @foto, 1);
                      SELECT LAST_INSERT_ID();",
                    new Dictionary<string, object>
                    {
                        { "nombre", user.Nombre },
                        { "apellido", user.Apellido ?? "" },
                        { "email", user.Email },
                        { "password", user.Contrasena },
                        { "telefono", user.Telefono ?? "" },
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
                            { "tech", tecnicoId },
                            { "service", serviceId }
                        }
                    );
                }

                _logger.LogInformation($"Technician created with ID: {tecnicoId}, Services: {serviceIds.Count}");
                return tecnicoId;
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
                // Determinar si es cliente o técnico basado en tipo_usuario
                if (user.TipoUsuario == "client")
                {
                    var result = await _db.ExecuteNonQueryAsync(
                        @"UPDATE clientes SET nombre = @nombre, apellido = @apellido, email = @email, 
                          telefono = @telefono, foto_perfil_url = @foto WHERE id_cliente = @id",
                        new Dictionary<string, object>
                        {
                            { "nombre", user.Nombre },
                            { "apellido", user.Apellido ?? "" },
                            { "email", user.Email },
                            { "telefono", user.Telefono ?? "" },
                            { "foto", user.FotoPerfilUrl ?? "" },
                            { "id", user.IdUsuario }
                        }
                    );

                    return result > 0;
                }
                else
                {
                    var result = await _db.ExecuteNonQueryAsync(
                        @"UPDATE tecnicos SET nombre = @nombre, apellido = @apellido, email = @email, 
                          telefono = @telefono, foto_perfil_url = @foto WHERE id_tecnico = @id",
                        new Dictionary<string, object>
                        {
                            { "nombre", user.Nombre },
                            { "apellido", user.Apellido ?? "" },
                            { "email", user.Email },
                            { "telefono", user.Telefono ?? "" },
                            { "foto", user.FotoPerfilUrl ?? "" },
                            { "id", user.IdUsuario }
                        }
                    );

                    return result > 0;
                }
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
                // Intentar eliminar de clientes primero
                var resultCliente = await _db.ExecuteNonQueryAsync(
                    "DELETE FROM clientes WHERE id_cliente = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (resultCliente > 0)
                    return true;

                // Si no está en clientes, eliminar de técnicos
                var resultTecnico = await _db.ExecuteNonQueryAsync(
                    "DELETE FROM tecnicos WHERE id_tecnico = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                return resultTecnico > 0;
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
                // Buscar en clientes
                var resultClientes = await _db.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM clientes WHERE email = @email",
                    new Dictionary<string, object> { { "email", email } }
                );

                if (resultClientes > 0)
                    return true;

                // Buscar en técnicos
                var resultTecnicos = await _db.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM tecnicos WHERE email = @email",
                    new Dictionary<string, object> { { "email", email } }
                );

                return resultTecnicos > 0;
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error checking user existence: {ex.Message}");
                throw;
            }
        }

        private UserModel MapClienteToUserModel(Dictionary<string, object> data, int id)
        {
            return new UserModel
            {
                IdUsuario = id,
                Nombre = (string)data["nombre"],
                Apellido = data.ContainsKey("apellido") ? (string?)data["apellido"] : null,
                Email = (string)data["email"],
                Contrasena = (string)data["password_hash"],
                Telefono = data.ContainsKey("telefono") ? (string?)data["telefono"] : null,
                TipoUsuario = "client",
                DireccionText = data.ContainsKey("direccion_text") ? (string?)data["direccion_text"] : null,
                UbicacionText = null,
                Latitud = Convert.ToDouble(data.ContainsKey("latitud") ? data["latitud"] : 0),
                Longitud = Convert.ToDouble(data.ContainsKey("longitud") ? data["longitud"] : 0),
                TarifaHora = null,
                FotoPerfilUrl = data.ContainsKey("foto_perfil_url") ? (string?)data["foto_perfil_url"] : null,
                FechaRegistro = Convert.ToDateTime(data.ContainsKey("created_at") ? data["created_at"] : DateTime.Now)
            };
        }

        private UserModel MapTecnicoToUserModel(Dictionary<string, object> data, int id)
        {
            return new UserModel
            {
                IdUsuario = id,
                Nombre = (string)data["nombre"],
                Apellido = data.ContainsKey("apellido") ? (string?)data["apellido"] : null,
                Email = (string)data["email"],
                Contrasena = (string)data["password_hash"],
                Telefono = data.ContainsKey("telefono") ? (string?)data["telefono"] : null,
                TipoUsuario = "technician",
                DireccionText = null,
                UbicacionText = data.ContainsKey("ubicacion_text") ? (string?)data["ubicacion_text"] : null,
                Latitud = Convert.ToDouble(data.ContainsKey("latitud") ? data["latitud"] : 0),
                Longitud = Convert.ToDouble(data.ContainsKey("longitud") ? data["longitud"] : 0),
                TarifaHora = data.ContainsKey("tarifa_hora") ? Convert.ToDouble(data["tarifa_hora"]) : null,
                FotoPerfilUrl = data.ContainsKey("foto_perfil_url") ? (string?)data["foto_perfil_url"] : null,
                FechaRegistro = Convert.ToDateTime(data.ContainsKey("created_at") ? data["created_at"] : DateTime.Now)
            };
        }
    }
}

