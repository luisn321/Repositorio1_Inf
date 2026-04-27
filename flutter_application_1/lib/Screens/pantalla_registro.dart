import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modelos/index.dart';
import '../servicios_red/index.dart';
import '../validadores/validadores_autenticacion.dart';
import 'HomeCliente.dart';
import 'HomeTecnico.dart';

// ── Design tokens (mismos que PantallaInicioSesion) ─────────────────────────
const Color _verde       = Color(0xFF1A5C38);
const Color _verdeClaro  = Color(0xFF247A4A);
const Color _verdeOscuro = Color(0xFF0F3B22);
const Color _acento      = Color(0xFF4CAF82);
const Color _blanco      = Colors.white;
const Color _grisTexto   = Color(0xFF8FA89B);
const Color _fondoCampo  = Color(0xFFF4F7F5);
const Color _bordeField  = Color(0xFFDDE8E3);
// ─────────────────────────────────────────────────────────────────────────────

/// Pantalla de selección de tipo de registro (Cliente / Técnico)
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_verdeOscuro, _verde, _verdeClaro],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          // Círculos decorativos
          Positioned(top: -80, right: -60,  child: _DecorCircle(size: 240, opacity: 0.06)),
          Positioned(top: 160, right: 30,   child: _DecorCircle(size: 70,  opacity: 0.09)),
          Positioned(bottom: -60, left: -70, child: _DecorCircle(size: 260, opacity: 0.05)),

          SafeArea(
            child: Column(
              children: [
                // AppBar personalizado
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Etiqueta
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _acento.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'SERVITEC',
                                style: GoogleFonts.dmMono(
                                  fontSize: 10, fontWeight: FontWeight.w600,
                                  color: _acento, letterSpacing: 2.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            Text(
                              'Crear\ncuenta',
                              style: GoogleFonts.sora(
                                fontSize: 34, fontWeight: FontWeight.w700,
                                color: _blanco, height: 1.15, letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¿Cómo quieres usar Servitec?',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Tarjetas centradas con ancho máximo
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 360),
                                child: Column(
                                  children: [
                                    _TarjetaTipoUsuario(
                                      titulo: 'Soy Cliente',
                                      descripcion: 'Busco y contrato servicios técnicos',
                                      imagenPath: 'Iconos/Cliente2.png',
                                      iconoFallback: Icons.person_rounded,
                                      etiqueta: 'PARA CLIENTES',
                                      onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => const PantallaRegistroCliente()),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    _TarjetaTipoUsuario(
                                      titulo: 'Soy Técnico',
                                      descripcion: 'Ofrezco mis servicios profesionales',
                                      imagenPath: 'Iconos/Tecnico.png',
                                      iconoFallback: Icons.build_rounded,
                                      etiqueta: 'PARA PROFESIONALES',
                                      onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => const PantallaRegistroTecnico()),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
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
}

/// Tarjeta de selección con diseño glassmorphism
class _TarjetaTipoUsuario extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String imagenPath;
  final IconData iconoFallback;
  final String etiqueta;
  final VoidCallback onPressed;

  const _TarjetaTipoUsuario({
    required this.titulo,
    required this.descripcion,
    required this.imagenPath,
    required this.iconoFallback,
    required this.etiqueta,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25), width: 1.5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              // Ícono
              Container(
                width: 72, height: 72,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  imagenPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      Icon(iconoFallback, color: Colors.white, size: 38),
                ),
              ),

              const SizedBox(width: 16),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge etiqueta
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _acento.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        etiqueta,
                        style: GoogleFonts.dmMono(
                          fontSize: 8, fontWeight: FontWeight.w600,
                          color: _acento, letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      titulo,
                      style: GoogleFonts.sora(
                        fontSize: 17, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      descripcion,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Flecha
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════════════════
// REGISTRO CLIENTE
// ════════════════════════════════════════════════════════════════════════════
class PantallaRegistroCliente extends StatefulWidget {
  const PantallaRegistroCliente({super.key});

  @override
  State<PantallaRegistroCliente> createState() =>
      _PantallaRegistroClienteState();
}

class _PantallaRegistroClienteState extends State<PantallaRegistroCliente> {
  final _formularioKey = GlobalKey<FormState>();
  final _controladorNombre    = TextEditingController();
  final _controladorApellido  = TextEditingController();
  final _controladorCorreo    = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorConfirmar = TextEditingController();
  final _controladorTelefono  = TextEditingController();
  final _controladorDireccion = TextEditingController();

  late ServicioAutenticacion _servicio;
  bool _esCargando = false;
  bool _ocultarContrasena = true;
  bool _ocultarConfirmar  = true;

  @override
  void initState() {
    super.initState();
    _servicio = ServicioAutenticacion();
  }

  @override
  void dispose() {
    _controladorNombre.dispose();    _controladorApellido.dispose();
    _controladorCorreo.dispose();    _controladorContrasena.dispose();
    _controladorConfirmar.dispose(); _controladorTelefono.dispose();
    _controladorDireccion.dispose();
    super.dispose();
  }

  Future<void> _registrarCliente() async {
    if (!_formularioKey.currentState!.validate()) return;
    setState(() => _esCargando = true);
    try {
      final solicitud = SolicitudRegistroClienteModelo(
        nombre:    _controladorNombre.text.trim(),
        apellido:  _controladorApellido.text.trim(),
        correo:    _controladorCorreo.text.trim(),
        contrasena: _controladorContrasena.text,
        telefono:  _controladorTelefono.text.trim(),
        direccion: _controladorDireccion.text.trim(),
        latitud: 0.0, longitud: 0.0,
      );
      final usuario = await _servicio.registrarCliente(solicitud);
      if (!mounted) return;
      _mostrarSnack('Registro exitoso');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => HomeCliente(clienteId: usuario.id, usuario: usuario)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _mostrarSnack(e.toString());
    } finally {
      if (mounted) setState(() => _esCargando = false);
    }
  }

  void _mostrarSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.info_outline, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg,
            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white))),
      ]),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: _verdeOscuro,
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _FormularioRegistroShell(
      titulo: 'Registro\nde Cliente',
      subtitulo: 'Completa tu información para comenzar',
      etiquetaBadge: 'CLIENTE',
      imagenPath: 'Iconos/Cliente1.png',
      iconoFallback: Icons.person_rounded,
      textoBoton: 'Crear cuenta',
      esCargando: _esCargando,
      onSubmit: _registrarCliente,
      formularioKey: _formularioKey,
      secciones: [
        _SeccionFormulario(
          titulo: 'Información personal',
          campos: [
            _FilaDual(
              izquierda: _CampoInfo(
                controlador: _controladorNombre,
                hint: 'Nombre',
                icono: Icons.person_outline_rounded,
                validador: (v) => ValidadoresAutenticacion.validarNombre(v),
              ),
              derecha: _CampoInfo(
                controlador: _controladorApellido,
                hint: 'Apellido',
                icono: Icons.person_outline_rounded,
                validador: (v) => ValidadoresAutenticacion.validarCampoRequerido(v, 'Apellido'),
              ),
            ),
            _CampoInfo(
              controlador: _controladorCorreo,
              hint: 'Correo electrónico',
              icono: Icons.alternate_email_rounded,
              teclado: TextInputType.emailAddress,
              validador: ValidadoresAutenticacion.validarCorreo,
            ),
            _CampoInfo(
              controlador: _controladorTelefono,
              hint: 'Teléfono',
              icono: Icons.phone_outlined,
              teclado: TextInputType.phone,
              validador: ValidadoresAutenticacion.validarTelefono,
            ),
            _CampoInfo(
              controlador: _controladorDireccion,
              hint: 'Dirección',
              icono: Icons.location_on_outlined,
              validador: (v) => ValidadoresAutenticacion.validarCampoRequerido(v, 'Dirección'),
            ),
          ],
        ),
        _SeccionFormulario(
          titulo: 'Seguridad',
          campos: [
            _CampoInfo(
              controlador: _controladorContrasena,
              hint: 'Contraseña',
              icono: Icons.lock_outline_rounded,
              esContrasena: true,
              ocultar: _ocultarContrasena,
              onToggleOcultar: () =>
                  setState(() => _ocultarContrasena = !_ocultarContrasena),
              validador: ValidadoresAutenticacion.validarContrasena,
            ),
            _CampoInfo(
              controlador: _controladorConfirmar,
              hint: 'Confirmar contraseña',
              icono: Icons.lock_outline_rounded,
              esContrasena: true,
              ocultar: _ocultarConfirmar,
              onToggleOcultar: () =>
                  setState(() => _ocultarConfirmar = !_ocultarConfirmar),
              validador: (v) =>
                  ValidadoresAutenticacion.validarConfirmacionContrasena(
                      v, _controladorContrasena.text),
            ),
          ],
        ),
      ],
    );
  }
}


// ════════════════════════════════════════════════════════════════════════════
// REGISTRO TÉCNICO
// ════════════════════════════════════════════════════════════════════════════
class PantallaRegistroTecnico extends StatefulWidget {
  const PantallaRegistroTecnico({super.key});

  @override
  State<PantallaRegistroTecnico> createState() =>
      _PantallaRegistroTecnicoState();
}

class _PantallaRegistroTecnicoState extends State<PantallaRegistroTecnico> {
  final _formularioKey          = GlobalKey<FormState>();
  final _controladorNombre      = TextEditingController();
  final _controladorApellido    = TextEditingController();
  final _controladorCorreo      = TextEditingController();
  final _controladorContrasena  = TextEditingController();
  final _controladorConfirmar   = TextEditingController();
  final _controladorTelefono    = TextEditingController();
  final _controladorUbicacion   = TextEditingController();
  final _controladorTarifa      = TextEditingController();
  final _controladorDescripcion = TextEditingController();
  final _controladorExperiencia = TextEditingController();

  late ServicioAutenticacion _servicio;
  bool _esCargando = false;
  bool _ocultarContrasena = true;
  bool _ocultarConfirmar  = true;
  final Set<int> _serviciosSeleccionados = {};

  final _servicios = [
    {'id': 1, 'nombre': 'Electricista', 'icono': Icons.bolt_rounded},
    {'id': 2, 'nombre': 'Plomero',      'icono': Icons.water_drop_outlined},
    {'id': 3, 'nombre': 'Carpintero',   'icono': Icons.handyman_outlined},
    {'id': 4, 'nombre': 'Técnico PC',   'icono': Icons.computer_outlined},
    {'id': 5, 'nombre': 'Jardinería',   'icono': Icons.yard_outlined},
    {'id': 6, 'nombre': 'Línea Blanca', 'icono': Icons.kitchen_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _servicio = ServicioAutenticacion();
  }

  @override
  void dispose() {
    _controladorNombre.dispose();     _controladorApellido.dispose();
    _controladorCorreo.dispose();     _controladorContrasena.dispose();
    _controladorConfirmar.dispose();  _controladorTelefono.dispose();
    _controladorUbicacion.dispose();  _controladorTarifa.dispose();
    _controladorDescripcion.dispose(); _controladorExperiencia.dispose();
    super.dispose();
  }

  Future<void> _registrarTecnico() async {
    if (!_formularioKey.currentState!.validate()) {
      _mostrarSnack('Por favor completa todos los campos');
      return;
    }
    if (_serviciosSeleccionados.isEmpty) {
      _mostrarSnack('Selecciona al menos un servicio');
      return;
    }
    setState(() => _esCargando = true);
    try {
      final solicitud = SolicitudRegistroTecnicoModelo(
        nombre:    _controladorNombre.text.trim(),
        apellido:  _controladorApellido.text.trim(),
        correo:    _controladorCorreo.text.trim(),
        contrasena: _controladorContrasena.text,
        telefono:  _controladorTelefono.text.trim(),
        ubicacion: _controladorUbicacion.text.trim(),
        latitud: 0.0, longitud: 0.0,
        tarifaHora: double.parse(_controladorTarifa.text.trim()),
        idsServicios: _serviciosSeleccionados.toList(),
        descripcion: _controladorDescripcion.text.trim(),
        anosExperiencia: int.tryParse(_controladorExperiencia.text.trim()),
      );
      final usuario = await _servicio.registrarTecnico(solicitud);
      if (!mounted) return;
      _mostrarSnack('Registro exitoso');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => HomeTecnico(tecnicoId: usuario.id, usuario: usuario)),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _mostrarSnack(e.toString());
    } finally {
      if (mounted) setState(() => _esCargando = false);
    }
  }

  void _mostrarSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.info_outline, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg,
            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white))),
      ]),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: _verdeOscuro,
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return _FormularioRegistroShell(
      titulo: 'Perfil\nTécnico',
      subtitulo: 'Completa tus datos para ofrecer servicios',
      etiquetaBadge: 'TÉCNICO',
      imagenPath: 'Iconos/TecnicoPC2.png',
      iconoFallback: Icons.construction_rounded,
      textoBoton: 'Registrarme como técnico',
      esCargando: _esCargando,
      onSubmit: _registrarTecnico,
      formularioKey: _formularioKey,
      secciones: [
        _SeccionFormulario(
          titulo: 'Datos personales',
          campos: [
            _FilaDual(
              izquierda: _CampoInfo(
                controlador: _controladorNombre,
                hint: 'Nombre',
                icono: Icons.person_outline_rounded,
                validador: (v) => ValidadoresAutenticacion.validarNombre(v),
              ),
              derecha: _CampoInfo(
                controlador: _controladorApellido,
                hint: 'Apellido',
                icono: Icons.person_outline_rounded,
                validador: (v) =>
                    ValidadoresAutenticacion.validarCampoRequerido(v, 'Apellido'),
              ),
            ),
            _CampoInfo(
              controlador: _controladorCorreo,
              hint: 'Correo electrónico',
              icono: Icons.alternate_email_rounded,
              teclado: TextInputType.emailAddress,
              validador: ValidadoresAutenticacion.validarCorreo,
            ),
            _CampoInfo(
              controlador: _controladorTelefono,
              hint: 'Teléfono',
              icono: Icons.phone_outlined,
              teclado: TextInputType.phone,
              validador: ValidadoresAutenticacion.validarTelefono,
            ),
            _CampoInfo(
              controlador: _controladorUbicacion,
              hint: 'Ubicación / Dirección',
              icono: Icons.location_on_outlined,
              validador: (v) =>
                  ValidadoresAutenticacion.validarCampoRequerido(v, 'Ubicación'),
            ),
          ],
        ),
        _SeccionFormulario(
          titulo: 'Información profesional',
          campos: [
            _FilaDual(
              izquierda: _CampoInfo(
                controlador: _controladorTarifa,
                hint: 'Tarifa / hora (\$)',
                icono: Icons.attach_money_rounded,
                teclado: TextInputType.numberWithOptions(decimal: true),
                validador: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (double.tryParse(v) == null) return 'Número inválido';
                  if (double.parse(v) <= 0) return 'Debe ser > 0';
                  return null;
                },
              ),
              derecha: _CampoInfo(
                controlador: _controladorExperiencia,
                hint: 'Años de experiencia',
                icono: Icons.workspace_premium_outlined,
                teclado: TextInputType.number,
                validador: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (int.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),
            ),
            _CampoInfo(
              controlador: _controladorDescripcion,
              hint: 'Describe tu especialidad…',
              icono: Icons.description_outlined,
              maxLineas: 3,
              validador: (v) =>
                  ValidadoresAutenticacion.validarCampoRequerido(v, 'Descripción'),
            ),
          ],
        ),
        _SeccionFormulario(
          titulo: 'Seguridad',
          campos: [
            _CampoInfo(
              controlador: _controladorContrasena,
              hint: 'Contraseña',
              icono: Icons.lock_outline_rounded,
              esContrasena: true,
              ocultar: _ocultarContrasena,
              onToggleOcultar: () =>
                  setState(() => _ocultarContrasena = !_ocultarContrasena),
              validador: ValidadoresAutenticacion.validarContrasena,
            ),
            _CampoInfo(
              controlador: _controladorConfirmar,
              hint: 'Confirmar contraseña',
              icono: Icons.lock_outline_rounded,
              esContrasena: true,
              ocultar: _ocultarConfirmar,
              onToggleOcultar: () =>
                  setState(() => _ocultarConfirmar = !_ocultarConfirmar),
              validador: (v) =>
                  ValidadoresAutenticacion.validarConfirmacionContrasena(
                      v, _controladorContrasena.text),
            ),
          ],
        ),
        // Sección de servicios
        _SeccionServicios(
          servicios: _servicios,
          seleccionados: _serviciosSeleccionados,
          onToggle: (id) => setState(() {
            if (_serviciosSeleccionados.contains(id)) {
              _serviciosSeleccionados.remove(id);
            } else {
              _serviciosSeleccionados.add(id);
            }
          }),
        ),
      ],
    );
  }
}


