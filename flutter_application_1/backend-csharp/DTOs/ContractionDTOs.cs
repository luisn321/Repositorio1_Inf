namespace ServitecAPI.DTOs
{
    using System.Text.Json.Serialization;

    public class CreateContractionDto
    {
        [JsonPropertyName("idCliente")]
        public int IdCliente { get; set; }

        [JsonPropertyName("idTecnico")]
        public int? IdTecnico { get; set; }  

        [JsonPropertyName("idServicio")]
        public int IdServicio { get; set; }

        [JsonPropertyName("descripcion")]
        public string? Descripcion { get; set; }

        [JsonPropertyName("fechaEstimada")]
        public DateTime? FechaEstimada { get; set; }

        [JsonPropertyName("detallesCliente")]
        public string? DetallesCliente { get; set; }

        [JsonPropertyName("horasSolicitadas")]
        public double? HorasSolicitadas { get; set; }

        [JsonPropertyName("horaSolicitada")]
        public string? HoraSolicitada { get; set; }

        [JsonPropertyName("fotosClienteUrls")]
        public string? FotosClienteUrls { get; set; }

        [JsonPropertyName("ubicacion")]
        public string? Ubicacion { get; set; }
    }

    public class UpdateContractionDto
    {
        public string? Estado { get; set; }
        public int? IdTecnico { get; set; }
        public DateTime? FechaEstimada { get; set; }
        public string? Descripcion { get; set; }
        public string? FotosTrabajoUrls { get; set; }
        public decimal? MontoPropuesto { get; set; }
        public string? EstadoMonto { get; set; }
        public string? Comentarios { get; set; }
        public string? MotivoCambio { get; set; } // ✨ Para el reembolso
        public decimal? MontoPagado { get; set; }
        public DateTime? FechaPago { get; set; }
        public string? PaymentIntentId { get; set; } // ✨
    }

    public class AssignTechnicianDto
    {
        public int IdTecnico { get; set; }
        public double? MontoPropuesto { get; set; }
        public string? Comentarios { get; set; }
    }

    public class RejectContractionDto
    {
        [JsonPropertyName("motivo")]
        public string? Motivo { get; set; } 
    }

    public class AcceptContractionDto
    {
        [JsonPropertyName("idTecnico")]
        public int IdTecnico { get; set; } 
    }

    public class ProposeAlternativeDto
    {
        [JsonPropertyName("fechaPropuestaSolicitada")]
        public DateTime FechaPropuestaSolicitada { get; set; }
        
        [JsonPropertyName("horaPropuestaSolicitada")]
        public string? HoraPropuestaSolicitada { get; set; }
        
        [JsonPropertyName("motivoCambio")]
        public string? MotivoCambio { get; set; }
    }

    public class ProposeMountDto
    {
        public double Monto { get; set; } 
        [JsonPropertyName("clabeTecnico")]
        public string? ClabeTecnico { get; set; } // ✨ La tarjeta o CLABE del técnico
    }

    public class ContractionResponse
    {
        [JsonPropertyName("idContratacion")]
        public int IdContratacion { get; set; }
        
        [JsonPropertyName("idCliente")]
        public int IdCliente { get; set; }
        
        [JsonPropertyName("nombreCliente")]
        public string? NombreCliente { get; set; }  
        
        [JsonPropertyName("idTecnico")]
        public int? IdTecnico { get; set; }
        
        [JsonPropertyName("nombreTecnico")]
        public string? NombreTecnico { get; set; }  

        [JsonPropertyName("fotoPerfilCliente")]
        public string? FotoPerfilCliente { get; set; }  
        
        [JsonPropertyName("fotoPerfilTecnico")]
        public string? FotoPerfilTecnico { get; set; }  
        
        [JsonPropertyName("idServicio")]
        public int IdServicio { get; set; }

        [JsonPropertyName("nombreServicio")]
        public string? NombreServicio { get; set; }
        
        [JsonPropertyName("estado")]
        public string Estado { get; set; } = "";
        
        [JsonPropertyName("fechaSolicitud")]
        public DateTime FechaSolicitud { get; set; }
        
        [JsonPropertyName("fechaAsignacion")]
        public DateTime? FechaAsignacion { get; set; }
        
        [JsonPropertyName("fechaEstimada")]
        public DateTime? FechaEstimada { get; set; }
        
        [JsonPropertyName("fechaCompletada")]
        public DateTime? FechaCompletada { get; set; }
        
        [JsonPropertyName("descripcion")]
        public string? Descripcion { get; set; }
        
        [JsonPropertyName("detallesCliente")]
        public string? DetallesCliente { get; set; }
        
        [JsonPropertyName("horasSolicitadas")]
        public double? HorasSolicitadas { get; set; }
        
        [JsonPropertyName("horaSolicitada")]
        public string? HoraSolicitada { get; set; }
        
        [JsonPropertyName("fotosClienteUrls")]
        public string? FotosClienteUrls { get; set; }
        
        [JsonPropertyName("fotosTrabajoUrls")]
        public string? FotosTrabajoUrls { get; set; }
        
        [JsonPropertyName("montoPropuesto")]
        public decimal? MontoPropuesto { get; set; }
        
        [JsonPropertyName("puntuacionCliente")]
        public int? PuntuacionCliente { get; set; }  
        
        [JsonPropertyName("comentarioCliente")]
        public string? ComentarioCliente { get; set; } 
        
        [JsonPropertyName("fechaCalificacion")]
        public DateTime? FechaCalificacion { get; set; } 
        
        [JsonPropertyName("estadoMonto")]
        public string? EstadoMonto { get; set; }
        
        [JsonPropertyName("ubicacion")]
        public string? Ubicacion { get; set; }
        
        [JsonPropertyName("comentarios")]
        public string? Comentarios { get; set; }
        
        [JsonPropertyName("fechaPropuestaCambios")]
        public DateTime? FechaPropuestaCambios { get; set; }
        
        [JsonPropertyName("fechaPropuestaSolicitada")]
        public DateTime? FechaPropuestaSolicitada { get; set; }
        
        [JsonPropertyName("horaPropuestaSolicitada")]
        public string? HoraPropuestaSolicitada { get; set; }
        
        [JsonPropertyName("motivoCambio")]
        public string? MotivoCambio { get; set; }
        
        [JsonPropertyName("fechaPago")]
        public DateTime? FechaPago { get; set; }
        
        [JsonPropertyName("montoPagado")]
        public decimal? MontoPagado { get; set; }
        
        [JsonPropertyName("paymentIntentId")]
        public string? PaymentIntentId { get; set; } // ✨ Para Stripe Escrow
        
        [JsonPropertyName("clabeTecnico")]
        public string? ClabeTecnico { get; set; } // ✨ Tarjeta/CLABE del técnico
    }

    public class AcceptAmountDto { }  

    public class RejectAmountDto
    {
        [JsonPropertyName("motivo")]
        public string? Motivo { get; set; }  
    }
}
