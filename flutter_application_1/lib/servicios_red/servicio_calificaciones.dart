import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../modelos/calificacion_modelo.dart';
import '../almacenamiento/almacenamiento_seguro_servicio.dart';

const String _urlBase = 'https://repositorio1-inf.onrender.com/api';

class ServicioCalificaciones {
  final AlmacenamientoSeguroServicio _almacenamiento =
      AlmacenamientoSeguroServicio();

  /// Obtiene todas las calificaciones recibidas por un técnico
  Future<List<CalificacionModelo>> obtenerCalificacionesPorTecnico(
    int idTecnico,
  ) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final url = '$_urlBase/ratings?technicianId=$idTecnico';
      debugPrint('📡 [ServicioCalificaciones] GET $url');

      final respuesta = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final calificaciones = datos
            .map((cal) => CalificacionModelo.desdeJson(cal))
            .toList();
        debugPrint(
          '✅ Obtenidas ${calificaciones.length} calificaciones para técnico $idTecnico',
        );
        return calificaciones;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en obtenerCalificacionesPorTecnico: $e');
      rethrow;
    }
  }

  /// Obtiene una calificación específica por ID
  Future<CalificacionModelo?> obtenerCalificacionPorId(
    int idCalificacion,
  ) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint(
        '📡 [ServicioCalificaciones] GET $_urlBase/ratings/$idCalificacion',
      );

      final respuesta = await http
          .get(
            Uri.parse('$_urlBase/ratings/$idCalificacion'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final calificacion = CalificacionModelo.desdeJson(datos);
        debugPrint('Calificación obtenida: $idCalificacion');
        return calificacion;
      } else {
        debugPrint('Status code: ${respuesta.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint(' Error en obtenerCalificacionPorId: $e');
      rethrow;
    }
  }

  /// Obtiene la calificación de una contratación específica
  Future<CalificacionModelo?> obtenerCalificacionPorContratacion(
    int idContratacion,
  ) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final url = '$_urlBase/ratings?contractionId=$idContratacion';
      debugPrint(' [ServicioCalificaciones] GET $url');

      final respuesta = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        if (datos is List && datos.isNotEmpty) {
          final calificacion = CalificacionModelo.desdeJson(datos.first);
          debugPrint(
            ' Calificación obtenida para contratación $idContratacion',
          );
          return calificacion;
        }
        return null;
      } else {
        debugPrint(' Status code: ${respuesta.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint(' Error en obtenerCalificacionPorContratacion: $e');
      rethrow;
    }
  }

  /// Crea una nueva calificación para un técnico después de completar un servicio
  Future<CalificacionModelo> crearCalificacion({
    required int idContratacion,
    required int idTecnico,
    required int puntuacion, // 1-5
    String? comentario,
  }) async {
    try {
      // Validar rango de puntuación
      if (puntuacion < 1 || puntuacion > 5) {
        throw ArgumentError('La puntuación debe estar entre 1 y 5');
      }

      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final payload = {
        'contractionId': idContratacion,
        'technicianId': idTecnico,
        'score': puntuacion,
        if (comentario != null && comentario.isNotEmpty) 'comment': comentario,
      };

      debugPrint(' [ServicioCalificaciones] POST $_urlBase/ratings');
      debugPrint(' Payload: $payload');
      debugPrint(' Puntuación: $puntuacion/5 - Comentario: $comentario');

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/ratings'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 201 || respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final calificacion = CalificacionModelo.desdeJson(datos);
        debugPrint(' Calificación creada: ${calificacion.idCalificacion}');
        return calificacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en crearCalificacion: $e');
      rethrow;
    }
  }

  /// Optener el promedio de calificaciones de un técnico
  Future<double> obtenerPromedioCalificacionesTecnico(int idTecnico) async {
    try {
      final calificaciones = await obtenerCalificacionesPorTecnico(idTecnico);
      if (calificaciones.isEmpty) return 0.0;

      final suma = calificaciones.fold<int>(
        0,
        (acc, cal) => acc + cal.puntuacion,
      );
      final promedio = suma / calificaciones.length;

      debugPrint(
        ' Promedio de calificaciones para técnico $idTecnico: $promedio/5',
      );
      return promedio;
    } catch (e) {
      debugPrint(' Error en obtenerPromedioCalificacionesTecnico: $e');
      rethrow;
    }
  }
}
