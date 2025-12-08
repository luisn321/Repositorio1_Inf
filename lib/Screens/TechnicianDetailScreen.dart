import 'package:flutter/material.dart';

class TechnicianDetailScreen extends StatelessWidget {
  final String name;
  final String job;
  final String rating;
  final String experience;
  final String cost;
  final String description;

  const TechnicianDetailScreen({
    super.key,
    required this.name,
    required this.job,
    required this.rating,
    required this.experience,
    required this.cost,
    required this.description,
  });

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
        title: Text(
          job,
          style: const TextStyle(color: white),
        ),
        iconTheme: const IconThemeData(color: white),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ▬▬▬▬▬ FOTO GRANDE ▬▬▬▬▬
            Container(
              width: double.infinity,
              height: 260,
              decoration: const BoxDecoration(
                color: darkGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: midGreen,
                  child: const Icon(Icons.person, size: 90, color: white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ▬▬▬▬▬ INFORMACIÓN PRINCIPAL ▬▬▬▬▬
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Nombre
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Especialidad
                  Text(
                    job,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 28),
                      const SizedBox(width: 6),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ▬▬▬▬▬ DETALLES DEL SERVICIO ▬▬▬▬▬
                  _detailRow(Icons.work_history, "Experiencia:", "$experience años"),
                  const SizedBox(height: 12),

                  _detailRow(Icons.attach_money, "Costo aproximado:", "\$$cost MXN"),
                  const SizedBox(height: 12),

                  const Text(
                    "Descripción",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),

                  const SizedBox(height: 30),

                  // ▬▬▬▬▬ BOTÓN SOLICITAR SERVICIO ▬▬▬▬▬
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Aquí abrirás pantalla para hacer la solicitud
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: midGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Solicitar servicio",
                        style: TextStyle(
                          fontSize: 20,
                          color: white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ▬▬▬▬▬ WIDGET PARA FILAS DE DETALLE ▬▬▬▬▬
  Widget _detailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: midGreen, size: 30),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 17),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
