class CalificacionModelo {
  final int idCalificacion;
  final int idContratacion;
  final int idTecnico;
  final int puntuacion; // 1-5
  final String? comentario;
  final DateTime fechaCalificacion;

  CalificacionModelo({
    required this.idCalificacion,
    required this.idContratacion,
    required this.idTecnico,
    required this.puntuacion,
    this.comentario,
    required this.fechaCalificacion,
  });

  factory CalificacionModelo.desdeJson(Map<String, dynamic> json) {
    return CalificacionModelo(
      idCalificacion: json['id_calificacion'] as int? ?? json['idCalificacion'] as int? ?? 0,
      idContratacion: json['id_contratacion'] as int? ?? json['idContratacion'] as int? ?? 0,
      idTecnico: json['id_tecnico'] as int? ?? json['idTecnico'] as int? ?? 0,
      puntuacion: json['puntuacion'] as int? ?? json['score'] as int? ?? 0,
      comentario: json['comentario'] as String? ?? json['comment'] as String?,
      fechaCalificacion: json['fecha'] != null || json['fechaCalificacion'] != null
          ? DateTime.tryParse(
                (json['fecha'] ?? json['fechaCalificacion']).toString(),
              ) ??
              DateTime.now()
          : DateTime.now(),
    );
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
