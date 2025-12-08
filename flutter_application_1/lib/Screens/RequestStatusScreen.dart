import 'package:flutter/material.dart';
import 'PaymentScreen.dart';

class RequestStatusScreen extends StatelessWidget {
  final String service;
  final String technician;
  final String date;
  final String details;
  final String estado; // Estado: "pendiente", "aceptada", "completada"

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color white = Colors.white;

  const RequestStatusScreen({
    super.key,
    required this.service,
    required this.technician,
    required this.date,
    required this.details,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: darkGreen,
        title: const Text(
          "Estado de solicitud",
          style: TextStyle(color: white),
        ),
        iconTheme: const IconThemeData(color: white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Servicio: $service",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),

            const SizedBox(height: 10),

            Text("Técnico: $technician"),
            const SizedBox(height: 10),

            Text("Fecha programada: $date"),
            const SizedBox(height: 20),

            const Text(
              "Detalles:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Text(details),

            const Spacer(),

            // Mostrar estado actual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getEstadoColor(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Estado: ${estado.toUpperCase()}",
                style: const TextStyle(
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mostrar botón solo si está aceptada
            if (estado.toLowerCase() == 'aceptada')
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
                  ),
                  child: const Text(
                    "Finalizar y pagar",
                    style: TextStyle(color: white, fontSize: 18),
                  ),
                ),
              )
            else
              Text(
                "Esperando aceptación del técnico...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor() {
    switch (estado.toLowerCase()) {
      case 'aceptada':
        return Colors.green;
      case 'completada':
        return Colors.blue;
      case 'rechazada':
        return Colors.red;
      default:
        return Colors.orange; // pendiente
    }
  }
}

