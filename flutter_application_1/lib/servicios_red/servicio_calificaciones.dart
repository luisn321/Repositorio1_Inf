import 'package:flutter/foundation.dart';
import '../modelos/calificacion_modelo.dart';
import '../almacenamiento/almacenamiento_seguro_servicio.dart';

const String _urlBase = 'http://10.0.2.2:3000/api';

class ServicioCalificaciones {
  final AlmacenamientoSeguroServicio _almacenamiento = AlmacenamientoSeguroServicio();

  /// Obtiene todas las calificaciones recibidas por un técnico
  Future<List<CalificacionModelo>> obtenerCalificacionesPorTecnico(int idTecnico) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final url = '$_urlBase/ratings?technicianId=$idTecnico';
      debugPrint('📡 [ServicioCalificaciones] GET $url');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en obtenerCalificacionesPorTecnico: $e');
      rethrow;
    }
  }

  /// Obtiene una calificación específica por ID
  Future<CalificacionModelo?> obtenerCalificacionPorId(int idCalificacion) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioCalificaciones] GET $_urlBase/ratings/$idCalificacion');

      // TODO: Implementar con http.get()
      return null;
    } catch (e) {
      debugPrint('❌ Error en obtenerCalificacionPorId: $e');
      rethrow;
    }
  }

  /// Obtiene la calificación de una contratación específica
  Future<CalificacionModelo?> obtenerCalificacionPorContratacion(int idContratacion) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final url = '$_urlBase/ratings?contractionId=$idContratacion';
      debugPrint('📡 [ServicioCalificaciones] GET $url');

      // TODO: Implementar con http.get()
      return null;
    } catch (e) {
      debugPrint('❌ Error en obtenerCalificacionPorContratacion: $e');
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

      debugPrint('📡 [ServicioCalificaciones] POST $_urlBase/ratings');
      debugPrint('📦 Payload: $payload');
      debugPrint('⭐ Puntuación: $puntuacion/5 - Comentario: $comentario');

      // TODO: Implementar con http.post()
      throw Exception('Not yet implemented');
    } catch (e) {
      debugPrint('❌ Error en crearCalificacion: $e');
      rethrow;
    }
  }

  /// Optener el promedio de calificaciones de un técnico
  Future<double> obtenerPromedioCalificacionesTecnico(int idTecnico) async {
    try {
      final calificaciones = await obtenerCalificacionesPorTecnico(idTecnico);
      if (calificaciones.isEmpty) return 0.0;

      final suma = calificaciones.fold<int>(0, (acc, cal) => acc + cal.puntuacion);
      final promedio = suma / calificaciones.length;

      debugPrint('📊 Promedio de calificaciones para técnico $idTecnico: $promedio/5');
      return promedio;
    } catch (e) {
      debugPrint('❌ Error en obtenerPromedioCalificacionesTecnico: $e');
      rethrow;
    }
  }
}