// ════════════════════════════════════════════════════════════════════════════
// SHELL COMPARTIDO — estructura del formulario de registro
// ════════════════════════════════════════════════════════════════════════════
class _FormularioRegistroShell extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String etiquetaBadge;
  final String imagenPath;
  final IconData iconoFallback;
  final String textoBoton;
  final bool esCargando;
  final VoidCallback onSubmit;
  final GlobalKey<FormState> formularioKey;
  final List<Widget> secciones;

  const _FormularioRegistroShell({
    required this.titulo,
    required this.subtitulo,
    required this.etiquetaBadge,
    required this.imagenPath,
    required this.iconoFallback,
    required this.textoBoton,
    required this.esCargando,
    required this.onSubmit,
    required this.formularioKey,
    required this.secciones,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [_verdeOscuro, _verde, _verdeClaro],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Positioned(top: -60, right: -50,
              child: _DecorCircle(size: 200, opacity: 0.06)),
          Positioned(bottom: -80, left: -60,
              child: _DecorCircle(size: 250, opacity: 0.05)),

          SafeArea(
            child: Column(
              children: [
                // Header compacto
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      // Logo pequeño
                      Container(
                        width: 40, height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          imagenPath, fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              Icon(iconoFallback, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cabecera
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _acento.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          etiquetaBadge,
                          style: GoogleFonts.dmMono(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: _acento, letterSpacing: 2.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        titulo,
                        style: GoogleFonts.sora(
                          fontSize: 30, fontWeight: FontWeight.w700,
                          color: _blanco, height: 1.15, letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitulo,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Formulario en tarjeta blanca que ocupa el resto
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Form(
                      key: formularioKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...secciones,
                            const SizedBox(height: 28),
                            // Botón principal
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: esCargando ? null : onSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _verde,
                                  foregroundColor: _blanco,
                                  disabledBackgroundColor:
                                      _verde.withValues(alpha: 0.5),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                child: esCargando
                                    ? const SizedBox(
                                        height: 22, width: 22,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2.5,
                                        ))
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            textoBoton,
                                            style: GoogleFonts.sora(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 18),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
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
}


// ════════════════════════════════════════════════════════════════════════════
// COMPONENTES REUTILIZABLES
// ════════════════════════════════════════════════════════════════════════════

/// Sección con título y lista de campos
class _SeccionFormulario extends StatelessWidget {
  final String titulo;
  final List<Widget> campos;
  const _SeccionFormulario({required this.titulo, required this.campos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                  color: _acento,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: GoogleFonts.sora(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: _verde, letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        ...campos.expand((c) => [c, const SizedBox(height: 12)]).toList()
          ..removeLast(),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Dos campos en la misma fila (responsive)
class _FilaDual extends StatelessWidget {
  final Widget izquierda;
  final Widget derecha;
  const _FilaDual({required this.izquierda, required this.derecha});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 420) {
        return Row(children: [
          Expanded(child: izquierda),
          const SizedBox(width: 12),
          Expanded(child: derecha),
        ]);
      }
      return Column(children: [
        izquierda,
        const SizedBox(height: 12),
        derecha,
      ]);
    });
  }
}

/// Campo de texto unificado
class _CampoInfo extends StatelessWidget {
  final TextEditingController controlador;
  final String hint;
  final IconData icono;
  final bool esContrasena;
  final bool ocultar;
  final VoidCallback? onToggleOcultar;
  final TextInputType teclado;
  final FormFieldValidator<String?>? validador;
  final int maxLineas;

  const _CampoInfo({
    required this.controlador,
    required this.hint,
    required this.icono,
    this.esContrasena = false,
    this.ocultar = true,
    this.onToggleOcultar,
    this.teclado = TextInputType.text,
    this.validador,
    this.maxLineas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      obscureText: esContrasena ? ocultar : false,
      keyboardType: teclado,
      maxLines: esContrasena ? 1 : maxLineas,
      minLines: 1,
      style: GoogleFonts.dmSans(color: _verdeOscuro, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(color: _grisTexto, fontSize: 14),
        filled: true,
        fillColor: _fondoCampo,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icono, color: _verde, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: esContrasena
            ? IconButton(
                icon: Icon(
                  ocultar
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _grisTexto, size: 20,
                ),
                onPressed: onToggleOcultar,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
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
          borderSide:
              const BorderSide(color: Color(0xFFE05252), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE05252), width: 2),
        ),
        errorStyle: GoogleFonts.dmSans(
            fontSize: 11, color: const Color(0xFFE05252)),
      ),
      validator: validador,
    );
  }
}

/// Sección de selección de servicios
class _SeccionServicios extends StatelessWidget {
  final List<Map<String, dynamic>> servicios;
  final Set<int> seleccionados;
  final ValueChanged<int> onToggle;

  const _SeccionServicios({
    required this.servicios,
    required this.seleccionados,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título sección
        Row(
          children: [
            Container(
              width: 4, height: 18,
              decoration: BoxDecoration(
                color: _acento,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Servicios que ofreces',
              style: GoogleFonts.sora(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: _verde,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _acento.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'mín. 1',
                style: GoogleFonts.dmMono(
                    fontSize: 10, color: _verde, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Grid de tiles con icono
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.25,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: servicios.length,
          itemBuilder: (context, index) {
            final s = servicios[index];
            final id = s['id'] as int;
            final nombre = s['nombre'] as String;
            final icono = s['icono'] as IconData;
            final seleccionado = seleccionados.contains(id);

            return GestureDetector(
              onTap: () => onToggle(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: seleccionado ? _verde : _fondoCampo,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: seleccionado ? _verde : _bordeField,
                    width: seleccionado ? 2 : 1.5,
                  ),
                  boxShadow: seleccionado
                      ? [BoxShadow(
                          color: _verde.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4))]
                      : [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2))],
                ),
                child: Stack(
                  children: [
                    // Check badge arriba derecha
                    if (seleccionado)
                      Positioned(
                        top: 10, right: 10,
                        child: Container(
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 13),
                        ),
                      ),
                    // Contenido centrado
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Círculo con icono
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: seleccionado
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : _verde.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icono,
                              size: 24,
                              color: seleccionado ? Colors.white : _verde,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nombre,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: seleccionado ? Colors.white : _verdeOscuro,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Círculo decorativo (mismo que en login)
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

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

/// Selector tipo usuario (legacy placeholder)
class PantallaSelectorTipoUsuario extends StatelessWidget {
  const PantallaSelectorTipoUsuario({super.key});

  @override
  Widget build(BuildContext context) => const PantallaRegistro();
}
