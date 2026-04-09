using Microsoft.AspNetCore.Mvc;
using ServitecAPI.DTOs;
using ServitecAPI.Services;

namespace ServitecAPI.Controllers
{
    [ApiController]
    [Route("api/ratings")]
    public class RatingController : ControllerBase
    {
        private readonly IRatingService _service;
        private readonly ILogger<RatingController> _logger;

        public RatingController(IRatingService service, ILogger<RatingController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateRatingRequest request)
        {
            try
            {
                _logger.LogInformation($"⭐ [RATING] Recibiendo calificación para contrato {request.IdContratacion}");
                var ratingId = await _service.CreateRatingAsync(request);
                return Ok(new { id = ratingId, message = "Rating created successfully" });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError($"❌ ERROR EN CREATE RATING: {ex.Message}");
                return StatusCode(500, new { message = "Error creating rating" });
            }
        }

        [HttpGet("technician/{technicianId}")]
        public async Task<IActionResult> GetByTechnician(int technicianId)
        {
            try
            {
                var ratings = await _service.GetRatingsByTechnicianAsync(technicianId);
                return Ok(ratings);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving ratings" });
            }
        }

        [HttpGet("contraction/{contractionId}")]
        public async Task<IActionResult> GetByContraction(int contractionId)
        {
            try
            {
                var rating = await _service.GetRatingByContractionAsync(contractionId);
                if (rating == null) return NotFound(new { message = "Rating not found" });
                return Ok(rating);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error: {ex.Message}");
                return StatusCode(500, new { message = "Error retrieving rating" });
            }
        }
    }
}
