import 'package:flutter/material.dart';
import 'TechnicianServicesScreen.dart';
import 'TechnicianRequestScreen.dart';   // ← Nombre correcto
import 'TechnicianProfileScreen.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  int currentIndex = 0;

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color white = Colors.white;

  // ← Las 3 pantallas del panel del técnico
  final List<Widget> screens = [
    const TechnicianServicesScreen(),     // → Mis servicios
    const TechnicianRequestScreen(),      // → Mis solicitudes
    const TechnicianProfileScreen(),      // → Mi perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,

      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: darkGreen,
        unselectedItemColor: Colors.grey,
        backgroundColor: white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: "Servicios",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Solicitudes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
