import 'package:flutter/material.dart';

class TechnicianServicesScreen extends StatefulWidget {
  const TechnicianServicesScreen({super.key});

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<TechnicianServicesScreen> createState() => _TechnicianServicesScreenState();
}

class _TechnicianServicesScreenState extends State<TechnicianServicesScreen> {
  // Lista de servicios disponibles
  final Map<String, bool> services = {
    "Electricista": false,
    "Plomero": false,
    "Carpintero": false,
    "Técnico PC": false,
    "Jardinería": false,
    "Línea Blanca": false,
    "Cerrajería": false,
    "Pintura": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechnicianServicesScreen.white,
      appBar: AppBar(
        backgroundColor: TechnicianServicesScreen.darkGreen,
        title: const Text(
          "Mis Servicios",
          style: TextStyle(color: TechnicianServicesScreen.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selecciona los servicios que ofreces",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TechnicianServicesScreen.darkGreen,
              ),
            ),

            const SizedBox(height: 20),

            // Lista de servicios en tarjetas
            Expanded(
              child: ListView(
                children: services.keys.map((service) {
                  return _serviceCard(
                    title: service,
                    value: services[service]!,
                    onChanged: (val) {
                      setState(() {
                        services[service] = val!;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  List<String> selected = services.entries
                      .where((e) => e.value == true)
                      .map((e) => e.key)
                      .toList();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        selected.isEmpty
                            ? "No seleccionaste ningún servicio"
                            : "Servicios guardados correctamente",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TechnicianServicesScreen.darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Guardar",
                  style: TextStyle(
                    color: TechnicianServicesScreen.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget de tarjeta de servicio
  Widget _serviceCard({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TechnicianServicesScreen.lightGreen,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            activeColor: TechnicianServicesScreen.midGreen,
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: TechnicianServicesScreen.darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
