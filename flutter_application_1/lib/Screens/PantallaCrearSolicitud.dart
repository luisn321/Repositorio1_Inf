import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../validadores/validadores_servicios.dart';
import '../servicios_red/servicio_contrataciones.dart';

// ── Design tokens (sistema unificado Servitec) ───────────────────────────────
const Color _verde       = Color(0xFF1A5C38);
const Color _verdeClaro  = Color(0xFF247A4A);
const Color _verdeOscuro = Color(0xFF0F3B22);
const Color _acento      = Color(0xFF4CAF82);
const Color _fondoPage   = Color(0xFFF2F6F4);
const Color _fondoCampo  = Color(0xFFF4F7F5);
const Color _bordeField  = Color(0xFFDDE8E3);
const Color _grisTexto   = Color(0xFF8FA89B);
const Color _grisOscuro  = Color(0xFF3D4F46);
const Color _errorColor  = Color(0xFFE05252);
// ─────────────────────────────────────────────────────────────────────────────

class PantallaCrearSolicitud extends StatefulWidget {
  final int idCliente;
  final int? idTecnico;
  final int? idServicio;

  const PantallaCrearSolicitud({
    Key? key,
    required this.idCliente,
    this.idTecnico,
    this.idServicio,
  }) : super(key: key);

  @override
  State<PantallaCrearSolicitud> createState() => _PantallaCrearSolicitudState();
}

