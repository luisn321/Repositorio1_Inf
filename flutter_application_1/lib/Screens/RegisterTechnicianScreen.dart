import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/TechnicianHomeScreen.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api.dart';
import 'SelectLocationScreen.dart';


class RegisterTechnicianScreen extends StatefulWidget {
  const RegisterTechnicianScreen({super.key});

  @override
  State<RegisterTechnicianScreen> createState() => _RegisterTechnicianScreenState();
}

class _RegisterTechnicianScreenState extends State<RegisterTechnicianScreen> {
  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  // Controladores
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController especialidadController = TextEditingController();
  final TextEditingController experienciaController = TextEditingController();
  final TextEditingController tarifaController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  // Para guardar internamente la ubicación
  double? latitud;
  double? longitud;
  bool _isLoading = false;

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    telefonoController.dispose();
    addressController.dispose();
    especialidadController.dispose();
    experienciaController.dispose();
    tarifaController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // Validaciones
    if (nombreController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        telefonoController.text.isEmpty ||
        addressController.text.isEmpty ||
        tarifaController.text.isEmpty ||
        descripcionController.text.isEmpty) {
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
      
      // Convertir tarifa a double
      final tarifa = double.tryParse(tarifaController.text) ?? 0.0;
      
      final result = await apiService.registerTechnician(
        nombre: nombreController.text,
        email: emailController.text,
        password: passwordController.text,
        telefono: telefonoController.text,
        ubicacionText: addressController.text,
        lat: latitud!,
        lng: longitud!,
        tarifaHora: tarifa,
        serviceIds: [], // Aquí se pueden agregar servicios después
        experiencia: experienciaController.text,
        descripcion: descripcionController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Cuenta como técnico creada exitosamente!"),
            backgroundColor: Colors.green,
          ),
        );

        // Obtener el ID del técnico registrado
        final technicianId = result['id_tecnico'] ?? result['idTecnico'] ?? result['id'] as int?;
        print('🟠 Resultado completo del registro técnico: $result');
        print('🟠 Técnico registrado con ID: $technicianId');

        // Navegar a home sin permitir volver
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => TechnicianHomeScreen(technicianId: technicianId ?? 0),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Error en RegisterTechnician: $e');
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
                    "Registro de Técnico",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Regístrate como técnico y ofrece tus servicios a clientes.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: white.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FORM CARD
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
                          hint: "Nombre",
                          controller: nombreController,
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
                              try {
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
                              } catch (e) {
                                print('Error al obtener dirección: $e');
                              }
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
                          icon: Icons.build_outlined,
                          hint: "Especialidad (Electricista, Plomero, etc.)",
                          controller: especialidadController,
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          icon: Icons.work_history_outlined,
                          hint: "Años de experiencia",
                          keyboard: TextInputType.number,
                          controller: experienciaController,
                        ),
                        const SizedBox(height: 16),

                        _buildInputField(
                          icon: Icons.attach_money,
                          hint: "Tarifa por hora",
                          keyboard: TextInputType.number,
                          controller: tarifaController,
                        ),
                        const SizedBox(height: 16),

                        // DESCRIPCIÓN
                        TextField(
                          controller: descripcionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: white,
                            hintText: "Descripción de tus servicios",
                            prefixIcon: const Icon(Icons.description_outlined),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

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

                        // BOTÓN REGISTRAR
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
                                    "Registrarme como técnico",
                                    style: TextStyle(
                                      fontSize: 18,
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
