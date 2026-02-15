namespace ServitecAPI.Models
{
    public class ContractionModel
    {
        public int IdContratacion { get; set; }
        public int IdCliente { get; set; }
        public int? IdTecnico { get; set; }
        public int IdServicio { get; set; }
        public string Estado { get; set; } = "solicitada"; // solicitada, asignada, en_proceso, completada, cancelada
        public DateTime FechaSolicitud { get; set; }
        public DateTime? FechaAsignacion { get; set; }
        public DateTime? FechaEstimada { get; set; }
        public DateTime? FechaCompletada { get; set; }
        public string? Descripcion { get; set; }
        public string? DetallesCliente { get; set; }
        public double? HorasSolicitadas { get; set; }
        public string? HoraSolicitada { get; set; }
        public string? FotosClienteUrls { get; set; } // JSON array
        public string? FotosTrabajoUrls { get; set; } // JSON array
        public string? MontoPropuesto { get; set; }
        public string? EstadoMonto { get; set; } // pendiente, confirmado, rechazado
        public string? Ubicacion { get; set; }
        public string? Comentarios { get; set; }
        public DateTime? FechaActualizacion { get; set; }
    }
}
