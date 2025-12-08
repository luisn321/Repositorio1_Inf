import 'package:flutter/material.dart';
import 'TechnicianDetailScreen.dart';
class TechnicianListScreen extends StatelessWidget {
  final String serviceName;

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  const TechnicianListScreen({
    super.key,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: darkGreen,
        title: Text(
          "Técnicos de $serviceName",
          style: const TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _technicianCard(
            context,
            name: "Carlos Pérez",
            specialty: serviceName,
            experience: "5 años",
            price: "\$250 MXN/hora",
            rating: "4.8",
          ),

          _technicianCard(
            context,
            name: "María Gómez",
            specialty: serviceName,
            experience: "3 años",
            price: "\$200 MXN/hora",
            rating: "4.7",
          ),

          _technicianCard(
            context,
            name: "Jorge Torres",
            specialty: serviceName,
            experience: "6 años",
            price: "\$300 MXN/hora",
            rating: "4.9",
          ),

        ],
      ),
    );
  }

  // ▬▬▬▬▬ TARJETA DE TÉCNICO ▬▬▬▬▬
  Widget _technicianCard(
    BuildContext context, {
    required String name,
    required String specialty,
    required String experience,
    required String price,
    required String rating,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              // Avatar
              const CircleAvatar(
                radius: 28,
                backgroundColor: midGreen,
                child: Icon(Icons.person, size: 32, color: white),
              ),
              const SizedBox(width: 16),

              // Info principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 14),

          Text("Experiencia: $experience"),
          Text("Costo: $price"),

          const SizedBox(height: 14),

          // Botón ver más
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TechnicianDetailScreen(
                      name: name,
                      specialty: specialty,
                      experience: experience,
                      price: price,
                      rating: rating,
                      description: "Profesional dedicado y con amplia experiencia en $specialty. Comprometido con la calidad y satisfacción del cliente.",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: midGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Ver perfil",
                style: TextStyle(
                  color: white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
