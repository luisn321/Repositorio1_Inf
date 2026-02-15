import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../modelos/pago_modelo.dart';
import 'almacenamiento_seguro_servicio.dart';

const String _urlBase = 'http://10.0.2.2:3000/api';

class ServicioPagos {
  final AlmacenamientoSeguroServicio _almacenamiento = AlmacenamientoSeguroServicio();

  /// Obtiene todos los pagos del usuario
  Future<List<PagoModelo>> obtenerTodosLosPagos() async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioPagos] GET $_urlBase/payments');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en obtenerTodosLosPagos: $e');
      rethrow;
    }
  }

  /// Obtiene un pago específico por ID
  Future<PagoModelo?> obtenerPagoPorId(int idPago) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioPagos] GET $_urlBase/payments/$idPago');

      // TODO: Implementar con http.get()
      return null;
    } catch (e) {
      debugPrint('❌ Error en obtenerPagoPorId: $e');
      rethrow;
    }
  }

  /// Obtiene los pagos de una contratación específica
  Future<List<PagoModelo>> obtenerPagosPorContratacion(int idContratacion) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final url = '$_urlBase/payments?contractionId=$idContratacion';
      debugPrint('📡 [ServicioPagos] GET $url');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en obtenerPagosPorContratacion: $e');
      rethrow;
    }
  }

  /// Obtiene los pagos pendientes (para recordatorios)
  Future<List<PagoModelo>> obtenerPagosPendientes() async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioPagos] GET $_urlBase/payments/pending');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en obtenerPagosPendientes: $e');
      rethrow;
    }
  }

  /// Obtiene los pagos vencidos
  Future<List<PagoModelo>> obtenerPagosVencidos() async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioPagos] GET $_urlBase/payments/overdue');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en obtenerPagosVencidos: $e');
      rethrow;
    }
  }

  /// Crea un nuevo pago para una contratación
  Future<PagoModelo> crearPago({
    required int idContratacion,
    required double monto,
    required String metodoPago,
  }) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final payload = {
        'contractionId': idContratacion,
        'amount': monto,
        'paymentMethod': metodoPago,
      };

      debugPrint('📡 [ServicioPagos] POST $_urlBase/payments');
      debugPrint('📦 Payload: $payload');

      // TODO: Implementar con http.post()
      throw Exception('Not yet implemented');
    } catch (e) {
      debugPrint('❌ Error en crearPago: $e');
      rethrow;
    }
  }

  /// Actualiza el estado de un pago
  Future<PagoModelo> actualizarEstadoPago({
    required int idPago,
    required String nuevoEstado,
  }) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final payload = {'status': nuevoEstado};

      debugPrint('📡 [ServicioPagos] PUT $_urlBase/payments/$idPago/status');
      debugPrint('📦 Payload: $payload');

      // TODO: Implementar con http.put()
      throw Exception('Not yet implemented');
    } catch (e) {
      debugPrint('❌ Error en actualizarEstadoPago: $e');
      rethrow;
    }
  }
}
