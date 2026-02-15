using Microsoft.AspNetCore.Mvc;
using ServitecAPI.Services;

namespace ServitecAPI.Controllers
{
    [ApiController]
    [Route("api")]
    public class HealthController : ControllerBase
    {
        [HttpGet("health")]
        public IActionResult Health()
        {
            return Ok(new { status = "API Servitec funcionando correctamente" });
        }
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
                    return NotFound(new { error = "Cliente no encontrado" });

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
                // Construir query dinámicamente dependiendo de qué campos se envíen
                var updates = new List<string>();
                var parameters = new Dictionary<string, object> { { "id", id } };

                if (!string.IsNullOrEmpty(req.Nombre))
                {
                    updates.Add("nombre = @nombre");
                    parameters["nombre"] = req.Nombre;
                }
                if (!string.IsNullOrEmpty(req.Apellido))
                {
                    updates.Add("apellido = @apellido");
                    parameters["apellido"] = req.Apellido;
                }
                if (!string.IsNullOrEmpty(req.Email))
                {
                    updates.Add("email = @email");
                    parameters["email"] = req.Email;
                }
                if (!string.IsNullOrEmpty(req.Telefono))
                {
                    updates.Add("telefono = @telefono");
                    parameters["telefono"] = req.Telefono;
                }
                if (!string.IsNullOrEmpty(req.DireccionText))
                {
                    updates.Add("direccion_text = @direccion_text");
                    parameters["direccion_text"] = req.DireccionText;
                }
                if (req.Latitud.HasValue)
                {
                    updates.Add("latitud = @latitud");
                    parameters["latitud"] = req.Latitud;
                }
                if (req.Longitud.HasValue)
                {
                    updates.Add("longitud = @longitud");
                    parameters["longitud"] = req.Longitud;
                }
                if (!string.IsNullOrEmpty(req.Password))
                {
                    updates.Add("password_hash = @password_hash");
                    parameters["password_hash"] = _db.HashPassword(req.Password);
                }

                if (updates.Count == 0)
                    return BadRequest(new { error = "No hay campos para actualizar" });

                updates.Add("updated_at = NOW()");

                var query = $"UPDATE clientes SET {string.Join(", ", updates)} WHERE id_cliente = @id";
                await _db.ExecuteNonQueryAsync(query, parameters);

