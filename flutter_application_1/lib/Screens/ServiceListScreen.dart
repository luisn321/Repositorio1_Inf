import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/TechnicianListScreen.dart';
import '../config/app_icons.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  // Lista de servicios basados en tu sistema
  final List<Map<String, dynamic>> services = const [
    {"icon": Icons.electrical_services, "name": "Electricista"},
    {"icon": Icons.plumbing, "name": "Plomero"},
    {"icon": Icons.computer, "name": "Técnico PC"},
    {"icon": Icons.carpenter, "name": "Carpintero"},
    {"icon": Icons.grass, "name": "Jardinería"},
    {"icon": Icons.kitchen, "name": "Línea Blanca"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppIcons.white,
      appBar: AppBar(
        backgroundColor: AppIcons.darkGreen,
        elevation: 0,
        title: const Text(
          "Servicios disponibles",
          style: TextStyle(
            color: AppIcons.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: const IconThemeData(color: AppIcons.white),
      ),
    
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Elige el servicio que necesitas",
              style: AppIcons.subheadingStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final service = services[index];

                  return Hero(
                    tag: 'service_${service["name"]}',
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppIcons.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppIcons.lightGreen,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppIcons.midGreen.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TechnicianListScreen(
                                  serviceName: service["name"],
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icono decorativo con fondo
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: AppIcons.lightGreen,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  service["icon"],
                                  size: 38,
                                  color: AppIcons.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Nombre del servicio
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8),
                                child: Text(
                                  service["name"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppIcons.darkGreen,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Indicador de técnicos disponibles
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppIcons.lightGreen.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Ver técnicos",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppIcons.darkGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}