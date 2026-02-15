namespace ServitecAPI.Models
{
    public class TechnicianModel
    {
        public int IdTecnico { get; set; }
        public string Nombre { get; set; } = "";
        public string? Apellido { get; set; }  // ✨ NUEVO: Apellido del técnico
        public string Email { get; set; } = "";
        public string Contrasena { get; set; } = "";
        public string? Telefono { get; set; }
        public string? UbicacionText { get; set; }
        public double Latitud { get; set; }
        public double Longitud { get; set; }
        public double? TarifaHora { get; set; }
        public int? ExperienciaYears { get; set; }
        public string? Descripcion { get; set; }
        public string? FotoPerfilUrl { get; set; }
        public double CalificacionPromedio { get; set; }
        public int NumCalificaciones { get; set; }
        public DateTime FechaRegistro { get; set; }
        public List<int>? IdsServicios { get; set; }
    }
}
