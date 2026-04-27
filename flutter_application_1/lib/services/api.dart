import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


const String API_BASE_URL = 'https://repositorio1-inf.onrender.com/api'; 


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
      // Logs para debugging
      final body = {
        'firstName': nombre,
        'lastName': apellido,
        'email': email,
        'password': password,
        'phone': telefono,
        'addressText': direccionText,
        'latitude': lat,
        'longitude': lng,
      };

      print('URL: $API_BASE_URL/auth/register/client');
      print('Body enviado: ${jsonEncode(body)}');

      final resp = await _client.post(
        Uri.parse('$API_BASE_URL/auth/register/client'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('Status Code: ${resp.statusCode}');
      print('Response Body: ${resp.body}');

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
      print(' Error completo: $e');
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
          'firstName': nombre,
          'email': email,
          'password': password,
          'phone': telefono,
          'locationText': ubicacionText,
          'latitude': lat,
          'longitude': lng,
          'hourlyRate': tarifaHora,
          'serviceIds': serviceIds,
          'experienceYears': int.tryParse(experiencia) ?? 0,
          'description': descripcion,
        }),
      );

      print(' Status: ${resp.statusCode}');
      print(' Response: ${resp.body}');

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        _authToken = data['token'];
        await _secureStorage.write(key: 'auth_token', value: _authToken!);
        return data; // {id_tecnico, token, ...}
      } else if (resp.statusCode == 409) {
        throw Exception('El email ya está registrado.');
      } else {
        throw Exception('Error al registrar: ${resp.statusCode} - ${resp.body}');
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

  /// GET /clients/{id} - Obtener perfil del cliente
  Future<Map<String, dynamic>> getClientProfile(int clientId) async {
    try {
      final token = await getToken();
      print('🔵 Obteniendo perfil del cliente: $clientId');
      
      // Intentar primero con /clients/
      var response = await _client.get(
        Uri.parse('$API_BASE_URL/clients/$clientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(' Status: ${response.statusCode}');
      print(' Response: ${response.body}');

      // Si falla, intentar con /auth/clients/
      if (response.statusCode == 404) {
        print('Endpoint /clients no encontrado, intentando /auth/clients/');
        response = await _client.get(
          Uri.parse('$API_BASE_URL/auth/clients/$clientId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        print(' Status: ${response.statusCode}');
        print(' Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener perfil: ${response.statusCode}');
      }
    } catch (e) {
      print(' Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// PUT /clients/{id} - Actualizar perfil del cliente
  Future<Map<String, dynamic>> updateClientProfile({
    required int clientId,
    required String nombre,
    required String apellido,
    required String email,
    required String telefono,
    required String direccionText,
    required double lat,
    required double lng,
    String? password,
  }) async {
    try {
      final token = await getToken();
      
      final body = {
        'firstName': nombre,
        'lastName': apellido,
        'email': email,
        'phone': telefono,
        'addressText': direccionText,
        'latitude': lat,
        'longitude': lng,
      };
      
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      print('🔵 Actualizando perfil del cliente: $clientId');
      print('🔵 Body: ${jsonEncode(body)}');

      // Intentar primero con /clients/
      var response = await _client.put(
        Uri.parse('$API_BASE_URL/clients/$clientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print(' Status: ${response.statusCode}');
      print(' Response: ${response.body}');

      // Si falla, intentar con /auth/clients/
      if (response.statusCode == 404) {
        print('Endpoint /clients no encontrado, intentando /auth/clients/');
        response = await _client.put(
          Uri.parse('$API_BASE_URL/auth/clients/$clientId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );
        print(' Status: ${response.statusCode}');
        print(' Response: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar perfil: ${response.statusCode}');
      }
    } catch (e) {
      print(' Error: $e');
      throw Exception('Error: $e');
    }
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

  /// GET /technicians/search?q=nombre
  Future<List<Map<String, dynamic>>> searchTechnicians(String query) async {
    try {
      final params = <String, String>{'q': query};
      final uri = Uri.parse('$API_BASE_URL/technicians/search').replace(queryParameters: params);
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al buscar técnicos: ${response.statusCode}');
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
    int? idTecnico,
    required int idServicio,
    required String detalles,
    DateTime? fechaProgramada,
  }) async {
    try {
      final token = await getToken();
      
      print('🔵 Creando contratación: cliente=$idCliente, técnico=$idTecnico, servicio=$idServicio');
      
      final response = await _client.post(
        Uri.parse('$API_BASE_URL/contractions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'clientId': idCliente,
          'technicianId': idTecnico,
          'serviceId': idServicio,
          'description': detalles,
          'scheduledDate': fechaProgramada?.toIso8601String(),
        }),
      );

      print('🔴 Status: ${response.statusCode}');
      print('🔴 Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al crear contratación: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error: $e');
    }
  }

  /// GET /contractions/client/{clientId}
  Future<List<Map<String, dynamic>>> getClientContractations(int idCliente) async {
    try {
      final token = await getToken();
      final response = await _client.get(
        Uri.parse('$API_BASE_URL/contractions/client/$idCliente'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener contrataciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// GET /contractions/technician/{technicianId}
  Future<List<Map<String, dynamic>>> getTechnicianContractations(int idTecnico) async {
    try {
      final token = await getToken();
      final response = await _client.get(
        Uri.parse('$API_BASE_URL/contractions/technician/$idTecnico'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener contrataciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// PUT /contractations/{id}/status
  Future<Map<String, dynamic>> updateContractationStatus(int idContratacion, String estado) async {
    try {
      final token = await getToken();
      
      print('🔵 Actualizando contratación $idContratacion a estado: $estado');
      
      final response = await _client.put(
        Uri.parse('$API_BASE_URL/contractions/$idContratacion/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': estado}),
      );

      print('🔴 Status: ${response.statusCode}');
      print('🔴 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Error: $e');
    }
  }

  /// GET /contractions/{id}
  Future<Map<String, dynamic>> getContractation(int id) async {
    try {
      final token = await getToken();
      final response = await _client.get(
        Uri.parse('$API_BASE_URL/contractions/$id'),
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
          'idContratacion': idContratacion, 
          'idTecnico': idTecnico, 
          'puntuacion': puntuacion,
          'comentario': comentario,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        String body = response.body;
        try {
          final parsed = jsonDecode(response.body);
          if (parsed is Map && parsed.containsKey('error')) body = parsed['error'].toString();
        } catch (_) {}
        throw Exception('Error al guardar calificación: ${response.statusCode} - $body');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ==================== TECHNICIANS PROFILE ====================

  /// GET /technicians/{id} - Obtener perfil del técnico
  Future<Map<String, dynamic>> getTechnicianProfile(int technicianId) async {
    try {
      final token = await getToken();
      print('🔵 Obteniendo perfil del técnico: $technicianId');
      
      // Intentar primero con /technicians/
      var response = await _client.get(
        Uri.parse('$API_BASE_URL/technicians/$technicianId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(' Status: ${response.statusCode}');
      print(' Response: ${response.body}');

      // Si falla, intentar con /auth/technicians/
      if (response.statusCode == 404) {
        print(' Endpoint /technicians no encontrado, intentando /auth/technicians/');
        response = await _client.get(
          Uri.parse('$API_BASE_URL/auth/technicians/$technicianId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        print(' Status: ${response.statusCode}');
        print(' Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener perfil: ${response.statusCode}');
      }
    } catch (e) {
      print(' Error: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// PUT /technicians/{id} - Actualizar perfil del técnico
  Future<Map<String, dynamic>> updateTechnicianProfile({
    required int technicianId,
    required String nombre,
    required String email,
    required String telefono,
    required String ubicacionText,
    required double lat,
    required double lng,
    required double tarifaHora,
    required String experiencia,
    required String descripcion,
    String? password,
  }) async {
    try {
      final token = await getToken();
      
      final body = {
        'firstName': nombre,
        'email': email,
        'phone': telefono,
        'locationText': ubicacionText,
        'latitude': lat,
        'longitude': lng,
        'hourlyRate': tarifaHora,
        'experienceYears': int.tryParse(experiencia) ?? 0,
        'description': descripcion,
      };
      
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }

      print(' Actualizando perfil del técnico: $technicianId');
      print(' Body: ${jsonEncode(body)}');

      // Intentar primero con /technicians/
      var response = await _client.put(
        Uri.parse('$API_BASE_URL/technicians/$technicianId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print(' Status: ${response.statusCode}');
      print(' Response: ${response.body}');

      // Si falla, intentar con /auth/technicians/
      if (response.statusCode == 404) {
        print(' Endpoint /technicians no encontrado, intentando /auth/technicians/');
        response = await _client.put(
          Uri.parse('$API_BASE_URL/auth/technicians/$technicianId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );
        print(' Status: ${response.statusCode}');
        print(' Response: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar perfil: ${response.statusCode}');
      }
    } catch (e) {
      print(' Error: $e');
      throw Exception('Error: $e');
    }
  }

  /// POST /technicians/{id}/services - Actualizar servicios del técnico
  Future<Map<String, dynamic>> updateTechnicianServices({
    required int technicianId,
    required List<int> serviceIds,
  }) async {
    try {
      final token = await getToken();
      
      final response = await _client.post(
        Uri.parse('$API_BASE_URL/technicians/$technicianId/services'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'serviceIds': serviceIds,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar servicios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

