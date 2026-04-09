using System.Text.RegularExpressions;

namespace ServitecAPI.Validators
{
    public static class EmailValidator
    {
        public static bool IsValid(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            var pattern = @"^[^@\s]+@[^@\s]+\.[^@\s]+$";
            return Regex.IsMatch(email, pattern);
        }
    }

    public static class PasswordValidator
    {
        public static bool IsValid(string password)
        {
            if (string.IsNullOrWhiteSpace(password))
                return false;

            // Mínimo 6 caracteres, al menos una mayúscula y un número
            return password.Length >= 6 &&
                   password.Any(char.IsUpper) &&
                   password.Any(char.IsDigit);
        }

        public static string GetValidationMessage()
        {
            return "La contraseña debe tener al menos 6 caracteres, incluir al menos una mayúscula y un dígito.";
        }
    }

    public static class PhoneValidator
    {
        public static bool IsValid(string phone)
        {
            if (string.IsNullOrWhiteSpace(phone))
                return false;

            var cleanPhone = Regex.Replace(phone, @"\D", "");
            return cleanPhone.Length >= 10;
        }
        
    }
}
