import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/TechnicianListScreen.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  // Lista de servicios basados en tu sistema
  final List<Map<String, dynamic>> services = const [
    {"icon": Icons.bolt, "name": "Electricista"},
    {"icon": Icons.plumbing, "name": "Plomero"},
    {"icon": Icons.computer, "name": "Técnico PC"},
    {"icon": Icons.handyman, "name": "Carpintero"},
    {"icon": Icons.forest, "name": "Jardinería"},
    {"icon": Icons.kitchen, "name": "Línea Blanca"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: darkGreen,
        title: const Text(
          "Servicios disponibles",
          style: TextStyle(color: white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final service = services[index];

            return GestureDetector(
              onTap: () {
                // 🔗 Aquí irá la navegación a la pantalla 12 (lista de técnicos)

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TechnicianListScreen(
                      serviceName: service["name"],
                      
                    ), // TEMPORAL
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      service["icon"],
                      size: 52,
                      color: darkGreen,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      service["name"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}