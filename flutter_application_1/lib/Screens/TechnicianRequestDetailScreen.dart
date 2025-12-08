import 'package:flutter/material.dart';

class TechnicianRequestDetailScreen extends StatefulWidget {
  final String clientName;
  final String service;
  final String date;
  final String status;
  final String details;

  const TechnicianRequestDetailScreen({
    super.key,
    required this.clientName,
    required this.service,
    required this.date,
    required this.status,
    required this.details,
  });

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<TechnicianRequestDetailScreen> createState() =>
      _TechnicianRequestDetailScreenState();
}

class _TechnicianRequestDetailScreenState
    extends State<TechnicianRequestDetailScreen> {

  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.status;
  }

  void updateStatus(String newStatus) {
    setState(() {
      status = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Estado actualizado a: $newStatus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechnicianRequestDetailScreen.white,

      appBar: AppBar(
        backgroundColor: TechnicianRequestDetailScreen.darkGreen,
        title: const Text(
          "Solicitud",
          style: TextStyle(color: TechnicianRequestDetailScreen.white),
        ),
        iconTheme: const IconThemeData(color: TechnicianRequestDetailScreen.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              widget.service,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: TechnicianRequestDetailScreen.darkGreen,
              ),
            ),

            const SizedBox(height: 10),

            Text("Cliente: ${widget.clientName}", style: const TextStyle(fontSize: 18)),
            Text("Fecha: ${widget.date}", style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 20),

            const Text(
              "Estado actual:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              status,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Cambiar estado:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _statusButton("Aceptar", Colors.blue),
            _statusButton("En proceso", Colors.orange),
            _statusButton("Completado", Colors.green),

          ],
        ),
      ),
    );
  }

  Widget _statusButton(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => updateStatus(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
