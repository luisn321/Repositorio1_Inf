using System.Text.Json.Serialization;

namespace ServitecAPI.DTOs
{
    public class LoginRequest
    {
        [JsonPropertyName("Correo")]
        public string Correo { get; set; } = "";
        
        [JsonPropertyName("Contrasena")]
        public string Contrasena { get; set; } = "";
    }
}
