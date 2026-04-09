namespace ServitecAPI.DTOs
{
    /// <summary>
    /// DTO para actualizar el perfil del usuario (cliente o técnico)
    /// </summary>
    public class UpdateProfileRequest
    {
        public int Id { get; set; }
        public string? Nombre { get; set; }
        public string? Apellido { get; set; }
        public string? Correo { get; set; }
        public string? Telefono { get; set; }
        public string? Ubicacion { get; set; }
        public double? TarifaHora { get; set; }
        public string? Descripcion { get; set; }
        public int? AnosExperiencia { get; set; }
        public string? ContrasenaActual { get; set; }
        public string? ContrasenaNueva { get; set; }
        public string? FotoPerfilUrl { get; set; }
    }
}
