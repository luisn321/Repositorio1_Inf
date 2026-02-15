import 'package:flutter/material.dart';
import 'ClientRequestScreen.dart';
import 'ClientProfileScreen.dart';
import 'ServiceDetailScreen.dart';

class ClientHomeScreen extends StatefulWidget {
  final int? clientId;

  const ClientHomeScreen({
    super.key,
    this.clientId,
  });

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int currentIndex = 0;

  static const Color darkGreen = Color(0xFF0F6B44);

  static const Color white = Colors.white;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    // Inicializar las páginas con el clientId
    pages = [
      const _HomeView(),         // ← Inicio
      const ClientRequestScreen(), // ← Mis servicios
      ClientProfileScreen(clientId: widget.clientId ?? 0), // ← Perfil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: white,
        selectedItemColor: darkGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Servicios"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}

// ------- VISTA DE INICIO DEL CLIENTE -------

class _HomeView extends StatelessWidget {
  const _HomeView();

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

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Buscador
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Buscar técnico o servicio",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: lightGreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Título categorías
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

            // Grid de categorías
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
                  _categoryCard(context, Icons.build, "Electricista"),
                  _categoryCard(context, Icons.plumbing, "Plomero"),
                  _categoryCard(context, Icons.handyman, "Carpintero"),
                  _categoryCard(context, Icons.computer, "Técnico PC"),
                  _categoryCard(context, Icons.forest, "Jardinería"),
                  _categoryCard(context, Icons.bolt, "Reparación Línea Blanca"),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
    );
  }

  // TARJETA DE CATEGORÍAS
  Widget _categoryCard(BuildContext context, IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(
              serviceName: title,
              serviceIcon: icon,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius: BorderRadius.circular(20),
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
      ),
    );
  }

  // TARJETA DE TÉCNICOS
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
          CircleAvatar(
            radius: 28,
            backgroundColor: midGreen,
            child: const Icon(Icons.person, size: 32, color: white),
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

          Text(job, style: const TextStyle(fontSize: 14, color: Colors.black54)),

          const Spacer(),

          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 20),
              Text(rating),
            ],
          )
        ],
      ),
    );
  }
}
