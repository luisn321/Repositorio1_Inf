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
  /// Retorna [UsuarioModelo] si tiene éxito
  /// Lanza excepción si falla
  Future<UsuarioModelo> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      print('📍 Iniciando sesión con: $correo');

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

        print('✅ Sesión iniciada exitosamente');
        return UsuarioModelo(
          id: respuestaAuth.usuarioId,
          nombre: respuestaAuth.nombre,
          apellido: '',
          correo: respuestaAuth.correo,
          tipoUsuario: respuestaAuth.tipoUsuario,
          telefono: '',
          latitud: respuestaAuth.latitud ?? 0,
          longitud: respuestaAuth.longitud ?? 0,
        );
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
