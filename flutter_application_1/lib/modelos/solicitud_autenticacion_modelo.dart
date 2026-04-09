/// Modelo para solicitud de autenticación (login)
class SolicitudAutenticacionModelo {
  final String correo;
  final String contrasena;

  SolicitudAutenticacionModelo({
    required this.correo,
    required this.contrasena,
  });

  /// Convierte el modelo a JSON para enviar al servidor
  Map<String, dynamic> aJson() {
    return {
      'Correo': correo,
      'Contrasena': contrasena,
    };
  }

  @override
  String toString() => 'SolicitudAutenticacionModelo(correo: $correo)';
}
