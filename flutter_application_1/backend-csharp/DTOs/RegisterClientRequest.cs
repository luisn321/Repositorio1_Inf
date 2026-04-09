using System.Text.Json.Serialization;

namespace ServitecAPI.DTOs
{
    public class RegisterClientRequest
    {
        [JsonPropertyName("Nombre")]
        public string Nombre { get; set; } = "";
        
        [JsonPropertyName("Apellido")]
        public string Apellido { get; set; } = "";
        
        [JsonPropertyName("Correo")]
        public string Correo { get; set; } = "";
        
        [JsonPropertyName("Contrasena")]
        public string Contrasena { get; set; } = "";
        
        [JsonPropertyName("Telefono")]
        public string? Telefono { get; set; }
        
        [JsonPropertyName("DireccionTexto")]
        public string? DireccionTexto { get; set; }
        
        [JsonPropertyName("Latitud")]
        public double Latitud { get; set; } = 0;
        
        [JsonPropertyName("Longitud")]
        public double Longitud { get; set; }
    }
}
