import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../modelos/contratacion_modelo.dart';
import '../servicios_red/servicio_contrataciones.dart';
import '../utilidades/dialogos_solicitudes.dart';
import 'PantallaPago.dart';
import 'PantallaCalificaciones.dart';
import '../utilidades/visor_imagenes_universal.dart';

// ── Design tokens (sistema unificado Servitec) ───────────────────────────────
const Color _verde = Color(0xFF1A5C38);
const Color _verdeClaro = Color(0xFF247A4A);
const Color _verdeOscuro = Color(0xFF0F3B22);
const Color _acento = Color(0xFF4CAF82);
const Color _fondoPage = Color(0xFFF2F6F4);
const Color _fondoCampo = Color(0xFFF4F7F5);
const Color _bordeField = Color(0xFFDDE8E3);
const Color _grisTexto = Color(0xFF8FA89B);
const Color _grisOscuro = Color(0xFF3D4F46);
const Color _errorColor = Color(0xFFE05252);
const Color _ambar = Color(0xFFF5A623);
const Color _purpura = Color(0xFF673AB7);
const Color _azul = Color(0xFF1565C0);
// ─────────────────────────────────────────────────────────────────────────────

class PantallaDetalleSolicitud extends StatefulWidget {
  final ContratacionModelo solicitud;
  final bool esCliente;

  const PantallaDetalleSolicitud({
    super.key,
    required this.solicitud,
    required this.esCliente,
  });

  @override
  State<PantallaDetalleSolicitud> createState() =>
      _PantallaDetalleSolicitudState();
}

