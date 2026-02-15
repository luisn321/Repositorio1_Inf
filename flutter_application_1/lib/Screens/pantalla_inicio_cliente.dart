import 'package:flutter/material.dart';

/// Pantalla de inicio para clientes
class PantallaInicioCliente extends StatelessWidget {
  final int clienteId;

  const PantallaInicioCliente({required this.clienteId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio - Cliente')),
      body: Center(
        child: Text('Pantalla de cliente (ID: $clienteId)'),
      ),
    );
  }
}
