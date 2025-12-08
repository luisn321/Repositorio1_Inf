import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api.dart';
import 'SelectLocationScreen.dart';
import 'ClientHomeScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Colores
  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  // Controladores para todos los campos
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Campos para guardar internamente
  double? latitud;
  double? longitud;
  bool _isLoading = false;

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    telefonoController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  const Text(
                    "Crear cuenta",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Regístrate y comienza a solicitar técnicos.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: white.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FORMULARIO
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInputField(
                          icon: Icons.person_outline,
                          hint: "Nombres",
                          controller: nombreController,
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          icon: Icons.person_outline,
                          hint: "Apellidos",
                          controller: apellidoController,
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          icon: Icons.email_outlined,
                          hint: "Correo electrónico",
                          controller: emailController,
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          icon: Icons.phone_outlined,
                          hint: "Teléfono",
                          keyboard: TextInputType.phone,
                          controller: telefonoController,
                        ),
                        const SizedBox(height: 16),

                        // CAMPO DIRECCIÓN (controlado)
                        _buildInputField(
                          icon: Icons.home_outlined,
                          hint: "Dirección",
                          controller: addressController,
                        ),

                        const SizedBox(height: 16),

                        // BOTÓN PARA ABRIR EL MAPA
                        ElevatedButton(
                          onPressed: () async {
                            final LatLng? point = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SelectLocationScreen(),
                              ),
                            );

                            if (point != null) {
                              latitud = point.latitude;
                              longitud = point.longitude;

                              // Obtener dirección real (texto)
                              List<Placemark> places =
                                  await placemarkFromCoordinates(
                                latitud!,
                                longitud!,
                              );

                              Placemark place = places.first;

                              String fullAddress =
                                  "${place.street}, ${place.locality}, "
                                  "${place.administrativeArea}, ${place.country}";

                              setState(() {
                                addressController.text = fullAddress;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: midGreen,
                            foregroundColor: white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Seleccionar ubicación en el mapa",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildInputField(
                          icon: Icons.lock_outline,
                          hint: "Contraseña",
                          obscure: true,
                          controller: passwordController,
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          icon: Icons.lock_outline,
                          hint: "Confirmar contraseña",
                          obscure: true,
                          controller: confirmPasswordController,
                        ),

                        const SizedBox(height: 24),

                        // BOTÓN CREAR CUENTA
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: midGreen,
                              foregroundColor: white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 5,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Crear cuenta",
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "¿Ya tienes cuenta? Inicia sesión",
                      style: TextStyle(
                        color: white,
                        fontSize: 17,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    // Validaciones
    if (nombreController.text.isEmpty ||
        apellidoController.text.isEmpty ||
        emailController.text.isEmpty ||
        telefonoController.text.isEmpty ||
        addressController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor completa todos los campos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las contraseñas no coinciden."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (latitud == null || longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor selecciona una ubicación en el mapa."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      await apiService.registerClient(
        nombre: nombreController.text,
        apellido: apellidoController.text,
        email: emailController.text,
        password: passwordController.text,
        telefono: telefonoController.text,
        direccionText: addressController.text,
        lat: latitud!,
        lng: longitud!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Cuenta creada exitosamente!"),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar a home sin permitir volver
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ClientHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // WIDGET REUTILIZABLE
  Widget _buildInputField({
    required IconData icon,
    required String hint,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        filled: true,
        fillColor: white,
        hintText: hint,
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}


