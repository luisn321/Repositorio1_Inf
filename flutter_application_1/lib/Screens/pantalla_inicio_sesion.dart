import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../servicios_red/index.dart';
import '../validadores/index.dart';
import 'HomeCliente.dart';
import 'HomeTecnico.dart';
import 'pantalla_registro.dart';

class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion>
    with SingleTickerProviderStateMixin {
  final _formularioKey = GlobalKey<FormState>();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();

  late ServicioAutenticacion _servicioAutenticacion;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _esCargando = false;
  bool _ocultarContrasena = true;

  // ── Design tokens ────────────────────────────────────────────────────────────
  static const Color _verde = Color(0xFF1A5C38);
  static const Color _verdeClaro = Color(0xFF247A4A);
  static const Color _verdeOscuro = Color(0xFF0F3B22);
  static const Color _acento = Color(0xFF4CAF82);
  static const Color _blanco = Colors.white;
  static const Color _grisTexto = Color(0xFF8FA89B);
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _servicioAutenticacion = ServicioAutenticacion();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ── Lógica ──────────────────────────────────────────────────
  Future<void> _manejarInicioSesion() async {
    if (!_formularioKey.currentState!.validate()) return;
    setState(() => _esCargando = true);
    try {
      final usuario = await _servicioAutenticacion.iniciarSesion(
        correo: _controladorCorreo.text.trim(),
        contrasena: _controladorContrasena.text,
      );
      if (!mounted) return;
      final pantalla = usuario.esTecnico()
          ? HomeTecnico(tecnicoId: usuario.id, usuario: usuario)
          : HomeCliente(clienteId: usuario.id, usuario: usuario);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => pantalla),
        (route) => false,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      _mostrarMensaje('${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _esCargando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mensaje,
                style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: _verdeOscuro,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Fondo degradado ────────────────────────────────────────────
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

          // ── Decoración geométrica de fondo ─────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: _DecorCircle(size: 240, opacity: 0.06),
          ),
          Positioned(
            top: 100,
            right: 40,
            child: _DecorCircle(size: 80, opacity: 0.08),
          ),
          Positioned(
            bottom: -50,
            left: -70,
            child: _DecorCircle(size: 260, opacity: 0.05),
          ),

          // ── Contenido principal ────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),

                      // LOGO
                      Center(child: _buildLogo()),

                      const SizedBox(height: 40),

                      // CABECERA
                      _buildHeader(),

                      const SizedBox(height: 36),

                      // TARJETA DEL FORMULARIO
                      _buildFormCard(),

                      const SizedBox(height: 24),

                      // CREAR CUENTA
                      _buildRegistroRow(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Secciones ─────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Image.asset(
        'Iconos/TecnicoPC.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.construction_rounded,
          color: Colors.white,
          size: 46,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta pequeña
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _acento.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'SERVITEC',
            style: GoogleFonts.dmMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _acento,
              letterSpacing: 2.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Bienvenido\nde vuelta',
          style: GoogleFonts.sora(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: _blanco,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión para continuar',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.65),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formularioKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Correo electrónico'),
            const SizedBox(height: 8),
            _buildCampoCorreo(),

            const SizedBox(height: 20),

            _buildLabel('Contraseña'),
            const SizedBox(height: 8),
            _buildCampoContrasena(),

            const SizedBox(height: 28),

            _buildBotonInicioSesion(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String texto) {
    return Text(
      texto,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _verdeOscuro,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildRegistroRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Aún no tienes cuenta?  ',
          style: GoogleFonts.dmSans(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PantallaRegistro())),
          child: Text(
            'Regístrate',
            style: GoogleFonts.dmSans(
              color: _acento,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: _acento,
            ),
          ),
        ),
      ],
    );
  }

  // ── Campos ────────────────────────────────────────────────────────────────

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(color: _grisTexto, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF4F7F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, color: _verde, size: 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDE8E3), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _verde, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE05252), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE05252), width: 2),
      ),
      errorStyle: GoogleFonts.dmSans(
        fontSize: 12,
        color: const Color(0xFFE05252),
      ),
    );
  }

  Widget _buildCampoCorreo() {
    return TextFormField(
      controller: _controladorCorreo,
      keyboardType: TextInputType.emailAddress,
      style: GoogleFonts.dmSans(color: _verdeOscuro, fontSize: 14),
      decoration: _inputDeco(
        hint: 'tu@correo.com',
        icon: Icons.alternate_email_rounded,
      ),
      validator: ValidadoresAutenticacion.validarCorreo,
    );
  }

  Widget _buildCampoContrasena() {
    return TextFormField(
      controller: _controladorContrasena,
      obscureText: _ocultarContrasena,
      style: GoogleFonts.dmSans(color: _verdeOscuro, fontSize: 14),
      decoration: _inputDeco(
        hint: '••••••••',
        icon: Icons.lock_outline_rounded,
        suffix: IconButton(
          icon: Icon(
            _ocultarContrasena
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _grisTexto,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _ocultarContrasena = !_ocultarContrasena),
        ),
      ),
      validator: (valor) {
        if (valor == null || valor.isEmpty) {
          return 'La contraseña es obligatoria';
        }
        return null;
      },
    );
  }

  Widget _buildBotonInicioSesion() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _esCargando ? null : _manejarInicioSesion,
        style: ElevatedButton.styleFrom(
          backgroundColor: _verde,
          foregroundColor: _blanco,
          disabledBackgroundColor: _verde.withValues(alpha: 0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _esCargando
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Iniciar sesión',
                    style: GoogleFonts.sora(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }
}

// ── Widget auxiliar: círculo decorativo ────────────────────────────────────────
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
