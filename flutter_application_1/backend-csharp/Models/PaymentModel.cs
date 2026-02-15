namespace ServitecAPI.Models
{
    public class PaymentModel
    {
        public int IdPago { get; set; }
        public int IdContratacion { get; set; }
        public int IdTecnico { get; set; }
        public int IdCliente { get; set; }
        public double Monto { get; set; }
        public double MontoProyectado { get; set; }
        public string EstadoMonto { get; set; } = "pendiente"; // pendiente, confirmado, rechazado
        public string MetodoPago { get; set; } = ""; // tarjeta, transferencia, etc
        public string EstatusPago { get; set; } = "sin_pagar"; // sin_pagar, pagado, reembolsado
        public DateTime FechaPago { get; set; }
        public DateTime FechaVencimiento { get; set; }
        public string? DescripcionPago { get; set; }
        public string? ReferenciaPago { get; set; }
        public DateTime FechaRegistro { get; set; }
        public DateTime? FechaActualizacion { get; set; }
    }
}
