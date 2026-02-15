import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../modelos/tecnico_modelo.dart';
import '../modelos/almacenamiento_seguro_modelo.dart';
import 'almacenamiento_seguro_servicio.dart';

const String _urlBase = 'http://10.0.2.2:3000/api';

class ServicioTecnicos {
  final AlmacenamientoSeguroServicio _almacenamiento = AlmacenamientoSeguroServicio();

  /// Obtiene todos los técnicos disponibles
  Future<List<TecnicoModelo>> obtenerTodosTecnicos() async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      // Simulando llamada HTTP - en producción usar http.get
      debugPrint('📡 [ServicioTecnicos] GET $_urlBase/technicians');
      debugPrint('🔑 Token: ${token.substring(0, 20)}...');

      // TODO: Implementar llamada real con http.get()
      // var respuesta = await http.get(
      //   Uri.parse('$_urlBase/technicians'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );

      // Por ahora retornamos lista vacía - será implementado cuando el frontend conecte
      return [];
    } catch (e) {
      debugPrint('❌ Error en obtenerTodosTecnicos: $e');
      rethrow;
    }
  }

  /// Obtiene un técnico específico por ID
  Future<TecnicoModelo?> obtenerTecnicoPorId(int idTecnico) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioTecnicos] GET $_urlBase/technicians/$idTecnico');

      // TODO: Implementar con http.get()
      return null;
    } catch (e) {
      debugPrint('❌ Error en obtenerTecnicoPorId: $e');
      rethrow;
    }
  }

  /// Busca técnicos por servicio
  Future<List<TecnicoModelo>> obtenerTecnicosPorServicio(int idServicio) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint('📡 [ServicioTecnicos] GET $_urlBase/technicians?serviceId=$idServicio');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en obtenerTecnicosPorServicio: $e');
      rethrow;
    }
  }

  /// Busca técnicos cercanos por ubicación (geolocalización)
  Future<List<TecnicoModelo>> buscarTecnicosCercanos({
    required double latitud,
    required double longitud,
    required int idServicio,
    double radiusKm = 5.0,
  }) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final url =
          '$_urlBase/technicians/nearby?lat=$latitud&lng=$longitud&service=$idServicio&radius=$radiusKm';
      debugPrint('📡 [ServicioTecnicos] GET $url');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en buscarTecnicosCercanos: $e');
      rethrow;
    }
  }

  /// Busca técnicos por nombre
  Future<List<TecnicoModelo>> buscarTecnicosPorNombre(String nombreBusqueda) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final url = '$_urlBase/technicians/search?name=$nombreBusqueda';
      debugPrint('📡 [ServicioTecnicos] GET $url');

      // TODO: Implementar con http.get()
      return [];
    } catch (e) {
      debugPrint('❌ Error en buscarTecnicosPorNombre: $e');
      rethrow;
    }
  }
}
