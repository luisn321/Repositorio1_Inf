import 'package:flutter/material.dart';
import '../services/api.dart';

class TechnicianServicesScreen extends StatefulWidget {
  final int? technicianId;

  const TechnicianServicesScreen({
    super.key,
    this.technicianId,
  });

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<TechnicianServicesScreen> createState() => _TechnicianServicesScreenState();
}

class _TechnicianServicesScreenState extends State<TechnicianServicesScreen> {
  Map<int, Map<String, dynamic>> services = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final api = ApiService();
      final list = await api.getServices();
      setState(() {
        services = {
          for (var s in list) (s['id_servicio'] as int): {'nombre': s['nombre'] as String, 'sel': false}
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando servicios: $e')));
    }
  }

  Future<void> _guardarServicios() async {
    if (widget.technicianId == null || widget.technicianId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de técnico no disponible')),
      );
      return;
    }

    final selected = services.entries
        .where((e) => e.value['sel'] == true)
        .map((e) => e.key)
        .toList();

    setState(() => _isSaving = true);

    try {
      final api = ApiService();
      await api.updateTechnicianServices(
        technicianId: widget.technicianId!,
        serviceIds: selected,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Servicios guardados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechnicianServicesScreen.white,
      appBar: AppBar(
        backgroundColor: TechnicianServicesScreen.darkGreen,
        title: const Text(
          "Mis Servicios",
          style: TextStyle(color: TechnicianServicesScreen.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selecciona los servicios que ofreces",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: TechnicianServicesScreen.darkGreen,
              ),
            ),

            const SizedBox(height: 20),

            // Lista de servicios en tarjetas
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: services.keys.map((id) {
                        final item = services[id]!;
                        return _serviceCard(
                          title: item['nombre'],
                          value: item['sel'],
                          onChanged: (val) {
                            setState(() {
                              services[id]!['sel'] = val!;
                            });
                          },
                        );
                      }).toList(),
                    ),
            ),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _guardarServicios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TechnicianServicesScreen.darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            TechnicianServicesScreen.white,
                          ),
                        ),
                      )
                    : const Text(
                        "Guardar",
                        style: TextStyle(
                          color: TechnicianServicesScreen.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget de tarjeta de servicio
  Widget _serviceCard({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TechnicianServicesScreen.lightGreen,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            activeColor: TechnicianServicesScreen.midGreen,
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: TechnicianServicesScreen.darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
