import 'package:flutter/material.dart';
import 'TechnicianRequestDetailScreen.dart';

class TechnicianRequestScreen extends StatelessWidget {
  const TechnicianRequestScreen({super.key});

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: darkGreen,
        title: const Text(
          "Solicitudes asignadas",
          style: TextStyle(color: white),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _requestCard(
            context,
            clientName: "Juan Pérez",
            service: "Plomería",
            date: "15/02/2025",
            status: "Pendiente",
            details: "Fuga en tubería del baño.",
          ),

          _requestCard(
            context,
            clientName: "María López",
            service: "Electricidad",
            date: "20/02/2025",
            status: "Aceptado",
            details: "Revisión de apagadores.",
          ),

        ],
      ),
    );
  }

  Widget _requestCard(
    BuildContext context, {
    required String clientName,
    required String service,
    required String date,
    required String status,
    required String details,
  }) {
    Color statusColor = Colors.orange;

    if (status == "Aceptado") statusColor = Colors.blue;
    if (status == "En proceso") statusColor = Colors.purple;
    if (status == "Completado") statusColor = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            service,
            style: const TextStyle(
              fontSize: 20,
              color: darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text("Cliente: $clientName"),
          Text("Fecha: $date"),

          const SizedBox(height: 6),

          Row(
            children: [
              Icon(Icons.circle, color: statusColor, size: 12),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TechnicianRequestDetailScreen(
                      clientName: clientName,
                      service: service,
                      date: date,
                      status: status,
                      details: details,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: midGreen,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Gestionar solicitud",
                style: TextStyle(color: white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
