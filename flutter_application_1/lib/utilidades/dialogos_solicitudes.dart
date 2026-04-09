import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../servicios_red/servicio_contrataciones.dart';

// ───────────────────────────────────────────────────────────────────────────
// 1. DIÁLOGO: ACEPTAR SOLICITUD (Técnico)
// ───────────────────────────────────────────────────────────────────────────

class DialogoAceptarSolicitud extends StatefulWidget {
  final int idSolicitud;
  final int idTecnico;
  final String descripcionSolicitud;
  final String? nombreCliente;
  final DateTime? fechaSolicitada;
  final String? horaStr;
  final String? ubicacion;
  final VoidCallback onAceptacion;

  const DialogoAceptarSolicitud({
    super.key,
    required this.idSolicitud,
    required this.idTecnico,
    required this.descripcionSolicitud,
    this.nombreCliente,
    this.fechaSolicitada,
    this.horaStr,
    this.ubicacion,
    required this.onAceptacion,
  });

  @override
  State<DialogoAceptarSolicitud> createState() =>
      _DialogoAceptarSolicitudState();
}

class _DialogoAceptarSolicitudState extends State<DialogoAceptarSolicitud> {
  final _servicio = ServicioContrataciones();
  bool _cargando = false;

  Future<void> _aceptar() async {
    setState(() => _cargando = true);
    try {
      await _servicio.aceptarSolicitud(
        widget.idSolicitud,
        widget.idTecnico,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onAceptacion();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF1A5C38)),
          const SizedBox(width: 12),
          Text(
            'Aceptar Solicitud',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── CLIENTE ────────────────────────────────────────────────
            if (widget.nombreCliente != null && widget.nombreCliente!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5C38).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF1A5C38).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(children: [
                  const Icon(Icons.person_rounded, size: 16, color: Color(0xFF1A5C38)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cliente',
                        style: GoogleFonts.dmSans(
                          fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      Text(widget.nombreCliente!,
                        style: GoogleFonts.dmSans(
                          fontSize: 13, color: const Color(0xFF1A5C38), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 12),
            ],

            // ── INFO GRID: Fecha, Hora, Ubicación ──────────────────────
            if (widget.fechaSolicitada != null || widget.horaStr != null || widget.ubicacion != null) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.fechaSolicitada != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fecha',
                            style: GoogleFonts.dmSans(
                              fontSize: 9, color: Colors.blue, fontWeight: FontWeight.w600)),
                          Text(
                            '${widget.fechaSolicitada!.day.toString().padLeft(2, '0')}/'
                            '${widget.fechaSolicitada!.month.toString().padLeft(2, '0')}/'
                            '${widget.fechaSolicitada!.year}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                          ],
                      ),
                    ),
                  ],
                  if (widget.horaStr != null && widget.horaStr!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hora',
                            style: GoogleFonts.dmSans(
                              fontSize: 9, color: Colors.teal, fontWeight: FontWeight.w600)),
                          Text(widget.horaStr!,
                            style: GoogleFonts.dmSans(
                              fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                  if (widget.ubicacion != null && widget.ubicacion!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ubicación',
                            style: GoogleFonts.dmSans(
                              fontSize: 9, color: const Color(0xFFFF9800), fontWeight: FontWeight.w600)),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(widget.ubicacion!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
            ],

            // ── DESCRIPCIÓN ────────────────────────────────────────────
            Text(
              'Descripción del trabajo:',
              style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.descripcionSolicitud,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Confirmas que aceptas esta solicitud?',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.dmSans(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _cargando ? null : _aceptar,
          icon: _cargando ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ) : const Icon(Icons.check),
          label: Text(_cargando ? 'Aceptando...' : 'Aceptar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A5C38),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 2. DIÁLOGO: RECHAZAR SOLICITUD (Técnico)
// ───────────────────────────────────────────────────────────────────────────

class DialogoRechazarSolicitud extends StatefulWidget {
  final int idSolicitud;
  final VoidCallback onRechazo;

  const DialogoRechazarSolicitud({
    super.key,
    required this.idSolicitud,
    required this.onRechazo,
  });

  @override
  State<DialogoRechazarSolicitud> createState() =>
      _DialogoRechazarSolicitudState();
}

class _DialogoRechazarSolicitudState extends State<DialogoRechazarSolicitud> {
  final _servicio = ServicioContrataciones();
  final _motivoController = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _rechazar() async {
    final motivo = _motivoController.text.trim();
    if (motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un motivo')),
      );
      return;
    }

    setState(() => _cargando = true);
    try {
      await _servicio.rechazarSolicitud(widget.idSolicitud, motivo);
      if (mounted) {
        Navigator.pop(context);
        widget.onRechazo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.cancel_rounded, color: Color(0xFFCC3333)),
          const SizedBox(width: 12),
          Text(
            'Rechazar Solicitud',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explica por qué rechazas esta solicitud:',
              style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _motivoController,
              enabled: !_cargando,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ej: No tengo disponibilidad en esas fechas...',
                hintStyle: GoogleFonts.dmSans(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFCC3333),
                    width: 2,
                  ),
                ),
              ),
              style: GoogleFonts.dmSans(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.dmSans(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _cargando ? null : _rechazar,
          icon: _cargando ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
          ) : const Icon(Icons.close),
          label: Text(_cargando ? 'Rechazando...' : 'Rechazar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCC3333),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 3. DIÁLOGO: PROPONER MONTO (Técnico)
// ───────────────────────────────────────────────────────────────────────────

class DialogoProponerMonto extends StatefulWidget {
  final int idSolicitud;
  final double? montoOriginal;
  final VoidCallback onMontoProuesto;

  const DialogoProponerMonto({
    super.key,
    required this.idSolicitud,
    this.montoOriginal,
    required this.onMontoProuesto,
  });

  @override
  State<DialogoProponerMonto> createState() => _DialogoProponerMontoState();
}

class _DialogoProponerMontoState extends State<DialogoProponerMonto> {
  final _servicio = ServicioContrataciones();
  final _montoController = TextEditingController();
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    if (widget.montoOriginal != null && widget.montoOriginal! > 0) {
      _montoController.text = widget.montoOriginal!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  Future<void> _proponer() async {
    final montoStr = _montoController.text.trim();
    if (montoStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto')),
      );
      return;
    }

    final monto = double.tryParse(montoStr);
    if (monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido (mayor a 0)')),
      );
      return;
    }

    setState(() => _cargando = true);
    try {
      await _servicio.proponerMonto(widget.idSolicitud, monto);
      if (mounted) {
        Navigator.pop(context);
        widget.onMontoProuesto();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.local_atm_rounded, color: Color(0xFFFF9800)),
          const SizedBox(width: 12),
          Text(
            'Proponer Monto',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monto que cobrarás por este servicio:',
              style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _montoController,
              enabled: !_cargando,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                hintStyle: GoogleFonts.dmSans(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF9800),
                    width: 2,
                  ),
                ),
              ),
              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              '💡 El cliente podrá aceptar o rechazar este monto.',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.dmSans(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _cargando ? null : _proponer,
          icon: _cargando ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
          ) : const Icon(Icons.check),
          label: Text(_cargando ? 'Proponiendo...' : 'Proponer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 4. DIÁLOGO: RESPONDER MONTO (Cliente)
// ───────────────────────────────────────────────────────────────────────────

class DialogoResponderMonto extends StatefulWidget {
  final int idSolicitud;
  final double monto;
  final String? nombreTecnico;
  final VoidCallback onRespuesta;

  const DialogoResponderMonto({
    super.key,
    required this.idSolicitud,
    required this.monto,
    this.nombreTecnico,
    required this.onRespuesta,
  });

  @override
  State<DialogoResponderMonto> createState() => _DialogoResponderMontoState();
}

class _DialogoResponderMontoState extends State<DialogoResponderMonto> {
  final _servicio = ServicioContrataciones();
  bool _cargando = false;

  Future<void> _aceptarMonto() async {
    setState(() => _cargando = true);
    try {
      await _servicio.aceptarMonto(widget.idSolicitud);
      if (mounted) {
        Navigator.pop(context);
        widget.onRespuesta();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _rechazarMonto() async {
    setState(() => _cargando = true);
    try {
      await _servicio.rechazarMonto(widget.idSolicitud);
      if (mounted) {
        Navigator.pop(context);
        widget.onRespuesta();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.attach_money_rounded, color: Color(0xFF1A5C38)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Monto Propuesto',
              style: GoogleFonts.sora(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.nombreTecnico != null) ...[
              Text(
                'El técnico',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                widget.nombreTecnico!,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A5C38),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'propone cobrar:',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Text(
                '\$${widget.monto.toStringAsFixed(2)}',
                style: GoogleFonts.sora(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '¿Aceptas este monto?',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: _cargando ? null : _rechazarMonto,
          icon: _cargando ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
          ) : const Icon(Icons.close),
          label: const Text('Rechazar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCC3333),
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _cargando ? null : _aceptarMonto,
          icon: _cargando ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
          ) : const Icon(Icons.check_circle),
          label: const Text('Aceptar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A5C38),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 5. DIÁLOGO: PROPONER PROPUESTA/ALTERNATIVA (Técnico - PARTE 1)
// ───────────────────────────────────────────────────────────────────────────

class DialogoPropuestaCambios extends StatefulWidget {
  final int idSolicitud;
  final VoidCallback onPropuestaPropuesta;

  const DialogoPropuestaCambios({
    super.key,
    required this.idSolicitud,
    required this.onPropuestaPropuesta,
  });

  @override
  State<DialogoPropuestaCambios> createState() =>
      _DialogoPropuestaCambiosState();
}

class _DialogoPropuestaCambiosState extends State<DialogoPropuestaCambios> {
  final _servicio = ServicioContrataciones();
  final _motivoController = TextEditingController();
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  bool _cargando = false;

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _mostrarSeleccionadorFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (fecha != null) {
      setState(() => _fechaSeleccionada = fecha);
    }
  }

  Future<void> _mostrarSeleccionadorHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (hora != null) {
      setState(() => _horaSeleccionada = hora);
    }
  }

  Future<void> _proponer() async {
    final motivo = _motivoController.text.trim();
    if (motivo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa una razón para el cambio')),
      );
      return;
    }

    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una fecha')),
      );
      return;
    }

    if (_horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una hora')),
      );
      return;
    }

    setState(() => _cargando = true);
    try {
      final horaStr =
          '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}';

      await _servicio.proponerPropuesta(
        widget.idSolicitud,
        fechaPropuestaSolicitada: _fechaSeleccionada!,
        horaPropuestaSolicitada: horaStr,
        motivoCambio: motivo,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onPropuestaPropuesta();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.edit_calendar_rounded, color: Color(0xFF673AB7)),
          const SizedBox(width: 12),
          Text(
            'Proponer Alternativa',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Propón una alternativa diferente:',
              style: GoogleFonts.sora(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // 📅 FECHA
            Text(
              'Fecha Propuesta:',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _cargando ? null : _mostrarSeleccionadorFecha,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _fechaSeleccionada == null
                    ? 'Seleccionar fecha'
                    : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 🕐 HORA
            Text(
              'Hora Propuesta:',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _cargando ? null : _mostrarSeleccionadorHora,
              icon: const Icon(Icons.access_time),
              label: Text(
                _horaSeleccionada == null
                    ? 'Seleccionar hora'
                    : '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 📝 MOTIVO
            Text(
              'Razón del cambio:',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _motivoController,
              enabled: !_cargando,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Ej: No tengo disponibilidad en la hora original, propongo estas fechas...',
                hintStyle: GoogleFonts.dmSans(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF673AB7),
                    width: 2,
                  ),
                ),
              ),
              style: GoogleFonts.dmSans(),
            ),
            const SizedBox(height: 12),
            Text(
              '💡 El cliente recibirá tu propuesta y podrá aceptarla o rechazarla.',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cargando ? null : () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: GoogleFonts.dmSans(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _cargando ? null : _proponer,
          icon: _cargando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.send),
          label: Text(_cargando ? 'Enviando...' : 'Enviar Propuesta'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
