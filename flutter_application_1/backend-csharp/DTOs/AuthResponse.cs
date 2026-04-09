namespace ServitecAPI.DTOs
{
    public class AuthResponse
    {
        public string Token { get; set; } = "";
        public string TipoUsuario { get; set; } = "";
        public int IdUsuario { get; set; }
        public string Nombre { get; set; } = "";
        public string Correo { get; set; } = "";
        public double? Latitud { get; set; }
        public double? Longitud { get; set; }
    }
}
