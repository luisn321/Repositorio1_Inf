import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../modelos/contratacion_modelo.dart';
import '../modelos/calificacion_modelo.dart';
import '../almacenamiento/almacenamiento_seguro_servicio.dart';

const String _urlBase = 'http://10.0.2.2:3000/api';

class ServicioContrataciones {
  final AlmacenamientoSeguroServicio _almacenamiento =
      AlmacenamientoSeguroServicio();

  /// Obtiene todas las contrataciones del usuario
  Future<List<ContratacionModelo>> obtenerTodasLasContrataciones() async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint(' [ServicioContrataciones] GET $_urlBase/contractions');

      final respuesta = await http
          .get(
            Uri.parse('$_urlBase/contractions'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final contrataciones = datos
            .map((cont) => ContratacionModelo.desdeJson(cont))
            .toList();
        debugPrint(' Obtenidas ${contrataciones.length} contrataciones');
        return contrataciones;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en obtenerTodasLasContrataciones: $e');
      rethrow;
    }
  }

  /// Obtiene una contratación específica por ID
  Future<ContratacionModelo?> obtenerContratacionPorId(
    int idContratacion,
  ) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint(
        '📡 [ServicioContrataciones] GET $_urlBase/contractions/$idContratacion',
      );

      final respuesta = await http
          .get(
            Uri.parse('$_urlBase/contractions/$idContratacion'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint('✅ Contratación obtenida: $idContratacion');
        return contratacion;
      } else {
        debugPrint(' Status code: ${respuesta.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint(' Error en obtenerContratacionPorId: $e');
      rethrow;
    }
  }

  /// Obtiene contrataciones por estado
  Future<List<ContratacionModelo>> obtenerContratacionesPorEstado(
    String estado,
  ) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final url = '$_urlBase/contractions?status=$estado';
      debugPrint(' [ServicioContrataciones] GET $url');

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
        final contrataciones = datos
            .map((cont) => ContratacionModelo.desdeJson(cont))
            .toList();
        debugPrint(
          ' Obtenidas ${contrataciones.length} contrataciones con estado $estado',
        );
        return contrataciones;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en obtenerContratacionesPorEstado: $e');
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

      debugPrint(
        ' [ServicioContrataciones] GET $_urlBase/contractions/pending',
      );

      final respuesta = await http
          .get(
            Uri.parse('$_urlBase/contractions/pending'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        debugPrint('📦 RESPUESTA CLIENTE: $datos');
        final contrataciones = datos.map((cont) {
          debugPrint(
            '   └─ Solicitud ${cont['IdContratacion']}: HoraSolicitada=${cont['HoraSolicitada']}, Ubicacion=${cont['Ubicacion']}',
          );
          return ContratacionModelo.desdeJson(cont);
        }).toList();
        debugPrint(
          '✅ Obtenidas ${contrataciones.length} contrataciones pendientes',
        );
        return contrataciones;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en obtenerContratacionesPendientes: $e');
      rethrow;
    }
  }

  /// Crea una nueva contratación/solicitud de servicio
  Future<ContratacionModelo> crearContratacion({
    required int idCliente,
    int? idTecnico, // ✨ Técnico al que se dirige la solicitud
    required int idServicio,
    required String descripcion,
    required DateTime fechaEstimada,
    TimeOfDay? horaSolicitada, // ✨ Hora solicitada por el cliente
    String? ubicacion,
  }) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      final payload = {
        'idCliente': idCliente,
        if (idTecnico != null)
          'idTecnico': idTecnico, // ✨ Sólo si hay técnico asignado
        'idServicio': idServicio,
        'descripcion': descripcion,
        'fechaEstimada': fechaEstimada.toIso8601String(),
        if (horaSolicitada != null)
          'horaSolicitada':
              '${horaSolicitada.hour.toString().padLeft(2, '0')}:${horaSolicitada.minute.toString().padLeft(2, '0')}',
        if (ubicacion != null) 'ubicacion': ubicacion,
      };

      debugPrint('📡 [ServicioContrataciones] POST $_urlBase/contractions');
      debugPrint('📦 Payload: $payload');

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 201 || respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        debugPrint(' RESPUESTA COMPLETA DEL BACKEND: $datos');
        debugPrint('   ├─ HoraSolicitada: ${datos['HoraSolicitada']}');
        debugPrint('   ├─ Ubicacion: ${datos['Ubicacion']}');
        debugPrint('   ├─ NombreCliente: ${datos['NombreCliente']}');
        debugPrint('   └─ Descripcion: ${datos['Descripcion']}');
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint(' Contratación creada: ${contratacion.idContratacion}');
        debugPrint(
          '   ├─ horaSolicitadaStr: ${contratacion.horaSolicitadaStr}',
        );
        debugPrint('   ├─ ubicacion: ${contratacion.ubicacion}');
        debugPrint('   └─ nombreCliente: ${contratacion.nombreCliente}');
        return contratacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en crearContratacion: $e');
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

      debugPrint(
        '[ServicioContrataciones] PUT $_urlBase/contractions/$idContratacion',
      );
      debugPrint(' Payload: $payload');

      final respuesta = await http
          .put(
            Uri.parse('$_urlBase/contractions/$idContratacion'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint('Estado actualizado: $nuevoEstado');
        return contratacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint('Error en actualizarEstadoContratacion: $e');
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

      debugPrint(
        '📡 [ServicioContrataciones] POST $_urlBase/contractions/$idContratacion/assign',
      );
      debugPrint(' Body: $payload');

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idContratacion/assign'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint(' Técnico asignado: $idTecnico');
        return contratacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en asignarTecnico: $e');
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

      debugPrint(
        ' [ServicioContrataciones] POST $_urlBase/contractions/$idContratacion/complete',
      );

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idContratacion/complete'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint('Contratación completada: $idContratacion');
        return contratacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en completarContratacion: $e');
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

      debugPrint(
        ' [ServicioContrataciones] POST $_urlBase/contractions/$idContratacion/cancel',
      );

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idContratacion/cancel'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final contratacion = ContratacionModelo.desdeJson(datos);
        debugPrint(' Contratación cancelada: $idContratacion');
        return contratacion;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en cancelarContratacion: $e');
      rethrow;
    }
  }

  /// CLIENTE: Obtiene mis solicitudes creadas
  Future<List<ContratacionModelo>> obtenerMisSolicitudes(int idCliente) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint(
        ' [ServicioContrataciones] GET $_urlBase/contractions/client/$idCliente',
      );

      final respuesta = await http
          .get(
            Uri.parse('$_urlBase/contractions/client/$idCliente'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        debugPrint(' RESPUESTA CLIENTE (${datos.length} items):');
        final solicitudes = datos.map((sol) {
          debugPrint(
            '    Solicitud ${sol['idContratacion']}: hora=${sol['horaSolicitada']}, ubicacion=${sol['ubicacion']}, cliente=${sol['nombreCliente']}',
          );
          return ContratacionModelo.desdeJson(sol);
        }).toList();
        debugPrint(
          ' Obtenidas ${solicitudes.length} solicitudes del cliente $idCliente',
        );
        for (var s in solicitudes) {
          debugPrint(
            '   ✓ ID ${s.idContratacion}: hora=${s.horaSolicitadaStr}, ubicacion=${s.ubicacion}, cliente=${s.nombreCliente}',
          );
        }
        return solicitudes;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en obtenerMisSolicitudes: $e');
      rethrow;
    }
  }

  /// TÉCNICO: Obtiene mis contratos asignados
  Future<List<ContratacionModelo>> obtenerMisContratos(int idTecnico) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint(
        ' [ServicioContrataciones] GET $_urlBase/contractions/technician/$idTecnico',
      );

      final respuesta = await http
          .get(
            Uri.parse('$_urlBase/contractions/technician/$idTecnico'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body) as List;
        final contratos = datos
            .map((cont) => ContratacionModelo.desdeJson(cont))
            .toList();
        debugPrint(
          '✅ Obtenidos ${contratos.length} contratos del técnico $idTecnico',
        );
        return contratos;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en obtenerMisContratos: $e');
      rethrow;
    }
  }

