import 'package:flutter/material.dart';
import '../services/api.dart';

class TechnicianRequestsScreen extends StatefulWidget {
  final int technicianId;

  const TechnicianRequestsScreen({
    super.key,
    required this.technicianId,
  });

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<TechnicianRequestsScreen> createState() =>
      _TechnicianRequestsScreenState();
}

class _TechnicianRequestsScreenState extends State<TechnicianRequestsScreen> {
  late Future<List<Map<String, dynamic>>> _contractations;

  @override
  void initState() {
    super.initState();
    _loadContractations();
  }

  void _loadContractations() {
    final apiService = ApiService();
    _contractations =
        apiService.getTechnicianContractations(widget.technicianId);
  }

  Future<void> _updateStatus(int idContratacion, String newStatus) async {
    try {
      final apiService = ApiService();
      await apiService.updateContractationStatus(
        idContratacion,
        newStatus,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'Aceptada'
                ? '✅ Solicitud aceptada'
                : '❌ Solicitud rechazada',
          ),
          backgroundColor:
              newStatus == 'Aceptada' ? Colors.green : Colors.red,
        ),
      );

      // Recargar lista
      setState(() => _loadContractations());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechnicianRequestsScreen.white,
      appBar: AppBar(
        backgroundColor: TechnicianRequestsScreen.darkGreen,
        title: const Text(
          'Solicitudes de Servicio',
          style: TextStyle(color: TechnicianRequestsScreen.white),
        ),
        iconTheme:
            const IconThemeData(color: TechnicianRequestsScreen.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contractations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _loadContractations()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay solicitudes de servicio'),
            );
          }

          // Filtrar solo contractaciones pendientes
          final contractations =
              snapshot.data!.where((c) => c['estado'] == 'Pendiente').toList();

          if (contractations.isEmpty) {
            return const Center(
              child: Text('No hay solicitudes pendientes'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: contractations.length,
            itemBuilder: (context, index) {
              final contract = contractations[index];
              final clientName = contract['client_name'] ?? 'Sin nombre';
              final serviceName = contract['service_name'] ?? 'Sin servicio';
              final detalles = contract['detalles'] ?? 'Sin descripción';
              final fechaSolicitud = contract['fecha_solicitud'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cliente
                      Row(
                        children: [
                          const Icon(Icons.person,
                              color:
                                  TechnicianRequestsScreen.midGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cliente:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  clientName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: TechnicianRequestsScreen
                                        .darkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Servicio
                      Row(
                        children: [
                          const Icon(Icons.build,
                              color:
                                  TechnicianRequestsScreen.midGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Servicio:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  serviceName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Fecha
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color:
                                  TechnicianRequestsScreen.midGreen,
                              size: 18),
                          const SizedBox(width: 8),
                          Text(
                            fechaSolicitud,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Detalles del trabajo
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TechnicianRequestsScreen.lightGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detalles del trabajo:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TechnicianRequestsScreen.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              detalles,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botones
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          // Rechazar
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateStatus(
                                contract['id_contratacion'],
                                'Cancelada',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Rechazar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Aceptar
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _updateStatus(
                                contract['id_contratacion'],
                                'Aceptada',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    TechnicianRequestsScreen.midGreen,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Aceptar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
