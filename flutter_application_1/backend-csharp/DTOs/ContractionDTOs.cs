namespace ServitecAPI.DTOs
{
    public class CreateContractionDto
    {
        public int IdCliente { get; set; }
        public int IdServicio { get; set; }
        public string? Descripcion { get; set; }
        public DateTime? FechaEstimada { get; set; }
        public string? DetallesCliente { get; set; }
        public double? HorasSolicitadas { get; set; }
        public string? HoraSolicitada { get; set; }
        public string? FotosClienteUrls { get; set; }
        public string? Ubicacion { get; set; }
    }

    public class UpdateContractionDto
    {
        public string? Estado { get; set; }
        public int? IdTecnico { get; set; }
        public DateTime? FechaEstimada { get; set; }
        public string? Descripcion { get; set; }
        public string? FotosTrabajoUrls { get; set; }
        public string? MontoPropuesto { get; set; }
        public string? EstadoMonto { get; set; }
        public string? Comentarios { get; set; }
    }

    public class AssignTechnicianDto
    {
        public int IdTecnico { get; set; }
        public double? MontoPropuesto { get; set; }
        public string? Comentarios { get; set; }
    }

    public class ContractionResponse
    {
        public int IdContratacion { get; set; }
        public int IdCliente { get; set; }
        public int? IdTecnico { get; set; }
        public int IdServicio { get; set; }
        public string Estado { get; set; } = "";
        public DateTime FechaSolicitud { get; set; }
        public DateTime? FechaAsignacion { get; set; }
        public DateTime? FechaEstimada { get; set; }
        public DateTime? FechaCompletada { get; set; }
        public string? Descripcion { get; set; }
        public string? DetallesCliente { get; set; }
        public double? HorasSolicitadas { get; set; }
        public string? HoraSolicitada { get; set; }
        public string? FotosClienteUrls { get; set; }
        public string? FotosTrabajoUrls { get; set; }
        public string? MontoPropuesto { get; set; }
        public string? EstadoMonto { get; set; }
        public string? Ubicacion { get; set; }
        public string? Comentarios { get; set; }
    }
}
