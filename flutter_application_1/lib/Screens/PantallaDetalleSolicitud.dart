import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../modelos/contratacion_modelo.dart';
import '../servicios_red/servicio_contrataciones.dart';
import '../utilidades/dialogos_solicitudes.dart';
import 'PantallaPago.dart';
import 'PantallaCalificaciones.dart';
import '../utilidades/visor_imagenes_universal.dart';

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

class _PantallaDetalleSolicitudState extends State<PantallaDetalleSolicitud> {
  final ServicioContrataciones _servicioRed = ServicioContrataciones();
  late ContratacionModelo _solicitud;
  bool _cargando = false;
  Timer? _timerAutoRefresco;

  // Design Tokens
  static const Color _verde = Color(0xFF1A5C38);
  static const Color _verdeClaro = Color(0xFF4CAF82);
  static const Color _naranja = Color(0xFFFF9800);
  static const Color _rojo = Color(0xFFCC3333);
  static const Color _fondo = Color(0xFFF8FAF9);

  @override
  void initState() {
    super.initState();
    _solicitud = widget.solicitud;
    _iniciarAutoRefresco();
  }

  @override
  void dispose() {
    _timerAutoRefresco?.cancel();
    super.dispose();
  }

  void _iniciarAutoRefresco() {
    _timerAutoRefresco = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) _refrescarDatos();
    });
  }

  Future<void> _refrescarDatos() async {
    try {
      // Nota: Aquí lo ideal sería tener un endpoint GetById en el servicio,
      // pero usaremos la lista filtrada por ahora si no existe el GetById específico.
      // Por simplicidad, asumimos que el técnico/cliente refresca la lista y actualiza el objeto local.
      // Pero mejor intentamos obtener la versión más reciente si el servicio lo permite.
      final lista = await _servicioRed.obtenerMisSolicitudes(
        widget.esCliente ? _solicitud.idCliente : (_solicitud.idTecnico ?? 0),
      );

      final actualizado = lista.firstWhere(
        (s) => s.idContratacion == _solicitud.idContratacion,
        orElse: () => _solicitud,
      );

      if (mounted && actualizado != _solicitud) {
        setState(() => _solicitud = actualizado);
      }
    } catch (e) {
      debugPrint('Error al autorefrescar detalle: $e');
    }
  }

  // --- ACCIONES TÉCNICO ---
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
      _snack('Error: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  // --- ACCIONES CLIENTE ---
  Future<void> _pagarServicio() async {
    if (_solicitud.estadoMonto != 'Propuesto') return;

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
              onPagoCorrecto: () => _refrescarDatos(),
            ),
          ),
        );
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _rechazarMonto() async {
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
                style: ElevatedButton.styleFrom(backgroundColor: _rojo),
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
      _snack('Error: $e');
    } finally {
      setState(() => _cargando = false);
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

  Future<void> _rechazarSolicitud() async {
    // ✨ Selección: ¿Proponer alternativa o rechazo total?
    final String? accion = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: Color(0xFF673AB7)),
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
                color: _rojo,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'PROPONER_CAMBIO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF673AB7),
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
            Navigator.pop(context); // Salir si se cancela permanentemente
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
                      color: Color(0xFF673AB7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatearFecha(_solicitud.fechaPropuestaSolicitada!),
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF673AB7),
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
                      color: Color(0xFF673AB7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _solicitud.horaPropuestaSolicitada ?? '---',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF673AB7),
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
                  backgroundColor: const Color(0xFF673AB7),
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
        _snack('Propuesta aceptada!');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      setState(() => _cargando = false);
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
                color: _rojo,
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
                  backgroundColor: _rojo,
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
      _snack('Error: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _snack(String msg) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- UI COMPONENTS ---

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

  @override
  Widget build(BuildContext context) {
    final color = _colorEstado(_solicitud.estado);

    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        title: Text(
          'Detalle de Solicitud',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: _verde,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTicketCard(color),
                  const SizedBox(height: 24),
                  _buildActions(color),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildTicketCard(Color colorEstado) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // CABECERA TICKET
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SOLICITUD #${_solicitud.idContratacion}',
                      style: GoogleFonts.dmMono(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _verde,
                        letterSpacing: 1.2,
                      ),
                    ),
                    _buildStatusBadge(colorEstado),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                _buildParticipantInfo(),
              ],
            ),
          ),

          // CUERPO TICKET
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildApartadoPropuesta(),
                _buildApartadoCancelacion(),
                _buildSectionHeader('Descripción del Servicio'),
                const SizedBox(height: 12),
                Text(
                  _solicitud.descripcion ?? 'Sin descripción proporcionada.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Ubicación y Tiempo'),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.location_on_rounded,
                  'Ubicación',
                  _solicitud.ubicacion ?? 'No especificada',
                  _naranja,
                ),
                _buildInfoRow(
                  Icons.event_rounded,
                  'Fecha Programada',
                  _solicitud.fechaEstimada != null
                      ? _formatearFecha(_solicitud.fechaEstimada!)
                      : _formatearFecha(_solicitud.fechaSolicitud),
                  Colors.blue,
                ),
                _buildInfoRow(
                  Icons.access_time_filled_rounded,
                  'Hora',
                  _solicitud.horaSolicitadaStr ?? 'Pendiente',
                  Colors.teal,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Pagos y Finanzas'),
                const SizedBox(height: 16),
                _buildFinanceDetails(),
                _buildRatingSection(),
              ],
            ),
          ),

          // PIE TICKET (Corte decorativo)
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: _fondo,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _solicitud.estado.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontWeight: FontWeight.w800,
          fontSize: 11,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildParticipantInfo() {
    final String label = widget.esCliente ? 'Tu Técnico' : 'Tu Cliente';
    final String? nombre = widget.esCliente
        ? _solicitud.nombreTecnico
        : _solicitud.nombreCliente;
    final int? id = widget.esCliente
        ? _solicitud.idTecnico
        : _solicitud.idCliente;

    final String? foto = widget.esCliente
        ? _solicitud.fotoPerfilTecnico
        : _solicitud.fotoPerfilCliente;
    final String heroTag = 'avatar_detalle_${_solicitud.idContratacion}';

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (foto != null && foto.isNotEmpty) {
              VisorImagenUniversal.abrir(context, foto, heroTag);
            }
          },
          child: Hero(
            tag: heroTag,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: _verde.withValues(alpha: 0.1),
              backgroundImage: (foto != null && foto.isNotEmpty)
                  ? NetworkImage(foto)
                  : null,
              child: (foto == null || foto.isEmpty)
                  ? const Icon(Icons.person_rounded, color: _verde, size: 28)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                nombre ?? (id != null ? 'Usuario #$id' : 'Por asignar'),
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _verde,
                ),
              ),
            ],
          ),
        ),
        if (id != null)
          IconButton(
            onPressed: () => _snack('Función de chat próximamente'),
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: _verdeClaro,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: Colors.blueGrey[300],
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceDetails() {
    final hasMonto =
        _solicitud.montoPropuesto != null && _solicitud.montoPropuesto! > 0;
    final statusMonto = _solicitud.estadoMonto ?? 'Sin Propuesta';
    final isPaid =
        _solicitud.montoPagado != null && _solicitud.montoPagado! > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // 1. MONTO (CANTIDAD)
          _buildFinanceRow(
            'Monto del Servicio:',
            hasMonto
                ? '\$${_solicitud.montoPropuesto!.toStringAsFixed(2)}'
                : '---',
            _verde,
            isBold: true,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),

          // 2. ESTADO DEL MONTO
          _buildFinanceRow(
            'Estado del Monto:',
            statusMonto.toUpperCase(),
            _colorEstadoMonto(statusMonto),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),

          // 3. ESTADO DEL PAGO
          _buildFinanceRow(
            'Estado del Pago:',
            isPaid ? 'COMPLETADO' : 'PENDIENTE',
            isPaid ? _verde : _naranja,
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: GoogleFonts.sora(
              fontSize: isBold ? 15 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _colorEstadoMonto(String status) {
    switch (status.toLowerCase()) {
      case 'propuesto':
        return _naranja;
      case 'aceptado':
        return _verde;
      case 'rechazado':
        return _rojo;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActions(Color colorEstado) {
    final estado = _solicitud.estado.toLowerCase();
    final isPaid =
        _solicitud.montoPagado != null && _solicitud.montoPagado! > 0;
    final statusMonto = _solicitud.estadoMonto ?? 'Sin Propuesta';

    // --- ACCIONES TÉCNICO ---
    if (!widget.esCliente) {
      // Si hay propuesta pendiente, quitar botones de aceptar/rechazar general
      if (estado == 'pendiente' &&
          _solicitud.fechaPropuestaSolicitada != null) {
        return const SizedBox.shrink();
      }

      if (estado == 'pendiente') {
        return Row(
          children: [
            Expanded(
              child: _btnAccion(
                'Aceptar Solicitud',
                Icons.check_circle_rounded,
                _verde,
                _aceptarSolicitud,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _btnAccion(
                'Rechazar',
                Icons.cancel_rounded,
                _rojo,
                _rechazarSolicitud,
              ),
            ),
          ],
        );
      }

      // Si ya aceptó pero no hay monto propuesto
      if ((estado == 'aceptada' || estado == 'en progreso') &&
          statusMonto == 'Sin Propuesta') {
        return _btnAccion(
          'Proponer Monto',
          Icons.local_atm_rounded,
          _naranja,
          _proponerMonto,
        );
      }

      // SOLO MOSTRAR COMPLETAR SI YA PAGÓ
      if ((estado == 'aceptada' || estado == 'en progreso') && isPaid) {
        return _btnAccion(
          'Marcar como Completada',
          Icons.verified_rounded,
          _verde,
          _completarServicio,
        );
      }
    }

    // --- ACCIONES CLIENTE ---
    if (widget.esCliente) {
      if (statusMonto == 'Propuesto') {
        return Row(
          children: [
            Expanded(
              child: _btnAccion(
                'Pagar \$${_solicitud.montoPropuesto?.toStringAsFixed(2)}',
                Icons.payment_rounded,
                _verde,
                _pagarServicio,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _btnAccion(
                'Rechazar',
                Icons.close_rounded,
                _rojo,
                _rechazarMonto,
              ),
            ),
          ],
        );
      }

      // ACCIONES DE PROPUESTA ALTERNATIVA (Diferentes de aceptar monto)
      if (estado == 'pendiente' &&
          _solicitud.fechaPropuestaSolicitada != null) {
        return Row(
          children: [
            Expanded(
              child: _btnAccion(
                'Aceptar Propuesta',
                Icons.check_circle_rounded,
                const Color(0xFF673AB7),
                _aceptarPropuestaCambio,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _btnAccion(
                'Rechazar Propuesta',
                Icons.cancel_rounded,
                _rojo,
                _rechazarPropuestaCambio,
              ),
            ),
          ],
        );
      }
      if (estado == 'completada' &&
          (_solicitud.puntuacionCliente == null ||
              _solicitud.puntuacionCliente == 0)) {
        return _btnAccion(
          'Calificar Servicio',
          Icons.star_rounded,
          Colors.amber[700]!,
          () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaCalificaciones(
                  idContratacion: _solicitud.idContratacion,
                  idTecnico: _solicitud.idTecnico ?? 0,
                  nombreTecnico: _solicitud.nombreTecnico ?? 'Técnico',
                  onCalificacionEnviada: _refrescarDatos,
                ),
              ),
            );
          },
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _btnAccion(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }

  Widget _buildRatingSection() {
    if (_solicitud.puntuacionCliente == null ||
        _solicitud.puntuacionCliente == 0)
      return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Calificación del Servicio'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < _solicitud.puntuacionCliente!
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber[700],
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_solicitud.puntuacionCliente}.0',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber[900],
                    ),
                  ),
                ],
              ),
              if (_solicitud.comentarioCliente != null &&
                  _solicitud.comentarioCliente!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '"${_solicitud.comentarioCliente}"',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Evaluación del cliente',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _solicitud.fechaCalificacion != null
                        ? _formatearFecha(_solicitud.fechaCalificacion!)
                        : '',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApartadoPropuesta() {
    // ✨ Solo mostrar propuesta si el estado es Pendiente (si ya se aceptó, backend limpia los campos)
    if (_solicitud.fechaPropuestaSolicitada == null ||
        _solicitud.estado.toLowerCase() != 'pendiente') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Propuesta de cambio en solicitud'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF673AB7).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF673AB7).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                Icons.event_repeat_rounded,
                'Fecha de envío propuesta',
                _solicitud.fechaPropuestaCambios != null
                    ? _formatearFecha(_solicitud.fechaPropuestaCambios!)
                    : 'Hoy',
                const Color(0xFF673AB7),
              ),
              _buildInfoRow(
                Icons.calendar_today_rounded,
                'Nueva Fecha Solicitada',
                _formatearFecha(_solicitud.fechaPropuestaSolicitada!),
                const Color(0xFF673AB7),
              ),
              _buildInfoRow(
                Icons.access_time_rounded,
                'Nueva Hora Solicitada',
                _solicitud.horaPropuestaSolicitada ?? '---',
                const Color(0xFF673AB7),
              ),
              _buildInfoRow(
                Icons.chat_rounded,
                'Motivo del Cambio',
                _solicitud.motivoCambio ?? 'Sin motivo',
                const Color(0xFF673AB7),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildApartadoCancelacion() {
    // ✨ Mostrar motivo si está cancelada y hay un motivo guardado (rechazo o propuesta rechazada)
    if (_solicitud.estado.toLowerCase() != 'cancelada' ||
        _solicitud.motivoCambio == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Motivo de Cancelación'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _rojo.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _rojo.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: _rojo, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Esta solicitud fue cancelada',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      color: _rojo,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _solicitud.motivoCambio!,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _formatearFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
