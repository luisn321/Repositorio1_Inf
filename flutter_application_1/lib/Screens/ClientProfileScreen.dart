import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api.dart';
import 'SelectLocationScreen.dart';

class ClientProfileScreen extends StatefulWidget {
  final int clientId;

  const ClientProfileScreen({
    super.key,
    required this.clientId,
  });

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  double? latitud;
  double? longitud;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    print('🔵 ClientProfileScreen - clientId: ${widget.clientId}');
    if (widget.clientId > 0) {
      _loadProfileData();
    } else {
      setState(() {
        _isLoading = false;
      });
      print('ClientId es 0, no se puede cargar perfil');
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final apiService = ApiService();
      print('🔵 Llamando a getClientProfile con ID: ${widget.clientId}');
      final data = await apiService.getClientProfile(widget.clientId);

      print('✅ Datos recibidos: $data');

      setState(() {
        nameController.text = data['nombre'] ?? '';
        surnameController.text = data['apellido'] ?? '';
        phoneController.text = data['telefono'] ?? '';
        emailController.text = data['email'] ?? '';
        addressController.text = data['direccion_text'] ?? data['direccionText'] ?? data['direccion'] ?? '';
        latitud = double.tryParse(data['latitud']?.toString() ?? data['lat']?.toString() ?? '');
        longitud = double.tryParse(data['longitud']?.toString() ?? data['lng']?.toString() ?? '');
        _isLoading = false;
      });

      print('Datos del perfil cargados correctamente');
    } catch (e) {
      print('Error al cargar perfil: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cargar perfil: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (nameController.text.isEmpty ||
        surnameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor completa todos los campos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final apiService = ApiService();
      await apiService.updateClientProfile(
        clientId: widget.clientId,
        nombre: nameController.text,
        apellido: surnameController.text,
        email: emailController.text,
        telefono: phoneController.text,
        direccionText: addressController.text,
        lat: latitud ?? 0,
        lng: longitud ?? 0,
        password: passwordController.text.isNotEmpty ? passwordController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Perfil actualizado exitosamente."),
            backgroundColor: Colors.green,
          ),
        );
        passwordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClientProfileScreen.white,
      appBar: AppBar(
        backgroundColor: ClientProfileScreen.darkGreen,
        title: const Text(
          "Mi Perfil",
          style: TextStyle(color: ClientProfileScreen.white),
        ),
        iconTheme: const IconThemeData(color: ClientProfileScreen.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // FOTO DE PERFIL
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: ClientProfileScreen.midGreen,
                      child: const Icon(Icons.person,
                          size: 70, color: ClientProfileScreen.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // CARD PRINCIPAL
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: ClientProfileScreen.lightGreen,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _input("Nombre", Icons.person_outline, nameController),
                        const SizedBox(height: 16),
                        _input(
                            "Apellido", Icons.person_outline, surnameController),
                        const SizedBox(height: 16),
                        _input("Teléfono", Icons.phone, phoneController,
                            keyboard: TextInputType.phone),
                        const SizedBox(height: 16),
                        _input("Correo", Icons.email_outlined, emailController),
                        const SizedBox(height: 16),
                        _input("Dirección", Icons.home_outlined,
                            addressController),
                        const SizedBox(height: 16),
                        // BOTÓN PARA CAMBIAR UBICACIÓN
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
                            backgroundColor: ClientProfileScreen.midGreen,
                            foregroundColor: ClientProfileScreen.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Actualizar ubicación",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _input("Contraseña (opcional)", Icons.lock_outline,
                            passwordController,
                            obscure: true),
                        const SizedBox(height: 25),
                        // BOTÓN GUARDAR CAMBIOS
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  ClientProfileScreen.darkGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ClientProfileScreen.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Guardar Cambios",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: ClientProfileScreen.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ---------- INPUT REUTILIZABLE ----------
  Widget _input(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: ClientProfileScreen.white,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: ClientProfileScreen.darkGreen,
        ),
      ),
    );
  }
}
