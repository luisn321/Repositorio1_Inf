namespace ServitecAPI.DTOs
{
    public class RegisterClientRequest
    {
        public string FirstName { get; set; } = "";
        public string LastName { get; set; } = "";
        public string Email { get; set; } = "";
        public string Password { get; set; } = "";
        public string Phone { get; set; } = "";
        public string AddressText { get; set; } = "";
        public double Latitude { get; set; }
        public double Longitude { get; set; }
    }
}
