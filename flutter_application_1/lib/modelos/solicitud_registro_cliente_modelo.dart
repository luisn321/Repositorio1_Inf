/// Modelo para registro de cliente
class SolicitudRegistroClienteModelo {
  final String nombre;
  final String apellido;
  final String correo;
  final String contrasena;
  final String telefono;
  final String direccion;
  final double latitud;
  final double longitud;

  SolicitudRegistroClienteModelo({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.contrasena,
    required this.telefono,
    required this.direccion,
    required this.latitud,
    required this.longitud,
  });

  /// Convierte el modelo a JSON para enviar al servidor
  Map<String, dynamic> aJson() {
    return {
      'firstName': nombre,
      'lastName': apellido,
      'email': correo,
      'password': contrasena,
      'phone': telefono,
      'addressText': direccion,
      'latitude': latitud,
      'longitude': longitud,
    };
  }

  @override
  String toString() => 'SolicitudRegistroClienteModelo(correo: $correo)';
}