                return Ok(new { message = "Cliente actualizado correctamente" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }

    [ApiController]
    [Route("api/technicians")]
    public class TechniciansController : ControllerBase
    {
        private readonly DatabaseService _db;

        public TechniciansController(DatabaseService db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<IActionResult> GetTechnicians([FromQuery] int? serviceId, [FromQuery] double? lat, [FromQuery] double? lng, [FromQuery] double? radius)
        {
            try
            {
                string query = @"
                    SELECT t.id_tecnico, t.nombre, t.email, t.tarifa_hora, t.calificacion_promedio, t.latitud, t.longitud
                    FROM tecnicos t
                ";

                if (serviceId.HasValue)
                {
                    query += @" INNER JOIN tecnico_servicio ts ON t.id_tecnico = ts.id_tecnico 
                               WHERE ts.id_servicio = @serviceId";
                }

                var results = await _db.ExecuteQueryAsync(query, 
                    serviceId.HasValue ? new Dictionary<string, object> { { "serviceId", serviceId } } : null);

                return Ok(results);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetTechnicianDetail(int id)
        {
            try
            {
                var results = await _db.ExecuteQueryAsync(
                    "SELECT * FROM tecnicos WHERE id_tecnico = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (results.Count == 0)
                    return NotFound();

                return Ok(results[0]);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTechnicianProfile(int id, [FromBody] UpdateTechnicianRequest req)
        {
            try
            {
                // Construir query dinámicamente dependiendo de qué campos se envíen
                var updates = new List<string>();
                var parameters = new Dictionary<string, object> { { "id", id } };

                if (!string.IsNullOrEmpty(req.Nombre))
                {
                    updates.Add("nombre = @nombre");
                    parameters["nombre"] = req.Nombre;
                }
                if (!string.IsNullOrEmpty(req.Email))
                {
                    updates.Add("email = @email");
                    parameters["email"] = req.Email;
                }
                if (!string.IsNullOrEmpty(req.Telefono))
                {
                    updates.Add("telefono = @telefono");
                    parameters["telefono"] = req.Telefono;
                }
                if (!string.IsNullOrEmpty(req.UbicacionText))
                {
                    updates.Add("ubicacion_text = @ubicacion_text");
                    parameters["ubicacion_text"] = req.UbicacionText;
                }
                if (req.Latitud.HasValue)
                {
                    updates.Add("latitud = @latitud");
                    parameters["latitud"] = req.Latitud;
                }
                if (req.Longitud.HasValue)
                {
                    updates.Add("longitud = @longitud");
                    parameters["longitud"] = req.Longitud;
                }
                if (req.TarifaHora.HasValue)
                {
                    updates.Add("tarifa_hora = @tarifa_hora");
                    parameters["tarifa_hora"] = req.TarifaHora;
                }
                if (req.ExperienciaYears.HasValue)
                {
                    updates.Add("experiencia_years = @experiencia_years");
                    parameters["experiencia_years"] = req.ExperienciaYears;
                }
                if (!string.IsNullOrEmpty(req.Descripcion))
                {
                    updates.Add("descripcion = @descripcion");
                    parameters["descripcion"] = req.Descripcion;
                }
                if (!string.IsNullOrEmpty(req.Password))
                {
                    updates.Add("password_hash = @password_hash");
                    parameters["password_hash"] = _db.HashPassword(req.Password);
                }

                if (updates.Count == 0)
                    return BadRequest(new { error = "No hay campos para actualizar" });

                updates.Add("updated_at = NOW()");

                var query = $"UPDATE tecnicos SET {string.Join(", ", updates)} WHERE id_tecnico = @id";
                await _db.ExecuteNonQueryAsync(query, parameters);

                return Ok(new { message = "Técnico actualizado correctamente" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }

    [ApiController]
    [Route("api/contractations")]
    public class ContractationsController : ControllerBase
    {
        private readonly DatabaseService _db;

        public ContractationsController(DatabaseService db)
        {
            _db = db;
        }

        [HttpPost]
        public async Task<IActionResult> CreateContractation([FromBody] CreateContractationRequest req)
        {
            try
            {
                var query = @"
                    INSERT INTO contrataciones (id_cliente, id_tecnico, id_servicio, descripcion, fecha_solicitud, estado)
                    VALUES (@client, @tech, @service, @desc, NOW(), 'pendiente');
                    SELECT LAST_INSERT_ID();
                ";

                var parameters = new Dictionary<string, object>
                {
                    { "client", req.IdCliente },
                    { "tech", req.IdTecnico },
                    { "service", req.IdServicio },
                    { "desc", req.Descripcion ?? "" }
                };

                var id = await _db.ExecuteScalarAsync<int>(query, parameters);
                return Ok(new { id_contratacion = id });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetContractation(int id)
        {
            try
            {
                var results = await _db.ExecuteQueryAsync(
                    "SELECT * FROM contrataciones WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                if (results.Count == 0)
                    return NotFound();

                return Ok(results[0]);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }

    [ApiController]
    [Route("api/payments")]
    public class PaymentsController : ControllerBase
    {
        private readonly DatabaseService _db;

        public PaymentsController(DatabaseService db)
        {
            _db = db;
        }

        [HttpPost]
        public async Task<IActionResult> CreatePayment([FromBody] CreatePaymentRequest req)
        {
            try
            {
                var query = @"
                    INSERT INTO pagos (id_contratacion, monto, metodo_pago, fecha_pago, estado_pago)
                    VALUES (@contractation, @amount, @method, NOW(), 'completado');
                    SELECT LAST_INSERT_ID();
                ";

                var parameters = new Dictionary<string, object>
                {
                    { "contractation", req.IdContratacion },
                    { "amount", req.Monto },
                    { "method", req.MetodoPago }
                };

                var id = await _db.ExecuteScalarAsync<int>(query, parameters);
                return Ok(new { id_pago = id });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }

    [ApiController]
    [Route("api/ratings")]
    public class RatingsController : ControllerBase
    {
        private readonly DatabaseService _db;

        public RatingsController(DatabaseService db)
        {
            _db = db;
        }

        [HttpPost]
        public async Task<IActionResult> CreateRating([FromBody] CreateRatingRequest req)
        {
            try
            {
                var query = @"
                    INSERT INTO calificaciones (id_contratacion, id_tecnico, puntuacion, comentario, fecha_calificacion)
                    VALUES (@contractation, @tech, @score, @comment, NOW());
                    SELECT LAST_INSERT_ID();
                ";

                var parameters = new Dictionary<string, object>
                {
                    { "contractation", req.IdContratacion },
                    { "tech", req.IdTecnico },
                    { "score", req.Puntuacion },
                    { "comment", req.Comentario ?? "" }
                };

                var id = await _db.ExecuteScalarAsync<int>(query, parameters);

                // Actualizar promedio del técnico
                await _db.ExecuteNonQueryAsync(
                    @"UPDATE tecnicos SET calificacion_promedio = (
                        SELECT AVG(puntuacion) FROM calificaciones WHERE id_tecnico = @tech
                      ), num_calificaciones = (
                        SELECT COUNT(*) FROM calificaciones WHERE id_tecnico = @tech
                      ) WHERE id_tecnico = @tech",
                    new Dictionary<string, object> { { "tech", req.IdTecnico } }
                );

                return Ok(new { id_calificacion = id });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }

    public class CreateContractationRequest
    {
        public int IdCliente { get; set; }
        public int IdTecnico { get; set; }
        public int IdServicio { get; set; }
        public string? Descripcion { get; set; }
    }

    public class CreatePaymentRequest
    {
        public int IdContratacion { get; set; }
        public double Monto { get; set; }
        public string MetodoPago { get; set; } = "";
    }

    public class CreateRatingRequest
    {
        public int IdContratacion { get; set; }
        public int IdTecnico { get; set; }
        public int Puntuacion { get; set; }
        public string? Comentario { get; set; }
    }

    public class UpdateClientRequest
    {
        public string? Nombre { get; set; }
        public string? Apellido { get; set; }
        public string? Email { get; set; }
        public string? Telefono { get; set; }
        public string? DireccionText { get; set; }
        public double? Latitud { get; set; }
        public double? Longitud { get; set; }
        public string? Password { get; set; }
    }

    public class UpdateTechnicianRequest
    {
        public string? Nombre { get; set; }
        public string? Email { get; set; }
        public string? Telefono { get; set; }
        public string? UbicacionText { get; set; }
        public double? Latitud { get; set; }
        public double? Longitud { get; set; }
        public double? TarifaHora { get; set; }
        public int? ExperienciaYears { get; set; }
        public string? Descripcion { get; set; }
        public string? Password { get; set; }
    }
}
