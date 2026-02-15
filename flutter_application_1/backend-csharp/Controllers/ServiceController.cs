using Microsoft.AspNetCore.Mvc;
using ServitecAPI.DTOs;
using ServitecAPI.Services;

namespace ServitecAPI.Controllers
{
    [ApiController]
    [Route("api/services")]
    public class ServiceController : ControllerBase
    {
        private readonly IServiceService _service;
        private readonly ILogger<ServiceController> _logger;

        public ServiceController(IServiceService service, ILogger<ServiceController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var services = await _service.GetAllServicesAsync();
                return Ok(services);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving services" });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var service = await _service.GetServiceAsync(id);
                return Ok(service);
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Service not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving service" });
            }
        }

        [HttpGet("search")]
        public async Task<IActionResult> Search([FromQuery] string? q)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(q))
                    return await GetAll();

                var services = await _service.SearchServicesAsync(q);
                return Ok(services);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error searching services" });
            }
        }

        [HttpGet("active")]
        public async Task<IActionResult> GetActives()
        {
            try
            {
                var services = await _service.GetActivesAsync();
                return Ok(services);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving active services" });
            }
        }

        [HttpGet("category/{category}")]
        public async Task<IActionResult> GetByCategory(string category)
        {
            try
            {
                var services = await _service.GetByCategoryAsync(category);
                return Ok(services);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving services by category" });
            }
        }

        [HttpGet("with-technicians")]
        public async Task<IActionResult> GetWithTechnicians()
        {
            try
            {
                var services = await _service.GetWithTechniciansAsync();
                return Ok(services);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving services" });
            }
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateServiceRequest request)
        {
            try
            {
                var serviceId = await _service.CreateServiceAsync(request);
                return Ok(new { id = serviceId, message = "Service created successfully" });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error creating service" });
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateServiceRequest request)
        {
            try
            {
                var success = await _service.UpdateServiceAsync(id, request);
                if (!success)
                    return BadRequest(new { message = "Failed to update service" });

                return Ok(new { message = "Service updated successfully" });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Service not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error updating service" });
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            try
            {
                var success = await _service.DeleteServiceAsync(id);
                if (!success)
                    return BadRequest(new { message = "Failed to delete service" });

                return Ok(new { message = "Service deleted successfully" });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { message = "Service not found" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error deleting service" });
            }
        }
    }
}
