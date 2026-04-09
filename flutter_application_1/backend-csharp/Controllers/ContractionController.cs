using Microsoft.AspNetCore.Mvc;
using ServitecAPI.DTOs;
using ServitecAPI.Services;

namespace ServitecAPI.Controllers
{
    [ApiController]
    [Route("api/contractions")]
    public class ContractionController : ControllerBase
    {
        private readonly IContractionService _service;
        private readonly ILogger<ContractionController> _logger;

        public ContractionController(IContractionService service, ILogger<ContractionController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var contractions = await _service.GetAllAsync();
                return Ok(contractions);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving contractions" });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var contraction = await _service.GetContractionAsync(id);
                return Ok(contraction);
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Contraction not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving contraction" });
            }
        }

        [HttpGet("client/{clientId}")]
        public async Task<IActionResult> GetByClient(int clientId)
        {
            try
            {
                var contractions = await _service.GetByClientAsync(clientId);
                return Ok(contractions);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving contractions" });
            }
        }

        [HttpGet("technician/{technicianId}")]
        public async Task<IActionResult> GetByTechnician(int technicianId)
        {
            try
            {
                var contractions = await _service.GetByTechnicianAsync(technicianId);
                return Ok(contractions);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving contractions" });
            }
        }

        [HttpGet("status/{status}")]
        public async Task<IActionResult> GetByStatus(string status)
        {
            try
            {
                var contractions = await _service.GetByStatusAsync(status);
                return Ok(contractions);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving contractions" });
            }
        }

