import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
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

  // Controladores
  final TextEditingController addressController = TextEditingController();

  // Campos para guardar internamente
  double? latitud;
  double? longitud;

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
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          icon: Icons.person_outline,
                          hint: "Apellidos",
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          icon: Icons.email_outlined,
                          hint: "Correo electrónico",
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          icon: Icons.phone_outlined,
                          hint: "Teléfono",
                          keyboard: TextInputType.phone,
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
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          icon: Icons.lock_outline,
                          hint: "Confirmar contraseña",
                          obscure: true,
                        ),

                        const SizedBox(height: 24),

                        // BOTÓN CREAR CUENTA
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {Navigator.push( context, MaterialPageRoute(builder: (context) => const ClientHomeScreen()),
                            );

                              // Aquí mandarás:
                              // latitud, longitud, direccion y demás datos a tu BD
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: midGreen,
                              foregroundColor: white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
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


