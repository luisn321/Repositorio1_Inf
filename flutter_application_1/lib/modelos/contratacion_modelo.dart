class ContratacionModelo {
  final int idContratacion;
  final int idCliente;
  final int? idTecnico;
  final int idServicio;
  final String estado; // solicitada, asignada, en_proceso, completada, cancelada
  final DateTime fechaSolicitud;
  final DateTime? fechaEstimada;
  final String? descripcion;
  final double? montoPropuesto;
  final String? estadoMonto; // pendiente, confirmado, rechazado
  final List<String>? fotosClienteUrls;
  final List<String>? fotosTrabajoUrls;
  final String? ubicacion;
  final DateTime? horaSolicitud;

  ContratacionModelo({
    required this.idContratacion,
    required this.idCliente,
    this.idTecnico,
    required this.idServicio,
    required this.estado,
    required this.fechaSolicitud,
    this.fechaEstimada,
    this.descripcion,
    this.montoPropuesto,
    this.estadoMonto,
    this.fotosClienteUrls,
    this.fotosTrabajoUrls,
    this.ubicacion,
    this.horaSolicitud,
  });

  factory ContratacionModelo.desdeJson(Map<String, dynamic> json) {
    return ContratacionModelo(
      idContratacion: json['id_contratacion'] as int? ?? json['idContratacion'] as int? ?? 0,
      idCliente: json['id_cliente'] as int? ?? json['idCliente'] as int? ?? 0,
      idTecnico: json['id_tecnico'] as int? ?? json['idTecnico'] as int?,
      idServicio: json['id_servicio'] as int? ?? json['idServicio'] as int? ?? 0,
      estado: json['estado'] as String? ?? '',
      fechaSolicitud: json['fecha_solicitud'] != null
          ? DateTime.tryParse(json['fecha_solicitud'].toString()) ?? DateTime.now()
          : DateTime.now(),
      fechaEstimada: json['fecha_estimada'] != null
          ? DateTime.tryParse(json['fecha_estimada'].toString())
          : null,
      descripcion: json['descripcion'] as String?,
      montoPropuesto: (json['monto_propuesto'] as num?)?.toDouble(),
      estadoMonto: json['estado_monto'] as String?,
      fotosClienteUrls: _parseFotos(json['fotos_cliente_urls']),
      fotosTrabajoUrls: _parseFotos(json['fotos_trabajo_urls']),
      ubicacion: json['ubicacion'] as String?,
      horaSolicitud: json['hora_solicitud'] != null
          ? DateTime.tryParse(json['hora_solicitud'].toString())
          : null,
    );
  }

  static List<String>? _parseFotos(dynamic fotos) {
    if (fotos == null) return null;
    if (fotos is String) {
      try {
        // Si es una string JSON, parsearlo
        if (fotos.startsWith('[')) {
          // Es un array JSON
          return List<String>.from(
            fotos.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').split(','),
          );
        }
        return [fotos];
      } catch (e) {
        return [fotos];
      }
    }
    if (fotos is List) {
      return fotos.map((e) => e.toString()).toList();
    }
    return null;
  }

  Map<String, dynamic> aJson() {
    return {
      'id_contratacion': idContratacion,
      'id_cliente': idCliente,
      'id_tecnico': idTecnico,
      'id_servicio': idServicio,
      'estado': estado,
      'fecha_solicitud': fechaSolicitud.toIso8601String(),
      'fecha_estimada': fechaEstimada?.toIso8601String(),
      'descripcion': descripcion,
      'monto_propuesto': montoPropuesto,
      'estado_monto': estadoMonto,
      'fotos_cliente_urls': fotosClienteUrls,
      'fotos_trabajo_urls': fotosTrabajoUrls,
      'ubicacion': ubicacion,
      'hora_solicitud': horaSolicitud?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'ContratacionModelo(id=$idContratacion, cliente=$idCliente, tecnico=$idTecnico, estado=$estado)';
}
