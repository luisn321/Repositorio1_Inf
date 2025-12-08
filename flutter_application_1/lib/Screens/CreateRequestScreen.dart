import 'package:flutter/material.dart';
import 'RequestStatusScreen.dart';

class CreateRequestScreen extends StatefulWidget {
  final String serviceName;
  final String technicianName;

  const CreateRequestScreen({
    super.key,
    required this.serviceName,
    required this.technicianName,
  });

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  DateTime? serviceDate;
  final TextEditingController detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CreateRequestScreen.white,
      appBar: AppBar(
        backgroundColor: CreateRequestScreen.darkGreen,
        title: const Text(
          "Crear Solicitud",
          style: TextStyle(color: CreateRequestScreen.white),
        ),
        iconTheme: const IconThemeData(color: CreateRequestScreen.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Servicio
            Text(
              "Servicio: ${widget.serviceName}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CreateRequestScreen.darkGreen,
              ),
            ),
            const SizedBox(height: 8),

            // Técnico
            Text(
              "Técnico: ${widget.technicianName}",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            // Fecha del servicio
            const Text(
              "Fecha del servicio:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );

                if (picked != null) {
                  setState(() {
                    serviceDate = picked;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CreateRequestScreen.midGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                serviceDate == null
                    ? "Seleccionar fecha"
                    : "${serviceDate!.day}/${serviceDate!.month}/${serviceDate!.year}",
                style: const TextStyle(color: CreateRequestScreen.white),
              ),
            ),

            const SizedBox(height: 20),

            // Detalles del trabajo
            const Text(
              "Detalles del trabajo:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            TextField(
              controller: detailsController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: CreateRequestScreen.lightGreen,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                hintText: "Describe lo que necesitas...",
              ),
            ),

            const Spacer(),

            // Botón Enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (serviceDate == null || detailsController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Completa todos los campos."),
                      ),
                    );
                    return;
                  }

                  // ───────────────────────────────────────────────
                  //   NAVEGAR A RequestStatusScreen
                  // ───────────────────────────────────────────────
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestStatusScreen(
                        service: widget.serviceName,
                        technician: widget.technicianName,
                        date: "${serviceDate!.day}/${serviceDate!.month}/${serviceDate!.year}",
                        details: detailsController.text,
                        estado: "pendiente", // Estado inicial
                      ),
                    ),
                  );

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CreateRequestScreen.darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Enviar solicitud",
                  style: TextStyle(
                    color: CreateRequestScreen.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

