import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../modelos/contratacion_modelo.dart';
import '../servicios_red/servicio_contrataciones.dart';
import 'PantallaDetalleSolicitud.dart';

class PantallaSolicitudesTecnico extends StatefulWidget {
  final int idTecnico;

  const PantallaSolicitudesTecnico({super.key, required this.idTecnico});

  @override
  State<PantallaSolicitudesTecnico> createState() =>
      _PantallaSolicitudesTecnicoState();
}

class _PantallaSolicitudesTecnicoState extends State<PantallaSolicitudesTecnico>
    with SingleTickerProviderStateMixin {
  final ServicioContrataciones _servicioContrataciones =
      ServicioContrataciones();
  late TabController _controladorTabs;
  bool _cargando = false;
  late Timer
  _timerRefresco; // ✨ NUEVO: Timer para auto-refrescar cada 3 segundos

  // Design tokens
  static const Color _verde = Color(0xFF1A5C38);
  static const Color _acento = Color(0xFF4CAF82);
  static const Color _fondoPage = Color(0xFFF2F6F4);
  static const Color _naranja = Color(0xFFFF9800);
  static const Color _rojo = Color(0xFFCC3333);

  List<ContratacionModelo> _solicitudesDisponibles = [];
  List<ContratacionModelo> _misContratosActivos = []; // ✨ Aceptadas / en curso

  @override
  void initState() {
    super.initState();
    _controladorTabs = TabController(length: 2, vsync: this);
    _cargarDatos();

    // ✨ NUEVO: Refrescar datos cada 3 segundos para sincronizar con cambios del cliente
    _timerRefresco = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _cargarDatos();
      }
    });
  }

  @override
  void dispose() {
    _timerRefresco
        .cancel(); // ✨ NUEVO: Cancelar timer cuando se cierra la pantalla
    _controladorTabs.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    try {
      final disponibles = await _servicioContrataciones
          .obtenerContratacionesPendientes();
      final mios = await _servicioContrataciones.obtenerMisContratos(
        widget.idTecnico,
      );

      setState(() {
        // En "Disponibles" mostramos:
        // 1. Las globales (sin técnico asignado aún)
        // 2. Las que me enviaron a mí directamente pero que sigo analizando (Pendiente)
        final misPendientes = mios
            .where((s) => s.estado.toLowerCase() == 'pendiente')
            .toList();

        _solicitudesDisponibles = [...disponibles, ...misPendientes];

        // En "Mis Contratos" solo lo que ya acepté (Aceptada, En Progreso, etc.)
        _misContratosActivos = mios
            .where((s) => s.estado.toLowerCase() != 'pendiente')
            .toList();

        // Mantenemos esta lista para si necesitamos usarla, pero la UI principal usará _solicitudesDisponibles
      });
    } catch (e) {
      _mostrarError('Error al cargar solicitudes: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: _rojo));
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

  Widget _construirTarjetaSolicitud(
    ContratacionModelo solicitud, {
    bool disponible = true,
  }) {
    final esPendiente = solicitud.estado.toLowerCase() == 'pendiente';
    final colorBorde = disponible || esPendiente
        ? _acento.withValues(alpha: 0.3)
        : Colors.green.withValues(alpha: 0.3);

    String badgeLabel;
    Color badgeColor;
    IconData badgeIcon;
    if (disponible) {
      badgeLabel = 'DISPONIBLE';
      badgeColor = _naranja;
      badgeIcon = Icons.schedule_rounded;
    } else {
      badgeLabel = solicitud.estado.toUpperCase();
      badgeColor = _verde;
      badgeIcon = Icons.check_circle_rounded;

      final st = solicitud.estado.toLowerCase();
      if (st == "pendiente") {
        badgeColor = const Color(0xFFE65100); // 🟠 Misma Naranja que el cliente
        badgeIcon = Icons.notifications_active_rounded;
      } else if (st == "en progreso") {
        badgeColor = Colors.teal; // 🔵 Teal uniforme
        badgeIcon = Icons.play_circle_fill_rounded;
      } else if (st == "completada") {
        badgeColor = const Color(0xFF2E7D32); // 🟢 Verde oscuro
        badgeIcon = Icons.verified_rounded;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorBorde, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorBorde.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitud #${solicitud.idContratacion}',
                      style: GoogleFonts.sora(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _verde,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(badgeIcon, color: badgeColor, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        badgeLabel,
                        style: GoogleFonts.dmSans(
                          color: badgeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── CLIENTE SOLICITANTE ──────────────────────────────────────
                _chipCliente(solicitud),

                const SizedBox(height: 12),

                // ── ENUNCIADO DE ESTADO ──────────────────────────────────────
                _buildEnunciado(solicitud),

                const SizedBox(height: 12),

                // ── BOTÓN VER DETALLES (NUEVO) ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _verDetalle(solicitud),
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: Text(
                      'VER DETALLES Y SEGUIMIENTO',
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _verde,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPage,
      appBar: AppBar(
        backgroundColor: _verde,
        title: Text(
          'Solicitudes de Trabajo',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _controladorTabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            const Tab(text: 'Disponibles'),
            const Tab(text: 'Mis Contratos'),
          ],
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _controladorTabs,
              children: [
                // TAB 1: DISPONIBLES (sin asignar - cualquiera puede tomar)
                RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: _solicitudesDisponibles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay solicitudes disponibles',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _cargarDatos,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Actualizar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _verde,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _solicitudesDisponibles.length,
                          itemBuilder: (context, index) {
                            return _construirTarjetaSolicitud(
                              _solicitudesDisponibles[index],
                              disponible: true,
                            );
                          },
                        ),
                ),

                // TAB 2: MIS SOLICITUDES (solo aceptadas / activas)
                RefreshIndicator(
                  onRefresh: _cargarDatos,
                  child: (_misContratosActivos.isEmpty)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.done_all_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tienes contratos activos aún',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _cargarDatos,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Actualizar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _verde,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: [
                            // Activas (aceptadas / en curso)
                            if (_misContratosActivos.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: _verde,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'En curso (${_misContratosActivos.length})',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _verde,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ..._misContratosActivos.map(
                                (s) => _construirTarjetaSolicitud(
                                  s,
                                  disponible: false,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEnunciado(ContratacionModelo s) {
    String texto = "";
    Color colorText = Colors.blueGrey[700]!;
    final st = s.estado.toLowerCase();

    if (st == 'pendiente') {
      if (s.fechaPropuestaSolicitada != null) {
        texto = "Propuesta enviada";
        colorText = const Color(0xFF673AB7);
      } else {
        texto = "Pendiente de respuesta";
        colorText = const Color(0xFFE65100);
      }
    } else if (st == 'aceptada') {
      if (s.estadoMonto == 'Propuesto') {
        texto = "Monto propuesto: \$${s.montoPropuesto?.toStringAsFixed(2)}";
        colorText = Colors.blue[700]!;
      } else {
        texto = "Aceptada - Monto pendiente";
        colorText = _verde;
      }
    } else if (st == 'en progreso') {
      if (s.montoPagado != null && s.montoPagado! > 0) {
        texto = "Pagado - En Proceso";
        colorText = _verde;
      } else {
        texto = "En Proceso";
        colorText = Colors.teal;
      }
    } else if (st == 'completada') {
      texto = "Solicitud Completada";
      colorText = const Color(0xFF2E7D32);
    } else if (st == 'cancelada') {
      texto = "Solicitud Cancelada";
      colorText = _rojo;
    }

    if (texto.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorText.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorText.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded, size: 14, color: colorText),
            const SizedBox(width: 8),
            Text(
              texto,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipCliente(ContratacionModelo s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline_rounded,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(
            'Cliente: ',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              s.nombreCliente ?? 'Cliente #${s.idCliente}',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Colors.blue[900],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
