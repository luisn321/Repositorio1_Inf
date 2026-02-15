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
        public async Task<IActionResult> GetTechnicians([FromQuery] int? serviceId, [FromQuery] int? service_id, [FromQuery] double? lat, [FromQuery] double? lng, [FromQuery] double? radius)
        {
            try
            {
                // Usar service_id si serviceId no viene
                int? finalServiceId = serviceId ?? service_id;

                Console.WriteLine($"🔍 GetTechnicians - ServiceId: {finalServiceId}");

                string query = @"
                    SELECT t.id_tecnico, t.nombre, t.email, t.tarifa_hora, t.calificacion_promedio, t.latitud, t.longitud
                    FROM tecnicos t
                ";

                Dictionary<string, object>? parameters = null;

                if (finalServiceId.HasValue)
                {
                    query += @" INNER JOIN tecnico_servicio ts ON t.id_tecnico = ts.id_tecnico 
                               WHERE ts.id_servicio = @serviceId";
                    parameters = new Dictionary<string, object> { { "serviceId", finalServiceId.Value } };
                    Console.WriteLine($"✓ Filtering by service: {finalServiceId.Value}");
                }
                else
                {
                    Console.WriteLine($"✗ No service filter - returning all technicians");
                }

                var results = await _db.ExecuteQueryAsync(query, parameters);
                Console.WriteLine($"✓ Found {results.Count} technicians");

                return Ok(results);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error in GetTechnicians: {ex.Message}");
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("search")]
        public async Task<IActionResult> SearchTechnicians([FromQuery] string? q, [FromQuery] string? query)
        {
            try
            {
                // Usar q o query como nombre de parámetro
                string searchTerm = q ?? query ?? "";

                Console.WriteLine($"SearchTechnicians - Query: '{searchTerm}'");

                if (string.IsNullOrWhiteSpace(searchTerm))
                {
                    Console.WriteLine($"Empty search term");
                    return Ok(new List<object>());
                }

                string sqlQuery = @"
                    SELECT id_tecnico, nombre, email, tarifa_hora, calificacion_promedio, latitud, longitud
                    FROM tecnicos
                    WHERE nombre LIKE @search OR email LIKE @search
                    ORDER BY nombre
                ";

                var parameters = new Dictionary<string, object>
                {
                    { "search", $"%{searchTerm}%" }
                };

                var results = await _db.ExecuteQueryAsync(sqlQuery, parameters);
                Console.WriteLine($" Found {results.Count} technicians matching '{searchTerm}'");

                return Ok(results);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in SearchTechnicians: {ex.Message}");
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

                var technician = results[0];

                // Get services for this technician
                var services = await _db.ExecuteQueryAsync(
                    @"SELECT s.id_servicio, s.nombre 
                      FROM servicios s
                      INNER JOIN tecnico_servicio ts ON s.id_servicio = ts.id_servicio
                      WHERE ts.id_tecnico = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                technician["servicios"] = services;

                return Ok(technician);
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
                // Build query dynamically based on what fields are sent
                var updates = new List<string>();
                var parameters = new Dictionary<string, object> { { "id", id } };

                if (!string.IsNullOrEmpty(req.FirstName))
                {
                    updates.Add("nombre = @nombre");
                    parameters["nombre"] = req.FirstName;
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
                if (!string.IsNullOrEmpty(req.LocationText))
                {
                    updates.Add("ubicacion_text = @ubicacion_text");
                    parameters["ubicacion_text"] = req.LocationText;
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
                if (req.HourlyRate.HasValue)
                {
                    updates.Add("tarifa_hora = @tarifa_hora");
                    parameters["tarifa_hora"] = req.HourlyRate;
                }
                if (req.ExperienceYears.HasValue)
                {
                    updates.Add("experiencia_years = @experiencia_years");
                    parameters["experiencia_years"] = req.ExperienceYears;
                }
                if (!string.IsNullOrEmpty(req.Description))
                {
                    updates.Add("descripcion = @descripcion");
                    parameters["descripcion"] = req.Description;
                }
                if (!string.IsNullOrEmpty(req.Password))
                {
                    updates.Add("password_hash = @password_hash");
                    parameters["password_hash"] = _db.HashPassword(req.Password);
                }

                if (updates.Count == 0)
                    return BadRequest(new { error = "No fields to update" });

                updates.Add("updated_at = NOW()");

                var query = $"UPDATE tecnicos SET {string.Join(", ", updates)} WHERE id_tecnico = @id";
                await _db.ExecuteNonQueryAsync(query, parameters);

                return Ok(new { message = "Technician updated successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpPost("{id}/services")]
        public async Task<IActionResult> UpdateTechnicianServices(int id, [FromBody] UpdateTechnicianServicesRequest req)
        {
            try
            {
                // Validate technician exists
                var technicianExists = await _db.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM tecnicos WHERE id_tecnico = @id",
                    new Dictionary<string, object> { { "id", id } }
                );
                if (technicianExists == 0)
                    return NotFound(new { error = "Technician does not exist" });

                // Delete previous services
                await _db.ExecuteNonQueryAsync(
                    "DELETE FROM tecnico_servicio WHERE id_tecnico = @id",
                    new Dictionary<string, object> { { "id", id } }
                );

                // Insert new services
                if (req.ServiceIds != null && req.ServiceIds.Count > 0)
                {
                    foreach (var serviceId in req.ServiceIds)
                    {
                        await _db.ExecuteNonQueryAsync(
                            "INSERT INTO tecnico_servicio (id_tecnico, id_servicio) VALUES (@tech, @svc)",
                            new Dictionary<string, object> { { "tech", id }, { "svc", serviceId } }
                        );
                    }
                }

                return Ok(new { message = "Services updated successfully" });
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

    [ApiController]
    [Route("api/contractions")]
    public class ContractionsController : ControllerBase
    {
        private readonly DatabaseService _db;

        public ContractionsController(DatabaseService db)
        {
            _db = db;
        }

        [HttpPost]
        public async Task<IActionResult> CreateContraction([FromBody] CreateContractionRequest req)
        {
            try
            {
                // Validate client exists
                var clientExists = await _db.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM clientes WHERE id_cliente = @id",
                    new Dictionary<string, object> { { "id", req.ClientId } }
                );
                if (clientExists == 0)
                    return BadRequest(new { error = "Client does not exist" });

                // Validate service exists
                var serviceExists = await _db.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM servicios WHERE id_servicio = @id",
                    new Dictionary<string, object> { { "id", req.ServiceId } }
                );
                if (serviceExists == 0)
                    return BadRequest(new { error = "Service does not exist" });

                // If technician is specified, validate it exists
                if (req.TechnicianId.HasValue)
                {
                    var technicianExists = await _db.ExecuteScalarAsync<int>(
                        "SELECT COUNT(*) FROM tecnicos WHERE id_tecnico = @id",
                        new Dictionary<string, object> { { "id", req.TechnicianId } }
                    );
                    if (technicianExists == 0)
                        return BadRequest(new { error = "Technician does not exist" });
                }

                var query = @"
                    INSERT INTO contrataciones (id_cliente, id_tecnico, id_servicio, detalles, fecha_solicitud, fecha_programada, estado)
                    VALUES (@client, @tech, @service, @desc, NOW(), @fecha_programada, 'Pendiente');
                    SELECT LAST_INSERT_ID();
                ";

                var parameters = new Dictionary<string, object>
                {
                    { "client", req.ClientId },
                    { "tech", req.TechnicianId ?? 0 },
                    { "service", req.ServiceId },
                    { "desc", req.Description ?? "" },
                    { "fecha_programada", req.ScheduledDate ?? (object)DBNull.Value }
                };

                var id = await _db.ExecuteScalarAsync<int>(query, parameters);
                return Ok(new { id_contratacion = id, estado = "Pendiente" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in CreateContraction: {ex.Message}");
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("client/{clientId}")]
        public async Task<IActionResult> GetContractionsByClient(int clientId)
        {
            try
            {
                var query = @"
                    SELECT c.*, s.nombre as service_name, t.nombre as technician_name, t.email as technician_email, t.id_tecnico
                    FROM contrataciones c
                    JOIN servicios s ON c.id_servicio = s.id_servicio
                    LEFT JOIN tecnicos t ON c.id_tecnico = t.id_tecnico
                    WHERE c.id_cliente = @cliente
                    ORDER BY c.fecha_solicitud DESC
                ";

                var results = await _db.ExecuteQueryAsync(query, 
                    new Dictionary<string, object> { { "cliente", clientId } });

                return Ok(results);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("technician/{technicianId}")]
        public async Task<IActionResult> GetContractionsByTechnician(int technicianId)
        {
            try
            {
                var query = @"
                    SELECT c.*, s.nombre as service_name, cl.nombre as client_name, cl.email as client_email, cl.telefono as client_phone, cl.id_cliente
                    FROM contrataciones c
                    JOIN servicios s ON c.id_servicio = s.id_servicio
                    JOIN clientes cl ON c.id_cliente = cl.id_cliente
                    WHERE c.id_tecnico = @tecnico
                    ORDER BY c.fecha_solicitud DESC
                ";

                var results = await _db.ExecuteQueryAsync(query,
                    new Dictionary<string, object> { { "tecnico", technicianId } });

                return Ok(results);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateContractionStatus(int id, [FromBody] UpdateContractionStatusRequest req)
        {
            try
            {
                // Valid statuses: Pendiente, Aceptada, En Progreso, Completada, Cancelada
                var validStatuses = new[] { "Pendiente", "Aceptada", "En Progreso", "Completada", "Cancelada" };
                if (!validStatuses.Contains(req.Status))
                    return BadRequest(new { error = "Invalid status" });

                var query = "UPDATE contrataciones SET estado = @estado, updated_at = NOW() WHERE id_contratacion = @id";
                await _db.ExecuteNonQueryAsync(query, 
                    new Dictionary<string, object> { { "estado", req.Status }, { "id", id } });

                return Ok(new { message = "Contraction updated", status = req.Status });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetContraction(int id)
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
                // Usar valores que vengan en camelCase o PascalCase
                var contractionId = req.ContractionId > 0 ? req.ContractionId : req.IdContratacion;
                var amount = req.Amount > 0 ? req.Amount : req.Monto;
                var method = !string.IsNullOrEmpty(req.PaymentMethod) ? req.PaymentMethod : req.MetodoPago;

                Console.WriteLine($"CreatePayment - IdContraction: {contractionId}, Amount: {amount}, Method: {method}");

                // Validar que la contratación existe
                var contractionExists = await _db.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM contrataciones WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", contractionId } }
                );

                if (contractionExists == 0)
                {
                    Console.WriteLine($"Contraction not found: {contractionId}");
                    return NotFound(new { error = "Contraction not found" });
                }

                var query = @"
                    INSERT INTO pagos (id_contratacion, monto, metodo_pago, fecha_pago, estado_pago)
                    VALUES (@contractation, @amount, @method, NOW(), 'Completado');
                    SELECT LAST_INSERT_ID();
                ";

                var parameters = new Dictionary<string, object>
                {
                    { "contractation", contractionId },
                    { "amount", amount },
                    { "method", method }
                };

                var id = await _db.ExecuteScalarAsync<int>(query, parameters);
                Console.WriteLine($"✅ Payment created - ID: {id}");
                return CreatedAtAction(nameof(CreatePayment), new { id_pago = id });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in CreatePayment: {ex.Message}");
                Console.WriteLine($"StackTrace: {ex.StackTrace}");
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
                // Usar valores que vengan en camelCase o PascalCase
                var contractionId = req.ContractionId > 0 ? req.ContractionId : req.IdContratacion;
                var technicianId = req.TechnicianId > 0 ? req.TechnicianId : req.IdTecnico;
                var score = req.Score > 0 ? req.Score : req.Puntuacion;
                var comment = !string.IsNullOrEmpty(req.Comment) ? req.Comment : req.Comentario;

                Console.WriteLine($"⭐ CreateRating - IdContraction: {contractionId}, IdTech: {technicianId}, Score: {score}");

                // Validations: contraction exists, belongs to technician, and isn't already rated
                var contraction = await _db.ExecuteQueryAsync(
                    "SELECT id_contratacion, id_tecnico, estado FROM contrataciones WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", contractionId } }
                );

                if (contraction.Count == 0)
                {
                    Console.WriteLine($"Contraction not found: {contractionId}");
                    return BadRequest(new { error = "Contraction not found" });
                }

                var row = contraction[0];
                var technicianInContraction = Convert.ToInt32(row["id_tecnico"]);
                var status = row.ContainsKey("estado") ? row["estado"]?.ToString() ?? "" : "";

                if (technicianInContraction != technicianId)
                {
                    Console.WriteLine($"Technician mismatch: {technicianId} != {technicianInContraction}");
                    return BadRequest(new { error = "Technician does not match the contraction" });
                }

                // Check if this contraction is already rated
                var existing = await _db.ExecuteScalarAsync<int>(
                    "SELECT COUNT(*) FROM calificaciones WHERE id_contratacion = @id",
                    new Dictionary<string, object> { { "id", contractionId } }
                );

                if (existing > 0)
                {
                    Console.WriteLine($"Already rated: {contractionId}");
                    return BadRequest(new { error = "This contraction has already been rated" });
                }

                // Allow rating without status restriction (client decides when to evaluate)
                // Only check that contraction exists and isn't duplicated

                var query = @"
                    INSERT INTO calificaciones (id_contratacion, id_tecnico, puntuacion, comentario)
                    VALUES (@contractation, @tech, @score, @comment);
                    SELECT LAST_INSERT_ID();
                ";

                var parameters = new Dictionary<string, object>
                {
                    { "contractation", contractionId },
                    { "tech", technicianId },
                    { "score", score },
                    { "comment", comment ?? "" }
                };

                var id = await _db.ExecuteScalarAsync<int>(query, parameters);
                Console.WriteLine($"Rating created - ID: {id}");

                // Update technician's average rating
                await _db.ExecuteNonQueryAsync(
                    @"UPDATE tecnicos SET calificacion_promedio = (
                        SELECT AVG(puntuacion) FROM calificaciones WHERE id_tecnico = @tech
                      ), num_calificaciones = (
                        SELECT COUNT(*) FROM calificaciones WHERE id_tecnico = @tech
                      ) WHERE id_tecnico = @tech",
                    new Dictionary<string, object> { { "tech", technicianId } }
                );

                return Ok(new { id_calificacion = id });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error in CreateRating: {ex.Message}");
                Console.WriteLine($"StackTrace: {ex.StackTrace}");
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }

    public class CreateContractionRequest
    {
        public int ClientId { get; set; }
        public int? TechnicianId { get; set; }
        public int ServiceId { get; set; }
        public string? Description { get; set; }
        public DateTime? ScheduledDate { get; set; }
    }

    public class UpdateContractionStatusRequest
    {
        public string Status { get; set; } = "";
    }

    public class CreatePaymentRequest
    {
        public int ContractionId { get; set; }
        public int IdContratacion { get; set; } // Para compatibilidad con camelCase
        public double Amount { get; set; }
        public double Monto { get; set; } // Para compatibilidad
        public string PaymentMethod { get; set; } = "";
        public string MetodoPago { get; set; } = ""; // Para compatibilidad
    }

    public class CreateRatingRequest
    {
        public int ContractionId { get; set; }
        public int IdContratacion { get; set; } // Para compatibilidad con camelCase
        public int TechnicianId { get; set; }
        public int IdTecnico { get; set; } // Para compatibilidad
        public int Score { get; set; }
        public int Puntuacion { get; set; } // Para compatibilidad
        public string? Comment { get; set; }
        public string? Comentario { get; set; } // Para compatibilidad
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

    public class UpdateTechnicianRequest
    {
        public string? FirstName { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? LocationText { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public double? HourlyRate { get; set; }
        public int? ExperienceYears { get; set; }
        public string? Description { get; set; }
        public string? Password { get; set; }
    }
}
   