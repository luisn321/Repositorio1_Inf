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
                var contractionId = await _service.CreateContractionAsync(request);
                return Ok(new { id = contractionId, message = "Contraction created successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error creating contraction" });
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
    }
}
