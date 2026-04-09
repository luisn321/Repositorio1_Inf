using System.Text.Json.Serialization;

namespace ServitecAPI.DTOs
{
    public class RegisterTechnicianRequest
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
        
        [JsonPropertyName("UbicacionTexto")]
        public string? UbicacionTexto { get; set; }
        
        [JsonPropertyName("Latitud")]
        public double Latitud { get; set; } = 0;
        
        [JsonPropertyName("Longitud")]
        public double Longitud { get; set; } = 0;
        
        [JsonPropertyName("TarifaHora")]
        public double TarifaHora { get; set; } = 0;
        
        [JsonPropertyName("AnosExperiencia")]
        public int? AnosExperiencia { get; set; }
        
        [JsonPropertyName("Descripcion")]
        public string? Descripcion { get; set; }
        
        [JsonPropertyName("IdServicios")]
        public List<int> IdServicios { get; set; } = new();
    }
}
