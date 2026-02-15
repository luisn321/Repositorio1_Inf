namespace ServitecAPI.DTOs
{
    public class GetServiceRequest
    {
        public int? IdServicio { get; set; }
        public string? SearchTerm { get; set; }
        public bool? Activo { get; set; }
    }

    public class CreateServiceRequest
    {
        public string Nombre { get; set; } = "";
        public string? Descripcion { get; set; }
        public string? Categoria { get; set; }
        public double? TarifaBase { get; set; }
    }

    public class UpdateServiceRequest
    {
        public string? Nombre { get; set; }
        public string? Descripcion { get; set; }
        public string? Categoria { get; set; }
        public double? TarifaBase { get; set; }
        public bool? Activo { get; set; }
    }

    public class ServiceResponse
    {
        public int IdServicio { get; set; }
        public string Nombre { get; set; } = "";
        public string Descripcion { get; set; } = "";
        public string? Categoria { get; set; }
        public double? TarifaBase { get; set; }
        public bool Activo { get; set; }
        public int TecnicosDisponibles { get; set; }
    }
}