  //  Para flujo de aceptación/rechazo
  /// TÉCNICO: Rechaza una solicitud
  Future<bool> rechazarSolicitud(int idSolicitud, String motivo) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint(
        '📡 [ServicioContrataciones] POST $_urlBase/contractions/$idSolicitud/reject',
      );

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idSolicitud/reject'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'motivo': motivo}),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        debugPrint(' Solicitud rechazada: $idSolicitud');
        return true;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en rechazarSolicitud: $e');
      rethrow;
    }
  }

  /// TÉCNICO: Acepta una solicitud
  Future<bool> aceptarSolicitud(int idSolicitud, int idTecnico) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint(
        ' [ServicioContrataciones] POST $_urlBase/contractions/$idSolicitud/accept',
      );

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idSolicitud/accept'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'idTecnico': idTecnico}),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        debugPrint(' Solicitud aceptada: $idSolicitud');
        return true;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en aceptarSolicitud: $e');
      rethrow;
    }
  }

  /// TÉCNICO: Propone una alternativa (fecha, hora, motivo diferente) (PARTE 1)
  Future<bool> proponerPropuesta(
    int idSolicitud, {
    required DateTime fechaPropuestaSolicitada,
    required String horaPropuestaSolicitada, // Formato "HH:mm"
    required String motivoCambio,
  }) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      debugPrint(
        '📡 [ServicioContrataciones] POST $_urlBase/contractions/$idSolicitud/propose-propuesta',
      );
      debugPrint('   ├─ fechaPropuestaSolicitada: $fechaPropuestaSolicitada');
      debugPrint('   ├─ horaPropuestaSolicitada: $horaPropuestaSolicitada');
      debugPrint('   └─ motivoCambio: $motivoCambio');

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idSolicitud/propose-propuesta'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'fechaPropuestaSolicitada': fechaPropuestaSolicitada
                  .toIso8601String(),
              'horaPropuestaSolicitada': horaPropuestaSolicitada,
              'motivoCambio': motivoCambio,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        debugPrint(
          ' Propuesta alternativa enviada para solicitud $idSolicitud',
        );
        return true;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en proponerPropuesta: $e');
      rethrow;
    }
  }

  /// TÉCNICO: Propone un monto para la solicitud (PARTE 2)
  Future<bool> proponerMonto(int idSolicitud, double monto, {String? clabeTecnico}) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) {
        throw Exception('No authorization token found');
      }

      // Validar monto
      if (monto <= 0) {
        throw Exception('El monto debe ser mayor a 0');
      }

      debugPrint(
        ' [ServicioContrataciones] POST $_urlBase/contractions/$idSolicitud/propose-amount (monto: \$$monto)',
      );

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idSolicitud/propose-amount'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'monto': monto,
              if (clabeTecnico != null) 'clabeTecnico': clabeTecnico,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        debugPrint('Monto propuesto: \$$monto para solicitud $idSolicitud');
        return true;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en proponerMonto: $e');
      rethrow;
    }
  }

  /// CLIENTE: Acepta el monto propuesto por el técnico → cambia a 'En Progreso'
  Future<bool> aceptarMonto(int idSolicitud) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      debugPrint(
        '📡 [ServicioContrataciones] POST $_urlBase/contractions/$idSolicitud/accept-amount',
      );

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idSolicitud/accept-amount'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        debugPrint(' Monto aceptado para solicitud $idSolicitud → En Progreso');
        return true;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en aceptarMonto: $e');
      rethrow;
    }
  }

  /// CLIENTE: Rechaza el monto propuesto por el técnico (puede pedir otro)
  Future<bool> rechazarMonto(int idSolicitud, {String? motivo}) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      debugPrint(
        ' [ServicioContrataciones] POST $_urlBase/contractions/$idSolicitud/reject-amount',
      );

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idSolicitud/reject-amount'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'motivo': motivo ?? 'Monto rechazado por el cliente',
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        debugPrint(' Monto rechazado para solicitud $idSolicitud');
        return true;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en rechazarMonto: $e');
      rethrow;
    }
  }

  //Registrar pago completado
  Future<bool> registrarPago(
    int idSolicitud,
    double monto,
    String numeroTarjeta,
  ) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      debugPrint(' [ServicioContrataciones] POST $_urlBase/payments');

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/payments'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'idContratacion': idSolicitud,
              'monto': monto,
              'metodoPago': 'Tarjeta de Crédito',
              'transactionRef':
                  'TRANS_${DateTime.now().millisecondsSinceEpoch}_${numeroTarjeta.substring(numeroTarjeta.length - 4)}',
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        debugPrint('✅ Pago registrado para solicitud $idSolicitud');
        return true;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en registrarPago: $e');
      rethrow;
    }
  }

  //  Técnico marca solicitud como completada
  Future<bool> marcarCompletada(int idSolicitud) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      debugPrint(
        ' [ServicioContrataciones] POST $_urlBase/contractions/$idSolicitud/complete',
      );

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idSolicitud/complete'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        debugPrint(' Solicitud $idSolicitud marcada como completada');
        return true;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en marcarCompletada: $e');
      rethrow;
    }
  }

  //Calificar servicio del técnico
  Future<bool> calificarTecnico(
    int idContratacion,
    int idTecnico,
    int puntuacion,
    String comentario,
    String? fotosResenaUrls,
  ) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      debugPrint(' [ServicioContrataciones] POST $_urlBase/ratings');

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/ratings'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'idContratacion': idContratacion,
              'idTecnico': idTecnico,
              'puntuacion': puntuacion,
              'comentario': comentario,
              'fotosResenaUrls': fotosResenaUrls,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        debugPrint(' Calificación enviada para solicitud $idContratacion');
        return true;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en calificarTecnico: $e');
      rethrow;
    }
  }

  //  Para aceptar/rechazar propuestas alternativas
  Future<bool> aceptarPropuesta(int idSolicitud) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      debugPrint(
        '[ServicioContrataciones] POST $_urlBase/contractions/$idSolicitud/accept-propuesta',
      );

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idSolicitud/accept-propuesta'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      return respuesta.statusCode == 200;
    } catch (e) {
      debugPrint(' Error en aceptarPropuesta: $e');
      rethrow;
    }
  }

  Future<bool> rechazarPropuesta(int idSolicitud) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      debugPrint(
        '📡 [ServicioContrataciones] POST $_urlBase/contractions/$idSolicitud/reject-propuesta',
      );

      final respuesta = await http
          .post(
            Uri.parse('$_urlBase/contractions/$idSolicitud/reject-propuesta'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      return respuesta.statusCode == 200;
    } catch (e) {
      debugPrint('Error en rechazarPropuesta: $e');
      rethrow;
    }
  }

  // Gestión de servicios del técnico
  /// Obtiene los servicios actuales de un técnico
  Future<List<int>> obtenerServiciosConfigurados(int idTecnico) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      debugPrint(
        '[ServicioContrataciones] GET $_urlBase/technicians/$idTecnico',
      );

      final respuesta = await http
          .get(
            Uri.parse('$_urlBase/technicians/$idTecnico'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        final servicios =
            (datos['Servicios'] ?? datos['servicios']) as List? ?? [];

        final List<int> ids = [];
        for (var s in servicios) {
          final id = s['IdServicio'] ?? s['idServicio'] ?? s['id_servicio'];
          if (id != null) ids.add(int.parse(id.toString()));
        }

        debugPrint(' Servicios configurados para técnico $idTecnico: $ids');
        return ids;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint('Error en obtenerServiciosConfigurados: $e');
      rethrow;
    }
  }

  /// Actualiza la lista de servicios que ofrece un técnico
  Future<bool> actualizarServiciosConfigurados(
    int idTecnico,
    List<int> serviceIds,
  ) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      debugPrint(
        '📡 [ServicioContrataciones] PUT $_urlBase/technicians/$idTecnico/services',
      );
      debugPrint(' Body: $serviceIds');

      final respuesta = await http
          .put(
            Uri.parse('$_urlBase/technicians/$idTecnico/services'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(serviceIds),
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        debugPrint(
          ' Servicios actualizados exitosamente para técnico $idTecnico',
        );
        return true;
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en actualizarServiciosConfigurados: $e');
      rethrow;
    }
  }

  /// Obtiene las reseñas (comentarios/estrellas) de un técnico
  Future<List<CalificacionModelo>> obtenerResenasTecnico(int idTecnico) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      debugPrint(
        '[ServicioContrataciones] GET $_urlBase/ratings/technician/$idTecnico',
      );

      final respuesta = await http
          .get(
            Uri.parse('$_urlBase/ratings/technician/$idTecnico'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) {
        final List<dynamic> datos = json.decode(respuesta.body);
        return datos.map((r) => CalificacionModelo.desdeJson(r)).toList();
      } else {
        throw Exception('Error ${respuesta.statusCode}: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en obtenerResenasTecnico: $e');
      rethrow;
    }
  }

  // ✨ NUEVO: STRIPE METHODS ✨

  Future<Map<String, dynamic>> crearPaymentIntent(int idContratacion) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('No authorization token found');

      final respuesta = await http.post(
        Uri.parse('$_urlBase/contractions/$idContratacion/create-payment-intent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print("Response crear intent ${respuesta.statusCode}: ${respuesta.body}");
      if (respuesta.statusCode == 200) {
        return json.decode(respuesta.body);
      } else {
        throw Exception('Error al crear pago: ${respuesta.body}');
      }
    } catch (e) {
      debugPrint(' Error en crearPaymentIntent: $e');
      rethrow;
    }
  }

  Future<bool> confirmarPago(int idContratacion) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('Token no encontrado');

      final respuesta = await http.post(
        Uri.parse('$_urlBase/contractions/$idContratacion/confirm-payment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) return true;
      throw Exception('Error al confirmar pago en backend: ${respuesta.body}');
    } catch (e) {
      return false;
    }
  }

  Future<bool> verificarCompletado(int idContratacion) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('Token no encontrado');

      final respuesta = await http.post(
        Uri.parse('$_urlBase/contractions/$idContratacion/verify-completion'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) return true;
      throw Exception('Error al liberar pago: ${respuesta.body}');
    } catch (e) {
      return false;
    }
  }

  Future<bool> reembolsarPago(int idContratacion) async {
    try {
      final token = await _almacenamiento.obtenerToken();
      if (token == null) throw Exception('Token no encontrado');

      final respuesta = await http.post(
        Uri.parse('$_urlBase/contractions/$idContratacion/refund'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (respuesta.statusCode == 200) return true;
      throw Exception('Error al reembolsar pago: ${respuesta.body}');
    } catch (e) {
      return false;
    }
  }
}
