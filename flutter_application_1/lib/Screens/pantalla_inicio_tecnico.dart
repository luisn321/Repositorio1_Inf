import 'package:flutter/material.dart';

/// Pantalla de inicio para técnicos
class PantallaInicioTecnico extends StatelessWidget {
  final int tecnicoId;

  const PantallaInicioTecnico({required this.tecnicoId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio - Técnico')),
      body: Center(
        child: Text('Pantalla de técnico (ID: $tecnicoId)'),
      ),
    );
  }
}
