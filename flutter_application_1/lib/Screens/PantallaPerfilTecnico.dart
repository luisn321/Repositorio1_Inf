import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../modelos/usuario_modelo.dart';
import '../servicios_red/servicio_autenticacion.dart';
import '../servicios_red/servicio_imagenes.dart';
import '../utilidades/visor_imagenes_universal.dart';
import 'pantalla_inicio_sesion.dart';


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
const Color _ambarSuave = Color(0xFFFFE0B2);
// ─────────────────────────────────────────────────────────────────────────────

class PantallaPerfilTecnico extends StatefulWidget {
  final int tecnicoId;
  final UsuarioModelo? usuarioActual;

  const PantallaPerfilTecnico({
    required this.tecnicoId,
    this.usuarioActual,
    super.key,
  });

  @override
  State<PantallaPerfilTecnico> createState() => _PantallaPerfilTecnicoState();
}

class _PantallaPerfilTecnicoState extends State<PantallaPerfilTecnico>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nombreCtrl;
  late TextEditingController _apellidoCtrl;
  late TextEditingController _correoCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _ubicacionCtrl;
  late TextEditingController _tarifaCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _experienciaCtrl;
  late TextEditingController _contrasenaActualCtrl;
  late TextEditingController _contrasenaNuevaCtrl;
  late TextEditingController _confirmarContrasenaCtrl;

  late ServicioAutenticacion _servicio;
  late ServicioImagenes _servicioImagenes; // ✨
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  UsuarioModelo? _usuarioActual;
  String? _ubicacionTextDelBackend;

  bool _enEdicion = false;
  bool _cargandoPerfil = true;
  bool _esCargando = false;
  bool _ocultarContrasena = true;
  bool _ocultarContrasenaNueva = true;
  bool _ocultarConfirmarContrasena = true;

  @override
  void initState() {
    super.initState();
    _servicio = ServicioAutenticacion();
    _servicioImagenes = ServicioImagenes(); // ✨
    _usuarioActual = widget.usuarioActual;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    _cargarPerfilCompleto();
  }

  // ── Lógica de red (sin cambios) ──────────────────────────────────────────
  Future<void> _cargarPerfilCompleto() async {
    try {
      final token = await _servicio.obtenerToken();
      if (token != null) {
        final respuesta = await http.get(
          Uri.parse('https://repositorio1-inf.onrender.com/api/auth/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        if (respuesta.statusCode == 200) {
          final datos = jsonDecode(respuesta.body);
          print(' Datos perfil técnico recibidos: $datos');
          _usuarioActual = UsuarioModelo.desdeJson(datos);
          _ubicacionTextDelBackend = _usuarioActual?.ubicacionTexto ?? '';
        }
      }
    } catch (e) {
      debugPrint('Error cargando perfil técnico: $e');
    } finally {
      if (mounted) {
        setState(() {
          _cargandoPerfil = false;
          _inicializarControladores();
        });
        _animCtrl.forward();
      }
    }
  }

  void _inicializarControladores() {
    final u = _usuarioActual;
    _nombreCtrl = TextEditingController(text: u?.nombre ?? '');
    _apellidoCtrl = TextEditingController(text: u?.apellido ?? '');
    _correoCtrl = TextEditingController(text: u?.correo ?? '');
    _telefonoCtrl = TextEditingController(text: u?.telefono ?? '');
    _ubicacionCtrl = TextEditingController(
      text: _ubicacionTextDelBackend ?? '',
    );
    _tarifaCtrl = TextEditingController(text: u?.tarifaHora?.toString() ?? '');
    _descripcionCtrl = TextEditingController(text: u?.descripcion ?? '');
    _experienciaCtrl = TextEditingController(
      text: u?.anosExperiencia?.toString() ?? '',
    );
    _contrasenaActualCtrl = TextEditingController();
    _contrasenaNuevaCtrl = TextEditingController();
    _confirmarContrasenaCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _ubicacionCtrl.dispose();
    _tarifaCtrl.dispose();
    _descripcionCtrl.dispose();
    _experienciaCtrl.dispose();
    _contrasenaActualCtrl.dispose();
    _contrasenaNuevaCtrl.dispose();
    _confirmarContrasenaCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleEdicion() {
    setState(() {
      _enEdicion = !_enEdicion;
      if (!_enEdicion) _inicializarControladores();
    });
  }

  Future<void> _guardarCambios() async {
    if (_nombreCtrl.text.trim().isEmpty) {
      _mostrarSnack('El nombre es requerido', error: true);
      return;
    }
    if (_apellidoCtrl.text.trim().isEmpty) {
      _mostrarSnack('El apellido es requerido', error: true);
      return;
    }
    if (_correoCtrl.text.trim().isEmpty) {
      _mostrarSnack('El correo es requerido', error: true);
      return;
    }
    if (_telefonoCtrl.text.trim().isEmpty) {
      _mostrarSnack('El teléfono es requerido', error: true);
      return;
    }
    if (_tarifaCtrl.text.trim().isEmpty) {
      _mostrarSnack('La tarifa es requerida', error: true);
      return;
    }
    if (_descripcionCtrl.text.trim().isEmpty) {
      _mostrarSnack('La descripción es requerida', error: true);
      return;
    }
    if (_experienciaCtrl.text.trim().isEmpty) {
      _mostrarSnack('Los años de experiencia son requeridos', error: true);
      return;
    }

    if (_contrasenaNuevaCtrl.text.isNotEmpty ||
        _confirmarContrasenaCtrl.text.isNotEmpty) {
      if (_contrasenaActualCtrl.text.isEmpty) {
        _mostrarSnack('Ingresa tu contraseña actual', error: true);
        return;
      }
      if (_contrasenaNuevaCtrl.text.length < 6) {
        _mostrarSnack(
          'La nueva contraseña debe tener al menos 6 caracteres',
          error: true,
        );
        return;
      }
      if (_contrasenaNuevaCtrl.text != _confirmarContrasenaCtrl.text) {
        _mostrarSnack('Las contraseñas no coinciden', error: true);
        return;
      }
    }

    setState(() => _esCargando = true);
    try {
      final tarifa = double.tryParse(_tarifaCtrl.text) ?? 0;
      final experiencia = int.tryParse(_experienciaCtrl.text) ?? 0;

      final usuarioActualizado = await _servicio.actualizarPerfil(
        usuarioId: _usuarioActual?.id ?? 0,
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
        correo: _correoCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        esTecnico: true,
        tarifa: tarifa,
        ubicacion: _ubicacionCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        anosExperiencia: experiencia,
        contrasenaActual: _contrasenaActualCtrl.text.isNotEmpty
            ? _contrasenaActualCtrl.text
            : null,
        contrasenaNueva: _contrasenaNuevaCtrl.text.isNotEmpty
            ? _contrasenaNuevaCtrl.text
            : null,
        fotoPerfilUrl: _usuarioActual?.fotoPerfilUrl, // ✨
      );

      if (!mounted) return;
      setState(() {
        _usuarioActual = usuarioActualizado;
        _enEdicion = false;
      });
      _inicializarControladores();
      _mostrarSnack('Perfil actualizado correctamente');
    } catch (e) {
      if (!mounted) return;
      _mostrarSnack('Error al guardar: $e', error: true);
    } finally {
      if (mounted) setState(() => _esCargando = false);
    }
  }

  void _mostrarSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String get _nombreCompleto {
    final n = _usuarioActual?.nombre ?? '';
    final a = _usuarioActual?.apellido ?? '';
    return '$n $a'.trim().isEmpty ? 'Técnico' : '$n $a'.trim();
  }

  String get _iniciales {
    final n = _usuarioActual?.nombre ?? '';
    final a = _usuarioActual?.apellido ?? '';
    final ni = n.isNotEmpty ? n[0].toUpperCase() : '';
    final ai = a.isNotEmpty ? a[0].toUpperCase() : '';
    return '$ni$ai'.isEmpty ? 'T' : '$ni$ai';
  }

  double? get _calificacion => _usuarioActual?.calificacionPromedio;

  // ── Lógica de Fotos ──────────────────────────────────────────────────────
  Future<void> _cambiarFotoPerfil() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                'Seleccionar foto de perfil',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w700,
                  color: _verde,
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: _verdeClaro,
                ),
                title: Text('Galería', style: GoogleFonts.dmSans()),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: _verdeClaro,
                ),
                title: Text('Cámara', style: GoogleFonts.dmSans()),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );

      if (source == null) return;

      final file = await _servicioImagenes.seleccionarImagen(source);
      if (file == null || !mounted) return;

      setState(() => _esCargando = true);
      _mostrarSnack('Subiendo imagen...');

      // 1. Subir a Cloudinary via Backend
      final url = await _servicioImagenes.subirImagen(
        file,
        folder: 'perfiles_tecnicos',
      );

      if (url == null) throw Exception('No se pudo subir la imagen');

      // 2. Actualizar perfil
      final usuarioActualizado = await _servicio.actualizarPerfil(
        usuarioId: _usuarioActual!.id,
        esTecnico: true,
        fotoPerfilUrl: url,
      );

      if (mounted) {
        setState(() {
          _usuarioActual = usuarioActualizado;
          _esCargando = false;
        });
        _mostrarSnack('Foto de perfil actualizada');
      }
    } catch (e) {
      debugPrint('Error _cambiarFotoPerfil: $e');
      if (mounted) {
        setState(() => _esCargando = false);
        _mostrarSnack('Error al cambiar foto', error: true);
      }
    }
  }

  void _verFotoPantallaCompleta() {
    if (_usuarioActual?.fotoPerfilUrl == null || _usuarioActual!.fotoPerfilUrl!.isEmpty) return;
    VisorImagenUniversal.abrir(context, _usuarioActual!.fotoPerfilUrl!, 'avatar_tecnico');
  }

  // ── Métodos de Cuenta ────────────────────────────────────────────────────
  void _mostrarMenuOpciones() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Opciones de cuenta',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _verde,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _verde.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: _verde, size: 20),
              ),
              title: Text(
                'Cerrar sesión',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Salir de tu cuenta actual',
                style: GoogleFonts.dmSans(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmarCerrarSesion();
              },
            ),
            const Divider(height: 1, indent: 70),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _errorColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                 ),
                child: const Icon(Icons.delete_forever_rounded, color: _errorColor, size: 20),
              ),
              title: Text(
                'Eliminar cuenta',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: _errorColor,
                ),
              ),
              subtitle: Text(
                'Borrar tus datos permanentemente',
                style: GoogleFonts.dmSans(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminarCuenta();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmarCerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Cerrar sesión?',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: _verde),
        ),
        content: Text(
          '¿Estás seguro de que deseas salir de tu cuenta?',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.dmSans(color: _grisTexto),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _ejecutarCerrarSesion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _verde,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cerrar sesión',
              style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarCerrarSesion() async {
    try {
      await _servicio.cerrarSesion();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PantallaInicioSesion()),
        (route) => false,
      );
    } catch (e) {
      _mostrarSnack('Error al cerrar sesión', error: true);
    }
  }

  void _confirmarEliminarCuenta() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: _errorColor),
            const SizedBox(width: 10),
            Text(
              'Eliminar cuenta',
              style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: _errorColor),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta acción es irreversible.',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Al eliminar tu cuenta, todos tus datos personales, historial de servicios y preferencias serán borrados de nuestra base de datos conforme a la normativa de protección de datos.',
              style: GoogleFonts.dmSans(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              '¿Deseas continuar?',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.dmSans(color: _grisTexto),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _ejecutarEliminarCuenta();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _errorColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Eliminar permanentemente',
              style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarEliminarCuenta() async {
    setState(() => _esCargando = true);
    try {
      final exito = await _servicio.eliminarCuenta();
      if (exito && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PantallaInicioSesion()),
          (route) => false,
        );
        _mostrarSnack('Tu cuenta ha sido eliminada exitosamente.');
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnack(e.toString().replaceAll('Exception: ', ''), error: true);
        setState(() => _esCargando = false);
      }
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_cargandoPerfil) {
      return Scaffold(
        backgroundColor: _fondoPage,
        body: Stack(
          children: [
            Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_verdeOscuro, _verde, _verdeClaro],
                  stops: [0.0, 0.55, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
            ),
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      );
    }

    if (_usuarioActual == null) {
      return Scaffold(
        backgroundColor: _fondoPage,
        body: Center(
          child: Text(
            'No hay datos de usuario',
            style: GoogleFonts.dmSans(color: _grisTexto),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _fondoPage,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── HEADER ──────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── CUERPO ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stats rápidos (solo vista)
                    if (!_enEdicion) _buildStatsRow(),
                    if (!_enEdicion) const SizedBox(height: 20),

                    // Sección: Información personal
                    _buildSeccion(
                      titulo: 'Información personal',
                      children: [
                        _buildFilaDual(
                          izq: _buildCampo(
                            label: 'Nombre',
                            ctrl: _nombreCtrl,
                            icono: Icons.person_outline_rounded,
                          ),
                          der: _buildCampo(
                            label: 'Apellido',
                            ctrl: _apellidoCtrl,
                            icono: Icons.person_outline_rounded,
                          ),
                        ),
                        _buildCampo(
                          label: 'Correo electrónico',
                          ctrl: _correoCtrl,
                          icono: Icons.alternate_email_rounded,
                          teclado: TextInputType.emailAddress,
                        ),
                        _buildCampo(
                          label: 'Teléfono',
                          ctrl: _telefonoCtrl,
                          icono: Icons.phone_outlined,
                          teclado: TextInputType.phone,
                        ),
                        _buildCampo(
                          label: 'Ubicación de trabajo',
                          ctrl: _ubicacionCtrl,
                          icono: Icons.location_on_outlined,
                          maxLineas: 2,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Sección: Información profesional
                    _buildSeccion(
                      titulo: 'Información profesional',
                      icono: Icons.workspace_premium_outlined,
                      children: [
                        _buildFilaDual(
                          izq: _buildCampo(
                            label: 'Tarifa / hora (\$)',
                            ctrl: _tarifaCtrl,
                            icono: Icons.attach_money_rounded,
                            teclado: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          der: _buildCampo(
                            label: 'Años de experiencia',
                            ctrl: _experienciaCtrl,
                            icono: Icons.school_outlined,
                            teclado: TextInputType.number,
                          ),
                        ),
                        _buildCampo(
                          label: 'Descripción de especialidad',
                          ctrl: _descripcionCtrl,
                          icono: Icons.description_outlined,
                          maxLineas: 3,
                        ),
                      ],
                    ),

                    // Sección contraseña (solo en edición)
                    if (_enEdicion) ...[
                      const SizedBox(height: 16),
                      _buildSeccionContrasena(),
                    ],

                    const SizedBox(height: 28),
                    _buildBotones(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
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
            top: -30,
            right: -20,
            child: _DecorCircle(size: 150, opacity: 0.07),
          ),
          Positioned(
            top: 55,
            right: 55,
            child: _DecorCircle(size: 60, opacity: 0.09),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // Fila superior
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge TÉCNICO
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
                          'TÉCNICO',
                          style: GoogleFonts.dmMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _acento,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ),
                      // Botón editar / cancelar
                      if (!_esCargando)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _toggleEdicion,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _enEdicion
                                          ? Icons.close_rounded
                                          : Icons.edit_outlined,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _enEdicion ? 'Cancelar' : 'Editar',
                                      style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _mostrarMenuOpciones,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),

                    ],
                  ),

                  const SizedBox(height: 20),

                  // Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: _enEdicion ? null : _verFotoPantallaCompleta,
                        child: Hero(
                          tag: 'avatar_tecnico',
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.18),
                              image:
                                  (_usuarioActual?.fotoPerfilUrl != null &&
                                      _usuarioActual!.fotoPerfilUrl!.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        _usuarioActual!.fotoPerfilUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                (_usuarioActual?.fotoPerfilUrl == null ||
                                    _usuarioActual!.fotoPerfilUrl!.isEmpty)
                                ? Center(
                                    child: Text(
                                      _iniciales,
                                      style: GoogleFonts.sora(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),

                      if (_enEdicion)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _esCargando ? null : _cambiarFotoPerfil,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _acento,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _nombreCompleto,
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _usuarioActual?.correo ?? '',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),

                  // Calificación visible solo en modo vista
                  if (!_enEdicion && _calificacion != null) ...[
                    const SizedBox(height: 10),
                    _buildCalificacionBadge(_calificacion!),
                  ],

                  if (_enEdicion) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _acento.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _acento.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Modo edición activo',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Badge calificación ───────────────────────────────────────────────────
  Widget _buildCalificacionBadge(double cal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: _ambar, size: 16),
          const SizedBox(width: 5),
          Text(
            cal.toStringAsFixed(1),
            style: GoogleFonts.sora(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'calificación',
            style: GoogleFonts.dmSans(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats rápidos ────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatChip(
          icono: Icons.attach_money_rounded,
          valor: _tarifaCtrl.text.isEmpty ? '—' : '\$${_tarifaCtrl.text}/h',
          etiqueta: 'Tarifa',
          color: _acento,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icono: Icons.workspace_premium_outlined,
          valor: _experienciaCtrl.text.isEmpty
              ? '—'
              : '${_experienciaCtrl.text} años',
          etiqueta: 'Experiencia',
          color: const Color(0xFF1565C0),
        ),
        const SizedBox(width: 10),
        _StatChip(
          icono: Icons.star_rounded,
          valor: _calificacion != null
              ? _calificacion!.toStringAsFixed(1)
              : '—',
          etiqueta: 'Rating',
          color: _ambar,
        ),
      ],
    );
  }

  // ── Sección ──────────────────────────────────────────────────────────────
  Widget _buildSeccion({
    required String titulo,
    required List<Widget> children,
    IconData? icono,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              Text(
                titulo,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _verde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children.expand((c) => [c, const SizedBox(height: 14)]).toList()
            ..removeLast(),
        ],
      ),
    );
  }

  // ── Sección contraseña ───────────────────────────────────────────────────
  Widget _buildSeccionContrasena() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _ambarSuave, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: _ambar,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Cambiar contraseña',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFBF7B00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              'Déjalo en blanco si no deseas cambiar',
              style: GoogleFonts.dmSans(fontSize: 12, color: _grisTexto),
            ),
          ),
          const SizedBox(height: 16),
          _buildCampoContrasena(
            label: 'Contraseña actual',
            ctrl: _contrasenaActualCtrl,
            ocultada: _ocultarContrasena,
            onToggle: () =>
                setState(() => _ocultarContrasena = !_ocultarContrasena),
          ),
          const SizedBox(height: 12),
          _buildCampoContrasena(
            label: 'Nueva contraseña',
            ctrl: _contrasenaNuevaCtrl,
            ocultada: _ocultarContrasenaNueva,
            onToggle: () => setState(
              () => _ocultarContrasenaNueva = !_ocultarContrasenaNueva,
            ),
          ),
          const SizedBox(height: 12),
          _buildCampoContrasena(
            label: 'Confirmar nueva contraseña',
            ctrl: _confirmarContrasenaCtrl,
            ocultada: _ocultarConfirmarContrasena,
            onToggle: () => setState(
              () => _ocultarConfirmarContrasena = !_ocultarConfirmarContrasena,
            ),
          ),
        ],
      ),
    );
  }

  // ── Botones ──────────────────────────────────────────────────────────────
  Widget _buildBotones() {
    if (_enEdicion) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _toggleEdicion,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _bordeField, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Cancelar',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _grisOscuro,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _esCargando ? null : _guardarCambios,
              style: ElevatedButton.styleFrom(
                backgroundColor: _verde,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _verde.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _esCargando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Guardar cambios',
                          style: GoogleFonts.sora(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.check_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _toggleEdicion,
        style: ElevatedButton.styleFrom(
          backgroundColor: _verde,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              'Editar perfil',
              style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Fila dual (2 campos lado a lado) ─────────────────────────────────────
  Widget _buildFilaDual({required Widget izq, required Widget der}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 380) {
          return Row(
            children: [
              Expanded(child: izq),
              const SizedBox(width: 12),
              Expanded(child: der),
            ],
          );
        }
        return Column(children: [izq, const SizedBox(height: 14), der]);
      },
    );
  }

  // ── Campo texto ──────────────────────────────────────────────────────────
  Widget _buildCampo({
    required String label,
    required TextEditingController ctrl,
    required IconData icono,
    TextInputType teclado = TextInputType.text,
    int maxLineas = 1,
  }) {
    final editable = _enEdicion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: editable ? _verde : _grisTexto,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          readOnly: !editable,
          maxLines: maxLineas,
          minLines: 1,
          keyboardType: teclado,
          cursorColor: _verde,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: editable ? _grisOscuro : const Color(0xFF637066),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: editable ? _fondoCampo : const Color(0xFFF0F3F1),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(
                icono,
                size: 19,
                color: editable ? _verde : _grisTexto,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 46),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: editable ? _bordeField : Colors.transparent,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _verde, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Campo contraseña ─────────────────────────────────────────────────────
  Widget _buildCampoContrasena({
    required String label,
    required TextEditingController ctrl,
    required bool ocultada,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _verde,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: ocultada,
          cursorColor: _verde,
          style: GoogleFonts.dmSans(fontSize: 14, color: _grisOscuro),
          decoration: InputDecoration(
            filled: true,
            fillColor: _fondoCampo,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 10),
              child: Icon(Icons.lock_outline_rounded, color: _verde, size: 19),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 46),
            suffixIcon: IconButton(
              icon: Icon(
                ocultada
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _grisTexto,
                size: 19,
              ),
              onPressed: onToggle,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _bordeField, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _verde, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ════════════════════════════════════════════════════════════════════════════

/// Chip de estadística rápida
class _StatChip extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color color;

  const _StatChip({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(height: 5),
            Text(
              valor,
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D3F35),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: const Color(0xFF8FA89B),
              ),
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
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
