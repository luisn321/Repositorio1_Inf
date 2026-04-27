using System;

namespace ServitecAPI.Models
{
    public class RatingModel
    {
        public int IdCalificacion { get; set; }
        public int? IdContratacion { get; set; }
        public int? IdTecnico { get; set; }
        public int Puntuacion { get; set; }
        public string? Comentario { get; set; }
        public string? FotosResenaUrls { get; set; }    // Soporta múltiples URLs (CSV o JSON)
        public string? NombreCliente { get; set; }      
        public string? FotoPerfilCliente { get; set; }   
        public DateTime CreatedAt { get; set; }
    }
}
