import 'package:flutter/material.dart';
import 'TechniciansByServiceScreen.dart';
import '../config/app_icons.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceName;
  final IconData serviceIcon;
  final int serviceId;
  final int clientId;

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  const ServiceDetailScreen({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
    this.serviceId = 0,
    this.clientId = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: darkGreen,
        title: Text(
          serviceName,
          style: const TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 20),

            // Ícono grande (imagen PNG)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: midGreen, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: midGreen.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  AppIcons.getServiceImagePath(serviceName),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Nombre del servicio
            Text(
              serviceName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),

            const SizedBox(height: 20),

            // Descripción genérica (puedes cambiar luego)
            Text(
              "Encuentra técnicos expertos en $serviceName. "
              "Todos verificados y con calificación de clientes.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),

            const Spacer(),

            // Botón para ver técnicos
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechniciansByServiceScreen(
                        serviceId: serviceId,
                        serviceName: serviceName,
                        clientId: clientId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: midGreen,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Ver técnicos disponibles",
                  style: TextStyle(
                    color: white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
