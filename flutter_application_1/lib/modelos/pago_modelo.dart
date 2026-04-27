class PagoModelo {
  final int idPago;
  final int idContratacion;
  final double monto;
  final String estadoPago; // Completado, Pendiente, Rechazado
  final String? estadoMonto; // pendiente, confirmado, rechazado
  final DateTime? fechaPago;
  final String? referenciaPago;
  final String? metodoPago;

  PagoModelo({
    required this.idPago,
    required this.idContratacion,
    required this.monto,
    required this.estadoPago,
    this.estadoMonto,
    this.fechaPago,
    this.referenciaPago,
    this.metodoPago,
  });

  factory PagoModelo.desdeJson(Map<String, dynamic> json) {
    return PagoModelo(
      idPago: json['id_pago'] as int? ?? json['idPago'] as int? ?? 0,
      idContratacion: json['id_contratacion'] as int? ?? json['idContratacion'] as int? ?? 0,
      monto: (json['monto'] as num? ?? 0).toDouble(),
      estadoPago: json['estado_pago'] as String? ?? json['estadoPago'] as String? ?? '',
      estadoMonto: json['estado_monto'] as String?,
      fechaPago: json['fecha_pago'] != null
          ? DateTime.tryParse(json['fecha_pago'].toString())
          : null,
      referenciaPago: json['referencia_pago'] as String? ?? json['referenciaPago'] as String?,
      metodoPago: json['metodo_pago'] as String? ?? json['metodoPago'] as String?,
    );
  }

  Map<String, dynamic> aJson() {
    return {
      'id_pago': idPago,
      'id_contratacion': idContratacion,
      'monto': monto,
      'estado_pago': estadoPago,
      'estado_monto': estadoMonto,
      'fecha_pago': fechaPago?.toIso8601String(),
      'referencia_pago': referenciaPago,
      'metodo_pago': metodoPago,
    };
  }

  @override
  String toString() =>
      'PagoModelo(id=$idPago, contratacion=$idContratacion, monto=$monto, estado=$estadoPago)';
}
