import 'package:flutter/material.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final TextEditingController nameController =
      TextEditingController();
  final TextEditingController phoneController =
      TextEditingController();
  final TextEditingController emailController =
      TextEditingController();
  final TextEditingController addressController =
      TextEditingController();
  final TextEditingController passwordController =
      TextEditingController();

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FOTO DE PERFIL
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: ClientProfileScreen.midGreen,
                child: const Icon(Icons.person, size: 70, color: ClientProfileScreen.white),
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
                  _input("Nombre completo", Icons.person_outline, nameController),
                  const SizedBox(height: 16),

                  _input("Teléfono", Icons.phone, phoneController,
                      keyboard: TextInputType.phone),
                  const SizedBox(height: 16),

                  _input("Correo", Icons.email_outlined, emailController),
                  const SizedBox(height: 16),

                  _input("Dirección", Icons.home_outlined, addressController),
                  const SizedBox(height: 16),

                  _input("Contraseña", Icons.lock_outline, passwordController,
                      obscure: true),
                  const SizedBox(height: 25),

                  // BOTÓN GUARDAR CAMBIOS
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Perfil actualizado correctamente.")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ClientProfileScreen.darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
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
