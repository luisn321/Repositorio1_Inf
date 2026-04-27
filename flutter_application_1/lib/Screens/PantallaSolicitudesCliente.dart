import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../modelos/contratacion_modelo.dart';
import '../servicios_red/servicio_contrataciones.dart';
import 'PantallaDetalleSolicitud.dart';

// ── Design tokens (sistema unificado Servitec) ───────────────────────────────
const Color _verde = Color(0xFF1A5C38);
const Color _verdeClaro = Color(0xFF247A4A);
const Color _verdeOscuro = Color(0xFF0F3B22);
const Color _acento = Color(0xFF4CAF82);
const Color _fondoPage = Color(0xFFF2F6F4);
const Color _fondoCampo = Color(0xFFF4F7F5);
const Color _grisTexto = Color(0xFF8FA89B);
const Color _grisOscuro = Color(0xFF3D4F46);
const Color _naranja = Color(0xFFFF9800);
const Color _rojo = Color(0xFFCC3333);
const Color _purpura = Color(0xFF673AB7);
const Color _azul = Color(0xFF1565C0);
// ─────────────────────────────────────────────────────────────────────────────

class PantallaSolicitudesCliente extends StatefulWidget {
  final int idCliente;
  const PantallaSolicitudesCliente({super.key, required this.idCliente});

  @override
  State<PantallaSolicitudesCliente> createState() =>
      _PantallaSolicitudesClienteState();
}

