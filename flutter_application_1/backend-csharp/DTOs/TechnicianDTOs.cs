namespace ServitecAPI.DTOs
{
    public class GetTechnicianRequest
    {
        public int? IdTecnico { get; set; }
        public int? ServiceId { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public double? Radius { get; set; }
    }

    public class UpdateTechnicianRequest
    {
        public string? Nombre { get; set; }
        public string? Apellido { get; set; }
        public string? Email { get; set; }
        public string? Telefono { get; set; }
        public string? UbicacionText { get; set; }
        public double? Latitud { get; set; }
        public double? Longitud { get; set; }
        public double? TarifaHora { get; set; }
        public int? ExperienciaYears { get; set; }
        public string? Descripcion { get; set; }
        public string? FotoPerfilUrl { get; set; }
        public string? Contrasena { get; set; }
    }

    public class TechnicianResponse
    {
        public int IdTecnico { get; set; }
        public string Nombre { get; set; } = "";
        public string? Apellido { get; set; }  
        public string Email { get; set; } = "";
        public string? Telefono { get; set; }
        public string? UbicacionText { get; set; }
        public double Latitud { get; set; }
        public double Longitud { get; set; }
        public double? TarifaHora { get; set; }
        public int? ExperienciaYears { get; set; }
        public string? Descripcion { get; set; }
        public double CalificacionPromedio { get; set; }
        public int NumCalificaciones { get; set; }
        public string? FotoPerfilUrl { get; set; }
        public List<ServiceDTO>? Servicios { get; set; }
    }

    public class ServiceDTO
    {
        public int IdServicio { get; set; }
        public string Nombre { get; set; } = "";
    }
}