class _PantallaCrearSolicitudState extends State<PantallaCrearSolicitud>
    with SingleTickerProviderStateMixin {
  final _formKey              = GlobalKey<FormState>();
  final _ctrlDescripcion      = TextEditingController();
  final _ctrlFecha            = TextEditingController();
  final _ctrlHora             = TextEditingController();
  final _ctrlUbicacion        = TextEditingController();

  DateTime?  _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  bool       _enviando = false;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _ctrlDescripcion.dispose();
    _ctrlFecha.dispose();
    _ctrlHora.dispose();
    _ctrlUbicacion.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Pickers ──────────────────────────────────────────────────────────────
  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: ahora.add(const Duration(days: 1)),
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _verde, onPrimary: Colors.white,
            surface: Colors.white, onSurface: _grisOscuro,
          ),
        ),
        child: child!,
      ),
    );
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _ctrlFecha.text =
            '${fecha.day.toString().padLeft(2, '0')}/'
            '${fecha.month.toString().padLeft(2, '0')}/'
            '${fecha.year}';
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _verde, onPrimary: Colors.white,
            surface: Colors.white, onSurface: _grisOscuro,
          ),
        ),
        child: child!,
      ),
    );
    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
        _ctrlHora.text = hora.format(context);
      });
    }
  }

  // ── Envío ─────────────────────────────────────────────────────────────────
  Future<void> _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaSeleccionada == null) {
      _snack('Selecciona una fecha', error: true);
      return;
    }
    if (_horaSeleccionada == null) {
      _snack('Selecciona una hora', error: true);
      return;
    }

    setState(() => _enviando = true);
    try {
      // Si no hay idServicio requerido, muestra error
      if (widget.idServicio == null) {
        _snack('Error: Servicio no especificado', error: true);
        return;
      }

      // Llamar al servicio real para crear la solicitud
      final servicio = ServicioContrataciones();
      await servicio.crearContratacion(
        idCliente: widget.idCliente,
        idTecnico: widget.idTecnico, // ✨ Técnico al que va dirigida la solicitud
        idServicio: widget.idServicio!,
        descripcion: _ctrlDescripcion.text.trim(),
        fechaEstimada: _fechaSeleccionada!,
        horaSolicitada: _horaSeleccionada,
        ubicacion: _ctrlUbicacion.text.isNotEmpty ? _ctrlUbicacion.text : null,
      );

      _snack('✅ Solicitud enviada correctamente');
      debugPrint('✅ Solicitud creada: cliente=${widget.idCliente}, '
          'servicio=${widget.idServicio}, '
          'fecha=${_fechaSeleccionada!.toIso8601String()}');
      
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context, true); // true = solicitud creada
    } catch (e) {
      debugPrint('❌ Error creando solicitud: $e');
      _snack('Error al enviar: $e', error: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(error ? Icons.error_outline_rounded : Icons.check_circle_outline,
            color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg,
            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white))),
      ]),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? _errorColor : _verde,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPage,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // HEADER
            _buildHeader(),

            // FORMULARIO
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tarjeta formulario
                      _buildCard(
                        children: [
                          _buildSectionLabel('Descripción del problema',
                              Icons.description_outlined),
                          const SizedBox(height: 12),
                          _buildTextArea(),

                          const SizedBox(height: 22),
                          _buildSectionLabel('Fecha estimada',
                              Icons.calendar_today_outlined),
                          const SizedBox(height: 12),
                          _buildCampoTap(
                            ctrl: _ctrlFecha,
                            hint: 'Selecciona una fecha',
                            icono: Icons.calendar_month_rounded,
                            confirmado: _fechaSeleccionada != null,
                            onTap: _seleccionarFecha,
                            validator: ValidadoresServicios.validarFechaFutura,
                          ),

                          const SizedBox(height: 22),
                          _buildSectionLabel('Hora estimada',
                              Icons.access_time_rounded),
                          const SizedBox(height: 12),
                          _buildCampoTap(
                            ctrl: _ctrlHora,
                            hint: 'Selecciona una hora',
                            icono: Icons.schedule_rounded,
                            confirmado: _horaSeleccionada != null,
                            onTap: _seleccionarHora,
                            validator: (_) => _horaSeleccionada == null
                                ? 'Selecciona una hora'
                                : null,
                          ),

                          const SizedBox(height: 22),
                          _buildSectionLabel('Ubicación',
                              Icons.location_on_outlined),
                          const SizedBox(height: 12),
                          _buildCampoUbicacion(),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Botón enviar
                      _buildBotonEnviar(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
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
          Positioned(top: -30, right: -20,
              child: _Circle(size: 140, opacity: 0.07)),
          Positioned(top: 40, right: 55,
              child: _Circle(size: 55, opacity: 0.09)),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila superior: botón volver + badge
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2), width: 1),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _acento.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('SERVITEC',
                        style: GoogleFonts.dmMono(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: _acento, letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // Ícono + título
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.assignment_add,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nueva solicitud',
                              style: GoogleFonts.sora(
                                fontSize: 22, fontWeight: FontWeight.w700,
                                color: Colors.white, height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text('Completa los detalles del servicio',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tarjeta contenedora ───────────────────────────────────────────────────
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 14, offset: const Offset(0, 4),
        )],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ── Label de sección ──────────────────────────────────────────────────────
  Widget _buildSectionLabel(String texto, IconData icono) {
    return Row(
      children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
            color: _acento, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 10),
        Icon(icono, color: _verde, size: 16),
        const SizedBox(width: 7),
        Text(texto,
          style: GoogleFonts.sora(
            fontSize: 13, fontWeight: FontWeight.w700, color: _verde),
        ),
      ],
    );
  }

  // ── Área de descripción ───────────────────────────────────────────────────
  Widget _buildTextArea() {
    return TextFormField(
      controller: _ctrlDescripcion,
      maxLines: 5,
      style: GoogleFonts.dmSans(fontSize: 14, color: _grisOscuro),
      decoration: InputDecoration(
        hintText: 'Describe el problema o el servicio que necesitas…',
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: _grisTexto),
        filled: true, fillColor: _fondoCampo,
        contentPadding: const EdgeInsets.all(16),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _bordeField, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _bordeField, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _verde, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
      ),
      validator: ValidadoresServicios.validarDescripcion,
    );
  }

  // ── Campo tap (fecha / hora) ──────────────────────────────────────────────
  Widget _buildCampoTap({
    required TextEditingController ctrl,
    required String hint,
    required IconData icono,
    required bool confirmado,
    required VoidCallback onTap,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.dmSans(fontSize: 14, color: _grisOscuro),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: _grisTexto),
        filled: true, fillColor: _fondoCampo,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 15),
        prefixIcon: Icon(icono, color: _grisTexto, size: 20),
        suffixIcon: confirmado
            ? const Icon(Icons.check_circle_rounded,
                color: _acento, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _bordeField, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _bordeField, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _verde, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  // ── Campo ubicación ───────────────────────────────────────────────────────
  Widget _buildCampoUbicacion() {
    return TextFormField(
      controller: _ctrlUbicacion,
      style: GoogleFonts.dmSans(fontSize: 14, color: _grisOscuro),
      decoration: InputDecoration(
        hintText: 'Dirección o referencia de ubicación',
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: _grisTexto),
        filled: true, fillColor: _fondoCampo,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 15),
        prefixIcon: const Icon(Icons.location_on_outlined,
            color: _grisTexto, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _bordeField, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _bordeField, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _verde, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
      ),
      validator: ValidadoresServicios.validarUbicacion,
    );
  }

  // ── Botón enviar ──────────────────────────────────────────────────────────
  Widget _buildBotonEnviar() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _enviando ? null : _enviarSolicitud,
        style: ElevatedButton.styleFrom(
          backgroundColor: _verde,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _grisTexto,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: _enviando
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 18),
                  const SizedBox(width: 10),
                  Text('Enviar solicitud',
                    style: GoogleFonts.sora(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Círculo decorativo ────────────────────────────────────────────────────────
class _Circle extends StatelessWidget {
  final double size, opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.white.withValues(alpha: opacity), width: 1.5),
      ),
    );
  }
}
