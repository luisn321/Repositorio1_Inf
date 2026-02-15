/// Modelo que representa un usuario (Cliente o Técnico)
/// Utilizado para almacenar datos del usuario autenticado
class UsuarioModelo {
  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String tipoUsuario; // 'cliente' o 'tecnico'
  final String telefono;
  final double latitud;
  final double longitud;
  final String? fotoPerfilUrl;
  final double? tarifaHora; // Solo para técnicos
  final double? calificacionPromedio; // Solo para técnicos

  UsuarioModelo({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.tipoUsuario,
    required this.telefono,
    required this.latitud,
    required this.longitud,
    this.fotoPerfilUrl,
    this.tarifaHora,
    this.calificacionPromedio,
  });

  /// Crea una instancia desde JSON (respuesta del servidor)
  factory UsuarioModelo.desdeJson(Map<String, dynamic> json) {
    return UsuarioModelo(
      id: json['UserId'] ?? json['IdUser'] ?? json['id'] ?? 0,
      nombre: json['Name'] ?? json['nombre'] ?? '',
      apellido: json['LastName'] ?? json['apellido'] ?? '',
      correo: json['Email'] ?? json['email'] ?? '',
      tipoUsuario: json['UserType'] ?? json['tipo_usuario'] ?? 'cliente',
      telefono: json['Phone'] ?? json['telefono'] ?? '',
      latitud: (json['Latitude'] ?? json['latitud'] ?? 0).toDouble(),
      longitud: (json['Longitude'] ?? json['longitud'] ?? 0).toDouble(),
      fotoPerfilUrl: json['FotoPerfilUrl'] ?? json['foto_perfil_url'],
      tarifaHora: json['TarifaHora'] != null ? double.parse(json['TarifaHora'].toString()) : null,
      calificacionPromedio: json['CalificacionPromedio'] != null ? double.parse(json['CalificacionPromedio'].toString()) : null,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> aJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'tipoUsuario': tipoUsuario,
      'telefono': telefono,
      'latitud': latitud,
      'longitud': longitud,
      'fotoPerfilUrl': fotoPerfilUrl,
      'tarifaHora': tarifaHora,
      'calificacionPromedio': calificacionPromedio,
    };
  }

  /// Retorna nombre completo del usuario
  String obtenerNombreCompleto() => '$nombre $apellido';

  /// Indica si el usuario es técnico
  /// Acepta tanto "tecnico" (español) como "technician" (inglés del backend)
  bool esTecnico() {
    final tipo = tipoUsuario.toLowerCase();
    return tipo == 'tecnico' || tipo == 'technician';
  }

  /// Indica si el usuario es cliente
  /// Acepta tanto "cliente" (español) como "client" (inglés del backend)
  bool esCliente() {
    final tipo = tipoUsuario.toLowerCase();
    return tipo == 'cliente' || tipo == 'client';
  }

  @override
  String toString() => 'UsuarioModelo(id: $id, nombre: $nombre, tipoUsuario: $tipoUsuario)';
}
