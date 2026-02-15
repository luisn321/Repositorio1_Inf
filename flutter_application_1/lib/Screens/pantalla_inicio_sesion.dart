import 'package:flutter/material.dart';
import '../servicios_red/index.dart';
import '../validadores/index.dart';
import '../config/app_icons.dart';
import 'pantalla_inicio_cliente.dart';
import 'pantalla_inicio_tecnico.dart';
import 'pantalla_registro.dart';

/// Pantalla de inicio de sesión (login)
/// Permite a usuarios iniciar sesión con correo y contraseña
class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _PantallaInicioSesionState();
}

class _PantallaInicioSesionState extends State<PantallaInicioSesion> {
  final _formularioKey = GlobalKey<FormState>();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  
  late ServicioAutenticacion _servicioAutenticacion;
  
  bool _esCargando = false;
  bool _ocultarContrasena = true;

  @override
  void initState() {
    super.initState();
    _servicioAutenticacion = ServicioAutenticacion();
  }

  @override
  void dispose() {
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }

  /// Maneja el inicio de sesión
  Future<void> _manejarInicioSesion() async {
    if (!_formularioKey.currentState!.validate()) {
      return; // Formulario no válido
    }

    setState(() => _esCargando = true);

    try {
      print('🔐 Iniciando sesión...');

      final usuario = await _servicioAutenticacion.iniciarSesion(
        correo: _controladorCorreo.text.trim(),
        contrasena: _controladorContrasena.text,
      );

      if (!mounted) return;

      print('✅ Sesión iniciada. Tipo: ${usuario.tipoUsuario}');

      // Navegar según tipo de usuario
      final pantalla = usuario.esTecnico()
          ? PantallaInicioTecnico(tecnicoId: usuario.id)
          : PantallaInicioCliente(clienteId: usuario.id);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => pantalla),
        (route) => false,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      _mostrarMensaje('❌ ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      if (mounted) {
        setState(() => _esCargando = false);
      }
    }
  }

  /// Muestra un mensaje emergente
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 3),
        backgroundColor: AppIcons.darkGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppIcons.darkGreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // TÍTULO
                  Text(
                    'Iniciar sesión',
                    style: AppIcons.headingStyle.copyWith(
                      color: AppIcons.white,
                      fontSize: 32,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // SUBTÍTULO
                  Text(
                    'Bienvenido a Servitec',
                    style: TextStyle(
                      color: AppIcons.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // FORMULARIO
                  Form(
                    key: _formularioKey,
                    child: Column(
                      children: [
                        // CAMPO CORREO
                        _construirCampoCorreo(),
                        const SizedBox(height: 20),

                        // CAMPO CONTRASEÑA
                        _construirCampoContrasena(),
                        const SizedBox(height: 30),

                        // BOTÓN INICIO SESIÓN
                        _construirBotonInicioSesion(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // DIVIDER
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppIcons.white.withOpacity(0.3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'O',
                          style: TextStyle(
                            color: AppIcons.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppIcons.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // BOTÓN REGISTRO
                  _construirBotonRegistro(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye el campo de entrada para correo
  Widget _construirCampoCorreo() {
    return TextFormField(
      controller: _controladorCorreo,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Correo electrónico',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: AppIcons.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: AppIcons.darkGreen,
        ),
      ),
      validator: ValidadoresAutenticacion.validarCorreo,
    );
  }

  /// Construye el campo de entrada para contraseña
  Widget _construirCampoContrasena() {
    return TextFormField(
      controller: _controladorContrasena,
      obscureText: _ocultarContrasena,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Contraseña',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: AppIcons.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: AppIcons.darkGreen,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _ocultarContrasena ? Icons.visibility_off : Icons.visibility,
            color: AppIcons.darkGreen,
          ),
          onPressed: () {
            setState(() => _ocultarContrasena = !_ocultarContrasena);
          },
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

  /// Construye el botón de inicio de sesión
  Widget _construirBotonInicioSesion() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _esCargando ? null : _manejarInicioSesion,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppIcons.white,
          foregroundColor: AppIcons.darkGreen,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _esCargando
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppIcons.darkGreen,
                  ),
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Construye el botón de registro (ir a registro)
  Widget _construirBotonRegistro() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PantallaRegistro()),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Crear cuenta',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