class _PantallaDetalleSolicitudState extends State<PantallaDetalleSolicitud>
    with SingleTickerProviderStateMixin {
  final ServicioContrataciones _servicioRed = ServicioContrataciones();
  late ContratacionModelo _solicitud;
  bool _cargando = false;
  Timer? _timerAutoRefresco;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _solicitud = widget.solicitud;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _iniciarAutoRefresco();
  }

  @override
  void dispose() {
    _timerAutoRefresco?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  void _iniciarAutoRefresco() {
    _timerAutoRefresco = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _refrescarDatos();
    });
  }

  Future<void> _refrescarDatos() async {
    try {
      final actualizado = await _servicioRed.obtenerContratacionPorId(
        _solicitud.idContratacion,
      );
      if (mounted && actualizado != null) {
        setState(() => _solicitud = actualizado);
      }
    } catch (e) {
      debugPrint('Error al autorefrescar detalle: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  Color _colorEstado(String e) {
    switch (e.toLowerCase()) {
      case 'pendiente':
        return _ambar;
      case 'aceptada':
        return _azul;
      case 'en progreso':
        return _purpura;
      case 'completada':
        return _acento;
      case 'cancelada':
        return _errorColor;
      default:
        return _grisTexto;
    }
  }

  IconData _iconoEstado(String e) {
    switch (e.toLowerCase()) {
      case 'pendiente':
        return Icons.hourglass_top_rounded;
      case 'aceptada':
        return Icons.check_circle_outline_rounded;
      case 'en progreso':
        return Icons.construction_rounded;
      case 'completada':
        return Icons.verified_rounded;
      case 'cancelada':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _colorEstadoMonto(String s) {
    switch (s.toLowerCase()) {
      case 'propuesto':
        return _ambar;
      case 'aceptado':
        return _verde;
      case 'rechazado':
        return _errorColor;
      case 'pago liberado':
        return _verde;
      case 'reembolsado':
        return _azul;
      default:
        return _grisTexto;
    }
  }

  String _formatearFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  // ── Acciones Técnico ───────────────────────────────────────────────────
  Future<void> _aceptarSolicitud() async {
    await showDialog(
      context: context,
      builder: (_) => DialogoAceptarSolicitud(
        idSolicitud: _solicitud.idContratacion,
        idTecnico: _solicitud.idTecnico ?? 0,
        descripcionSolicitud: _solicitud.descripcion ?? '',
        nombreCliente: _solicitud.nombreCliente,
        fechaSolicitada: _solicitud.fechaSolicitud,
        horaStr: _solicitud.horaSolicitadaStr,
        ubicacion: _solicitud.ubicacion,
        onAceptacion: _refrescarDatos,
      ),
    );
  }

  Future<void> _completarServicio() async {
    final confirma =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('¿Completaste el trabajo?'),
            content: const Text('Esto permitirá que el cliente te califique.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Sí, completar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirma) return;
    setState(() => _cargando = true);
    try {
      await _servicioRed.marcarCompletada(_solicitud.idContratacion);
      _refrescarDatos();
    } catch (e) {
      _snack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // ── Acciones Cliente ───────────────────────────────────────────────────
  Future<void> _pagarServicio() async {
    final statusMonto = (_solicitud.estadoMonto ?? '').trim();
    if (statusMonto != 'Propuesto' && statusMonto != 'Aceptado') return;

    setState(() => _cargando = true);
    try {
      final ok = await _servicioRed.aceptarMonto(_solicitud.idContratacion);
      if (ok && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PantallaPago(
              idSolicitud: _solicitud.idContratacion,
              monto: _solicitud.montoPropuesto ?? 0,
              nombreTecnico: _solicitud.nombreTecnico ?? 'Técnico',
              descripcion: _solicitud.descripcion ?? 'Sin detalles adicionales',
              nombreServicio: _solicitud.nombreServicio ?? 'Servicio Técnico',
              fechaCita: _solicitud.fechaEstimada != null
                  ? '${_formatearFecha(_solicitud.fechaEstimada!)} ${_solicitud.horaSolicitadaStr ?? ""}'
                  : 'Por definir',
              onPagoCorrecto: _refrescarDatos,
            ),
          ),
        );
      }
    } catch (e) {
      _snack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _rechazarMonto() async {
    final statusMonto = (_solicitud.estadoMonto ?? '').trim();
    if (statusMonto != 'Propuesto' && statusMonto != 'Aceptado') return;

    final confirma =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('¿Rechazar Monto?'),
            content: const Text(
              'Si rechazas el monto, el técnico deberá proponer uno nuevo o se cancelará la negociación.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: _errorColor),
                child: const Text('Rechazar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirma) return;
    setState(() => _cargando = true);
    try {
      await _servicioRed.rechazarMonto(_solicitud.idContratacion);
      _refrescarDatos();
    } catch (e) {
      _snack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _proponerMonto() async {
    await showDialog(
      context: context,
      builder: (_) => DialogoProponerMonto(
        idSolicitud: _solicitud.idContratacion,
        montoOriginal: _solicitud.montoPropuesto,
        onMontoProuesto: _refrescarDatos,
      ),
    );
  }

  Future<void> _confirmarFinalizacionParaPago() async {
    final confirma =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              '¿Confirmar Finalización?',
              style: GoogleFonts.sora(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Al confirmar, el dinero retenido será transferido al técnico y el servicio se marcará como cerrado. Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: _verde),
                child: const Text('Sí, confirmar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirma) return;
    setState(() => _cargando = true);
    try {
      final ok = await _servicioRed.verificarCompletado(
        _solicitud.idContratacion,
      );
      if (ok) {
        _snack('Pago liberado exitosamente');
        _refrescarDatos();
      }
    } catch (e) {
      _snack('Error al liberar pago: $e', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _solicitarReembolsoEscrow() async {
    final confirma =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              '¿Solicitar Reembolso?',
              style: GoogleFonts.sora(
                fontWeight: FontWeight.bold,
                color: _errorColor,
              ),
            ),
            content: const Text(
              'Si el técnico no realizó el servicio programado, puedes solicitar el reembolso del monto retenido.\n\nEl servicio será cancelado definitivamente.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Volver'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: _errorColor),
                child: const Text('Confirmar Reembolso'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirma) return;
    setState(() => _cargando = true);
    try {
      final ok = await _servicioRed.reembolsarPago(_solicitud.idContratacion);
      if (ok) {
        _snack('Reembolso procesado exitosamente');
        _refrescarDatos();
      }
    } catch (e) {
      _snack('Error al reembolsar: $e', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _rechazarSolicitud() async {
    final String? accion = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: _purpura),
            const SizedBox(width: 12),
            Text(
              '¿Cómo proceder?',
              style: GoogleFonts.sora(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Deseas proponer una alternativa (diferente fecha/hora) antes de rechazar por completo?',
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'SOLO_RECHAZAR'),
            child: Text(
              'Solo Rechazar',
              style: GoogleFonts.dmSans(
                color: _errorColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'PROPONER_CAMBIO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purpura,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Proponer Alternativa'),
          ),
        ],
      ),
    );

    if (accion == 'PROPONER_CAMBIO') {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => DialogoPropuestaCambios(
          idSolicitud: _solicitud.idContratacion,
          onPropuestaPropuesta: _refrescarDatos,
        ),
      );
    } else if (accion == 'SOLO_RECHAZAR') {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => DialogoRechazarSolicitud(
          idSolicitud: _solicitud.idContratacion,
          onRechazo: () {
            _refrescarDatos();
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  Future<void> _aceptarPropuestaCambio() async {
    final confirma =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Aceptar Propuesta?',
              style: GoogleFonts.sora(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La cita se reprogramará para el:',
                  style: GoogleFonts.dmSans(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: _purpura,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatearFecha(_solicitud.fechaPropuestaSolicitada!),
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: _purpura,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: _purpura,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _solicitud.horaPropuestaSolicitada ?? '---',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: _purpura,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Volver'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purpura,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sí, Aceptar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirma) return;
    setState(() => _cargando = true);
    try {
      final ok = await _servicioRed.aceptarPropuesta(_solicitud.idContratacion);
      if (ok) {
        _refrescarDatos();
        _snack('¡Propuesta aceptada!');
      }
    } catch (e) {
      _snack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _rechazarPropuestaCambio() async {
    final confirma =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '¿Rechazar Propuesta?',
              style: GoogleFonts.sora(
                fontWeight: FontWeight.bold,
                color: _errorColor,
              ),
            ),
            content: const Text(
              'Al rechazar la propuesta, la solicitud se cancelará definitivamente.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Volver'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _errorColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sí, Rechazar y Cancelar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirma) return;
    setState(() => _cargando = true);
    try {
      final ok = await _servicioRed.rechazarPropuesta(
        _solicitud.idContratacion,
      );
      if (ok) {
        _refrescarDatos();
        _snack('Propuesta rechazada y solicitud cancelada');
      }
    } catch (e) {
      _snack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? _errorColor : _verde,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPage,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _cargando
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: _verde,
                            strokeWidth: 2.5,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Actualizando…',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: _grisTexto,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                      child: Column(
                        children: [
                          _buildParticipante(),
                          const SizedBox(height: 14),
                          _buildApartadoPropuesta(),
                          _buildApartadoCancelacion(),
                          _buildSeccionDescripcion(),
                          const SizedBox(height: 14),
                          _buildSeccionUbicacionTiempo(),
                          const SizedBox(height: 14),
                          _buildSeccionFinanzas(),
                          _buildSeccionCalificacion(),
                          const SizedBox(height: 20),
                          _buildAcciones(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final colorEstado = _colorEstado(_solicitud.estado);
    final iconoEstado = _iconoEstado(_solicitud.estado);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_verdeOscuro, _verde, _verdeClaro],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -28,
            right: -18,
            child: _Circle(size: 130, opacity: 0.07),
          ),
          Positioned(
            top: 44,
            right: 52,
            child: _Circle(size: 52, opacity: 0.09),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila: botón volver + badge SERVITEC
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _acento.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SERVITEC',
                          style: GoogleFonts.dmMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _acento,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Fila: ícono + título + número
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalle de solicitud',
                            style: GoogleFonts.sora(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Nº ${_solicitud.idContratacion.toString().padLeft(5, '0')}',
                            style: GoogleFonts.dmMono(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── BANNER DE ESTADO — prominente, sólido, legible ────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorEstado.withOpacity(0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            iconoEstado,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ESTADO',
                                style: GoogleFonts.dmMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withOpacity(0.7),
                                  letterSpacing: 1.8,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _solicitud.estado,
                                style: GoogleFonts.sora(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Indicador pulsante
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.7),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PARTICIPANTE ─────────────────────────────────────────────────────────
  Widget _buildParticipante() {
    final label = widget.esCliente ? 'Tu técnico' : 'Tu cliente';
    final nombre = widget.esCliente
        ? _solicitud.nombreTecnico
        : _solicitud.nombreCliente;
    final id = widget.esCliente ? _solicitud.idTecnico : _solicitud.idCliente;
    final foto = widget.esCliente
        ? _solicitud.fotoPerfilTecnico
        : _solicitud.fotoPerfilCliente;
    final heroTag = 'avatar_detalle_${_solicitud.idContratacion}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _decoTarjeta(),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (foto != null && foto.isNotEmpty) {
                VisorImagenUniversal.abrir(context, foto, heroTag);
              }
            },
            child: Hero(
              tag: heroTag,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _verde.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: (foto != null && foto.isNotEmpty)
                      ? Image.network(
                          foto,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _AvatarIniciales(nombre: nombre ?? '?'),
                        )
                      : _AvatarIniciales(nombre: nombre ?? '?'),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: _grisTexto,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  nombre ?? (id != null ? 'Usuario #$id' : 'Por asignar'),
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _verde,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (id != null)
            GestureDetector(
              onTap: () => _snack('Chat próximamente disponible'),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _verde.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: _verde,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── SECCIÓN: DESCRIPCIÓN ─────────────────────────────────────────────────
  Widget _buildSeccionDescripcion() {
    return _TarjetaSeccion(
      titulo: 'Descripción del servicio',
      icono: Icons.description_outlined,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _fondoCampo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _bordeField),
        ),
        child: Text(
          _solicitud.descripcion ?? 'Sin descripción proporcionada.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: _grisOscuro,
            height: 1.65,
          ),
        ),
      ),
    );
  }

  // ── SECCIÓN: UBICACIÓN Y TIEMPO ───────────────────────────────────────────
  Widget _buildSeccionUbicacionTiempo() {
    return _TarjetaSeccion(
      titulo: 'Ubicación y tiempo',
      icono: Icons.location_on_outlined,
      child: Column(
        children: [
          _FilaInfo(
            icono: Icons.location_on_outlined,
            label: 'Ubicación',
            valor: _solicitud.ubicacion ?? 'No especificada',
            color: _ambar,
          ),
          const SizedBox(height: 12),
          _FilaInfo(
            icono: Icons.event_rounded,
            label: 'Fecha programada',
            valor: _solicitud.fechaEstimada != null
                ? _formatearFecha(_solicitud.fechaEstimada!)
                : _formatearFecha(_solicitud.fechaSolicitud),
            color: _azul,
          ),
          const SizedBox(height: 12),
          _FilaInfo(
            icono: Icons.schedule_rounded,
            label: 'Hora',
            valor: _solicitud.horaSolicitadaStr ?? 'Pendiente',
            color: const Color(0xFF00695C),
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN: FINANZAS ─────────────────────────────────────────────────────
  Widget _buildSeccionFinanzas() {
    final hasMonto = (_solicitud.montoPropuesto ?? 0) > 0;
    final statusMonto = _solicitud.estadoMonto ?? 'Sin Propuesta';
    final isPaid = (_solicitud.montoPagado ?? 0) > 0;

    return _TarjetaSeccion(
      titulo: 'Pagos y finanzas',
      icono: Icons.payments_outlined,
      child: Column(
        children: [
          _FilaFinanza(
            label: 'Monto del servicio',
            valor: hasMonto
                ? '\$${_solicitud.montoPropuesto!.toStringAsFixed(2)}'
                : '—',
            color: _verde,
            grande: true,
          ),
          Divider(height: 24, color: _bordeField),
          _FilaFinanza(
            label: 'Estado del monto',
            valor: statusMonto,
            color: _colorEstadoMonto(statusMonto),
          ),
          Divider(height: 24, color: _bordeField),
          _FilaFinanza(
            label: 'Estado del pago',
            valor: isPaid ? 'Completado' : 'Pendiente',
            color: isPaid ? _verde : _ambar,
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN: CALIFICACIÓN ─────────────────────────────────────────────────
  Widget _buildSeccionCalificacion() {
    final pts = _solicitud.puntuacionCliente;
    if (pts == null || pts == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: _TarjetaSeccion(
        titulo: 'Calificación del servicio',
        icono: Icons.star_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < pts ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: _ambar,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$pts.0',
                  style: GoogleFonts.sora(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ambar,
                  ),
                ),
              ],
            ),
            if (_solicitud.comentarioCliente?.isNotEmpty ?? false) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _ambar.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _ambar.withOpacity(0.2)),
                ),
                child: Text(
                  '"${_solicitud.comentarioCliente}"',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: _grisOscuro,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Evaluación del cliente',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: _grisTexto,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_solicitud.fechaCalificacion != null)
                  Text(
                    _formatearFecha(_solicitud.fechaCalificacion!),
                    style: GoogleFonts.dmSans(fontSize: 11, color: _grisTexto),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── APARTADO: PROPUESTA DE CAMBIO ─────────────────────────────────────────
  Widget _buildApartadoPropuesta() {
    if (_solicitud.fechaPropuestaSolicitada == null ||
        _solicitud.estado.toLowerCase() != 'pendiente') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _purpura.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _purpura.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Cabecera coloreada
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                color: _purpura.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _purpura.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.edit_calendar_rounded,
                      color: _purpura,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Propuesta de cambio',
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _purpura,
                    ),
                  ),
                ],
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_solicitud.fechaPropuestaCambios != null)
                    _FilaInfo(
                      icono: Icons.event_repeat_rounded,
                      label: 'Fecha de envío',
                      valor: _formatearFecha(_solicitud.fechaPropuestaCambios!),
                      color: _purpura,
                    ),
                  const SizedBox(height: 10),
                  _FilaInfo(
                    icono: Icons.calendar_today_rounded,
                    label: 'Nueva fecha propuesta',
                    valor: _formatearFecha(
                      _solicitud.fechaPropuestaSolicitada!,
                    ),
                    color: _purpura,
                  ),
                  const SizedBox(height: 10),
                  _FilaInfo(
                    icono: Icons.schedule_rounded,
                    label: 'Nueva hora propuesta',
                    valor: _solicitud.horaPropuestaSolicitada ?? '—',
                    color: _purpura,
                  ),
                  if (_solicitud.motivoCambio?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 10),
                    _FilaInfo(
                      icono: Icons.chat_bubble_outline_rounded,
                      label: 'Motivo',
                      valor: _solicitud.motivoCambio!,
                      color: _purpura,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── APARTADO: CANCELACIÓN ─────────────────────────────────────────────────
  Widget _buildApartadoCancelacion() {
    if (_solicitud.estado.toLowerCase() != 'cancelada' ||
        _solicitud.motivoCambio == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _errorColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _errorColor.withOpacity(0.25), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cancel_outlined, color: _errorColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Motivo de cancelación',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _errorColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _solicitud.motivoCambio!,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: _grisOscuro,
                fontStyle: FontStyle.italic,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ACCIONES ──────────────────────────────────────────────────────────────
  Widget _buildAcciones() {
    final estado = _solicitud.estado.toLowerCase();
    final statusMonto = (_solicitud.estadoMonto ?? 'Sin Propuesta').trim();
    final isPaid = (_solicitud.montoPagado ?? 0) > 0;
    final hayPropuesta = _solicitud.fechaPropuestaSolicitada != null;

    // TÉCNICO
    if (!widget.esCliente) {
      if (estado == 'pendiente' && hayPropuesta) {
        return const SizedBox.shrink();
      }
      if (estado == 'pendiente') {
        return _filaAcciones([
          _BtnAccion(
            label: 'Aceptar',
            icono: Icons.check_circle_rounded,
            color: _verde,
            onTap: _aceptarSolicitud,
          ),
          _BtnAccion(
            label: 'Rechazar',
            icono: Icons.cancel_rounded,
            color: _errorColor,
            onTap: _rechazarSolicitud,
          ),
        ]);
      }
      if ((estado == 'aceptada' || estado == 'en progreso') &&
          statusMonto == 'Sin Propuesta') {
        return _btnSolo(
          'Proponer monto',
          Icons.payments_outlined,
          _ambar,
          _proponerMonto,
        );
      }
      if ((estado == 'aceptada' || estado == 'en progreso') && isPaid) {
        return _btnSolo(
          'Marcar como completada',
          Icons.verified_rounded,
          _verde,
          _completarServicio,
        );
      }
    }

    // CLIENTE
    if (widget.esCliente) {
      if (statusMonto.toLowerCase() == 'propuesto' ||
          statusMonto.toLowerCase() == 'aceptado') {
        return _filaAcciones([
          _BtnAccion(
            label:
                'Pagar \$${_solicitud.montoPropuesto?.toStringAsFixed(2) ?? '—'}',
            icono: Icons.payment_rounded,
            color: _verde,
            onTap: _pagarServicio,
          ),
          _BtnAccion(
            label: 'Rechazar',
            icono: Icons.close_rounded,
            color: _errorColor,
            onTap: _rechazarMonto,
          ),
        ]);
      }
      if (estado == 'pendiente' && hayPropuesta) {
        return _filaAcciones([
          _BtnAccion(
            label: 'Aceptar propuesta',
            icono: Icons.check_circle_rounded,
            color: _purpura,
            onTap: _aceptarPropuestaCambio,
          ),
          _BtnAccion(
            label: 'Rechazar',
            icono: Icons.cancel_rounded,
            color: _errorColor,
            onTap: _rechazarPropuestaCambio,
          ),
        ]);
      }
      if (estado == 'completada') {
        final sm = statusMonto.toLowerCase();
        if (sm != 'pago liberado' && sm != 'reembolsado') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: _verde.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _verde.withOpacity(0.18), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: _verde,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El técnico marcó el servicio como completado.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: _verde,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _btnSolo(
                'Confirmar y liberar pago',
                Icons.check_circle_rounded,
                _verde,
                _confirmarFinalizacionParaPago,
              ),
              const SizedBox(height: 10),
              _btnSolo(
                'No realizó el servicio (Reembolso)',
                Icons.warning_amber_rounded,
                _errorColor,
                _solicitarReembolsoEscrow,
              ),
            ],
          );
        }
        if (statusMonto == 'Pago Liberado' &&
            (_solicitud.puntuacionCliente == null ||
                _solicitud.puntuacionCliente == 0)) {
          return _btnSolo(
            'Calificar servicio',
            Icons.star_rounded,
            _ambar,
            () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaCalificaciones(
                    idContratacion: _solicitud.idContratacion,
                    idTecnico: _solicitud.idTecnico ?? 0,
                    nombreTecnico: _solicitud.nombreTecnico ?? 'Técnico',
                    fotoTecnico: _solicitud.fotoPerfilTecnico,
                    onCalificacionEnviada: _refrescarDatos,
                  ),
                ),
              );
            },
          );
        }
      }
    }

    return const SizedBox.shrink();
  }

  // Helpers de acciones
  Widget _filaAcciones(List<_BtnAccion> btns) {
    return Row(
      children: btns
          .map(
            (b) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: btns.indexOf(b) == 0 ? 0 : 6,
                  right: btns.indexOf(b) == btns.length - 1 ? 0 : 6,
                ),
                child: _boton(b.label, b.icono, b.color, b.onTap),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _btnSolo(
    String label,
    IconData icono,
    Color color,
    VoidCallback onTap,
  ) => _boton(label, icono, color, onTap);

  Widget _boton(String label, IconData icono, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Decoración de tarjeta común ───────────────────────────────────────────
  BoxDecoration _decoTarjeta() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════════════════════
// COMPONENTES INTERNOS REUTILIZABLES
// ════════════════════════════════════════════════════════════════════════════

/// Tarjeta con título de sección (barra acento + icono + label)
class _TarjetaSeccion extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;

  const _TarjetaSeccion({
    required this.titulo,
    required this.icono,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con barra lateral
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: _acento,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icono, color: _verde, size: 15),
              const SizedBox(width: 7),
              Text(
                titulo,
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _verde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Fila de información con ícono en cuadro coloreado
class _FilaInfo extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final Color color;

  const _FilaInfo({
    required this.icono,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: _grisTexto,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _grisOscuro,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fila de finanzas con pill de color
class _FilaFinanza extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;
  final bool grande;

  const _FilaFinanza({
    required this.label,
    required this.valor,
    required this.color,
    this.grande = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: _grisOscuro,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            valor,
            style: GoogleFonts.sora(
              fontSize: grande ? 16 : 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Avatar de iniciales para cuando no hay foto
class _AvatarIniciales extends StatelessWidget {
  final String nombre;
  const _AvatarIniciales({required this.nombre});

  String get _iniciales {
    final p = nombre.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _verde.withOpacity(0.15),
      child: Center(
        child: Text(
          _iniciales,
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _verde,
          ),
        ),
      ),
    );
  }
}

/// Círculo decorativo del header
class _Circle extends StatelessWidget {
  final double size, opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(opacity),
          width: 1.5,
        ),
      ),
    );
  }
}

/// Data class para los botones de acción
class _BtnAccion {
  final String label;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  const _BtnAccion({
    required this.label,
    required this.icono,
    required this.color,
    required this.onTap,
  });
}
