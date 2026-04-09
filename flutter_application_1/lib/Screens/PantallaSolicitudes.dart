import 'package:flutter/material.dart';
import '../config/app_icons.dart';
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
        backgroundColor: AppIcons.darkGreen,
        elevation: 2,
        bottom: TabBar(
          controller: _controladorTabs,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
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
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade400,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar solicitudes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _cargarContrataciones,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppIcons.darkGreen,
                    ),
                  ),
                ],
              ),
            );
          }

          final contrataciones = snapshot.data ?? [];

          return TabBarView(
            controller: _controladorTabs,
            children: [
              _construirListaContrataciones(context, contrataciones),
              _construirListaContrataciones(
                context,
                _filtrarPorEstado(contrataciones, 'solicitada'),
              ),
              _construirListaContrataciones(
                context,
                _filtrarPorEstado(contrataciones, 'en_proceso'),
              ),
              _construirListaContrataciones(
                context,
                _filtrarPorEstado(contrataciones, 'completada'),
              ),
              _construirListaContrataciones(
                context,
                _filtrarPorEstado(contrataciones, 'cancelada'),
              ),
            ],
          );
        },
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
              size: 80,
              color: AppIcons.darkGreen.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay solicitudes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
    final esMovil = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: esMovil ? 12 : 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppIcons.darkGreen.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Solicitud #${contratacion.idContratacion}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppIcons.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        contratacion.descripcion ?? 'Sin descripción',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorEstado.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(iconoEstado, color: colorEstado, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorEstado.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        contratacion.estado.toUpperCase(),
                        style: TextStyle(
                          color: colorEstado,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: AppIcons.darkGreen.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (contratacion.montoPropuesto != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monto',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${contratacion.montoPropuesto!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppIcons.darkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Estado',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contratacion.estado,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorEstado,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'solicitada':
        return Colors.orange;
      case 'en_proceso':
        return Colors.blue;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return AppIcons.darkGreen;
    }
  }

  IconData _obtenerIconoEstado(String estado) {
    switch (estado) {
      case 'solicitada':
        return Icons.pending;
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
