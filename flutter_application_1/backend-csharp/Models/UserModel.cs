namespace ServitecAPI.Models
{
    public class UserModel
    {
        public int IdUsuario { get; set; }
        public string Nombre { get; set; } = "";
        public string? Apellido { get; set; }
        public string Email { get; set; } = "";
        public string Contrasena { get; set; } = "";
        public string? Telefono { get; set; }
        public string TipoUsuario { get; set; } = "client"; // "client" or "technician"
        public string? DireccionText { get; set; }
        public string? UbicacionText { get; set; }
        public double Latitud { get; set; }
        public double Longitud { get; set; }
        public double? TarifaHora { get; set; }
        public string? FotoPerfilUrl { get; set; }
        public DateTime FechaRegistro { get; set; }
    }
}
