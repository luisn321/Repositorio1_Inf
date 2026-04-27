import 'package:flutter/material.dart';
import '../modelos/pago_modelo.dart';
import '../servicios_red/servicio_pagos.dart';

class PantallaPagos extends StatefulWidget {
  const PantallaPagos({Key? key}) : super(key: key);

  @override
  State<PantallaPagos> createState() => _PantallaPagosState();
}

class _PantallaPagosState extends State<PantallaPagos>
    with SingleTickerProviderStateMixin {
  final ServicioPagos _servicioPagos = ServicioPagos();
  late TabController _controladorTabs;
  late Future<List<PagoModelo>> _futuroPagos;

  @override
  void initState() {
    super.initState();
    _controladorTabs = TabController(length: 3, vsync: this);
    _cargarPagos();
  }

  void _cargarPagos() {
    setState(() {
      _futuroPagos = _servicioPagos.obtenerTodosLosPagos();
    });
  }

  List<PagoModelo> _filtrarPorEstado(
    List<PagoModelo> pagos,
    String estado,
  ) {
    return pagos.where((p) => p.estadoPago == estado).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pagos'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _controladorTabs,
          tabs: const [
            Tab(text: 'Todos', icon: Icon(Icons.payment)),
            Tab(text: 'Completados', icon: Icon(Icons.check_circle)),
            Tab(text: 'Pendientes', icon: Icon(Icons.pending)),
          ],
        ),
      ),
      body: FutureBuilder<List<PagoModelo>>(
        future: _futuroPagos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarPagos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final pagos = snapshot.data ?? [];

          return TabBarView(
            controller: _controladorTabs,
            children: [
              // Todos los pagos
              _construirListaPagos(context, pagos),
              // Completados
              _construirListaPagos(
                context,
                _filtrarPorEstado(pagos, 'Completado'),
              ),
              // Pendientes
              _construirListaPagos(
                context,
                _filtrarPorEstado(pagos, 'Pendiente'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _construirListaPagos(BuildContext context, List<PagoModelo> pagos) {
    if (pagos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay pagos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: pagos.length,
      itemBuilder: (context, index) {
        final pago = pagos[index];
        return _construirTarjetaPago(context, pago);
      },
    );
  }

  Widget _construirTarjetaPago(BuildContext context, PagoModelo pago) {
    final esCompletado = pago.estadoPago == 'Completado';
    final colorEstado = esCompletado ? Colors.green : Colors.orange;
    final iconoEstado = esCompletado ? Icons.check_circle : Icons.pending;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: Icon(iconoEstado, color: colorEstado, size: 32),
        title: Text('Pago #${pago.idPago}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Contratación #${pago.idContratacion}'),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monto: \$${pago.monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Estado: ${pago.estadoPago}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorEstado,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          debugPrint('Tap en pago: ${pago.idPago}');
          // TODO: Mostrar detalles del pago
        },
      ),
    );
  }

  @override
  void dispose() {
    _controladorTabs.dispose();
    super.dispose();
  }
}
