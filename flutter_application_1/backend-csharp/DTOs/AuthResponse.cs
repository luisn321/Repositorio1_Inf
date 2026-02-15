namespace ServitecAPI.DTOs
{
    public class AuthResponse
    {
        public string Token { get; set; } = "";
        public string UserType { get; set; } = "";
        public int UserId { get; set; }
        public int? IdUser { get; set; } // Verificar con frontend lo que espera
        public string Name { get; set; } = "";
        public string Email { get; set; } = "";
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
    }
}
