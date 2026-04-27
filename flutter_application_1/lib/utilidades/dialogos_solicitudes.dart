import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../servicios_red/servicio_contrataciones.dart';

// ── Design tokens (sistema unificado Servitec) ───────────────────────────────
const Color _verde = Color(0xFF1A5C38);
const Color _verdeClaro = Color(0xFF247A4A);
const Color _acento = Color(0xFF4CAF82);
const Color _fondoCampo = Color(0xFFF4F7F5);
const Color _bordeField = Color(0xFFDDE8E3);
const Color _grisTexto = Color(0xFF8FA89B);
const Color _grisOscuro = Color(0xFF3D4F46);
const Color _errorColor = Color(0xFFE05252);
const Color _ambar = Color(0xFFF5A623);
const Color _purpura = Color(0xFF673AB7);
// ─────────────────────────────────────────────────────────────────────────────

// ════════════════════════════════════════════════════════════════════════════
// WIDGET BASE: Estructura común de todos los diálogos
// ════════════════════════════════════════════════════════════════════════════

/// Diálogo base con header coloreado + cuerpo blanco.
/// Evita repetir la estructura en cada diálogo.
class _DialogoBase extends StatelessWidget {
  final Color colorHeader;
  final IconData iconoHeader;
  final String titulo;
  final String? subtitulo;
  final Widget cuerpo;
  final List<Widget> acciones;

