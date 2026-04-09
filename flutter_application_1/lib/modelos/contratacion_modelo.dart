class ContratacionModelo {
  final int idContratacion;
  final int idCliente;
  final String? nombreCliente; // ✨ Del JOIN con clientes
  final int? idTecnico;
  final String? nombreTecnico; // ✨ Del JOIN con tecnicos
  final int idServicio;
  // ✅ ESTADOS VÁLIDOS en BD: 'Pendiente', 'Aceptada', 'En Progreso', 'Completada', 'Cancelada'
  final String estado;
  final DateTime fechaSolicitud;
  final DateTime? fechaEstimada;
  final String? descripcion;
  final double? montoPropuesto;
  // ✅ ESTADOS MONTO VÁLIDOS en BD: 'Sin Propuesta', 'Propuesto', 'Aceptado', 'Rechazado'
  final String? estadoMonto;
  final List<String>? fotosClienteUrls;
  final List<String>? fotosTrabajoUrls;
  final String? fotoPerfilCliente; // ✨ Nuevo
  final String? fotoPerfilTecnico; // ✨ Nuevo
  final String? ubicacion;
  final DateTime? horaSolicitud;
  final String? horaSolicitadaStr; // ✨ Hora como string (HH:mm) desde BD

  // ✨ NUEVOS: Para flujo de propuestas alternativas (PARTE 1)
  final DateTime? fechaPropuestaCambios;
  final DateTime? fechaPropuestaSolicitada;
  final String? horaPropuestaSolicitada;
  final String? motivoCambio;

  // ✨ NUEVOS: Para flujo de pagos (PARTE 3)
  final DateTime? fechaPago;
  final double? montoPagado;

  // ✨ NUEVOS: Para flujo de calificaciones (PARTE 4)
  final int? puntuacionCliente; // Puntuación que dejó el cliente (1-5)
  final String? comentarioCliente; // Comentario/reseña del cliente
  final DateTime? fechaCalificacion; // Cuándo calificó

  ContratacionModelo({
    required this.idContratacion,
    required this.idCliente,
    this.nombreCliente,
    this.idTecnico,
    this.nombreTecnico,
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
    this.horaSolicitadaStr,
    this.fechaPropuestaCambios,
    this.fechaPropuestaSolicitada,
    this.horaPropuestaSolicitada,
    this.motivoCambio,
    this.fechaPago,
    this.montoPagado,
    this.puntuacionCliente,
    this.comentarioCliente,
    this.fechaCalificacion,
    this.fotoPerfilCliente,
    this.fotoPerfilTecnico,
  });

  factory ContratacionModelo.desdeJson(Map<String, dynamic> json) {
    // La descripción puede venir como 'descripcion' (camelCase del backend)
    final descripcion =
        json['descripcion'] as String? ??
        json['Descripcion'] as String? ??
        json['detallesCliente'] as String? ??
        json['DetallesCliente'] as String? ??
        json['detalles'] as String? ??
        json['Detalles'] as String?;

    // La hora viene como 'horaSolicitada' (camelCase del backend)
    final horaRaw =
        json['horaSolicitada'] ??
        json['HoraSolicitada'] ??
        json['hora_solicitada'];
    DateTime? horaDt;
    String? horaStr;
    if (horaRaw != null) {
      final horaString = horaRaw.toString();
      // Si es formato HH:mm o HH:mm:ss, guardarlo como string
      if (horaString.contains(':') && !horaString.contains('T')) {
        horaStr = horaString.length >= 5
            ? horaString.substring(0, 5)
            : horaString;
      } else {
        horaDt = DateTime.tryParse(horaString);
        if (horaDt != null) {
          horaStr =
              '${horaDt.hour.toString().padLeft(2, '0')}:${horaDt.minute.toString().padLeft(2, '0')}';
        }
      }
    }

    return ContratacionModelo(
      idContratacion:
          json['idContratacion'] as int? ??
          json['IdContratacion'] as int? ??
          json['id_contratacion'] as int? ??
          0,
      idCliente:
          json['idCliente'] as int? ??
          json['IdCliente'] as int? ??
          json['id_cliente'] as int? ??
          0,
      nombreCliente:
          json['nombreCliente'] as String? ??
          json['NombreCliente'] as String? ??
          json['nombre_cliente'] as String?,
      idTecnico:
          json['idTecnico'] as int? ??
          json['IdTecnico'] as int? ??
          json['id_tecnico'] as int?,
      nombreTecnico:
          json['nombreTecnico'] as String? ??
          json['NombreTecnico'] as String? ??
          json['nombre_tecnico'] as String?,
      idServicio:
          json['idServicio'] as int? ??
          json['IdServicio'] as int? ??
          json['id_servicio'] as int? ??
          0,
      estado:
          json['estado'] as String? ??
          json['Estado'] as String? ??
          json['estado_contratacion'] as String? ??
          '',
      fechaSolicitud: json['fechaSolicitud'] != null
          ? DateTime.tryParse(json['fechaSolicitud'].toString()) ??
                DateTime.now()
          : json['FechaSolicitud'] != null
          ? DateTime.tryParse(json['FechaSolicitud'].toString()) ??
                DateTime.now()
          : json['fecha_solicitud'] != null
          ? DateTime.tryParse(json['fecha_solicitud'].toString()) ??
                DateTime.now()
          : DateTime.now(),
      fechaEstimada: json['fechaEstimada'] != null
          ? DateTime.tryParse(json['fechaEstimada'].toString())
          : json['FechaEstimada'] != null
          ? DateTime.tryParse(json['FechaEstimada'].toString())
          : json['fecha_estimada'] != null
          ? DateTime.tryParse(json['fecha_estimada'].toString())
          : null,
      descripcion: descripcion,
      montoPropuesto: _parseDouble(
        json['montoPropuesto'] as dynamic,
        json['MontoPropuesto'],
        json['monto_propuesto'],
      ),

      estadoMonto:
          json['estadoMonto'] as String? ??
          json['EstadoMonto'] as String? ??
          json['estado_monto'] as String?,
      fotosClienteUrls: _parseFotos(
        json['fotosClienteUrls'] ??
            json['FotosClienteUrls'] ??
            json['fotos_cliente_urls'],
      ),
      fotosTrabajoUrls: _parseFotos(
        json['fotosTrabajoUrls'] ??
            json['FotosTrabajoUrls'] ??
            json['fotos_trabajo_urls'],
      ),
      ubicacion:
          json['ubicacion'] as String? ??
          json['Ubicacion'] as String? ??
          json['ubicacion_trabajo'] as String?,
      horaSolicitud: horaDt,
      horaSolicitadaStr: horaStr,
      fechaPropuestaCambios: json['fechaPropuestaCambios'] != null
          ? DateTime.tryParse(json['fechaPropuestaCambios'].toString())
          : json['FechaPropuestaCambios'] != null
          ? DateTime.tryParse(json['FechaPropuestaCambios'].toString())
          : json['fecha_propuesta_cambios'] != null
          ? DateTime.tryParse(json['fecha_propuesta_cambios'].toString())
          : null,
      fechaPropuestaSolicitada: json['fechaPropuestaSolicitada'] != null
          ? DateTime.tryParse(json['fechaPropuestaSolicitada'].toString())
          : json['FechaPropuestaSolicitada'] != null
          ? DateTime.tryParse(json['FechaPropuestaSolicitada'].toString())
          : json['fecha_propuesta_solicitada'] != null
          ? DateTime.tryParse(json['fecha_propuesta_solicitada'].toString())
          : null,
      horaPropuestaSolicitada:
          json['horaPropuestaSolicitada'] as String? ??
          json['HoraPropuestaSolicitada'] as String? ??
          json['hora_propuesta_solicitada'] as String?,
      motivoCambio:
          json['motivoCambio'] as String? ??
          json['MotivoCambio'] as String? ??
          json['motivo_cambio'] as String?,
      fechaPago: json['fechaPago'] != null
          ? DateTime.tryParse(json['fechaPago'].toString())
          : json['FechaPago'] != null
          ? DateTime.tryParse(json['FechaPago'].toString())
          : json['fecha_pago'] != null
          ? DateTime.tryParse(json['fecha_pago'].toString())
          : null,
      montoPagado:
          (json['montoPagado'] as num?)?.toDouble() ??
          (json['MontoPagado'] as num?)?.toDouble() ??
          (json['monto_pagado'] as num?)?.toDouble() ??
          (json['montoPagado'] != null
              ? double.tryParse(json['montoPagado'].toString())
              : null),
      puntuacionCliente:
          json['puntuacionCliente'] as int? ??
          json['PuntuacionCliente'] as int? ??
          json['puntuacion_cliente'] as int?,
      comentarioCliente:
          json['comentarioCliente'] as String? ??
          json['ComentarioCliente'] as String? ??
          json['comentario_cliente'] as String?,
      fechaCalificacion: json['fechaCalificacion'] != null
          ? DateTime.tryParse(json['fechaCalificacion'].toString())
          : json['FechaCalificacion'] != null
          ? DateTime.tryParse(json['FechaCalificacion'].toString())
          : json['fecha_calificacion'] != null
          ? DateTime.tryParse(json['fecha_calificacion'].toString())
          : null,
      fotoPerfilCliente:
          json['fotoPerfilCliente'] as String? ??
          json['FotoPerfilCliente'] as String? ??
          json['foto_cliente'] as String?,
      fotoPerfilTecnico:
          json['fotoPerfilTecnico'] as String? ??
          json['FotoPerfilTecnico'] as String? ??
          json['foto_tecnico'] as String?,
    );
  }

  static List<String>? _parseFotos(dynamic fotos) {
    if (fotos == null) return null;
    if (fotos is String) {
      if (fotos.isEmpty) return null;
      if (fotos.startsWith('[')) {
        return List<String>.from(
          fotos
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .split(','),
        );
      }
      return [fotos];
    }
    if (fotos is List) return fotos.map((e) => e.toString()).toList();
    return null;
  }

  static double? _parseDouble(
    dynamic camelCase,
    dynamic pascalCase,
    dynamic snakeCase,
  ) {
    // Intentar camelCase primero
    if (camelCase != null) {
      if (camelCase is num) return camelCase.toDouble();
      if (camelCase is String) return double.tryParse(camelCase);
    }
    // Luego PascalCase
    if (pascalCase != null) {
      if (pascalCase is num) return pascalCase.toDouble();
      if (pascalCase is String) return double.tryParse(pascalCase);
    }
    // Finalmente snake_case
    if (snakeCase != null) {
      if (snakeCase is num) return snakeCase.toDouble();
      if (snakeCase is String) return double.tryParse(snakeCase);
    }
    return null;
  }

  Map<String, dynamic> aJson() {
    return {
      'id_contratacion': idContratacion,
      'id_cliente': idCliente,
      'nombre_cliente': nombreCliente,
      'id_tecnico': idTecnico,
      'nombre_tecnico': nombreTecnico,
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
      'hora_solicitada': horaSolicitadaStr,
      'fecha_propuesta_cambios': fechaPropuestaCambios?.toIso8601String(),
      'fecha_propuesta_solicitada': fechaPropuestaSolicitada?.toIso8601String(),
      'hora_propuesta_solicitada': horaPropuestaSolicitada,
      'motivo_cambio': motivoCambio,
      'fecha_pago': fechaPago?.toIso8601String(),
      'monto_pagado': montoPagado,
    };
  }

  @override
  String toString() =>
      'ContratacionModelo(id=$idContratacion, cliente=$idCliente($nombreCliente), tecnico=$idTecnico($nombreTecnico), estado=$estado)';
}
