import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para almacenar datos sensibles de forma segura (token, datos de usuario)
class AlmacenamientoSeguroServicio {
  static const String _claveToken = 'token_autenticacion';
  static const String _claveUsuarioId = 'usuario_id';
  static const String _claveNombreUsuario = 'nombre_usuario';
  static const String _claveTipoUsuario = 'tipo_usuario';
  static const String _claveCorreoUsuario = 'correo_usuario';
  static const String _claveFotoPerfilUrl = 'foto_perfil_url';

  final _almacenamiento = const FlutterSecureStorage();

  /// Guarda el token de autenticación
  Future<void> guardarToken(String token) async {
    try {
      await _almacenamiento.write(key: _claveToken, value: token);
    } catch (e) {
      print('Error guardando token: $e');
      rethrow;
    }
  }

  /// Obtiene el token de autenticación guardado
  Future<String?> obtenerToken() async {
    try {
      return await _almacenamiento.read(key: _claveToken);
    } catch (e) {
      print('Error obteniendo token: $e');
      return null;
    }
  }

  /// Guarda datos del usuario autenticado
  Future<void> guardarDatosUsuario({
    required int usuarioId,
    required String nombre,
    required String tipoUsuario,
    required String correo,
    String? fotoPerfilUrl,
  }) async {
    try {
      await Future.wait([
        _almacenamiento.write(key: _claveUsuarioId, value: usuarioId.toString()),
        _almacenamiento.write(key: _claveNombreUsuario, value: nombre),
        _almacenamiento.write(key: _claveTipoUsuario, value: tipoUsuario),
        _almacenamiento.write(key: _claveCorreoUsuario, value: correo),
        if (fotoPerfilUrl != null)
          _almacenamiento.write(key: _claveFotoPerfilUrl, value: fotoPerfilUrl),
      ]);
    } catch (e) {
      print('Error guardando datos de usuario: $e');
      rethrow;
    }
  }

  /// Obtiene el ID del usuario autenticado
  Future<int?> obtenerUsuarioId() async {
    try {
      final id = await _almacenamiento.read(key: _claveUsuarioId);
      return id != null ? int.parse(id) : null;
    } catch (e) {
      print('Error obteniendo usuario ID: $e');
      return null;
    }
  }

  /// Obtiene el nombre del usuario autenticado
  Future<String?> obtenerNombreUsuario() async {
    try {
      return await _almacenamiento.read(key: _claveNombreUsuario);
    } catch (e) {
      print('Error obteniendo nombre: $e');
      return null;
    }
  }

  /// Obtiene el tipo de usuario (cliente o tecnico)
  Future<String?> obtenerTipoUsuario() async {
    try {
      return await _almacenamiento.read(key: _claveTipoUsuario);
    } catch (e) {
      print('Error obteniendo tipo usuario: $e');
      return null;
    }
  }

  /// Obtiene el correo del usuario autenticado
  Future<String?> obtenerCorreoUsuario() async {
    try {
      return await _almacenamiento.read(key: _claveCorreoUsuario);
    } catch (e) {
      print('Error obteniendo correo: $e');
      return null;
    }
  }

  /// Obtiene la URL de la foto de perfil
  Future<String?> obtenerFotoPerfilUrl() async {
    try {
      return await _almacenamiento.read(key: _claveFotoPerfilUrl);
    } catch (e) {
      print('Error obteniendo foto perfil: $e');
      return null;
    }
  }

  /// Elimina TODOS los datos guardados (logout)
  Future<void> limpiar() async {
    try {
      await _almacenamiento.deleteAll();
    } catch (e) {
      print('Error limpiando almacenamiento: $e');
      rethrow;
    }
  }

  /// Verifica si existe un token válido (usuario autenticado)
  Future<bool> existeUsuarioAutenticado() async {
    try {
      final token = await obtenerToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error verificando autenticación: $e');
      return false;
    }
  }
}