  const _DialogoBase({
    required this.colorHeader,
    required this.iconoHeader,
    required this.titulo,
    this.subtitulo,
    required this.cuerpo,
    required this.acciones,
  });

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ancho < 400 ? 16 : 24,
        vertical: 32,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Franja header ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorHeader.withOpacity(0.92), colorHeader],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconoHeader, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          if (subtitulo != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitulo!,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Cuerpo blanco ──────────────────────────────────────────
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: cuerpo,
                    ),
                    // Acciones
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: acciones
                            .map(
                              (a) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: a,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets reutilizables dentro del cuerpo ───────────────────────────────

/// Chip de información (fecha, hora, ubicación, cliente…)
class _InfoChip extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color color;

  const _InfoChip({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.22), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: color, size: 11),
              const SizedBox(width: 4),
              Text(
                etiqueta,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              valor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _grisOscuro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloque de descripción / texto largo
class _BloqueTexto extends StatelessWidget {
  final String texto;
  final String? titulo;

  const _BloqueTexto({required this.texto, this.titulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo != null) ...[
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: _acento,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                titulo!,
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _verde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _fondoCampo,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _bordeField, width: 1),
          ),
          child: Text(
            texto,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: _grisOscuro,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

/// Campo de texto reutilizable con estilo del sistema
class _CampoDialogo extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final int maxLines;
  final Color colorFoco;
  final bool habilitado;
  final TextInputType? teclado;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;

  const _CampoDialogo({
    required this.ctrl,
    required this.hint,
    this.maxLines = 1,
    this.colorFoco = _verde,
    this.habilitado = true,
    this.teclado,
    this.prefixText,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      enabled: habilitado,
      maxLines: maxLines,
      keyboardType: teclado,
      inputFormatters: inputFormatters,
      style: GoogleFonts.dmSans(fontSize: 14, color: _grisOscuro),
      decoration: InputDecoration(
        prefixText: prefixText,
        prefixStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _grisOscuro,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(fontSize: 13, color: _grisTexto),
        filled: true,
        fillColor: _fondoCampo,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _bordeField, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _bordeField, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorFoco, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _bordeField.withOpacity(0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

/// Botón secundario (cancelar / rechazar outlined)
class _BotonSecundario extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _BotonSecundario({required this.label, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color ?? _grisTexto,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: (color ?? _grisTexto).withOpacity(0.3)),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

/// Botón primario de acción
class _BotonPrimario extends StatelessWidget {
  final String label;
  final IconData icono;
  final Color color;
  final bool cargando;
  final VoidCallback? onTap;

  const _BotonPrimario({
    required this.label,
    required this.icono,
    required this.color,
    this.cargando = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: cargando ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: _grisTexto,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: cargando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Pill selector de fecha/hora tap-able
class _PillSelector extends StatelessWidget {
  final IconData icono;
  final String label;
  final Color color;
  final bool seleccionado;
  final bool habilitado;
  final VoidCallback onTap;

  const _PillSelector({
    required this.icono,
    required this.label,
    required this.color,
    required this.seleccionado,
    required this.onTap,
    this.habilitado = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: habilitado ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: seleccionado ? color.withOpacity(0.08) : _fondoCampo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? color.withOpacity(0.4) : _bordeField,
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icono, color: seleccionado ? color : _grisTexto, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w400,
                  color: seleccionado ? _grisOscuro : _grisTexto,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: seleccionado ? color : _grisTexto,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 1. DIÁLOGO: ACEPTAR SOLICITUD
// ════════════════════════════════════════════════════════════════════════════
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
      await _servicio.aceptarSolicitud(widget.idSolicitud, widget.idTecnico);
      if (mounted) {
        Navigator.pop(context);
        widget.onAceptacion();
      }
    } catch (e) {
      if (mounted) _snackError('Error al aceptar: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _snackError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
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
        backgroundColor: _errorColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatFecha(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/'
      '${f.month.toString().padLeft(2, '0')}/'
      '${f.year}';

  @override
  Widget build(BuildContext context) {
    return _DialogoBase(
      colorHeader: _verde,
      iconoHeader: Icons.assignment_turned_in_outlined,
      titulo: 'Aceptar solicitud',
      subtitulo: '¿Confirmas que tomarás este trabajo?',
      acciones: [
        _BotonSecundario(
          label: 'Cancelar',
          onTap: _cargando ? null : () => Navigator.pop(context),
        ),
        _BotonPrimario(
          label: 'Aceptar',
          icono: Icons.check_rounded,
          color: _verde,
          cargando: _cargando,
          onTap: _aceptar,
        ),
      ],
      cuerpo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chips de info
          if (widget.nombreCliente != null &&
              widget.nombreCliente!.isNotEmpty) ...[
            _InfoChip(
              icono: Icons.person_rounded,
              etiqueta: 'CLIENTE',
              valor: widget.nombreCliente!,
              color: _verde,
            ),
            const SizedBox(height: 10),
          ],

          if (widget.fechaSolicitada != null ||
              widget.horaStr != null ||
              widget.ubicacion != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (widget.fechaSolicitada != null)
                  _InfoChip(
                    icono: Icons.calendar_today_outlined,
                    etiqueta: 'FECHA',
                    valor: _formatFecha(widget.fechaSolicitada!),
                    color: const Color(0xFF1565C0),
                  ),
                if (widget.horaStr != null && widget.horaStr!.isNotEmpty)
                  _InfoChip(
                    icono: Icons.schedule_rounded,
                    etiqueta: 'HORA',
                    valor: widget.horaStr!,
                    color: const Color(0xFF00695C),
                  ),
                if (widget.ubicacion != null && widget.ubicacion!.isNotEmpty)
                  _InfoChip(
                    icono: Icons.location_on_outlined,
                    etiqueta: 'UBICACIÓN',
                    valor: widget.ubicacion!,
                    color: _ambar,
                  ),
              ],
            ),

          const SizedBox(height: 14),

          // Descripción
          _BloqueTexto(
            titulo: 'Descripción del trabajo',
            texto: widget.descripcionSolicitud,
          ),

          const SizedBox(height: 14),

          // Aviso de confirmación
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _verde.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _verde.withOpacity(0.15), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: _verde, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Al aceptar, el cliente será notificado y podrás coordinar los detalles.',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: _verde,
                      height: 1.4,
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
}

// ════════════════════════════════════════════════════════════════════════════
// 2. DIÁLOGO: RECHAZAR SOLICITUD
// ════════════════════════════════════════════════════════════════════════════
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
  final _ctrlMotivo = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _ctrlMotivo.dispose();
    super.dispose();
  }

  Future<void> _rechazar() async {
    final motivo = _ctrlMotivo.text.trim();
    if (motivo.isEmpty) {
      _snack('Por favor escribe un motivo antes de continuar', warn: true);
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
      if (mounted) _snack('Error al rechazar: $e', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _snack(String msg, {bool error = false, bool warn = false}) {
    final bg = error
        ? _errorColor
        : warn
        ? _ambar
        : _verde;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DialogoBase(
      colorHeader: _errorColor,
      iconoHeader: Icons.cancel_outlined,
      titulo: 'Rechazar solicitud',
      subtitulo: 'Explica brevemente tu motivo',
      acciones: [
        _BotonSecundario(
          label: 'Volver',
          onTap: _cargando ? null : () => Navigator.pop(context),
        ),
        _BotonPrimario(
          label: 'Rechazar',
          icono: Icons.close_rounded,
          color: _errorColor,
          cargando: _cargando,
          onTap: _rechazar,
        ),
      ],
      cuerpo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: _errorColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Motivo del rechazo',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _CampoDialogo(
            ctrl: _ctrlMotivo,
            hint: 'Ej: No tengo disponibilidad en esa fecha…',
            maxLines: 4,
            colorFoco: _errorColor,
            habilitado: !_cargando,
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _errorColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _errorColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: _errorColor.withOpacity(0.7),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'El cliente verá este motivo para entender por qué fue rechazado.',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: _errorColor.withOpacity(0.8),
                      height: 1.4,
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
}

// ════════════════════════════════════════════════════════════════════════════
// 3. DIÁLOGO: PROPONER MONTO
// ════════════════════════════════════════════════════════════════════════════
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
  final _ctrlMonto = TextEditingController();
  final _ctrlClabe = TextEditingController();
  bool _cargando = false;
  double _montoNeto = 0;
  double _montoTotal = 0;
  double _comision = 0;

  @override
  void initState() {
    super.initState();
    if (widget.montoOriginal != null && widget.montoOriginal! > 0) {
      _ctrlMonto.text = widget.montoOriginal!.toStringAsFixed(2);
      _calcularComision();
    }
    _ctrlMonto.addListener(_calcularComision);
  }

  void _calcularComision() {
    final raw = double.tryParse(_ctrlMonto.text.trim()) ?? 0;
    if (raw <= 0) {
      setState(() {
        _montoNeto = 0;
        _montoTotal = 0;
        _comision = 0;
      });
      return;
    }

    // Fórmula: Total = (Neto + 3.48) / 0.95824
    // 3.48 = (3.00 * 1.16)
    // 0.95824 = 1 - (0.036 * 1.16)
    final total = (raw + 3.48) / 0.95824;
    setState(() {
      _montoNeto = raw;
      _montoTotal = total;
      _comision = total - raw;
    });
  }

  @override
  void dispose() {
    _ctrlMonto.removeListener(_calcularComision);
    _ctrlMonto.dispose();
    _ctrlClabe.dispose();
    super.dispose();
  }

  Future<void> _proponer() async {
    final monto = double.tryParse(_ctrlMonto.text.trim());
    if (monto == null || monto <= 0) {
      _snack('Ingresa un monto válido mayor a \$0', warn: true);
      return;
    }
    final clabe = _ctrlClabe.text.trim();
    if (clabe.isEmpty || clabe.length != 18) {
      _snack('La CLABE debe tener exactamente 18 dígitos', warn: true);
      return;
    }

    setState(() => _cargando = true);
    try {
      await _servicio.proponerMonto(
        widget.idSolicitud,
        monto,
        clabeTecnico: clabe,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onMontoProuesto();
      }
    } catch (e) {
      if (mounted) _snack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _snack(String msg, {bool error = false, bool warn = false}) {
    final bg = error
        ? _errorColor
        : warn
        ? _ambar
        : _verde;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DialogoBase(
      colorHeader: _ambar,
      iconoHeader: Icons.payments_outlined,
      titulo: 'Proponer monto',
      subtitulo: 'Define tu cobro por este servicio',
      acciones: [
        _BotonSecundario(
          label: 'Cancelar',
          onTap: _cargando ? null : () => Navigator.pop(context),
        ),
        _BotonPrimario(
          label: 'Proponer',
          icono: Icons.send_rounded,
          color: _ambar,
          cargando: _cargando,
          onTap: _proponer,
        ),
      ],
      cuerpo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo monto
          _LabelCampo(
            'Monto a cobrar',
            icono: Icons.attach_money_rounded,
            color: _ambar,
          ),
          const SizedBox(height: 8),
          _CampoDialogo(
            ctrl: _ctrlMonto,
            hint: '0.00',
            prefixText: '\$ ',
            colorFoco: _ambar,
            habilitado: !_cargando,
            teclado: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),

          if (_montoTotal > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _ambar.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _ambar.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _rowDesglose('Tú recibes (Neto):', '\$${_montoNeto.toStringAsFixed(2)}', isDestacado: true),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Divider(height: 1),
                  ),
                  _rowDesglose('Comisión Stripe:', '\$${_comision.toStringAsFixed(2)}'),
                  _rowDesglose('El cliente paga:', '\$${_montoTotal.toStringAsFixed(2)}', isBold: true),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Campo CLABE
          _LabelCampo(
            'CLABE interbancaria (18 dígitos)',
            icono: Icons.account_balance_outlined,
            color: _ambar,
          ),
          const SizedBox(height: 8),
          _CampoDialogo(
            ctrl: _ctrlClabe,
            hint: '000000000000000000',
            colorFoco: _ambar,
            habilitado: !_cargando,
            teclado: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(18),
            ],
          ),

          const SizedBox(height: 14),

          // Nota informativa
          _NotaInfo(
            '💡 El monto será asegurado del cliente y depositado a tu CLABE al finalizar el servicio.',
            color: _ambar,
          ),
        ],
      ),
    );
  }

  Widget _rowDesglose(String label, String value,
      {bool isBold = false, bool isDestacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: isDestacado ? _grisOscuro : _grisTexto,
              fontWeight: isDestacado ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight:
                  isBold || isDestacado ? FontWeight.w700 : FontWeight.w500,
              color: isDestacado ? _verde : (isBold ? _grisOscuro : _grisTexto),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 4. DIÁLOGO: RESPONDER MONTO (Cliente)
// ════════════════════════════════════════════════════════════════════════════
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

  Future<void> _aceptar() async {
    setState(() => _cargando = true);
    try {
      await _servicio.aceptarMonto(widget.idSolicitud);
      if (mounted) {
        Navigator.pop(context);
        widget.onRespuesta();
      }
    } catch (e) {
      if (mounted) _snackError('Error: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _rechazar() async {
    setState(() => _cargando = true);
    try {
      await _servicio.rechazarMonto(widget.idSolicitud);
      if (mounted) {
        Navigator.pop(context);
        widget.onRespuesta();
      }
    } catch (e) {
      if (mounted) _snackError('Error: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _snackError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _errorColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DialogoBase(
      colorHeader: _verde,
      iconoHeader: Icons.request_quote_outlined,
      titulo: 'Monto propuesto',
      subtitulo: widget.nombreTecnico != null
          ? 'Por ${widget.nombreTecnico}'
          : '¿Aceptas este cobro?',
      acciones: [
        _BotonPrimario(
          label: 'Rechazar',
          icono: Icons.close_rounded,
          color: _errorColor,
          cargando: _cargando,
          onTap: _rechazar,
        ),
        _BotonPrimario(
          label: 'Aceptar',
          icono: Icons.check_rounded,
          color: _verde,
          cargando: _cargando,
          onTap: _aceptar,
        ),
      ],
      cuerpo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Display monto grande centrado
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_verde.withOpacity(0.06), _acento.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _verde.withOpacity(0.15), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'Total a pagar',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _grisTexto,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${widget.monto.toStringAsFixed(2)}',
                  style: GoogleFonts.sora(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: _verde,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'MXN',
                  style: GoogleFonts.dmMono(
                    fontSize: 11,
                    color: _grisTexto,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _NotaInfo(
            'Al aceptar, el monto será reservado de forma segura hasta finalizar el servicio.',
            color: _verde,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// 5. DIÁLOGO: PROPONER ALTERNATIVA (Técnico)
// ════════════════════════════════════════════════════════════════════════════
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
  final _ctrlMotivo = TextEditingController();
  DateTime? _fecha;
  TimeOfDay? _hora;
  bool _cargando = false;

  @override
  void dispose() {
    _ctrlMotivo.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final f = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _purpura,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (f != null) setState(() => _fecha = f);
  }

  Future<void> _seleccionarHora() async {
    final h = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _purpura,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (h != null) setState(() => _hora = h);
  }

  Future<void> _proponer() async {
    final motivo = _ctrlMotivo.text.trim();
    if (_fecha == null) {
      _snack('Selecciona una fecha propuesta', warn: true);
      return;
    }
    if (_hora == null) {
      _snack('Selecciona una hora propuesta', warn: true);
      return;
    }
    if (motivo.isEmpty) {
      _snack('Escribe el motivo del cambio', warn: true);
      return;
    }

    setState(() => _cargando = true);
    try {
      final horaStr =
          '${_hora!.hour.toString().padLeft(2, '0')}:${_hora!.minute.toString().padLeft(2, '0')}';
      await _servicio.proponerPropuesta(
        widget.idSolicitud,
        fechaPropuestaSolicitada: _fecha!,
        horaPropuestaSolicitada: horaStr,
        motivoCambio: motivo,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onPropuestaPropuesta();
      }
    } catch (e) {
      if (mounted) _snack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _snack(String msg, {bool error = false, bool warn = false}) {
    final bg = error
        ? _errorColor
        : warn
        ? _ambar
        : _verde;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatFecha(DateTime f) =>
      '${f.day.toString().padLeft(2, '0')}/'
      '${f.month.toString().padLeft(2, '0')}/'
      '${f.year}';

  String _formatHora(TimeOfDay h) =>
      '${h.hour.toString().padLeft(2, '0')}:'
      '${h.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return _DialogoBase(
      colorHeader: _purpura,
      iconoHeader: Icons.edit_calendar_outlined,
      titulo: 'Proponer alternativa',
      subtitulo: 'Sugiere una nueva fecha y hora',
      acciones: [
        _BotonSecundario(
          label: 'Cancelar',
          onTap: _cargando ? null : () => Navigator.pop(context),
        ),
        _BotonPrimario(
          label: 'Enviar',
          icono: Icons.send_rounded,
          color: _purpura,
          cargando: _cargando,
          onTap: _proponer,
        ),
      ],
      cuerpo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fecha
          _LabelCampo(
            'Fecha propuesta',
            icono: Icons.calendar_today_outlined,
            color: _purpura,
          ),
          const SizedBox(height: 8),
          _PillSelector(
            icono: Icons.calendar_month_outlined,
            label: _fecha != null ? _formatFecha(_fecha!) : 'Seleccionar fecha',
            color: _purpura,
            seleccionado: _fecha != null,
            habilitado: !_cargando,
            onTap: _seleccionarFecha,
          ),

          const SizedBox(height: 14),

          // Hora
          _LabelCampo(
            'Hora propuesta',
            icono: Icons.schedule_outlined,
            color: _purpura,
          ),
          const SizedBox(height: 8),
          _PillSelector(
            icono: Icons.access_time_rounded,
            label: _hora != null ? _formatHora(_hora!) : 'Seleccionar hora',
            color: _purpura,
            seleccionado: _hora != null,
            habilitado: !_cargando,
            onTap: _seleccionarHora,
          ),

          const SizedBox(height: 14),

          // Motivo
          _LabelCampo(
            'Motivo del cambio',
            icono: Icons.chat_bubble_outline_rounded,
            color: _purpura,
          ),
          const SizedBox(height: 8),
          _CampoDialogo(
            ctrl: _ctrlMotivo,
            hint: 'Ej: No tengo disponibilidad en la hora original…',
            maxLines: 3,
            colorFoco: _purpura,
            habilitado: !_cargando,
          ),

          const SizedBox(height: 12),

          _NotaInfo(
            'El cliente recibirá tu propuesta y podrá aceptarla o rechazarla.',
            color: _purpura,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// HELPERS INTERNOS
// ════════════════════════════════════════════════════════════════════════════

/// Label de sección con barra lateral coloreada
class _LabelCampo extends StatelessWidget {
  final String texto;
  final IconData icono;
  final Color color;
  const _LabelCampo(this.texto, {required this.icono, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icono, color: color, size: 13),
        const SizedBox(width: 6),
        Text(
          texto,
          style: GoogleFonts.sora(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _grisOscuro,
          ),
        ),
      ],
    );
  }
}

/// Nota informativa con ícono y color
class _NotaInfo extends StatelessWidget {
  final String texto;
  final Color color;
  const _NotaInfo(this.texto, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: color.withOpacity(0.7),
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: color.withOpacity(0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
