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
const Color _grisTexto = Color(0xFF8FA89B);
const Color _grisOscuro = Color(0xFF3D4F46);
const Color _naranja = Color(0xFFFF9800);
const Color _rojo = Color(0xFFCC3333);
const Color _purpura = Color(0xFF673AB7);
const Color _azul = Color(0xFF1565C0);
const Color _teal = Color(0xFF00897B);
// ─────────────────────────────────────────────────────────────────────────────

class PantallaSolicitudesTecnico extends StatefulWidget {
  final int idTecnico;
  const PantallaSolicitudesTecnico({super.key, required this.idTecnico});

  @override
  State<PantallaSolicitudesTecnico> createState() =>
      _PantallaSolicitudesTecnicoState();
}

class _PantallaSolicitudesTecnicoState extends State<PantallaSolicitudesTecnico>
    with SingleTickerProviderStateMixin {
  final ServicioContrataciones _servicio = ServicioContrataciones();
  late TabController _tabs;
  bool _cargando = true;
  late Timer _timerRefresco;

  List<ContratacionModelo> _solicitudesDisponibles = [];
  List<ContratacionModelo> _misContratosActivos = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _cargarDatos();
    _timerRefresco = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _cargarDatos();
    });
  }

  @override
  void dispose() {
    _timerRefresco.cancel();
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final disponibles = await _servicio.obtenerContratacionesPendientes();
      final mios = await _servicio.obtenerMisContratos(widget.idTecnico);

      if (mounted) {
        setState(() {
          final misPendientes = mios
              .where((s) => s.estado.toLowerCase() == 'pendiente')
              .toList();
          _solicitudesDisponibles = [...disponibles, ...misPendientes];
          _misContratosActivos = mios
              .where((s) => s.estado.toLowerCase() != 'pendiente')
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackbar('Error al cargar: $e', _rojo, Icons.error_outline),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _verDetalle(ContratacionModelo solicitud) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PantallaDetalleSolicitud(solicitud: solicitud, esCliente: false),
      ),
    );
    _cargarDatos();
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

  // ── Helpers de estado ────────────────────────────────────────────────────
  Color _colorEstado(String e) {
    switch (e.toLowerCase()) {
      case 'pendiente':
        return _naranja;
      case 'aceptada':
        return _azul;
      case 'en progreso':
        return _teal;
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
        return Icons.notifications_active_rounded;
      case 'aceptada':
        return Icons.thumb_up_rounded;
      case 'en progreso':
        return Icons.play_circle_fill_rounded;
      case 'completada':
        return Icons.verified_rounded;
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
                onRefresh: _cargarDatos,
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _listaDisponibles(_solicitudesDisponibles),
                    _listaMisContratos(_misContratosActivos),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header completo ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    final disponibles = _solicitudesDisponibles.length;
    final enCurso = _misContratosActivos
        .where(
          (s) =>
              s.estado.toLowerCase() == 'aceptada' ||
              s.estado.toLowerCase() == 'en progreso',
        )
        .length;
    final completadas = _misContratosActivos
        .where((s) => s.estado.toLowerCase() == 'completada')
        .length;

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
                        onTap: _cargarDatos,
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
                        'Panel de Trabajo',
                        style: GoogleFonts.sora(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestión de solicitudes y contratos',
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
                        valor: disponibles,
                        etiqueta: 'Disponibles',
                        color: _naranja,
                      ),
                      const SizedBox(width: 10),
                      _StatHeaderChip(
                        valor: enCurso,
                        etiqueta: 'En curso',
                        color: _teal,
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
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.work_outline_rounded, size: 16),
                          text: 'Disponibles',
                        ),
                        Tab(
                          icon: Icon(Icons.assignment_rounded, size: 16),
                          text: 'Mis Contratos',
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

  // ── Lista de solicitudes disponibles ────────────────────────────────────
  Widget _listaDisponibles(List<ContratacionModelo> items) {
    if (items.isEmpty) {
      return _estadoVacio(
        icono: Icons.work_outline_rounded,
        titulo: 'No hay solicitudes disponibles',
        subtitulo: 'Tira hacia abajo para actualizar',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: items.length,
      itemBuilder: (_, i) => _TarjetaSolicitudTecnico(
        solicitud: items[i],
        esDisponible: true,
        colorEstado: _naranja,
        iconoEstado: Icons.schedule_rounded,
        labelEstado: 'Disponible',
        onVerDetalle: () => _verDetalle(items[i]),
      ),
    );
  }

  // ── Lista de mis contratos ───────────────────────────────────────────────
  Widget _listaMisContratos(List<ContratacionModelo> items) {
    if (items.isEmpty) {
      return _estadoVacio(
        icono: Icons.assignment_outlined,
        titulo: 'No tienes contratos activos',
        subtitulo: 'Aquí aparecerán tus solicitudes aceptadas',
      );
    }

    // Separar por grupos
    final enCurso = items
        .where(
          (s) =>
              s.estado.toLowerCase() == 'aceptada' ||
              s.estado.toLowerCase() == 'en progreso',
        )
        .toList();
    final completadas = items
        .where((s) => s.estado.toLowerCase() == 'completada')
        .toList();
    final canceladas = items
        .where((s) => s.estado.toLowerCase() == 'cancelada')
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (enCurso.isNotEmpty) ...[
          _seccionHeader('En curso', enCurso.length, _teal),
          ...enCurso.map(
            (s) => _TarjetaSolicitudTecnico(
              solicitud: s,
              esDisponible: false,
              colorEstado: _colorEstado(s.estado),
              iconoEstado: _iconoEstado(s.estado),
              labelEstado: _labelEstado(s.estado),
              onVerDetalle: () => _verDetalle(s),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (completadas.isNotEmpty) ...[
          _seccionHeader('Completadas', completadas.length, _verde),
          ...completadas.map(
            (s) => _TarjetaSolicitudTecnico(
              solicitud: s,
              esDisponible: false,
              colorEstado: _colorEstado(s.estado),
              iconoEstado: _iconoEstado(s.estado),
              labelEstado: _labelEstado(s.estado),
              onVerDetalle: () => _verDetalle(s),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (canceladas.isNotEmpty) ...[
          _seccionHeader('Canceladas', canceladas.length, _rojo),
          ...canceladas.map(
            (s) => _TarjetaSolicitudTecnico(
              solicitud: s,
              esDisponible: false,
              colorEstado: _colorEstado(s.estado),
              iconoEstado: _iconoEstado(s.estado),
              labelEstado: _labelEstado(s.estado),
              onVerDetalle: () => _verDetalle(s),
            ),
          ),
        ],
      ],
    );
  }

  Widget _seccionHeader(String titulo, int cantidad, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$titulo ($cantidad)',
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoVacio({
    required IconData icono,
    required String titulo,
    required String subtitulo,
  }) {
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
            child: Icon(icono, size: 38, color: _verde.withValues(alpha: 0.35)),
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: GoogleFonts.sora(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _grisOscuro,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitulo,
            style: GoogleFonts.dmSans(fontSize: 13, color: _grisTexto),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _cargarDatos,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
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
}

// ════════════════════════════════════════════════════════════════════════════
// TARJETA DE SOLICITUD (TÉCNICO)
// ════════════════════════════════════════════════════════════════════════════
class _TarjetaSolicitudTecnico extends StatelessWidget {
  final ContratacionModelo solicitud;
  final bool esDisponible;
  final Color colorEstado;
  final IconData iconoEstado;
  final String labelEstado;
  final VoidCallback onVerDetalle;

  const _TarjetaSolicitudTecnico({
    required this.solicitud,
    required this.esDisponible,
    required this.colorEstado,
    required this.iconoEstado,
    required this.labelEstado,
    required this.onVerDetalle,
  });

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final s = solicitud;
    final st = s.estado.toLowerCase();
    final hasPropuesta = s.fechaPropuestaSolicitada != null;

    // Determinar color y badge real
    final Color colorBadge = esDisponible
        ? const Color(0xFFFF9800)
        : colorEstado;
    final IconData iconoBadge = esDisponible
        ? Icons.schedule_rounded
        : iconoEstado;
    final String textoBadge = esDisponible
        ? 'DISPONIBLE'
        : labelEstado.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorBadge.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorBadge.withValues(alpha: 0.07),
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
              color: colorBadge.withValues(alpha: 0.06),
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
                    color: colorBadge.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorBadge.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(iconoBadge, color: colorBadge, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        textoBadge,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: colorBadge,
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
                // Chip cliente
                _chipCliente(s),
                const SizedBox(height: 10),

                // Banner de estado informativo
                _bannerEstado(st, s),

                // Bloque propuesta (si aplica y es técnico que la envió)
                if (hasPropuesta && st == 'pendiente') ...[
                  const SizedBox(height: 10),
                  _bloquePropuestaEnviada(s),
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

  Widget _chipCliente(ContratacionModelo s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1565C0).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (s.nombreCliente?.isNotEmpty ?? false)
                    ? s.nombreCliente![0].toUpperCase()
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
                  s.nombreCliente ?? 'Cliente #${s.idCliente}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1565C0),
                  ),
                ),
                Text(
                  'Cliente solicitante',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: const Color(0xFF8FA89B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.person_rounded, size: 16, color: Color(0xFF1565C0)),
        ],
      ),
    );
  }

  Widget _bannerEstado(String st, ContratacionModelo s) {
    String texto = '';
    Color color = const Color(0xFF8FA89B);

    if (esDisponible) {
      if (s.fechaPropuestaSolicitada != null) {
        texto = 'Propuesta de cambio enviada al cliente';
        color = const Color(0xFF673AB7);
      } else {
        texto = 'Solicitud pendiente de respuesta';
        color = const Color(0xFFFF9800);
      }
    } else {
      if (st == 'aceptada') {
        if (s.estadoMonto == 'Propuesto') {
          texto = 'Monto propuesto: \$${s.montoPropuesto?.toStringAsFixed(2)}';
          color = const Color(0xFF1565C0);
        } else {
          texto = 'Aceptada · Monto por definir';
          color = const Color(0xFF1A5C38);
        }
      } else if (st == 'en progreso') {
        texto = s.montoPagado != null && s.montoPagado! > 0
            ? 'Pago recibido · En proceso'
            : 'Servicio en proceso';
        color = const Color(0xFF00897B);
      } else if (st == 'completada') {
        texto = 'Servicio completado';
        color = const Color(0xFF1A5C38);
      } else if (st == 'cancelada') {
        texto = 'Solicitud cancelada';
        color = const Color(0xFFCC3333);
      }
    }

    if (texto.isEmpty) return const SizedBox.shrink();

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

  Widget _bloquePropuestaEnviada(ContratacionModelo s) {
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
                'Propuesta de reprogramación enviada',
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
                '${s.fechaPropuestaSolicitada!.day.toString().padLeft(2, '0')}/'
                '${s.fechaPropuestaSolicitada!.month.toString().padLeft(2, '0')}/'
                '${s.fechaPropuestaSolicitada!.year}',
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
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 13, color: color),
              const SizedBox(width: 6),
              Text(
                'Esperando respuesta del cliente',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
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
// WIDGETS AUXILIARES (sistema compartido Servitec)
// ════════════════════════════════════════════════════════════════════════════

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
