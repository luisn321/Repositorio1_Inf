using System.Text.Json.Serialization;

namespace ServitecAPI.DTOs
{
    public class GetPaymentRequest
    {
        public int? IdPago { get; set; }
        public int? IdContratacion { get; set; }
        public int? IdTecnico { get; set; }
        public int? IdCliente { get; set; }
        public string? EstatusPago { get; set; }
    }

    public class CreatePaymentRequest
    {
        [JsonPropertyName("idContratacion")]
        public int IdContratacion { get; set; }

        [JsonPropertyName("monto")]
        public double Monto { get; set; }

        [JsonPropertyName("montoProyectado")]
        public double? MontoProyectado { get; set; }

        [JsonPropertyName("metodoPago")]
        public string? MetodoPago { get; set; }

        [JsonPropertyName("descripcionPago")]
        public string? DescripcionPago { get; set; }

        [JsonPropertyName("transactionRef")]
        public string? TransactionRef { get; set; }  // ✨ NUEVO: Referencia de transacción
    }

    public class UpdatePaymentStatusRequest
    {
        public string EstatusPago { get; set; } = ""; // sin_pagar, pagado, reembolsado
        public string? EstadoMonto { get; set; } // pendiente, confirmado, rechazado
        public string? ReferenciaPago { get; set; }
    }

    public class PaymentResponse
    {
        public int IdPago { get; set; }
        public int IdContratacion { get; set; }
        public int IdTecnico { get; set; }
        public int IdCliente { get; set; }
        public double Monto { get; set; }
        public double MontoProyectado { get; set; }
        public string EstadoMonto { get; set; } = "";
        public string MetodoPago { get; set; } = "";
        public string EstatusPago { get; set; } = "";
        public DateTime FechaPago { get; set; }
        public DateTime FechaVencimiento { get; set; }
        public string? DescripcionPago { get; set; }
        public string? ReferenciaPago { get; set; }
    }
}