        [HttpGet("pending")]
        public async Task<IActionResult> GetPending()
        {
            try
            {
                var contractions = await _service.GetPendingAsync();
                return Ok(contractions);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving pending contractions" });
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateContractionDto request)
        {
            try
            {
                // 🔍 LOGGING DETALLADO PARA DEBUGGING
                _logger.LogInformation($"📡 [POST /api/contractions] SOLICITUD RECIBIDA");
                _logger.LogInformation($"   ├─ idCliente: {request?.IdCliente}");
                _logger.LogInformation($"   ├─ idTecnico: {request?.IdTecnico}");
                _logger.LogInformation($"   ├─ idServicio: {request?.IdServicio}");
                _logger.LogInformation($"   ├─ descripcion: {request?.Descripcion}");
                _logger.LogInformation($"   ├─ fechaEstimada: {request?.FechaEstimada}");
                _logger.LogInformation($"   ├─ ubicacion: {request?.Ubicacion}");
                _logger.LogInformation($"   └─ horaSolicitada: {request?.HoraSolicitada}");

                if (request == null)
                {
                    _logger.LogWarning("⚠️  CreateContractionDto es NULL");
                    return BadRequest(new { message = "Request body cannot be empty" });
                }

                if (request.IdCliente <= 0 || request.IdServicio <= 0)
                {
                    _logger.LogWarning($"⚠️  Validación fallida: IdCliente={request.IdCliente}, IdServicio={request.IdServicio}");
                    return BadRequest(new { message = "IdCliente and IdServicio are required and must be > 0" });
                }

                _logger.LogInformation($"✓ Validación DTO exitosa. Llamando ServicioContrataciones.CreateContractionAsync()...");

                var contractionId = await _service.CreateContractionAsync(request);

                _logger.LogInformation($"✅ CONTRATACIÓN CREADA EXITOSAMENTE con ID: {contractionId}");

                // ✨ Retornar el objeto completo para que Flutter lo pueda parsear
                var contraction = await _service.GetContractionAsync(contractionId);
                return Ok(contraction);
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ ERROR EN CREATE: {ex.GetType().Name}");
                _logger.LogError($"   └─ Mensaje: {ex.Message}");
                _logger.LogError($"   └─ Stack: {ex.StackTrace}");
                
                return StatusCode(500, new { 
                    message = "Error creating contraction",
                    details = ex.Message,
                    type = ex.GetType().Name
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateContractionDto request)
        {
            try
            {
                var success = await _service.UpdateContractionAsync(id, request);
                if (!success)
                    return BadRequest(new { message = "Failed to update contraction" });

                return Ok(new { message = "Contraction updated successfully" });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Contraction not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error updating contraction" });
            }
        }

        [HttpPost("{id}/assign")]
        public async Task<IActionResult> AssignTechnician(int id, [FromBody] AssignTechnicianDto request)
        {
            try
            {
                var success = await _service.AssignTechnicianAsync(id, request);
                if (!success)
                    return BadRequest(new { message = "Failed to assign technician" });

                return Ok(new { message = "Technician assigned successfully" });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Contraction not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error assigning technician" });
            }
        }

        [HttpPost("{id}/complete")]
        public async Task<IActionResult> Complete(int id)
        {
            try
            {
                var success = await _service.CompleteContractionAsync(id);
                if (!success)
                    return BadRequest(new { message = "Failed to complete contraction" });

                return Ok(new { message = "Contraction completed successfully" });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Contraction not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error completing contraction" });
            }
        }

        [HttpPost("{id}/cancel")]
        public async Task<IActionResult> Cancel(int id)
        {
            try
            {
                var success = await _service.CancelContractionAsync(id);
                if (!success)
                    return BadRequest(new { message = "Failed to cancel contraction" });

                return Ok(new { message = "Contraction cancelled successfully" });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Contraction not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error cancelling contraction" });
            }
        }

        // ✨ NUEVOS: Para flujo de aceptación/rechazo
        [HttpPost("{id}/reject")]
        public async Task<IActionResult> Reject(int id, [FromBody] RejectContractionDto request)
        {
            try
            {
                if (request == null) return BadRequest(new { message = "Request body is required" });
                var success = await _service.RejectContractionAsync(id, request);
                if (!success)
                    return BadRequest(new { message = "Failed to reject contraction" });

                return Ok(new { message = "Contraction rejected successfully" });
            }
            catch (KeyNotFoundException)
            {
                _logger.LogWarning($"⚠️ Contraction {id} not found");
                return NotFound(new { message = "Contraction not found" });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"⚠️ Invalid operation: {ex.Message}");
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ ERROR EN REJECT {id}: {ex.GetType().Name}");
                _logger.LogError($"   └─ Mensaje: {ex.Message}");
                _logger.LogError($"   └─ Stack: {ex.StackTrace}");
                return StatusCode(500, new { message = "Error rejecting contraction", details = ex.Message });
            }
        }

        [HttpPost("{id}/accept")]
        public async Task<IActionResult> Accept(int id, [FromBody] AcceptContractionDto request)
        {
            try
            {
                if (request == null) return BadRequest(new { message = "Request body is required" });
                var success = await _service.AcceptContractionAsync(id, request);
                if (!success)
                    return BadRequest(new { message = "Failed to accept contraction" });

                return Ok(new { message = "Contraction accepted successfully" });
            }
            catch (KeyNotFoundException)
            {
                _logger.LogWarning($"⚠️ Contraction {id} not found");
                return NotFound(new { message = "Contraction not found" });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"⚠️ Invalid operation: {ex.Message}");
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ ERROR EN ACCEPT {id}: {ex.GetType().Name}");
                _logger.LogError($"   └─ Mensaje: {ex.Message}");
                _logger.LogError($"   └─ Stack: {ex.StackTrace}");
                return StatusCode(500, new { message = "Error accepting contraction", details = ex.Message });
            }
        }

        // ✨ NUEVO: Técnico propone alternativa (fecha/hora/motivo diferente)
        [HttpPost("{id}/propose-propuesta")]
        public async Task<IActionResult> ProposePropuesta(int id, [FromBody] ProposeAlternativeDto request)
        {
            try
            {
                if (request == null) return BadRequest(new { message = "Request body is required" });
                _logger.LogInformation($"💡 [PROPOSE-PROPUESTA] Proponiendo alternativa para solicitud {id}");
                _logger.LogInformation($"   ├─ fechaPropuestaSolicitada: {request.FechaPropuestaSolicitada}");
                _logger.LogInformation($"   ├─ horaPropuestaSolicitada: {request.HoraPropuestaSolicitada}");
                _logger.LogInformation($"   └─ motivoCambio: {request.MotivoCambio}");

                var success = await _service.ProposePropuestaAsync(id, request);
                if (!success)
                    return BadRequest(new { message = "Failed to propose alternative" });

                return Ok(new { message = "Alternative proposal created successfully" });
            }
            catch (KeyNotFoundException)
            {
                _logger.LogWarning($"⚠️ Contraction {id} not found");
                return NotFound(new { message = "Contraction not found" });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning($"⚠️ Invalid operation: {ex.Message}");
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ ERROR EN PROPOSE-PROPUESTA {id}: {ex.GetType().Name}");
                _logger.LogError($"   └─ Mensaje: {ex.Message}");
                _logger.LogError($"   └─ Stack: {ex.StackTrace}");
                return StatusCode(500, new { message = "Error proposing alternative", details = ex.Message });
            }
        }

        // ✨ NUEVO: Cliente acepta la propuesta alternativa (fecha/hora) del técnico
        [HttpPost("{id}/accept-propuesta")]
        public async Task<IActionResult> AcceptPropuesta(int id)
        {
            try
            {
                var success = await _service.AcceptPropuestaAsync(id);
                if (!success)
                    return BadRequest(new { message = "Failed to accept proposal" });

                var contraction = await _service.GetContractionAsync(id);
                return Ok(contraction);
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Contraction not found" });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error accepting proposal: {ex.Message}");
                return StatusCode(500, new { message = "Error accepting proposal" });
            }
        }

        // ✨ NUEVO: Cliente rechaza la propuesta alternativa (fecha/hora) del técnico
        [HttpPost("{id}/reject-propuesta")]
        public async Task<IActionResult> RejectPropuesta(int id)
        {
            try
            {
                var success = await _service.RejectPropuestaAsync(id);
                if (!success)
                    return BadRequest(new { message = "Failed to reject proposal" });

                var contraction = await _service.GetContractionAsync(id);
                return Ok(contraction);
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Contraction not found" });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error rejecting proposal: {ex.Message}");
                return StatusCode(500, new { message = "Error rejecting proposal" });
            }
        }

