/// Modelos para el flujo de aceptación/rechazo de solicitudes

/// DTO para rechazar una solicitud
class RechazarSolicitudRequest {
  final String motivo;

  RechazarSolicitudRequest({required this.motivo});

  Map<String, dynamic> aJson() => {
        'motivo': motivo,
      };
}

/// DTO para aceptar una solicitud
class AceptarSolicitudRequest {
  final int idTecnico;

  AceptarSolicitudRequest({required this.idTecnico});

  Map<String, dynamic> aJson() => {
        'idTecnico': idTecnico,
      };
}

/// Respuesta al aceptar/rechazar
class RespuestaSolicitud {
  final bool exitoso;
  final String mensaje;
  final int? idContratacion;

  RespuestaSolicitud({
    required this.exitoso,
    required this.mensaje,
    this.idContratacion,
  });

  factory RespuestaSolicitud.desdeJson(Map<String, dynamic> json) {
    return RespuestaSolicitud(
      exitoso: json['exitoso'] ?? json['success'] ?? false,
      mensaje: json['mensaje'] ?? json['message'] ?? '',
      idContratacion: json['idContratacion'],
    );
  }
}

/// DTO para proponer un monto (PARTE 2)
class ProponerMontoRequest {
  final double monto;

  ProponerMontoRequest({required this.monto});

  Map<String, dynamic> aJson() => {
        'monto': monto,
      };
}

/// Respuesta al proponer monto
class RespuestaProponerMonto {
  final bool exitoso;
  final String mensaje;
  final double? monto;

  RespuestaProponerMonto({
    required this.exitoso,
    required this.mensaje,
    this.monto,
  });

  factory RespuestaProponerMonto.desdeJson(Map<String, dynamic> json) {
    return RespuestaProponerMonto(
      exitoso: json['message'] != null || json['monto'] != null,
      mensaje: json['message'] ?? 'Monto propuesto',
      monto: (json['monto'] as num?)?.toDouble(),
    );
  }
}
