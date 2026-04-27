class CalificacionModelo {
  final int idCalificacion;
  final int idContratacion;
  final int idTecnico;
  final int puntuacion;
  final String? comentario;
  final List<String> fotosResenaUrls;
  final String? nombreCliente;
  final String? fotoPerfilCliente;
  final DateTime fechaCalificacion;

  CalificacionModelo({
    required this.idCalificacion,
    required this.idContratacion,
    required this.idTecnico,
    required this.puntuacion,
    this.comentario,
    this.fotosResenaUrls = const [],
    this.nombreCliente,
    this.fotoPerfilCliente,
    required this.fechaCalificacion,
  });

  factory CalificacionModelo.desdeJson(Map<String, dynamic> json) {
    return CalificacionModelo(
      idCalificacion:
          json['idCalificacion'] as int? ??
          json['id_calificacion'] as int? ??
          0,
      idContratacion:
          json['idContratacion'] as int? ??
          json['id_contratacion'] as int? ??
          0,
      idTecnico: json['idTecnico'] as int? ?? json['id_tecnico'] as int? ?? 0,
      puntuacion: json['puntuacion'] as int? ?? 0,
      comentario: json['comentario'] as String?,
      fotosResenaUrls: _parseFotos(
        json['fotosResenaUrls'] ?? json['fotos_resena_urls'],
      ),
      nombreCliente:
          json['nombreCliente'] as String? ?? json['nombre_cliente'] as String?,
      fotoPerfilCliente:
          json['fotoPerfilCliente'] as String? ??
          json['FotoPerfilCliente'] as String? ??
          json['foto_cliente'] as String? ??
          json['foto_perfil_cliente'] as String?,
      fechaCalificacion: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static List<String> _parseFotos(dynamic fotosData) {
    if (fotosData == null) return [];
    if (fotosData is String) {
      if (fotosData.isEmpty) return [];
      return fotosData
          .split(',')
          .map((e) => e.trim())
          .where((url) => url.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> aJson() {
    return {
      'id_calificacion': idCalificacion,
      'id_contratacion': idContratacion,
      'id_tecnico': idTecnico,
      'puntuacion': puntuacion,
      'comentario': comentario,
      'fecha': fechaCalificacion.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'CalificacionModelo(id=$idCalificacion, tecnico=$idTecnico, puntuacion=$puntuacion/5)';
}
