import 'package:flutter/material.dart';
import 'PaymentScreen.dart';

class RequestDetailScreen extends StatelessWidget {
  final String service;
  final String technician;
  final String date;
  final String status;
  final String details;

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  const RequestDetailScreen({
    super.key,
    required this.service,
    required this.technician,
    required this.date,
    required this.status,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: darkGreen,
        title: const Text(
          "Detalles del servicio",
          style: TextStyle(color: white),
        ),
        iconTheme: const IconThemeData(color: white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              service,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),

            const SizedBox(height: 12),

            Text("Técnico: $technician"),
            Text("Fecha: $date"),
            Text("Estado: $status"),

            const SizedBox(height: 20),

            const Text(
              "Detalles del problema:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              details,
              style: const TextStyle(fontSize: 16),
            ),

            const Spacer(),

            // ---------- BOTÓN PARA IR A PAGO ----------
            if (status == "Pendiente" || status == "En proceso")
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          service: service,
                          technician: technician,
                          date: date,
                          details: details,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: midGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Proceder al pago",
                    style: TextStyle(
                      fontSize: 18,
                      color: white,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

