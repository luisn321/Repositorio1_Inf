import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../modelos/contratacion_modelo.dart';
import '../almacenamiento/almacenamiento_seguro_servicio.dart';

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

      final respuesta = await http.get(
        Uri.parse('$_urlBase/contractions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final contrataciones = datos
            .map((cont) => ContratacionModelo.desdeJson(cont))
            .toList();
        debugPrint('✅ Obtenidas ${contrataciones.length} contrataciones');
        return contrataciones;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.get(
        Uri.parse('$_urlBase/contractions/$idContratacion'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint('✅ Contratación obtenida: $idContratacion');
        return contratacion;
      } else {
        debugPrint('⚠️ Status code: ${respuesta.statusCode}');
        return null;
      }
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

      final respuesta = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final contrataciones = datos
            .map((cont) => ContratacionModelo.desdeJson(cont))
            .toList();
        debugPrint('✅ Obtenidas ${contrataciones.length} contrataciones con estado $estado');
        return contrataciones;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.get(
        Uri.parse('$_urlBase/contractions/pending'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final contrataciones = datos
            .map((cont) => ContratacionModelo.desdeJson(cont))
            .toList();
        debugPrint('✅ Obtenidas ${contrataciones.length} contrataciones pendientes');
        return contrataciones;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.post(
        Uri.parse('$_urlBase/contractions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 201 || respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint('✅ Contratación creada: ${contratacion.idContratacion}');
        return contratacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.put(
        Uri.parse('$_urlBase/contractions/$idContratacion'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint('✅ Estado actualizado: $nuevoEstado');
        return contratacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final payload = {'technicianId': idTecnico};

      debugPrint('📡 [ServicioContrataciones] POST $_urlBase/contractions/$idContratacion/assign');
      debugPrint('📦 Body: $payload');

      final respuesta = await http.post(
        Uri.parse('$_urlBase/contractions/$idContratacion/assign'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint('✅ Técnico asignado: $idTecnico');
        return contratacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.post(
        Uri.parse('$_urlBase/contractions/$idContratacion/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint('✅ Contratación completada: $idContratacion');
        return contratacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.post(
        Uri.parse('$_urlBase/contractions/$idContratacion/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint('✅ Contratación cancelada: $idContratacion');
        return contratacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint('❌ Error en cancelarContratacion: $e');
      rethrow;
    }
  }
}
