import 'package:flutter/material.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({super.key});

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  // Controladores
  final TextEditingController nameController = TextEditingController(text: "Juan Pérez");
  final TextEditingController phoneController = TextEditingController(text: "9991234567");
  final TextEditingController emailController = TextEditingController(text: "tecjuan@gmail.com");
  final TextEditingController experienceController = TextEditingController(text: "5");
  final TextEditingController priceController = TextEditingController(text: "250");
  final TextEditingController addressController = TextEditingController(text: "Av. Siempre Viva 123");
  final TextEditingController descriptionController =
      TextEditingController(text: "Servicio profesional con atención rápida y eficiente.");

  String specialty = "Electricista";

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

      body: SingleChildScrollView(
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
                  _input("Nombre completo", Icons.person_outline, nameController),
                  const SizedBox(height: 16),

                  _input("Teléfono", Icons.phone, phoneController, keyboard: TextInputType.phone),
                  const SizedBox(height: 16),

                  _input("Correo", Icons.email_outlined, emailController),
                  const SizedBox(height: 16),

                  // Especialidad
                  _label("Especialidad"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: TechnicianProfileScreen.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButton<String>(
                      value: specialty,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: "Electricista", child: Text("Electricista")),
                        DropdownMenuItem(value: "Plomero", child: Text("Plomero")),
                        DropdownMenuItem(value: "Carpintero", child: Text("Carpintero")),
                        DropdownMenuItem(value: "Técnico PC", child: Text("Técnico PC")),
                        DropdownMenuItem(value: "Jardinería", child: Text("Jardinería")),
                      ],
                      onChanged: (value) {
                        setState(() => specialty = value!);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  _input("Años de experiencia", Icons.work_history, experienceController,
                      keyboard: TextInputType.number),
                  const SizedBox(height: 16),

                  _input("Tarifa por hora (MXN)", Icons.attach_money, priceController,
                      keyboard: TextInputType.number),
                  const SizedBox(height: 16),

                  _input("Dirección", Icons.home_outlined, addressController),
                  const SizedBox(height: 16),

                  // Descripción
                  _label("Descripción"),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: TechnicianProfileScreen.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ▬▬▬▬▬ BOTÓN GUARDAR ▬▬▬▬▬
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Perfil actualizado correctamente.")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TechnicianProfileScreen.darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
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

  // ▬▬▬▬▬ INPUT REUTILIZABLE ▬▬▬▬▬
  Widget _input(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller,
          keyboardType: keyboard,
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
