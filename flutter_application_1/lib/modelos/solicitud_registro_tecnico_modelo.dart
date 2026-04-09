/// Modelo para registro de técnico
class SolicitudRegistroTecnicoModelo {
  final String nombre;
  final String apellido;
  final String correo;
  final String contrasena;
  final String telefono;
  final String ubicacion;
  final double latitud;
  final double longitud;
  final double tarifaHora;
  final List<int> idsServicios;
  final String? descripcion;  // Descripción de especialidad/servicios
  final int? anosExperiencia; // Años de experiencia

  SolicitudRegistroTecnicoModelo({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.contrasena,
    required this.telefono,
    required this.ubicacion,
    required this.latitud,
    required this.longitud,
    required this.tarifaHora,
    required this.idsServicios,
    this.descripcion,
    this.anosExperiencia,
  });

  /// Convierte el modelo a JSON para enviar al servidor
  Map<String, dynamic> aJson() {
    return {
      'Nombre': nombre,
      'Apellido': apellido,
      'Correo': correo,
      'Contrasena': contrasena,
      'Telefono': telefono,
      'UbicacionTexto': ubicacion,
      'Latitud': latitud,
      'Longitud': longitud,
      'TarifaHora': tarifaHora,
      'IdServicios': idsServicios,
      'Descripcion': descripcion,
      'AnosExperiencia': anosExperiencia,
    };
  }

  @override
  String toString() => 'SolicitudRegistroTecnicoModelo(correo: $correo)';
}
