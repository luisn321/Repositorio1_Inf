import 'package:flutter/material.dart';
import '../config/app_icons.dart';

/// Pantalla de perfil para cliente
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppIcons.darkGreen,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Pantalla de Perfil - Cliente'),
      ),
    );
  }
}
