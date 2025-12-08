import 'package:flutter/material.dart';
import 'RequestDetailScreen.dart';

class ClientRequestScreen extends StatelessWidget {
  const ClientRequestScreen({super.key});

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
          "Mis servicios",
          style: TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -------- SOLICITUD 1 --------
          _requestCard(
            context,
            service: "Carpintería",
            technician: "Carlos Pérez",
            date: "16/12/2025",
            status: "Pendiente",
            details: "Reparación de puerta de madera",
          ),

          // -------- SOLICITUD 2 --------
          _requestCard(
            context,
            service: "Electricidad",
            technician: "Luis Gómez",
            date: "10/12/2025",
            status: "En proceso",
            details: "Falla en contacto de cocina",
          ),

          // -------- SOLICITUD 3 --------
          _requestCard(
            context,
            service: "Plomería",
            technician: "Ana Torres",
            date: "03/12/2025",
            status: "Completado",
            details: "Fuga en tubería del fregadero",
          ),
        ],
      ),
    );
  }

  // -------- TARJETA REUTILIZABLE --------
  Widget _requestCard(
    BuildContext context, {
    required String service,
    required String technician,
    required String date,
    required String status,
    required String details,
  }) {
    Color statusColor;

    switch (status) {
      case "Pendiente":
        statusColor = Colors.orange;
        break;
      case "En proceso":
        statusColor = Colors.blue;
        break;
      case "Completado":
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Servicio
          Text(
            service,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkGreen,
            ),
          ),

          const SizedBox(height: 6),

          Text("Técnico: $technician"),
          Text("Fecha del servicio: $date"),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(Icons.circle, color: statusColor, size: 14),
              const SizedBox(width: 6),
              Text(
                "Estado: $status",
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Botón ver detalles
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RequestDetailScreen(
                      service: service,
                      technician: technician,
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
                "Ver detalles",
                style: TextStyle(
                  color: white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
