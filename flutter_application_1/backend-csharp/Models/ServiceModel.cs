namespace ServitecAPI.Models
{
    public class ServiceModel
    {
        public int IdServicio { get; set; }
        public string Nombre { get; set; } = "";
        public string Descripcion { get; set; } = "";
        public string? Categoria { get; set; }
        public double? TarifaBase { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime FechaRegistro { get; set; }
        public DateTime? FechaActualizacion { get; set; }
        public int TecnicosDisponibles { get; set; }
    }
}
