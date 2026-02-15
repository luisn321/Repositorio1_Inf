/// Modelo para respuesta de autenticación exitosa
class RespuestaAutenticacionModelo {
  final String token;
  final int usuarioId;
  final String nombre;
  final String correo;
  final String tipoUsuario;
  final double? latitud;
  final double? longitud;

  RespuestaAutenticacionModelo({
    required this.token,
    required this.usuarioId,
    required this.nombre,
    required this.correo,
    required this.tipoUsuario,
    this.latitud,
    this.longitud,
  });

  /// Crea una instancia desde JSON (respuesta del servidor)
  factory RespuestaAutenticacionModelo.desdeJson(Map<String, dynamic> json) {
    return RespuestaAutenticacionModelo(
      token: json['Token'] ?? json['token'] ?? '',
      usuarioId: json['UserId'] ?? json['IdUser'] ?? json['userId'] ?? 0,
      nombre: json['Name'] ?? json['nombre'] ?? '',
      correo: json['Email'] ?? json['email'] ?? '',
      tipoUsuario: json['UserType'] ?? json['tipoUsuario'] ?? 'cliente',
      latitud: json['Latitude'] != null ? (json['Latitude'] as num).toDouble() : null,
      longitud: json['Longitude'] != null ? (json['Longitude'] as num).toDouble() : null,
    );
  }

  @override
  String toString() => 'RespuestaAutenticacionModelo(usuarioId: $usuarioId, nombre: $nombre)';
}