        [HttpPost("{id}/propose-amount")]
        public async Task<IActionResult> ProposeAmount(int id, [FromBody] ProposeMountDto request)
        {
            try
            {
                var success = await _service.ProposeMountAsync(id, request);
                if (!success)
                    return BadRequest(new { message = "Failed to propose amount" });

                return Ok(new { message = "Amount proposed successfully", monto = request.Monto });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Contraction not found" });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error proposing amount" });
            }
        }

        // ✨ NUEVO: Cliente acepta el monto propuesto por el técnico
        [HttpPost("{id}/accept-amount")]
        public async Task<IActionResult> AcceptAmount(int id)
        {
            try
            {
                var success = await _service.AcceptAmountAsync(id);
                if (!success)
                    return BadRequest(new { message = "Failed to accept amount" });

                // Retornar la contratación actualizada
                var contraction = await _service.GetContractionAsync(id);
                return Ok(contraction);
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Contraction not found" });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error accepting amount" });
            }
        }

        // ✨ NUEVO: Cliente rechaza el monto propuesto por el técnico
        [HttpPost("{id}/reject-amount")]
        public async Task<IActionResult> RejectAmount(int id, [FromBody] RejectAmountDto request)
        {
            try
            {
                var success = await _service.RejectAmountAsync(id, request);
                if (!success)
                    return BadRequest(new { message = "Failed to reject amount" });

                var contraction = await _service.GetContractionAsync(id);
                return Ok(contraction);
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Contraction not found" });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error rejecting amount" });
            }
        }

    }
}
