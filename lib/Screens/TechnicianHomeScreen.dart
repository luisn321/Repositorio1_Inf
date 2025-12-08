import 'package:flutter/material.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  bool available = true; // Estado ONLINE/OFFLINE

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,

      // ▬▬▬▬▬ HEADER ▬▬▬▬▬
      appBar: AppBar(
        backgroundColor: darkGreen,
        elevation: 0,
        title: const Text(
          "Panel del Técnico",
          style: TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: white),
            onPressed: () {},
          )
        ],
      ),

      // ▬▬▬▬▬ CONTENIDO ▬▬▬▬▬
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ▬▬ ONLINE / OFFLINE ▬▬
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    available ? "Estás disponible" : "Estás offline",
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: available,
                    activeColor: darkGreen,
                    onChanged: (v) {
                      setState(() => available = v);
                    },
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ▬▬▬ ESTADÍSTICAS ▬▬▬
            const Text(
              "Estadísticas",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                _statCard("Trabajos", "24", Icons.build),
                const SizedBox(width: 12),
                _statCard("Rating", "4.8", Icons.star),
              ],
            ),

            const SizedBox(height: 20),

            // ▬▬▬ SOLICITUDES RECIENTES ▬▬▬
            const Text(
              "Solicitudes recientes",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),

            const SizedBox(height: 12),

            _requestCard("Juan Pérez", "Electricista", "Pendiente"),
            _requestCard("María Gómez", "Plomería", "En progreso"),
            _requestCard("Carlos López", "PC / Laptop", "Completado"),
          ],
        ),
      ),

      // ▬▬▬ NAV BAR ▬▬▬
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: darkGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Solicitudes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  // ▬▬▬ WIDGET TARJETA DE ESTADÍSTICAS ▬▬▬
  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 35, color: darkGreen),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                )),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // ▬▬▬ WIDGET TARJETA DE SOLICITUD ▬▬▬
  Widget _requestCard(String user, String type, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: midGreen,
            radius: 28,
            child: const Icon(Icons.person, color: white),
          ),
          const SizedBox(width: 16),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    )),
                Text(type, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),

          // Estado
          Text(
            status,
            style: TextStyle(
              color: status == "Completado"
                  ? Colors.green
                  : status == "Pendiente"
                      ? Colors.orange
                      : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
