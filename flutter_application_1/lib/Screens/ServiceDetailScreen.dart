import 'package:flutter/material.dart';
import 'TechnicianListScreen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceName;
  final IconData serviceIcon;

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  const ServiceDetailScreen({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
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

            // Ícono grande
            CircleAvatar(
              radius: 55,
              backgroundColor: lightGreen,
              child: Icon(serviceIcon, size: 60, color: darkGreen),
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
                      builder: (_) => TechnicianListScreen(
                        serviceName: serviceName,
                        
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