class _PantallaSolicitudesClienteState extends State<PantallaSolicitudesCliente>
    with SingleTickerProviderStateMixin {
  final ServicioContrataciones _servicio = ServicioContrataciones();
  late TabController _tabs;
  List<ContratacionModelo> _solicitudes = [];
  bool _cargando = true;
  late Timer _timerRefresco;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _cargar();
    _timerRefresco = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _cargar();
    });
  }

  @override
  void dispose() {
    _timerRefresco.cancel();
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final lista = await _servicio.obtenerMisSolicitudes(widget.idCliente);
      if (mounted) setState(() => _solicitudes = lista);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Error al cargar: $e',
                  style: GoogleFonts.dmSans(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: _rojo,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<ContratacionModelo> _filtrar(String estado) => _solicitudes
      .where((s) => s.estado.toLowerCase() == estado.toLowerCase())
      .toList();

  List<ContratacionModelo> _filtrarMultiple(List<String> estados) =>
      _solicitudes
          .where(
            (s) => estados
                .map((e) => e.toLowerCase())
                .contains(s.estado.toLowerCase()),
          )
          .toList();

  // ── Helpers de estado ────────────────────────────────────────────────────
  Color _colorEstado(String e) {
    switch (e.toLowerCase()) {
      case 'pendiente':
        return _naranja;
      case 'aceptada':
        return _azul;
      case 'en progreso':
        return _purpura;
      case 'completada':
        return _verde;
      case 'cancelada':
        return _rojo;
      default:
        return _grisTexto;
    }
  }

  IconData _iconoEstado(String e) {
    switch (e.toLowerCase()) {
      case 'pendiente':
        return Icons.schedule_rounded;
      case 'aceptada':
        return Icons.thumb_up_rounded;
      case 'en progreso':
        return Icons.bolt_rounded;
      case 'completada':
        return Icons.check_circle_rounded;
      case 'cancelada':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _labelEstado(String e) {
    switch (e.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'aceptada':
        return 'Aceptada';
      case 'en progreso':
        return 'En progreso';
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return e;
    }
  }

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  // ── Navegar al detalle ───────────────────────────────────────────────────
  Future<void> _verDetalle(ContratacionModelo s) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaDetalleSolicitud(solicitud: s, esCliente: true),
      ),
    );
    _cargar();
  }

  // ── Confirmar y ejecutar propuesta ───────────────────────────────────────
  void _mostrarConfirmacionPropuesta(ContratacionModelo s, bool aceptada) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          aceptada ? '¿Confirmar cambio?' : '¿Rechazar propuesta?',
          style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: Text(
          aceptada
              ? 'La cita se reprogramará para el '
                    '${_fecha(s.fechaPropuestaSolicitada!)} '
                    'a las ${s.horaPropuestaSolicitada}.'
              : 'Al rechazar la propuesta, la solicitud se cancelará '
                    'definitivamente.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: _grisOscuro,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Volver',
              style: GoogleFonts.dmSans(
                color: _grisTexto,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (aceptada) {
                _manejarAceptarPropuesta(s);
              } else {
                _manejarRechazarPropuesta(s);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: aceptada ? _purpura : _rojo,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              aceptada ? 'Confirmar' : 'Rechazar',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _manejarAceptarPropuesta(ContratacionModelo s) async {
    try {
      final exito = await _servicio.aceptarPropuesta(s.idContratacion);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackbar(
            exito ? '¡Propuesta aceptada!' : 'Error al aceptar la propuesta',
            exito ? _verde : _rojo,
            exito ? Icons.check_circle_outline : Icons.error_outline,
          ),
        );
        if (exito) _cargar();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(_snackbar('Error: $e', _rojo, Icons.error_outline));
      }
    }
  }

  Future<void> _manejarRechazarPropuesta(ContratacionModelo s) async {
    try {
      final exito = await _servicio.rechazarPropuesta(s.idContratacion);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackbar(
            exito ? 'Solicitud cancelada' : 'Error al rechazar la propuesta',
            exito ? _grisOscuro : _rojo,
            exito ? Icons.info_outline : Icons.error_outline,
          ),
        );
        if (exito) _cargar();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(_snackbar('Error: $e', _rojo, Icons.error_outline));
      }
    }
  }

  SnackBar _snackbar(String msg, Color bg, IconData icono) => SnackBar(
    content: Row(
      children: [
        Icon(icono, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(msg, style: GoogleFonts.dmSans(color: Colors.white)),
        ),
      ],
    ),
    backgroundColor: bg,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
  );

  // ════════════════════════════════════════════════════════════════════════
  // BUILD PRINCIPAL
  // ════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPage,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: _buildHeader()),
        ],
        body: _cargando
            ? const Center(child: CircularProgressIndicator(color: _verde))
            : RefreshIndicator(
                color: _verde,
                onRefresh: _cargar,
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _lista(_solicitudes),
                    _lista(_filtrar('pendiente')),
                    _lista(_filtrarMultiple(['aceptada', 'en progreso'])),
                    _lista(_filtrar('completada')),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header completo ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    final pendientes = _filtrar('pendiente').length;
    final enCurso = _filtrarMultiple(['aceptada', 'en progreso']).length;
    final completadas = _filtrar('completada').length;

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
          // Círculos decorativos
          Positioned(
            top: -30,
            right: -20,
            child: _DecorCircle(size: 140, opacity: 0.07),
          ),
          Positioned(
            top: 40,
            right: 60,
            child: _DecorCircle(size: 55, opacity: 0.1),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Fila superior ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge SERVITEC
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _acento.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SERVITEC',
                          style: GoogleFonts.dmMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _acento,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),
                      // Botón recargar
                      GestureDetector(
                        onTap: _cargar,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Título ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis Solicitudes',
                        style: GoogleFonts.sora(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Seguimiento de tus servicios',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Stats ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _StatHeaderChip(
                        valor: pendientes,
                        etiqueta: 'Pendientes',
                        color: _naranja,
                      ),
                      const SizedBox(width: 10),
                      _StatHeaderChip(
                        valor: enCurso,
                        etiqueta: 'En curso',
                        color: _purpura,
                      ),
                      const SizedBox(width: 10),
                      _StatHeaderChip(
                        valor: completadas,
                        etiqueta: 'Completadas',
                        color: _acento,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── TabBar ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabs,
                      labelColor: _verde,
                      unselectedLabelColor: Colors.white.withValues(
                        alpha: 0.65,
                      ),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.inbox_rounded, size: 16),
                          text: 'Todas',
                        ),
                        Tab(
                          icon: Icon(Icons.schedule_rounded, size: 16),
                          text: 'Pendientes',
                        ),
                        Tab(
                          icon: Icon(Icons.bolt_rounded, size: 16),
                          text: 'En Curso',
                        ),
                        Tab(
                          icon: Icon(Icons.done_all_rounded, size: 16),
                          text: 'Listas',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Lista ────────────────────────────────────────────────────────────────
  Widget _lista(List<ContratacionModelo> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _verde.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 38,
                color: _verde.withValues(alpha: 0.35),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay solicitudes aquí',
              style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _grisOscuro,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tira hacia abajo para actualizar',
              style: GoogleFonts.dmSans(fontSize: 13, color: _grisTexto),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _cargar,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: _verde,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Actualizar',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
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

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: items.length,
      itemBuilder: (_, i) => _TarjetaSolicitud(
        solicitud: items[i],
        colorEstado: _colorEstado(items[i].estado),
        iconoEstado: _iconoEstado(items[i].estado),
        labelEstado: _labelEstado(items[i].estado),
        onVerDetalle: () => _verDetalle(items[i]),
        onAceptarPropuesta: () => _mostrarConfirmacionPropuesta(items[i], true),
        onRechazarPropuesta: () =>
            _mostrarConfirmacionPropuesta(items[i], false),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TARJETA DE SOLICITUD
// ════════════════════════════════════════════════════════════════════════════
class _TarjetaSolicitud extends StatelessWidget {
  final ContratacionModelo solicitud;
  final Color colorEstado;
  final IconData iconoEstado;
  final String labelEstado;
  final VoidCallback onVerDetalle;
  final VoidCallback onAceptarPropuesta;
  final VoidCallback onRechazarPropuesta;

  const _TarjetaSolicitud({
    required this.solicitud,
    required this.colorEstado,
    required this.iconoEstado,
    required this.labelEstado,
    required this.onVerDetalle,
    required this.onAceptarPropuesta,
    required this.onRechazarPropuesta,
  });

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final s = solicitud;
    final hasPropuesta = s.fechaPropuestaSolicitada != null;
    final st = s.estado.toLowerCase();

    // Color y texto del banner informativo
    Color bannerColor = colorEstado;
    String bannerTexto = _bannerTexto(st, s);
    if (hasPropuesta && st == 'pendiente') {
      bannerColor = const Color(0xFF673AB7);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorEstado.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorEstado.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER TARJETA ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Solicitud #${s.idContratacion}',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A5C38),
                  ),
                ),
                // Badge estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorEstado.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(iconoEstado, color: colorEstado, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        labelEstado.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: colorEstado,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── CUERPO ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chip técnico
                _chipTecnico(s),
                const SizedBox(height: 10),

                // Banner de estado informativo
                if (bannerTexto.isNotEmpty)
                  _bannerEstado(bannerTexto, bannerColor),

                // Bloque propuesta de cambio
                if (hasPropuesta) ...[
                  const SizedBox(height: 10),
                  _bloquePropuesta(s),
                ],

                const SizedBox(height: 12),

                // Botón principal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onVerDetalle,
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: Text(
                      'Ver detalles y seguimiento',
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5C38),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bannerTexto(String st, ContratacionModelo s) {
    if (st == 'pendiente') {
      return s.fechaPropuestaSolicitada != null
          ? 'El técnico propone un cambio de fecha'
          : 'Esperando respuesta del técnico';
    }
    if (st == 'aceptada') {
      return s.estadoMonto == 'Propuesto'
          ? 'Monto propuesto: \$${s.montoPropuesto?.toStringAsFixed(2)}'
          : 'Aceptada · Monto por definir';
    }
    if (st == 'en progreso') {
      return s.montoPagado != null && s.montoPagado! > 0
          ? 'Pago recibido · En proceso'
          : 'Servicio en proceso';
    }
    if (st == 'completada') return 'Servicio completado';
    if (st == 'cancelada') return 'Solicitud cancelada';
    return '';
  }

  Widget _chipTecnico(ContratacionModelo s) {
    if (s.idTecnico == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Text(
              'Sin técnico asignado aún',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF82).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF82).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF1A5C38),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (s.nombreTecnico?.isNotEmpty ?? false)
                    ? s.nombreTecnico![0].toUpperCase()
                    : '?',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.nombreTecnico ?? 'ID ${s.idTecnico}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A5C38),
                  ),
                ),
                Text(
                  'Técnico asignado',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: const Color(0xFF8FA89B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.person_rounded, size: 16, color: Color(0xFF4CAF82)),
        ],
      ),
    );
  }

  Widget _bannerEstado(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              texto,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bloquePropuesta(ContratacionModelo s) {
    const color = Color(0xFF673AB7);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.swap_horiz_rounded, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                'El técnico propone reprogramar',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                _fecha(s.fechaPropuestaSolicitada!),
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3D4F46),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                s.horaPropuestaSolicitada ?? 'No definida',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3D4F46),
                ),
              ),
            ],
          ),
          if (s.motivoCambio?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(
              '"${s.motivoCambio}"',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            '¿Aceptas este cambio?',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3D4F46),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRechazarPropuesta,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFCC3333),
                    side: BorderSide(
                      color: const Color(0xFFCC3333).withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Text(
                    'Rechazar',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAceptarPropuesta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Text(
                    'Aceptar',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ════════════════════════════════════════════════════════════════════════════

class _InfoChip extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final Color? colorValor;

  const _InfoChip({
    required this.icono,
    required this.label,
    required this.valor,
    this.colorValor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(icono, size: 14, color: const Color(0xFF8FA89B)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: const Color(0xFF8FA89B),
                  ),
                ),
                Text(
                  valor,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorValor ?? const Color(0xFF3D4F46),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatHeaderChip extends StatelessWidget {
  final int valor;
  final String etiqueta;
  final Color color;

  const _StatHeaderChip({
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(height: 5),
            Text(
              '$valor',
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              etiqueta,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.65),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }
}
