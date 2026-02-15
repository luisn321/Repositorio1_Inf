import 'package:flutter/material.dart';
import '../modelos/contratacion_modelo.dart';
import '../servicios_red/servicio_contrataciones.dart';

class PantallaSolicitudes extends StatefulWidget {
  const PantallaSolicitudes({Key? key}) : super(key: key);

  @override
  State<PantallaSolicitudes> createState() => _PantallaSolicitudesState();
}

class _PantallaSolicitudesState extends State<PantallaSolicitudes>
    with SingleTickerProviderStateMixin {
  final ServicioContrataciones _servicioContrataciones = ServicioContrataciones();
  late TabController _controladorTabs;
  late Future<List<ContratacionModelo>> _futuroContrataciones;

  @override
  void initState() {
    super.initState();
    _controladorTabs = TabController(length: 5, vsync: this);
    _cargarContrataciones();
  }

  void _cargarContrataciones() {
    setState(() {
      _futuroContrataciones = _servicioContrataciones.obtenerTodasLasContrataciones();
    });
  }

  List<ContratacionModelo> _filtrarPorEstado(
    List<ContratacionModelo> contrataciones,
    String estado,
  ) {
    return contrataciones.where((c) => c.estado == estado).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _controladorTabs,
          tabs: const [
            Tab(text: 'Todas', icon: Icon(Icons.list)),
            Tab(text: 'Solicitadas', icon: Icon(Icons.pending)),
            Tab(text: 'En Proceso', icon: Icon(Icons.hourglass_bottom)),
            Tab(text: 'Completadas', icon: Icon(Icons.check_circle)),
            Tab(text: 'Canceladas', icon: Icon(Icons.cancel)),
          ],
        ),
      ),
      body: FutureBuilder<List<ContratacionModelo>>(
        future: _futuroContrataciones,
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
                    onPressed: _cargarContrataciones,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final contrataciones = snapshot.data ?? [];

          return TabBarView(
            controller: _controladorTabs,
            children: [
              // Pestaña: Todas
              _construirListaContrataciones(context, contrataciones),
              // Pestaña: Solicitadas
              _construirListaContrataciones(
                context,
                _filtrarPorEstado(contrataciones, 'solicitada'),
              ),
              // Pestaña: En Proceso
              _construirListaContrataciones(
                context,
                _filtrarPorEstado(contrataciones, 'en_proceso'),
              ),
              // Pestaña: Completadas
              _construirListaContrataciones(
                context,
                _filtrarPorEstado(contrataciones, 'completada'),
              ),
              // Pestaña: Canceladas
              _construirListaContrataciones(
                context,
                _filtrarPorEstado(contrataciones, 'cancelada'),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a pantalla de crear solicitud
          debugPrint('Crear nueva solicitud');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _construirListaContrataciones(
    BuildContext context,
    List<ContratacionModelo> contrataciones,
  ) {
    if (contrataciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay solicitudes',
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
      itemCount: contrataciones.length,
      itemBuilder: (context, index) {
        final contratacion = contrataciones[index];
        return _construirTarjetaContratacion(context, contratacion);
      },
    );
  }

  Widget _construirTarjetaContratacion(
    BuildContext context,
    ContratacionModelo contratacion,
  ) {
    final colorEstado = _obtenerColorEstado(contratacion.estado);
    final iconoEstado = _obtenerIconoEstado(contratacion.estado);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: Icon(
          iconoEstado,
          color: colorEstado,
          size: 32,
        ),
        title: Text('Solicitud #${contratacion.idContratacion}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              contratacion.descripcion ?? 'Sin descripción',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 16,
              children: [
                Text(
                  'Estado: ${contratacion.estado}',
                  style: TextStyle(
                    color: colorEstado,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (contratacion.montoPropuesto != null)
                  Text(
                    '\$${contratacion.montoPropuesto!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // TODO: Navegar a detalle
          debugPrint('Tap en contratación: ${contratacion.idContratacion}');
        },
      ),
    );
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'solicitada':
        return Colors.orange;
      case 'asignada':
        return Colors.blue;
      case 'en_proceso':
        return Colors.purple;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _obtenerIconoEstado(String estado) {
    switch (estado) {
      case 'solicitada':
        return Icons.pending;
      case 'asignada':
        return Icons.assignment;
      case 'en_proceso':
        return Icons.hourglass_bottom;
      case 'completada':
        return Icons.check_circle;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  void dispose() {
    _controladorTabs.dispose();
    super.dispose();
  }
}
