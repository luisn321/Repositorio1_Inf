import 'package:flutter/material.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  // Colores de la app
  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,

      // ▬▬▬▬▬ TOP BAR ▬▬▬▬▬
      appBar: AppBar(
        backgroundColor: darkGreen,
        elevation: 0,
        title: const Text(
          "Bienvenido",
          style: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: white,
              child: Icon(Icons.person, color: darkGreen),
            ),
          )
        ],
      ),

      // ▬▬▬▬▬ CONTENIDO PRINCIPAL ▬▬▬▬▬
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ▬▬ BUSCADOR ▬▬
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Buscar técnico o servicio",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: lightGreen,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ▬▬ TÍTULO CATEGORÍAS ▬▬
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Categorías",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ▬▬▬▬▬ GRID DE CATEGORÍAS ▬▬▬▬▬
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [

                  _categoryCard(Icons.build, "Electricista"),
                  _categoryCard(Icons.plumbing, "Plomero"),
                  _categoryCard(Icons.handyman, "Carpintero"),
                  _categoryCard(Icons.computer, "Técnico PC"),
                  _categoryCard(Icons.forest, "Jardinería"),
                  _categoryCard(Icons.bolt, "Reparación Línea Blanca"),

                ],
              ),
            ),

            const SizedBox(height: 20),

            // ▬▬▬▬▬ TÉCNICOS RECOMENDADOS ▬▬▬▬▬
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Técnicos recomendados",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 190,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                children: [
                  _techCard("Carlos Pérez", "Electricista", "4.8"),
                  _techCard("Luis Gómez", "Plomero", "4.7"),
                  _techCard("Ana Torres", "Técnica PC", "4.9"),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      // ▬▬▬▬▬ NAV BAR ▬▬▬▬▬
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: white,
        selectedItemColor: darkGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Servicios"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  // ▬▬▬▬▬ WIDGET: TARJETA DE CATEGORÍA ▬▬▬▬▬
  Widget _categoryCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 45, color: darkGreen),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ▬▬▬▬▬ WIDGET: TARJETA DE TÉCNICO ▬▬▬▬▬
  Widget _techCard(String name, String job, String rating) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: midGreen,
            child: Icon(Icons.person, size: 32, color: white),
          ),

          const SizedBox(height: 12),

          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: darkGreen,
            ),
          ),

          Text(
            job,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const Spacer(),

          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 20),
              Text(
                rating,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
