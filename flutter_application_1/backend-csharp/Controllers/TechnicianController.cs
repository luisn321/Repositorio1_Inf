using Microsoft.AspNetCore.Mvc;
using ServitecAPI.DTOs;
using ServitecAPI.Services;

namespace ServitecAPI.Controllers
{
    [ApiController]
    [Route("api/technicians")]
    public class TechnicianController : ControllerBase
    {
        private readonly ITechnicianService _service;
        private readonly ILogger<TechnicianController> _logger;

        public TechnicianController(ITechnicianService service, ILogger<TechnicianController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] int? serviceId)
        {
            try
            {
                // Si viene serviceId, filtrar por servicio
                if (serviceId.HasValue)
                {
                    _logger.LogInformation($"📡 GetAll con ServiceId: {serviceId}");
                    var technicians = await _service.GetByServiceAsync(serviceId.Value);
                    return Ok(technicians);
                }
                
                // Si no viene serviceId, obtener todos
                _logger.LogInformation($"📡 GetAll sin ServiceId (devolviendo todos)");
                var allTechnicians = await _service.GetAllTechniciansAsync();
                return Ok(allTechnicians);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving technicians" });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var technician = await _service.GetTechnicianAsync(id);
                return Ok(technician);
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Technician not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving technician" });
            }
        }

        [HttpGet("search")]
        public async Task<IActionResult> Search([FromQuery] string? q)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(q))
                    return await GetAll(null);

                var technicians = await _service.SearchTechniciansAsync(q);
                return Ok(technicians);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error searching technicians" });
            }
        }

        [HttpGet("service/{serviceId}")]
        public async Task<IActionResult> GetByService(int serviceId)
        {
            try
            {
                var technicians = await _service.GetByServiceAsync(serviceId);
                return Ok(technicians);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving technicians by service" });
            }
        }

        [HttpGet("nearby")]
        public async Task<IActionResult> GetNearby([FromQuery] double latitude, [FromQuery] double longitude, [FromQuery] double? radius)
        {
            try
            {
                var technicians = await _service.GetByLocationAsync(latitude, longitude, radius ?? 5);
                return Ok(technicians);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving nearby technicians" });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateTechnicianRequest request)
        {
            try
            {
                var success = await _service.UpdateTechnicianAsync(id, request);
                if (!success)
                    return BadRequest(new { message = "Failed to update technician" });

                return Ok(new { message = "Technician updated successfully" });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Technician not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error updating technician" });
            }
        }

        [HttpPut("{id}/services")]
        public async Task<IActionResult> UpdateServices(int id, [FromBody] List<int> serviceIds)
        {
            try
            {
                _logger.LogInformation($"📡 UpdateServices for tech {id}. Count: {serviceIds?.Count ?? 0}");
                var success = await _service.UpdateServicesAsync(id, serviceIds ?? new List<int>());
                if (!success)
                    return BadRequest(new { message = "Failed to update technician services" });

                return Ok(new { message = "Technician services updated successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error updating technician services" });
            }
        }
    }
}
