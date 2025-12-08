import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Configuración
const String API_BASE_URL = 'http://10.0.2.2:3000/api'; // Emulador Android
// Para dispositivo real, cambia a la IP de tu PC: http://192.168.x.x:3000/api

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final http.Client _client = http.Client();
  final _secureStorage = const FlutterSecureStorage();

  String? _authToken;

  // ==================== AUTH ====================

  /// POST /auth/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$API_BASE_URL/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        await _secureStorage.write(key: 'auth_token', value: _authToken!);
        return data; // {token, user_type, id_user, nombre, ...}
      } else if (response.statusCode == 401) {
        throw Exception('Email o contraseña incorrectos.');
      } else {
        throw Exception('Error al iniciar sesión: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// POST /auth/register/client
  Future<Map<String, dynamic>> registerClient({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String telefono,
    required String direccionText,
    required double lat,
    required double lng,
  }) async {
    try {
      // 🔵 Logs para debugging
      final body = {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password,
        'telefono': telefono,
        'direccionText': direccionText,  // ✅ CAMBIO: camelCase en lugar de snake_case
        'lat': lat,
        'lng': lng,
      };

      print('🔵 URL: $API_BASE_URL/auth/register/client');
      print('🔵 Body enviado: ${jsonEncode(body)}');

      final resp = await _client.post(
        Uri.parse('$API_BASE_URL/auth/register/client'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('🔴 Status Code: ${resp.statusCode}');
      print('🔴 Response Body: ${resp.body}');

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _authToken = data['token'];
        await _secureStorage.write(key: 'auth_token', value: _authToken!);
        return data; // {id_cliente, token, ...}
      } else if (resp.statusCode == 409) {
        throw Exception('El email ya está registrado.');
      } else if (resp.statusCode == 400) {
        final error = jsonDecode(resp.body);
        throw Exception(error['error'] ?? 'Error en los datos enviados');
      } else {
        throw Exception('Error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      print('❌ Error completo: $e');
      rethrow;
    }
  }

  /// POST /auth/register/technician
  Future<Map<String, dynamic>> registerTechnician({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String ubicacionText,
    required double lat,
    required double lng,
    required double tarifaHora,
    required List<int> serviceIds,
    required String experiencia,
    required String descripcion,
  }) async {
    try {
      final resp = await _client.post(
        Uri.parse('$API_BASE_URL/auth/register/technician'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'email': email,
          'password': password,
          'telefono': telefono,
          'ubicacion': ubicacionText,  // ✅ Simplificado
          'lat': lat,
          'lng': lng,
          'tarifaHora': tarifaHora,  // ✅ camelCase
          'serviceIds': serviceIds,  // ✅ camelCase
          'experienciaYears': int.tryParse(experiencia) ?? 0,  // ✅ camelCase
          'descripcion': descripcion,
        }),
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _authToken = data['token'];
        await _secureStorage.write(key: 'auth_token', value: _authToken!);
        return data; // {id_tecnico, token, ...}
      } else if (resp.statusCode == 409) {
        throw Exception('El email ya está registrado.');
      } else {
        throw Exception('Error al registrar: ${resp.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// GET stored token
  Future<String?> getToken() async {
    _authToken ??= await _secureStorage.read(key: 'auth_token');
    return _authToken;
  }

  /// Logout
  Future<void> logout() async {
    _authToken = null;
    await _secureStorage.delete(key: 'auth_token');
  }

  // ==================== SERVICES ====================

  /// GET /services
  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      final response = await _client.get(
        Uri.parse('$API_BASE_URL/services'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener servicios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ==================== TECHNICIANS ====================

  /// GET /technicians?service_id=X&lat=X&lng=Y&radius=R
  Future<List<Map<String, dynamic>>> getTechnicians({
    int? serviceId,
    double? lat,
    double? lng,
    double radius = 50.0,
  }) async {
    try {
      final params = <String, String>{};
      if (serviceId != null) params['service_id'] = serviceId.toString();
      if (lat != null && lng != null) {
        params['lat'] = lat.toString();
        params['lng'] = lng.toString();
        params['radius'] = radius.toString();
      }

      final uri = Uri.parse('$API_BASE_URL/technicians').replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener técnicos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// GET /technicians/{id}
  Future<Map<String, dynamic>> getTechnicianDetail(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('$API_BASE_URL/technicians/$id'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener técnico: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ==================== CONTRACTATIONS ====================

  /// POST /contractations
  Future<Map<String, dynamic>> createContractation({
    required int idCliente,
    required int idTecnico,
    required int idServicio,
    required String fechaProgramada,
    required String detalles,
  }) async {
    try {
      final token = await getToken();
      final response = await _client.post(
        Uri.parse('$API_BASE_URL/contractations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'idCliente': idCliente,  // ✅ camelCase
          'idTecnico': idTecnico,  // ✅ camelCase
          'idServicio': idServicio,  // ✅ camelCase
          'descripcion': detalles,  // ✅ Cambiado de 'detalles' a 'descripcion'
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body); // {id_contratacion, estado, ...}
      } else {
        throw Exception('Error al crear contratación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// GET /contractations/{id}
  Future<Map<String, dynamic>> getContractation(int id) async {
    try {
      final token = await getToken();
      final response = await _client.get(
        Uri.parse('$API_BASE_URL/contractations/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== PAYMENTS ====================

  /// POST /payments
  Future<Map<String, dynamic>> createPayment({
    required int idContratacion,
    required double monto,
    required String metodoPago,
    String? transactionRef,
  }) async {
    try {
      final token = await getToken();
      final response = await _client.post(
        Uri.parse('$API_BASE_URL/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'idContratacion': idContratacion,  // ✅ camelCase
          'monto': monto,
          'metodoPago': metodoPago,  // ✅ camelCase
          'transactionRef': transactionRef,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al procesar pago: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== RATINGS ====================

  /// POST /ratings
  Future<Map<String, dynamic>> createRating({
    required int idContratacion,
    required int idTecnico,
    required int puntuacion,
    String? comentario,
  }) async {
    try {
      final token = await getToken();
      final response = await _client.post(
        Uri.parse('$API_BASE_URL/ratings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'idContratacion': idContratacion,  // ✅ camelCase
          'idTecnico': idTecnico,  // ✅ camelCase
          'puntuacion': puntuacion,
          'comentario': comentario,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al guardar calificación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
