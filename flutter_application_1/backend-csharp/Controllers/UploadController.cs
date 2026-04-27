using Microsoft.AspNetCore.Mvc;
using ServitecAPI.Services;

namespace ServitecAPI.Controllers
{
    [ApiController]
    [Route("api/upload")]
    public class UploadController : ControllerBase
    {
        private readonly IImageUploadService _uploadService;
        private readonly ILogger<UploadController> _logger;

        public UploadController(IImageUploadService uploadService, ILogger<UploadController> logger)
        {
            _uploadService = uploadService;
            _logger = logger;
        }

        [HttpPost("image")]
        public async Task<IActionResult> UploadImage([FromForm] IFormFile file, [FromForm] string folder = "general")
        {
            try
            {
                if (file == null) return BadRequest(new { message = "No se proporcionó ningún archivo" });

                _logger.LogInformation($" Subiendo imagen: {file.FileName} a la carpeta {folder}");
                var imageUrl = await _uploadService.UploadImageAsync(file, folder);

                return Ok(new { url = imageUrl, success = true });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en UploadController: {ex.Message}");
                return StatusCode(500, new { message = "Error al subir la imagen", error = ex.Message });
            }
        }
    }
}
