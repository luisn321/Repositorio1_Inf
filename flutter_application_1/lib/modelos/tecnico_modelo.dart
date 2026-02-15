class TecnicoModelo {
  final int idTecnico;
  final String nombre;
  final String? apellido;
  final String email;
  final String telefono;
  final double? latitud;
  final double? longitud;
  final double tarifaHora;
  final double calificacionPromedio;
  final int numCalificaciones;
  final String? fotoPerfil;
  final List<int>? idServicios;

  TecnicoModelo({
    required this.idTecnico,
    required this.nombre,
    this.apellido,
    required this.email,
    required this.telefono,
    this.latitud,
    this.longitud,
    required this.tarifaHora,
    required this.calificacionPromedio,
    required this.numCalificaciones,
    this.fotoPerfil,
    this.idServicios,
  });

  factory TecnicoModelo.desdeJson(Map<String, dynamic> json) {
    return TecnicoModelo(
      idTecnico: json['id_tecnico'] as int? ?? json['idTecnico'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      apellido: json['apellido'] as String?,
      email: json['email'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      tarifaHora: (json['tarifa_hora'] as num? ?? json['tarifaHora'] as num? ?? 0).toDouble(),
      calificacionPromedio: (json['calificacion_promedio'] as num? ?? json['calificacionPromedio'] as num? ?? 0).toDouble(),
      numCalificaciones: json['num_calificaciones'] as int? ?? json['numCalificaciones'] as int? ?? 0,
      fotoPerfil: json['foto_perfil_url'] as String? ?? json['fotoPerfil'] as String?,
      idServicios: (json['id_servicios'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> aJson() {
    return {
      'id_tecnico': idTecnico,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'latitud': latitud,
      'longitud': longitud,
      'tarifa_hora': tarifaHora,
      'calificacion_promedio': calificacionPromedio,
      'num_calificaciones': numCalificaciones,
      'foto_perfil_url': fotoPerfil,
      'id_servicios': idServicios,
    };
  }

  String get nombreCompleto => apellido != null ? '$nombre $apellido' : nombre;

  @override
  String toString() => 'TecnicoModelo(id=$idTecnico, nombre=$nombreCompleto, tarifa=$tarifaHora, calificacion=$calificacionPromedio)';
}
