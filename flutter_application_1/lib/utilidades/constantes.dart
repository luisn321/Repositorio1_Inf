/// Constantes de la aplicación Servitec
class ConstantesAplicacion {
  // --- URLs Y ENDPOINTS ---
  static const String urlBase = 'http://10.0.2.2:3000';
  static const String urlBaseApi = '$urlBase/api';

  // Endpoints
  static const String endpointLogin = '$urlBaseApi/login';
  static const String endpointRegistro = '$urlBaseApi/register';
  static const String endpointTecnicos = '$urlBaseApi/technicians';
  static const String endpointServicios = '$urlBaseApi/services';
  static const String endpointContrataciones = '$urlBaseApi/contractions';
  static const String endpointPagos = '$urlBaseApi/payments';
  static const String endpointCalificaciones = '$urlBaseApi/ratings';

  // --- TIMEOUTS ---
  static const Duration tiempoEsperaConexion = Duration(seconds: 30);
  static const Duration tiempoEsperaLectura = Duration(seconds: 30);
  static const Duration tiempoEsperaEscritura = Duration(seconds: 30);

  // --- CÓDIGOS DE ESTADO HTTP ---
  static const int codigoExito = 200;
  static const int codigoCreado = 201;
  static const int codigoNoAutorizado = 401;
  static const int codigoForbidden = 403;
  static const int codigoNoEncontrado = 404;
  static const int codigoErrorServidor = 500;

  // --- TIPOS DE USUARIO ---
  static const String tipoUsuarioCliente = 'cliente';
  static const String tipoUsuarioTecnico = 'tecnico';

  // --- ESTADOS DE CONTRATACIÓN ---
  static const String estadoSolicitada = 'solicitada';
  static const String estadoAsignada = 'asignada';
  static const String estadoEnProceso = 'en_proceso';
  static const String estadoCompletada = 'completada';
  static const String estadoCancelada = 'cancelada';

  // --- ESTADOS DE PAGO ---
  static const String estadoPagoPendiente = 'Pendiente';
  static const String estadoPagoCompletado = 'Completado';
  static const String estadoPagoRechazado = 'Rechazado';

  // --- DURACIÓN DE SESIÓN ---
  static const Duration duracionSesion = Duration(hours: 24);

  // --- LÍMITES ---
  static const int limiteMaximoTecnicosEnBusqueda = 50;
  static const double radioBusquedaPorDefecto = 5.0; // km
  static const int puntuacionMaxima = 5;
  static const int puntuacionMinima = 1;

  // --- MENSAJES ---
  static const String mensajeErrorGral = 'Ocurrió un error. Por favor intenta nuevamente.';
  static const String mensajeconexionFallida = 'Error de conexión. Verifica tu internet.';
  static const String mensajeNoAutorizado = 'No estás autorizado para realizar esta acción.';
  static const String mensajeSesionExpirada = 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.';
}
