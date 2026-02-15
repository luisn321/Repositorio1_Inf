import 'package:flutter/material.dart';
import 'TechnicianServicesScreen.dart';
import 'TechnicianRequestsScreen.dart';
import 'TechnicianProfileScreen.dart';
import '../services/api.dart';
import '../config/app_icons.dart';

class TechnicianHomeScreen extends StatefulWidget {
  final int? technicianId;

  const TechnicianHomeScreen({
    super.key,
    this.technicianId,
  });

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  int currentIndex = 0;

  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      TechnicianServicesScreen(technicianId: widget.technicianId),     // → Mis servicios
      TechnicianRequestsScreen(technicianId: widget.technicianId ?? 0), // → Mis solicitudes
      _TechnicianContractationsView(technicianId: widget.technicianId ?? 0), // → Contractaciones
      TechnicianProfileScreen(technicianId: widget.technicianId ?? 0),      // → Mi perfil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppIcons.white,
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          selectedItemColor: AppIcons.darkGreen,
          unselectedItemColor: AppIcons.greyMedium,
          backgroundColor: AppIcons.white,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              icon: Icon(AppIcons.navigationIcons['configuracion']!),
              label: "Servicios",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_rounded),
              label: "Solicitudes",
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.navigationIcons['contratos']!),
              label: "Trabajos",
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.navigationIcons['perfil']!),
              label: "Perfil",
            ),
          ],
        ),
      ),
    );
  }
}

// ------- VISTA DE CONTRACTACIONES DEL TÉCNICO -------

class _TechnicianContractationsView extends StatefulWidget {
  final int technicianId;

  const _TechnicianContractationsView({required this.technicianId});

  @override
  State<_TechnicianContractationsView> createState() =>
      _TechnicianContractationsViewState();
}

class _TechnicianContractationsViewState
    extends State<_TechnicianContractationsView> {
  late Future<List<Map<String, dynamic>>> _contractations;

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

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

  Future<void> _markCompleted(int idContratacion) async {
    try {
      final apiService = ApiService();
      await apiService.updateContractationStatus(
        idContratacion,
        'Completada',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Trabajo marcado como completado'),
          backgroundColor: Colors.green,
        ),
      );

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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.orange;
      case 'Aceptada':
        return Colors.blue;
      case 'En Progreso':
        return Colors.purple;
      case 'Completada':
        return Colors.green;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: darkGreen,
        elevation: 0,
        title: const Text(
          "Mis Trabajos",
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
              child: Text('No hay trabajos asignados'),
            );
          }

          final contractations = snapshot.data!;
          // Filtrar solo contractaciones aceptadas o en progreso
          final activeContractations = contractations
              .where((c) =>
                  c['estado'] == 'Aceptada' ||
                  c['estado'] == 'En Progreso')
              .toList();

          if (activeContractations.isEmpty) {
            return const Center(
              child: Text('No hay trabajos activos'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: activeContractations.length,
            itemBuilder: (context, index) {
              final contract = activeContractations[index];
              final serviceName = contract['service_name'] ?? 'Sin servicio';
              final clientName = contract['client_name'] ?? 'Sin cliente';
              final estado = contract['estado'] ?? 'Desconocido';
              final detalles = contract['detalles'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  serviceName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: darkGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cliente: $clientName',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(estado),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              estado,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Detalles
                      if (detalles.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: lightGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            detalles,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Botón condicional
                      if (estado == 'En Progreso')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _markCompleted(
                              contract['id_contratacion'],
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: midGreen,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              '✅ Marcar como Completado',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
