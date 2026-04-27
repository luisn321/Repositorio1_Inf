namespace ServitecAPI.Models
{
    public class ContractionModel
    {
        public int IdContratacion { get; set; }
        public int IdCliente { get; set; }
        public string? NombreCliente { get; set; }  //  Del JOIN con clientes
        public int? IdTecnico { get; set; }
        public string? NombreTecnico { get; set; }  //  Del JOIN con tecnicos
        public int IdServicio { get; set; }
        public string? NombreServicio { get; set; } // ✨ NUEVO: Del JOIN con servicios
        public string Estado { get; set; } = "Pendiente"; // Pendiente, Propuesta, Aceptada, En Progreso, Completada, Cancelada
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
        public decimal? MontoPropuesto { get; set; }
        public string? EstadoMonto { get; set; } 
        public string? Ubicacion { get; set; }
        public string? Comentarios { get; set; }
        public DateTime? FechaActualizacion { get; set; }
        
        //  Para flujo de propuestas
        public DateTime? FechaPropuestaCambios { get; set; }
        public DateTime? FechaPropuestaSolicitada { get; set; }
        public string? HoraPropuestaSolicitada { get; set; }
        public string? MotivoCambio { get; set; }
        
        // Para seguimiento de pagos
        public DateTime? FechaPago { get; set; }
        public decimal? MontoPagado { get; set; }
        public string? PaymentIntentId { get; set; } // ✨ Para Stripe Escrow
        public string? ClabeTecnico { get; set; }    // ✨ Para registro de fondos
        
        // Para calificación del cliente
        public int? PuntuacionCliente { get; set; }      // Puntuación dejada por el cliente (1-5)
        public string? ComentarioCliente { get; set; }   // Comentario/reseña del cliente
        public DateTime? FechaCalificacion { get; set; } // Cuándo el cliente calificó

        //  Fotos de perfil para visualización en detalle
        public string? FotoPerfilCliente { get; set; }
        public string? FotoPerfilTecnico { get; set; }
    }
}

