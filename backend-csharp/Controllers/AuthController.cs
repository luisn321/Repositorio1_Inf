using Microsoft.AspNetCore.Mvc;
using ServitecAPI.Services;

namespace ServitecAPI.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly DatabaseService _db;
        private readonly AuthService _auth;

        public AuthController(DatabaseService db, AuthService auth)
        {
            _db = db;
            _auth = auth;
        }

        [HttpPost("register/client")]
        public async Task<IActionResult> RegisterClient([FromBody] RegisterClientRequest req)
        {
            try
            {
                // Log para debugging
                Console.WriteLine($"📥 Recibido - Nombre: {req.Nombre}, Email: {req.Email}");
                Console.WriteLine($"📥 DireccionText: '{req.DireccionText}', Lat: {req.Lat}, Lng: {req.Lng}");

                // Validar que email no exista
                var existingClient = await _db.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM clientes WHERE email = @email",
                    new Dictionary<string, object> { { "email", req.Email } }
                );

                if (existingClient > 0)
                    return Conflict(new { error = "El email ya está registrado." });

                var passwordHash = _db.HashPassword(req.Password);

                // ✅ CORRECCIÓN: direccion → direccion_text
                var query = @"
                    INSERT INTO clientes (nombre, apellido, email, password_hash, telefono, direccion_text, latitud, longitud)
                    VALUES (@nombre, @apellido, @email, @hash, @telefono, @direccion_text, @lat, @lng);
                    SELECT LAST_INSERT_ID();
                ";

                var parameters = new Dictionary<string, object>
                {
                    { "nombre", req.Nombre },
                    { "apellido", req.Apellido },
                    { "email", req.Email },
                    { "hash", passwordHash },
                    { "telefono", req.Telefono },
                    { "direccion_text", req.DireccionText },  // ✅ CAMBIO AQUÍ
                    { "lat", req.Lat },
                    { "lng", req.Lng }
                };

                var clientId = await _db.ExecuteScalarAsync<int>(query, parameters);

                if (clientId <= 0)
                    return StatusCode(500, new { error = "Error al crear cliente." });

                var token = _auth.GenerateToken(clientId, req.Email, "client");

                Console.WriteLine($"✅ Cliente creado exitosamente - ID: {clientId}");

                return Ok(new
                {
                    token,
                    user_type = "client",
                    id_cliente = clientId,
                    email = req.Email,
                    nombre = req.Nombre
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error en RegisterClient: {ex.Message}");
                Console.WriteLine($"❌ StackTrace: {ex.StackTrace}");
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpPost("register/technician")]
        public async Task<IActionResult> RegisterTechnician([FromBody] RegisterTechnicianRequest req)
        {
            try
            {
                var existingTech = await _db.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM tecnicos WHERE email = @email",
                    new Dictionary<string, object> { { "email", req.Email } }
                );

                if (existingTech > 0)
                    return Conflict(new { error = "El email ya está registrado." });

                var passwordHash = _db.HashPassword(req.Password);

                var query = @"
                    INSERT INTO tecnicos (nombre, email, password_hash, telefono, ubicacion, latitud, longitud, tarifa_hora, experiencia_years, descripcion)
                    VALUES (@nombre, @email, @hash, @telefono, @ubicacion, @lat, @lng, @tarifa, @exp, @desc);
                    SELECT LAST_INSERT_ID();
                ";

                var parameters = new Dictionary<string, object>
                {
                    { "nombre", req.Nombre },
                    { "email", req.Email },
                    { "hash", passwordHash },
                    { "telefono", req.Telefono },
                    { "ubicacion", req.Ubicacion },
                    { "lat", req.Lat },
                    { "lng", req.Lng },
                    { "tarifa", req.TarifaHora ?? 0 },
                    { "exp", req.ExperienciaYears ?? 0 },
                    { "desc", req.Descripcion ?? "" }
                };

                var techId = await _db.ExecuteScalarAsync<int>(query, parameters);

                if (techId <= 0)
                    return StatusCode(500, new { error = "Error al crear técnico." });

                // Insertar servicios
                if (req.ServiceIds != null && req.ServiceIds.Count > 0)
                {
                    foreach (var serviceId in req.ServiceIds)
                    {
                        await _db.ExecuteNonQueryAsync(
                            "INSERT INTO tecnico_servicio (id_tecnico, id_servicio) VALUES (@tech, @svc)",
                            new Dictionary<string, object> { { "tech", techId }, { "svc", serviceId } }
                        );
                    }
                }

                var token = _auth.GenerateToken(techId, req.Email, "technician");

                return Ok(new
                {
                    token,
                    user_type = "technician",
                    id_tecnico = techId,
                    email = req.Email,
                    nombre = req.Nombre
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error en RegisterTechnician: {ex.Message}");
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest req)
        {
            try
            {
                // Intentar como cliente
                var clientQuery = "SELECT id_cliente, nombre, email, password_hash FROM clientes WHERE email = @email";
                var clientResults = await _db.ExecuteQueryAsync(clientQuery, new Dictionary<string, object> { { "email", req.Email } });

                if (clientResults.Count > 0)
                {
                    var client = clientResults[0];
                    var hash = client["password_hash"].ToString() ?? "";
                    if (_db.VerifyPassword(req.Password, hash))
                    {
                        var token = _auth.GenerateToken((int)client["id_cliente"], req.Email, "client");
                        return Ok(new
                        {
                            token,
                            user_type = "client",
                            id_user = client["id_cliente"],
                            nombre = client["nombre"],
                            email = client["email"]
                        });
                    }
                }

                // Intentar como técnico
                var techQuery = "SELECT id_tecnico, nombre, email, password_hash FROM tecnicos WHERE email = @email";
                var techResults = await _db.ExecuteQueryAsync(techQuery, new Dictionary<string, object> { { "email", req.Email } });

                if (techResults.Count > 0)
                {
                    var tech = techResults[0];
                    var hash = tech["password_hash"].ToString() ?? "";
                    if (_db.VerifyPassword(req.Password, hash))
                    {
                        var token = _auth.GenerateToken((int)tech["id_tecnico"], req.Email, "technician");
                        return Ok(new
                        {
                            token,
                            user_type = "technician",
                            id_user = tech["id_tecnico"],
                            nombre = tech["nombre"],
                            email = tech["email"]
                        });
                    }
                }

                return Unauthorized(new { error = "Email o contraseña incorrectos." });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error en Login: {ex.Message}");
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }

    public class RegisterClientRequest
    {
        public string Nombre { get; set; } = "";
        public string Apellido { get; set; } = "";
        public string Email { get; set; } = "";
        public string Password { get; set; } = "";
        public string Telefono { get; set; } = "";
        public string DireccionText { get; set; } = "";
        public double Lat { get; set; }
        public double Lng { get; set; }
    }

    public class RegisterTechnicianRequest
    {
        public string Nombre { get; set; } = "";
        public string Email { get; set; } = "";
        public string Password { get; set; } = "";
        public string Telefono { get; set; } = "";
        public string Ubicacion { get; set; } = "";
        public double Lat { get; set; }
        public double Lng { get; set; }
        public double? TarifaHora { get; set; }
        public int? ExperienciaYears { get; set; }
        public string? Descripcion { get; set; }
        public List<int>? ServiceIds { get; set; }
    }

    public class LoginRequest
    {
        public string Email { get; set; } = "";
        public string Password { get; set; } = "";
    }
}
