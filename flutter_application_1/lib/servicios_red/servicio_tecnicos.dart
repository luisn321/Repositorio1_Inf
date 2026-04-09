import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../modelos/tecnico_modelo.dart';
import '../almacenamiento/almacenamiento_seguro_servicio.dart';

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

      debugPrint('📡 [ServicioTecnicos] GET $_urlBase/technicians');

      final respuesta = await http.get(
        Uri.parse('$_urlBase/technicians'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final tecnicos = datos
            .map((tecnico) => TecnicoModelo.desdeJson(tecnico))
            .toList();
        debugPrint('✅ Obtenidos ${tecnicos.length} técnicos');
        return tecnicos;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
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

      final respuesta = await http.get(
        Uri.parse('$_urlBase/technicians/$idTecnico'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final tecnico = TecnicoModelo.desdeJson(datos);
        debugPrint('✅ Técnico obtenido: ${tecnico.nombreCompleto}');
        return tecnico;
      } else {
        debugPrint('⚠️ Status code: ${respuesta.statusCode}');
        return null;
      }
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
        throw Exception('❌ Token no disponible - Usuario no autenticado');
      }

      final url = '$_urlBase/technicians?serviceId=$idServicio';
      debugPrint('📡 [ServicioTecnicos] GET $url');
      debugPrint('🔍 Buscando técnicos del servicio ID: $idServicio');

      final respuesta = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('📊 Status: ${respuesta.statusCode}');
      debugPrint('📦 Response length: ${respuesta.body.length}');

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final tecnicos = datos
            .map((tecnico) => TecnicoModelo.desdeJson(tecnico))
            .toList();
        debugPrint('✅ Obtenidos ${tecnicos.length} técnicos para servicio $idServicio');
        return tecnicos;
      } else if (respuesta.statusCode == 401) {
        throw Exception('❌ Token inválido o expirado (401)');
      } else if (respuesta.statusCode == 500) {
        throw Exception('❌ Error del servidor: ${respuesta.body}');
      } else {
        throw Exception('❌ Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint('❌ Excepción en obtenerTecnicosPorServicio: $e');
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

      final respuesta = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final tecnicos = datos
            .map((tecnico) => TecnicoModelo.desdeJson(tecnico))
            .toList();
        debugPrint('✅ Obtenidos ${tecnicos.length} técnicos cercanos');
        return tecnicos;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint('❌ Error en buscarTecnicosCercanos: $e');
      rethrow;
    }
  }

  /// Busca técnicos por nombre
  Future<List<TecnicoModelo>> buscarTecnicosPorNombre(String nombreBusqueda) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      debugPrint('🔑 Token obtenido: ${token != null ? 'Sí' : 'No'}');
      if (token == null) {
        throw Exception('❌ Token no disponible - Usuario no autenticado');
      }

      final nombreCodificado = Uri.encodeComponent(nombreBusqueda);
      final url = '$_urlBase/technicians/search?q=$nombreCodificado';
      debugPrint('📡 [ServicioTecnicos] Buscando: "$nombreBusqueda"');
      debugPrint('📡 URL completa: $url');

      final respuesta = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('📊 Status: ${respuesta.statusCode}');
      debugPrint('📦 Response: ${respuesta.body}');

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final tecnicos = datos
            .map((tecnico) => TecnicoModelo.desdeJson(tecnico))
            .toList();
        debugPrint('✅ Búsqueda encontró ${tecnicos.length} técnicos');
        return tecnicos;
      } else if (respuesta.statusCode == 401) {
        throw Exception('❌ Token inválido o expirado (401)');
      } else if (respuesta.statusCode == 500) {
        throw Exception('❌ Error del servidor: ${respuesta.body}');
      } else {
        throw Exception('❌ Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint('❌ Excepción en buscarTecnicosPorNombre: $e');
      rethrow;
    }
  }
}
