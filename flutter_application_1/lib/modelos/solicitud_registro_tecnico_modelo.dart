/// Modelo para registro de técnico
class SolicitudRegistroTecnicoModelo {
  final String nombre;
  final String correo;
  final String contrasena;
  final String telefono;
  final String ubicacion;
  final double latitud;
  final double longitud;
  final double tarifaHora;
  final List<int> idsServicios;

  SolicitudRegistroTecnicoModelo({
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.telefono,
    required this.ubicacion,
    required this.latitud,
    required this.longitud,
    required this.tarifaHora,
    required this.idsServicios,
  });

  /// Convierte el modelo a JSON para enviar al servidor
  Map<String, dynamic> aJson() {
    return {
      'name': nombre,
      'email': correo,
      'password': contrasena,
      'phone': telefono,
      'locationText': ubicacion,
      'latitude': latitud,
      'longitude': longitud,
      'ratePerHour': tarifaHora,
      'serviceIds': idsServicios,
    };
  }

  @override
  String toString() => 'SolicitudRegistroTecnicoModelo(correo: $correo)';
}
