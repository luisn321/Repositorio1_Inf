import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../modelos/pago_modelo.dart';
import '../almacenamiento/almacenamiento_seguro_servicio.dart';

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

      final respuesta = await http.get(
        Uri.parse('$_urlBase/payments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final pagos = datos.map((pago) => PagoModelo.desdeJson(pago)).toList();
        debugPrint('✅ Obtenidos ${pagos.length} pagos');
        return pagos;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.get(
        Uri.parse('$_urlBase/payments/$idPago'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final pago = PagoModelo.desdeJson(datos);
        debugPrint('✅ Pago obtenido: $idPago');
        return pago;
      } else {
        debugPrint('⚠️ Status code: ${respuesta.statusCode}');
        return null;
      }
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

      final respuesta = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final pagos = datos.map((pago) => PagoModelo.desdeJson(pago)).toList();
        debugPrint('✅ Obtenidos ${pagos.length} pagos de contratación $idContratacion');
        return pagos;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.get(
        Uri.parse('$_urlBase/payments/pending'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final pagos = datos.map((pago) => PagoModelo.desdeJson(pago)).toList();
        debugPrint('✅ Obtenidos ${pagos.length} pagos pendientes');
        return pagos;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.get(
        Uri.parse('$_urlBase/payments/overdue'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final pagos = datos.map((pago) => PagoModelo.desdeJson(pago)).toList();
        debugPrint('✅ Obtenidos ${pagos.length} pagos vencidos');
        return pagos;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.post(
        Uri.parse('$_urlBase/payments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 201 || respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final pago = PagoModelo.desdeJson(datos);
        debugPrint('✅ Pago creado: ${pago.idPago}');
        return pago;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.put(
        Uri.parse('$_urlBase/payments/$idPago/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final pago = PagoModelo.desdeJson(datos);
        debugPrint('✅ Estado actualizado: $nuevoEstado');
        return pago;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint('❌ Error en actualizarEstadoPago: $e');
      rethrow;
    }
  }
}
