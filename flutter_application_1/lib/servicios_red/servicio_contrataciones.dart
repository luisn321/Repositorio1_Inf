import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../modelos/contratacion_modelo.dart';
import 'almacenamiento_seguro_servicio.dart';

const String _urlBase = 'http://10.0.2.2:3000/api';

class ServicioContrataciones {
  final AlmacenamientoSeguroServicio _almacenamiento = AlmacenamientoSeguroServicio();

  /// Obtiene todas las contrataciones del usuario
  Future<List<ContratacionModelo>> obtenerTodasLasContrataciones() async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioContrataciones] GET $_urlBase/contractions');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en obtenerTodasLasContrataciones: $e');
      rethrow;
    }
  }

  /// Obtiene una contratación específica por ID
  Future<ContratacionModelo?> obtenerContratacionPorId(int idContratacion) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioContrataciones] GET $_urlBase/contractions/$idContratacion');

      // TODO: Implementar con http.get()
      return null;
    } catch (e) {
      debugPrint('❌ Error en obtenerContratacionPorId: $e');
      rethrow;
    }
  }

  /// Obtiene contrataciones por estado
  Future<List<ContratacionModelo>> obtenerContratacionesPorEstado(String estado) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final url = '$_urlBase/contractions?status=$estado';
      debugPrint('📡 [ServicioContrataciones] GET $url');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en obtenerContratacionesPorEstado: $e');
      rethrow;
    }
  }

  /// Obtiene contrataciones pendientes
  Future<List<ContratacionModelo>> obtenerContratacionesPendientes() async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioContrataciones] GET $_urlBase/contractions/pending');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en obtenerContratacionesPendientes: $e');
      rethrow;
    }
  }

  /// Crea una nueva contratación/solicitud de servicio
  Future<ContratacionModelo> crearContratacion({
    required int idCliente,
    required int idServicio,
    required String descripcion,
    required DateTime fechaEstimada,
    String? ubicacion,
  }) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final payload = {
        'clientId': idCliente,
        'serviceId': idServicio,
        'description': descripcion,
        'scheduledDate': fechaEstimada.toIso8601String(),
        if (ubicacion != null) 'location': ubicacion,
      };

      debugPrint('📡 [ServicioContrataciones] POST $_urlBase/contractions');
      debugPrint('📦 Payload: $payload');

      // TODO: Implementar con http.post()
      throw Exception('Not yet implemented');
    } catch (e) {
      debugPrint('❌ Error en crearContratacion: $e');
      rethrow;
    }
  }

  /// Actualiza el estado de una contratación
  Future<ContratacionModelo> actualizarEstadoContratacion({
    required int idContratacion,
    required String nuevoEstado,
  }) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final payload = {'status': nuevoEstado};

      debugPrint('📡 [ServicioContrataciones] PUT $_urlBase/contractions/$idContratacion');
      debugPrint('📦 Payload: $payload');

      // TODO: Implementar con http.put()
      throw Exception('Not yet implemented');
    } catch (e) {
      debugPrint('❌ Error en actualizarEstadoContratacion: $e');
      rethrow;
    }
  }

  /// Asigna un técnico a una contratación
  Future<ContratacionModelo> asignarTecnico({
    required int idContratacion,
    required int idTecnico,
  }) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioContrataciones] POST $_urlBase/contractions/$idContratacion/assign');
      debugPrint('📦 Body: idTecnico=$idTecnico');

      // TODO: Implementar con http.post()
      throw Exception('Not yet implemented');
    } catch (e) {
      debugPrint('❌ Error en asignarTecnico: $e');
      rethrow;
    }
  }

  /// Marca una contratación como completada
  Future<ContratacionModelo> completarContratacion(int idContratacion) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioContrataciones] POST $_urlBase/contractions/$idContratacion/complete');

      // TODO: Implementar con http.post()
      throw Exception('Not yet implemented');
    } catch (e) {
      debugPrint('❌ Error en completarContratacion: $e');
      rethrow;
    }
  }

  /// Cancela una contratación
  Future<ContratacionModelo> cancelarContratacion(int idContratacion) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioContrataciones] POST $_urlBase/contractions/$idContratacion/cancel');

      // TODO: Implementar con http.post()
      throw Exception('Not yet implemented');
    } catch (e) {
      debugPrint('❌ Error en cancelarContratacion: $e');
      rethrow;
    }
  }
}
