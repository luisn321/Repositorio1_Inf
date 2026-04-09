import 'package:http/http.dart' as http;
import 'dart:convert';
import '../modelos/usuario_modelo.dart';
import '../modelos/solicitud_autenticacion_modelo.dart';
import '../modelos/respuesta_autenticacion_modelo.dart';
import '../modelos/solicitud_registro_cliente_modelo.dart';
import '../modelos/solicitud_registro_tecnico_modelo.dart';
import '../almacenamiento/almacenamiento_seguro_servicio.dart';

/// Servicio para manejar autenticación (login y registro)
class ServicioAutenticacion {
  static const String _urlBase = 'http://10.0.2.2:3000/api/auth';

  final _almacenamientoSeguro = AlmacenamientoSeguroServicio();

  /// Inicia sesión con correo y contraseña
  /// Retorna [UsuarioModelo] con todos los datos del usuario
  /// Lanza excepción si falla
  Future<UsuarioModelo> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      print('🔐 Iniciando sesión con: $correo');

      final solicitud = SolicitudAutenticacionModelo(
        correo: correo,
        contrasena: contrasena,
      );

      final respuesta = await http.post(
        Uri.parse('$_urlBase/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(solicitud.aJson()),
      );

      print('📡 Respuesta del servidor: ${respuesta.statusCode}');
      print('📄 Body: ${respuesta.body}');

      if (respuesta.statusCode == 200) {
        final dato = jsonDecode(respuesta.body);
        final respuestaAuth = RespuestaAutenticacionModelo.desdeJson(dato);

        // Guardar token y datos del usuario
        await _almacenamientoSeguro.guardarToken(respuestaAuth.token);
        await _almacenamientoSeguro.guardarDatosUsuario(
          usuarioId: respuestaAuth.usuarioId,
          nombre: respuestaAuth.nombre,
          tipoUsuario: respuestaAuth.tipoUsuario,
          correo: respuestaAuth.correo,
        );

        print('✅ Sesión iniciada. Obteniendo datos completos del usuario...');
        
        // Obtener datos completos del usuario
        final usuarioCompleto = await _obtenerDatosPerfilCompleto(respuestaAuth.token);
        
        return usuarioCompleto;
      } else if (respuesta.statusCode == 400) {
        final error = jsonDecode(respuesta.body);
        throw Exception(error['error'] ?? 'Error al iniciar sesión');
      } else {
        throw Exception('Error del servidor: ${respuesta.statusCode}');
      }
    } catch (e) {
      print('❌ Error en iniciarSesion: $e');
      rethrow;
    }
  }

  /// Obtiene los datos completos del perfil del usuario autenticado
  Future<UsuarioModelo> _obtenerDatosPerfilCompleto(String token) async {
    try {
      final respuesta = await http.get(
        Uri.parse('$_urlBase/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📡 Respuesta perfil completo: ${respuesta.statusCode}');
      print('📄 Body: ${respuesta.body}');

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        print('✅ Datos completos obtenidos: $datos');
        return UsuarioModelo.desdeJson(datos);
      } else {
        throw Exception('Error al obtener perfil: ${respuesta.statusCode}');
      }
    } catch (e) {
      print('❌ Error obteniendo perfil completo: $e');
      rethrow;
    }
  }

  /// Registra un cliente nuevo
  /// Retorna [UsuarioModelo] si tiene éxito
  Future<UsuarioModelo> registrarCliente(
    SolicitudRegistroClienteModelo solicitud,
  ) async {
    try {
      print('📍 Registrando nuevo cliente: ${solicitud.correo}');

      final respuesta = await http.post(
        Uri.parse('$_urlBase/register/client'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(solicitud.aJson()),
      );

      print('📡 Respuesta del servidor: ${respuesta.statusCode}');
      print('📄 Body: ${respuesta.body}');

      if (respuesta.statusCode == 200) {
        final dato = jsonDecode(respuesta.body);
        final respuestaAuth = RespuestaAutenticacionModelo.desdeJson(dato);

        // Guardar token y datos del usuario
        await _almacenamientoSeguro.guardarToken(respuestaAuth.token);
        await _almacenamientoSeguro.guardarDatosUsuario(
          usuarioId: respuestaAuth.usuarioId,
          nombre: respuestaAuth.nombre,
          tipoUsuario: respuestaAuth.tipoUsuario,
          correo: respuestaAuth.correo,
        );

        print('✅ Cliente registrado exitosamente');
        return UsuarioModelo(
          id: respuestaAuth.usuarioId,
          nombre: respuestaAuth.nombre,
          apellido: solicitud.apellido,
          correo: respuestaAuth.correo,
          tipoUsuario: respuestaAuth.tipoUsuario,
          telefono: solicitud.telefono,
          latitud: solicitud.latitud,
          longitud: solicitud.longitud,
        );
      } else if (respuesta.statusCode == 400) {
        final error = jsonDecode(respuesta.body);
        throw Exception(error['error'] ?? 'Error al registrar cliente');
      } else {
        throw Exception('Error del servidor: ${respuesta.statusCode}');
      }
    } catch (e) {
      print('❌ Error en registrarCliente: $e');
      rethrow;
    }
  }

  /// Registra un técnico nuevo
  /// Retorna [UsuarioModelo] si tiene éxito
  Future<UsuarioModelo> registrarTecnico(
    SolicitudRegistroTecnicoModelo solicitud,
  ) async {
    try {
      print('📍 Registrando nuevo técnico: ${solicitud.correo}');

      final respuesta = await http.post(
        Uri.parse('$_urlBase/register/technician'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(solicitud.aJson()),
      );

      print('📡 Respuesta del servidor: ${respuesta.statusCode}');
      print('📄 Body: ${respuesta.body}');

      if (respuesta.statusCode == 200) {
        final dato = jsonDecode(respuesta.body);
        final respuestaAuth = RespuestaAutenticacionModelo.desdeJson(dato);

        // Guardar token y datos del usuario
        await _almacenamientoSeguro.guardarToken(respuestaAuth.token);
        await _almacenamientoSeguro.guardarDatosUsuario(
          usuarioId: respuestaAuth.usuarioId,
          nombre: respuestaAuth.nombre,
          tipoUsuario: respuestaAuth.tipoUsuario,
          correo: respuestaAuth.correo,
        );

        print('✅ Técnico registrado exitosamente');
        return UsuarioModelo(
          id: respuestaAuth.usuarioId,
          nombre: respuestaAuth.nombre,
          apellido: '',
          correo: respuestaAuth.correo,
          tipoUsuario: respuestaAuth.tipoUsuario,
          telefono: solicitud.telefono,
          latitud: solicitud.latitud,
          longitud: solicitud.longitud,
          tarifaHora: solicitud.tarifaHora,
        );
      } else if (respuesta.statusCode == 400) {
        final error = jsonDecode(respuesta.body);
        throw Exception(error['error'] ?? 'Error al registrar técnico');
      } else {
        throw Exception('Error del servidor: ${respuesta.statusCode}');
      }
    } catch (e) {
      print('❌ Error en registrarTecnico: $e');
      rethrow;
    }
  }

  /// Obtiene el usuario autenticado actual (desde almacenamiento local)
  Future<UsuarioModelo?> obtenerUsuarioActual() async {
    try {
      final usuarioId = await _almacenamientoSeguro.obtenerUsuarioId();
      final nombre = await _almacenamientoSeguro.obtenerNombreUsuario();
      final tipoUsuario = await _almacenamientoSeguro.obtenerTipoUsuario();
      final correo = await _almacenamientoSeguro.obtenerCorreoUsuario();

      if (usuarioId == null || nombre == null || tipoUsuario == null || correo == null) {
        return null; // No hay usuario autenticado
      }

      return UsuarioModelo(
        id: usuarioId,
        nombre: nombre,
        apellido: '',
        correo: correo,
        tipoUsuario: tipoUsuario,
        telefono: '',
        latitud: 0,
        longitud: 0,
      );
    } catch (e) {
      print('Error obteniendo usuario actual: $e');
      return null;
    }
  }

  /// Cierra sesión (elimina token y datos locales)
  Future<void> cerrarSesion() async {
    try {
      print('📍 Cerrando sesión...');
      await _almacenamientoSeguro.limpiar();
      print('✅ Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      rethrow;
    }
  }

  /// Obtiene el token de autenticación actual
  Future<String?> obtenerToken() async {
    try {
      return await _almacenamientoSeguro.obtenerToken();
    } catch (e) {
      print('Error obteniendo token: $e');
      return null;
    }
  }

  /// Actualiza el perfil del usuario
  /// Solo actualiza los campos que se pasan
  /// Retorna el perfil completo actualizado
  Future<UsuarioModelo> actualizarPerfil({
    required int usuarioId,
    required bool esTecnico,
    String? nombre,
    String? apellido,
    String? correo,
    String? telefono,
    String? ubicacion,
    double? tarifa,
    String? descripcion,
    int? anosExperiencia,
    String? contrasenaActual,
    String? contrasenaNueva,
    String? fotoPerfilUrl,
  }) async {
    try {
      print('🔄 Actualizando perfil del usuario $usuarioId...');

      final token = await _almacenamientoSeguro.obtenerToken();
      if (token == null) {
        throw Exception('No hay token disponible');
      }

      final endpoint = esTecnico ? 'technician' : 'client';
      final datos = {
        'id': usuarioId,
        if (nombre != null) 'nombre': nombre,
        if (apellido != null) 'apellido': apellido,
        if (correo != null) 'correo': correo,
        if (telefono != null) 'telefono': telefono,
        if (ubicacion != null) 'ubicacion': ubicacion,
        if (tarifa != null) 'tarifaHora': tarifa,
        if (descripcion != null) 'descripcion': descripcion,
        if (anosExperiencia != null) 'anosExperiencia': anosExperiencia,
        if (contrasenaActual != null) 'contrasenaActual': contrasenaActual,
        if (contrasenaNueva != null) 'contrasenaNueva': contrasenaNueva,
        if (fotoPerfilUrl != null) 'fotoPerfilUrl': fotoPerfilUrl,
      };

      final respuesta = await http.put(
        Uri.parse('$_urlBase/update-profile/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(datos),
      );

      print('📡 Respuesta actualización: ${respuesta.statusCode}');
      print('📄 Body: ${respuesta.body}');

      if (respuesta.statusCode == 200) {
        print('✅ Perfil actualizado. Obteniendo datos completos...');
        
        // Obtener datos completos del usuario actualizado
        final usuarioCompleto = await _obtenerDatosPerfilCompleto(token);
        return usuarioCompleto;
      } else {
        throw Exception('Error al actualizar perfil: ${respuesta.body}');
      }
    } catch (e) {
      print('❌ Error actualizando perfil: $e');
      rethrow;
    }
  }

  /// Verifica si existe un usuario autenticado
  Future<bool> estasAutenticado() async {
    try {
      return await _almacenamientoSeguro.existeUsuarioAutenticado();
    } catch (e) {
      print('Error verificando autenticación: $e');
      return false;
    }
  }
}
