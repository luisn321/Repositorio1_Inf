using System.Text.Json.Serialization;

namespace ServitecAPI.DTOs
{
    public class CreateRatingRequest
    {
        [JsonPropertyName("idContratacion")]
        public int IdContratacion { get; set; }

        [JsonPropertyName("idTecnico")]
        public int IdTecnico { get; set; }

        [JsonPropertyName("puntuacion")]
        public int Puntuacion { get; set; }

        [JsonPropertyName("comentario")]
        public string? Comentario { get; set; }

        [JsonPropertyName("fotosResenaUrls")]
        public string? FotosResenaUrls { get; set; }
    }

    public class RatingResponse
    {
        public int IdCalificacion { get; set; }
        public int IdContratacion { get; set; }
        public int IdTecnico { get; set; }
        public int Puntuacion { get; set; }
        public string? Comentario { get; set; }
        public string? FotosResenaUrls { get; set; }
        public string? NombreCliente { get; set; }     
        public string? FotoPerfilCliente { get; set; } 
        public DateTime CreatedAt { get; set; }
    }
}
