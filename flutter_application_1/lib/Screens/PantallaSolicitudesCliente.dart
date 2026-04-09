import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../modelos/contratacion_modelo.dart';
import '../servicios_red/servicio_contrataciones.dart';
import 'PantallaDetalleSolicitud.dart';

// ── Tokens de diseño ─────────────────────────────────────────────────────────
const Color _verde = Color(0xFF1A5C38);
const Color _verdeClaro = Color(0xFF4CAF82);
const Color _naranja = Color(0xFFFF9800);
const Color _rojo = Color(0xFFCC3333);
const Color _fondoPage = Color(0xFFF2F6F4);

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
  late Timer
  _timerRefresco; // ✨ NUEVO: Timer para auto-refrescar cada 3 segundos

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _cargar();

    // ✨ NUEVO: Refrescar datos cada 3 segundos para sincronizar con cambios del técnico
    _timerRefresco = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _cargar();
      }
    });
  }

  @override
  void dispose() {
    _timerRefresco
        .cancel(); // ✨ NUEVO: Cancelar timer cuando se cierra la pantalla
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final lista = await _servicio.obtenerMisSolicitudes(widget.idCliente);
      setState(() => _solicitudes = lista);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<ContratacionModelo> _filtrar(String estado) => _solicitudes
      .where((s) => s.estado.toLowerCase() == estado.toLowerCase())
      .toList();

  // ── Colores / iconos por estado ──────────────────────────────────────────
  Color _colorEstado(String e) {
    switch (e.toLowerCase()) {
      case 'pendiente':
        return _naranja;
      case 'aceptada':
        return Colors.blue;
      case 'en progreso':
        return Colors.purple;
      case 'completada':
        return _verde;
      case 'cancelada':
        return _rojo;
      default:
        return Colors.grey;
    }
  }

  IconData _iconoEstado(String e) {
    switch (e.toLowerCase()) {
      case 'pendiente':
        return Icons.schedule_rounded;
      case 'aceptada':
        return Icons.thumb_up_rounded;
      case 'en progreso':
        return Icons.hourglass_bottom_rounded;
      case 'completada':
        return Icons.check_circle_rounded;
      case 'cancelada':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Future<void> _verDetalle(ContratacionModelo s) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaDetalleSolicitud(
          solicitud: s,
          esCliente: true,
        ),
      ),
    );
    _cargar(); // Refrescar al volver
  }

  // ── Helpers de formato ───────────────────────────────────────────────────
  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ── Tarjeta de solicitud ─────────────────────────────────────────────────
  Widget _tarjeta(ContratacionModelo s) {
    final color = _colorEstado(s.estado);
    final icono = _iconoEstado(s.estado);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Solicitud #${s.idContratacion}',
                  style: GoogleFonts.sora(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _verde,
                  ),
                ),
                // Badge estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Icon(icono, color: color, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        s.estado.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.5,
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
                // ── TÉCNICO ASIGNADO ─────────────────────────────────────────
                _chipTecnico(s),

                // ── ENUNCIADO DE ESTADO ──────────────────────────────────────
                _buildEnunciado(s),

                const SizedBox(height: 12),

                const SizedBox(height: 4),

                // ── BOTÓN VER DETALLES (NUEVO) ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _verDetalle(s),
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

  Widget _buildEnunciado(ContratacionModelo s) {
    String texto = "";
    Color colorText = Colors.blueGrey[700]!;
    final st = s.estado.toLowerCase();

    if (st == 'pendiente') {
      if (s.fechaPropuestaSolicitada != null) {
        texto = "El técnico solicita un cambio";
        colorText = const Color(0xFF673AB7);
      } else {
        texto = "Pendiente de respuesta";
        colorText = const Color(0xFFE65100); // Naranja fuerte
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
      padding: const EdgeInsets.only(bottom: 12),
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

  Widget _chipTecnico(ContratacionModelo s) {
// ... existing code ...
    if (s.idTecnico == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 16,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 8),
            Text(
              'Sin técnico asignado aún',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _verdeClaro.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _verdeClaro.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded, size: 16, color: _verdeClaro),
          const SizedBox(width: 8),
          Text(
            'Técnico: ',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              s.nombreTecnico ?? 'ID ${s.idTecnico}',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: _verde,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPage,
      appBar: AppBar(
        title: Text(
          'Mis Solicitudes',
          style: GoogleFonts.sora(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: _verde,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _cargar,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: _verde,
            child: TabBar(
              controller: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.inbox_rounded, size: 18), text: 'Todas'),
                Tab(
                  icon: Icon(Icons.schedule_rounded, size: 18),
                  text: 'Pendientes',
                ),
                Tab(
                  icon: Icon(Icons.autorenew_rounded, size: 18),
                  text: 'En Curso',
                ),
                Tab(
                  icon: Icon(Icons.done_all_rounded, size: 18),
                  text: 'Completadas',
                ),
              ],
            ),
          ),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: TabBarView(
                controller: _tabs,
                children: [
                  _lista(_solicitudes),
                  _lista(_filtrar('pendiente')),
                  _lista([..._filtrar('aceptada'), ..._filtrar('en progreso')]),
                  _lista(_filtrar('completada')),
                ],
              ),
            ),
    );
  }

  Widget _lista(List<ContratacionModelo> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: _verde.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay solicitudes',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _verde,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: items.length,
      itemBuilder: (_, i) => _tarjeta(items[i]),
    );
  }

  // ✨ NUEVO: Bloque de diseño para propuestas de cambio de técnico
  Widget _bloquePropuestaAlternativa(ContratacionModelo s) {
    if (s.fechaPropuestaSolicitada == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF673AB7).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF673AB7).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF673AB7), size: 18),
              const SizedBox(width: 10),
              Text(
                'El técnico propone un cambio',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF673AB7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF673AB7)),
              const SizedBox(width: 8),
              Text(
                _fecha(s.fechaPropuestaSolicitada!),
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF673AB7)),
              const SizedBox(width: 8),
              Text(
                s.horaPropuestaSolicitada ?? 'No definida',
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (s.motivoCambio != null && s.motivoCambio!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '💭 Motivo: ${s.motivoCambio}',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '¿Aceptas este cambio de fecha/hora?',
            style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _mostrarConfirmacionPropuesta(s, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _rojo,
                    side: BorderSide(color: _rojo.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('NO, rechazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _mostrarConfirmacionPropuesta(s, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('SÍ, acepto'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarConfirmacionPropuesta(ContratacionModelo s, bool aceptada) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          aceptada ? '¿Confirmar Cambio?' : '¿Rechazar Propuesta?',
          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          aceptada
              ? 'La cita se reprogramará para el ${_fecha(s.fechaPropuestaSolicitada!)} a las ${s.horaPropuestaSolicitada}.'
              : 'Al rechazar la propuesta, la solicitud se cancelará definitivamente.',
          style: GoogleFonts.dmSans(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (aceptada) {
                _manejarAceptarPropuesta(s);
              } else {
                _manejarRechazarPropuesta(s);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: aceptada ? const Color(0xFF673AB7) : _rojo,
            ),
            child: Text(aceptada ? 'Hecho' : 'Confirmar Rechazo'),
          ),
        ],
      ),
    );
  }

  Future<void> _manejarAceptarPropuesta(ContratacionModelo s) async {
    try {
      final exito = await _servicio.aceptarPropuesta(s.idContratacion);
      if (exito) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Propuesta aceptada!')),
          );
          _cargar();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al aceptar la propuesta')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _manejarRechazarPropuesta(ContratacionModelo s) async {
    try {
      final exito = await _servicio.rechazarPropuesta(s.idContratacion);
      if (exito) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitud cancelada')),
          );
          _cargar();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al rechazar la propuesta')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
