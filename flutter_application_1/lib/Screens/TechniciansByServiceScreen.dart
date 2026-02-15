import 'package:flutter/material.dart';
import '../services/api.dart';
import '../config/app_icons.dart';
import 'TechnicianDetailScreen.dart';

class TechniciansByServiceScreen extends StatefulWidget {
  final int serviceId;
  final String serviceName;
  final int clientId;

  const TechniciansByServiceScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.clientId,
  });

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<TechniciansByServiceScreen> createState() =>
      _TechniciansByServiceScreenState();
}

class _TechniciansByServiceScreenState
    extends State<TechniciansByServiceScreen> {
  late Future<List<Map<String, dynamic>>> _technicians;

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  void _loadTechnicians() {
    final apiService = ApiService();
    _technicians = apiService.getTechnicians(serviceId: widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechniciansByServiceScreen.white,
      appBar: AppBar(
        backgroundColor: TechniciansByServiceScreen.darkGreen,
        title: Row(
          children: [
            // Imagen del servicio
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: TechniciansByServiceScreen.midGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                AppIcons.getServiceImagePath(widget.serviceName),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            // Título
            Expanded(
              child: Text(
                'Técnicos - ${widget.serviceName}',
                style: const TextStyle(
                  color: TechniciansByServiceScreen.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        iconTheme:
            const IconThemeData(color: TechniciansByServiceScreen.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _technicians,
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
                    onPressed: () => setState(() => _loadTechnicians()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay técnicos disponibles para este servicio'),
            );
          }

          final technicians = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              final tech = technicians[index];
              final nombre = tech['nombre'] ?? 'Sin nombre';
              final email = tech['email'] ?? 'Sin email';
              final tarifa = tech['tarifa_hora'] ?? 0.0;
              final calificacion = tech['calificacion_promedio'] ?? 0.0;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: TechniciansByServiceScreen.midGreen,
                    child: const Icon(Icons.person,
                        color: TechniciansByServiceScreen.white),
                  ),
                  title: Text(nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email, style: const TextStyle(fontSize: 12)),
                      Text(
                        'Tarifa: \$${tarifa.toStringAsFixed(2)}/h',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(' ${calificacion.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TechnicianDetailScreen(
                            technicianId: tech['id_tecnico'],
                            clientId: widget.clientId,
                            serviceId: widget.serviceId,
                            serviceName: widget.serviceName,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          TechniciansByServiceScreen.midGreen,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      'Ver',
                      style: TextStyle(
                          fontSize: 12,
                          color: TechniciansByServiceScreen.white),
                    ),
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
