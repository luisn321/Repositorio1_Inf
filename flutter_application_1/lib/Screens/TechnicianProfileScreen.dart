import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api.dart';
import 'SelectLocationScreen.dart';

class TechnicianProfileScreen extends StatefulWidget {
  final int technicianId;

  const TechnicianProfileScreen({
    super.key,
    required this.technicianId,
  });

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  // Controladores
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  double? latitud;
  double? longitud;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    print('🔵 TechnicianProfileScreen - technicianId: ${widget.technicianId}');
    if (widget.technicianId > 0) {
      _loadProfileData();
    } else {
      setState(() {
        _isLoading = false;
      });
      print('⚠️ TechnicianId es 0, no se puede cargar perfil');
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final apiService = ApiService();
      print('🔵 Llamando a getTechnicianProfile con ID: ${widget.technicianId}');
      final data = await apiService.getTechnicianProfile(widget.technicianId);

      print('✅ Datos recibidos: $data');

      setState(() {
        nameController.text = data['nombre'] ?? '';
        phoneController.text = data['telefono'] ?? '';
        emailController.text = data['email'] ?? '';
         experienceController.text = data['experiencia_years']?.toString() ?? data['experienciaYears']?.toString() ?? data['experiencia']?.toString() ?? '';
         priceController.text = data['tarifa_hora']?.toString() ?? data['tarifaHora']?.toString() ?? data['tarifa']?.toString() ?? '';
         addressController.text = data['ubicacion_text'] ?? data['ubicacion'] ?? data['direccion'] ?? data['direccionText'] ?? '';
        descriptionController.text = data['descripcion'] ?? '';
         latitud = double.tryParse(data['latitud']?.toString() ?? data['lat']?.toString() ?? '');
         longitud = double.tryParse(data['longitud']?.toString() ?? data['lng']?.toString() ?? '');
        _isLoading = false;
      });

      print('✅ Datos del perfil del técnico cargados correctamente');
    } catch (e) {
      print('❌ Error al cargar perfil: $e');
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
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        addressController.text.isEmpty ||
        priceController.text.isEmpty ||
        descriptionController.text.isEmpty) {
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
      final tarifa = double.tryParse(priceController.text) ?? 0.0;

      await apiService.updateTechnicianProfile(
        technicianId: widget.technicianId,
        nombre: nameController.text,
        email: emailController.text,
        telefono: phoneController.text,
        ubicacionText: addressController.text,
        lat: latitud ?? 0,
        lng: longitud ?? 0,
        tarifaHora: tarifa,
        experiencia: experienceController.text,
        descripcion: descriptionController.text,
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
    phoneController.dispose();
    emailController.dispose();
    experienceController.dispose();
    priceController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechnicianProfileScreen.white,
      appBar: AppBar(
        backgroundColor: TechnicianProfileScreen.darkGreen,
        title: const Text(
          "Mi Perfil",
          style: TextStyle(color: TechnicianProfileScreen.white),
        ),
        iconTheme: const IconThemeData(color: TechnicianProfileScreen.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ▬▬▬▬▬ FOTO DE PERFIL ▬▬▬▬▬
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: TechnicianProfileScreen.midGreen,
                      child: const Icon(Icons.person, size: 70, color: TechnicianProfileScreen.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ▬▬▬▬▬ CARD PRINCIPAL ▬▬▬▬▬
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: TechnicianProfileScreen.lightGreen,
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

                        _input("Teléfono", Icons.phone, phoneController, keyboard: TextInputType.phone),
                        const SizedBox(height: 16),

                        _input("Correo", Icons.email_outlined, emailController),
                        const SizedBox(height: 16),

                        _input("Años de experiencia", Icons.work_history, experienceController,
                            keyboard: TextInputType.number),
                        const SizedBox(height: 16),

                        _input("Tarifa por hora", Icons.attach_money, priceController,
                            keyboard: TextInputType.number),
                        const SizedBox(height: 16),

                        _input("Dirección", Icons.home_outlined, addressController),
                        const SizedBox(height: 16),

                        // BOTÓN PARA CAMBIAR UBICACIÓN
                        ElevatedButton(
                          onPressed: () async {
                            final LatLng? point = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SelectLocationScreen(),
                              ),
                            );

                            if (point != null) {
                              latitud = point.latitude;
                              longitud = point.longitude;

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
                            backgroundColor: TechnicianProfileScreen.midGreen,
                            foregroundColor: TechnicianProfileScreen.white,
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

                        // DESCRIPCIÓN
                        TextField(
                          controller: descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: TechnicianProfileScreen.white,
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
                              backgroundColor: TechnicianProfileScreen.darkGreen,
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
                                        TechnicianProfileScreen.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Guardar Cambios",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: TechnicianProfileScreen.white,
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
            fillColor: TechnicianProfileScreen.white,
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
          color: TechnicianProfileScreen.darkGreen,
        ),
      ),
    );
  }
}
