namespace ServitecAPI.DTOs
{
    public class RegisterTechnicianRequest
    {
        public string FirstName { get; set; } = "";  // ✨ NUEVO: Cambiar de Name a FirstName
        public string LastName { get; set; } = "";   // ✨ NUEVO: Agregar apellido
        public string Email { get; set; } = "";
        public string Password { get; set; } = "";
        public string Phone { get; set; } = "";
        public string LocationText { get; set; } = "";
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public double RatePerHour { get; set; }
        public List<int> ServiceIds { get; set; } = new();
    }
}
