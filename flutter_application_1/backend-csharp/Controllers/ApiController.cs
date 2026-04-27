using Microsoft.AspNetCore.Mvc;
using ServitecAPI.Services;

namespace ServitecAPI.Controllers
{
    [ApiController]
    [Route("api")]
    public class HealthController : ControllerBase
    {
        private readonly DatabaseService _db;

        public HealthController(DatabaseService db)
        {
            _db = db;
        }

        [HttpGet("health")]
        public IActionResult Health()
        {
            return Ok(new { status = "Servitec API is working correctly" });
        }

        [HttpPost("debug/hash")]
        public IActionResult GenerateHash([FromBody] DebugHashRequest req)
        {
            var hash = _db.HashPassword(req.Password);
            return Ok(new { password = req.Password, hash = hash });
        }
    }

    public class DebugHashRequest
    {
        public string Password { get; set; } = "";
    }

    [ApiController]
    [Route("api/services")]
    public class ServicesController : ControllerBase
    {
        private readonly DatabaseService _db;

        public ServicesController(DatabaseService db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<IActionResult> GetServices()
        {
            try
            {
                var results = await _db.ExecuteQueryAsync("SELECT id_servicio, nombre FROM servicios ORDER BY nombre");
                var services = results.Select(r => new
                {
                    id_servicio = r["id_servicio"],
                    nombre = r["nombre"]
                }).ToList();

                return Ok(services);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }

    [ApiController]
    [Route("api/clients")]
    public class ClientsController : ControllerBase
    {
        private readonly DatabaseService _db;

        public ClientsController(DatabaseService db)
        {
            _db = db;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetClientProfile(int id)
        {
            try
            {
                var results = await _db.ExecuteQueryAsync(
                    "SELECT * FROM clientes WHERE id_cliente = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (results.Count == 0)
                    return NotFound(new { error = "Client not found" });

                return Ok(results[0]);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateClientProfile(int id, [FromBody] UpdateClientRequest req)
        {
            try
            {
                // Build query dynamically based on what fields are sent
                var updates = new List<string>();
                var parameters = new Dictionary<string, object> { { "id", id } };

                if (!string.IsNullOrEmpty(req.FirstName))
                {
                    updates.Add("nombre = @nombre");
                    parameters["nombre"] = req.FirstName;
                }
                if (!string.IsNullOrEmpty(req.LastName))
                {
                    updates.Add("apellido = @apellido");
                    parameters["apellido"] = req.LastName;
                }
                if (!string.IsNullOrEmpty(req.Email))
                {
                    updates.Add("email = @email");
                    parameters["email"] = req.Email;
                }
                if (!string.IsNullOrEmpty(req.Phone))
                {
                    updates.Add("telefono = @telefono");
                    parameters["telefono"] = req.Phone;
                }
                if (!string.IsNullOrEmpty(req.AddressText))
                {
                    updates.Add("direccion_text = @direccion_text");
                    parameters["direccion_text"] = req.AddressText;
                }
                if (req.Latitude.HasValue)
                {
                    updates.Add("latitud = @latitud");
                    parameters["latitud"] = req.Latitude;
                }
                if (req.Longitude.HasValue)
                {
                    updates.Add("longitud = @longitud");
                    parameters["longitud"] = req.Longitude;
                }
                if (!string.IsNullOrEmpty(req.Password))
                {
                    updates.Add("password_hash = @password_hash");
                    parameters["password_hash"] = _db.HashPassword(req.Password);
                }

                if (updates.Count == 0)
                    return BadRequest(new { error = "No fields to update" });

                updates.Add("updated_at = NOW()");

                var query = $"UPDATE clientes SET {string.Join(", ", updates)} WHERE id_cliente = @id";
                await _db.ExecuteNonQueryAsync(query, parameters);

                return Ok(new { message = "Client updated successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }


    public class UpdateTechnicianServicesRequest
    {
        public List<int>? ServiceIds { get; set; }
    }

    public class UpdateClientRequest
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? AddressText { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public string? Password { get; set; }
    }


}
   