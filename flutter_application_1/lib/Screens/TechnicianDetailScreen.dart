import 'package:flutter/material.dart';
import '../services/api.dart';

class TechnicianDetailScreen extends StatefulWidget {
  final int technicianId;
  final int clientId;
  final int serviceId;
  final String serviceName;

  const TechnicianDetailScreen({
    super.key,
    required this.technicianId,
    required this.clientId,
    required this.serviceId,
    required this.serviceName,
  });

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<TechnicianDetailScreen> createState() =>
      _TechnicianDetailScreenState();
}

class _TechnicianDetailScreenState extends State<TechnicianDetailScreen> {
  late Future<Map<String, dynamic>> _technicianDetail;
  final TextEditingController _descriptionController =
      TextEditingController();
  DateTime? _scheduledDate;
  bool _isRequesting = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTechnicianDetail();
  }

  void _loadTechnicianDetail() {
    final apiService = ApiService();
    _technicianDetail =
        apiService.getTechnicianDetail(widget.technicianId);
  }

  Future<void> _requestService() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor describe el trabajo que necesitas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isRequesting = true);

    try {
      final apiService = ApiService();
      await apiService.createContractation(
        idCliente: widget.clientId,
        idTecnico: widget.technicianId,
        idServicio: widget.serviceId,
        detalles: _descriptionController.text,
        fechaProgramada: _scheduledDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Solicitud enviada al técnico'),
            backgroundColor: Colors.green,
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isRequesting = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechnicianDetailScreen.white,
      appBar: AppBar(
        backgroundColor: TechnicianDetailScreen.darkGreen,
        title: const Text(
          'Detalle Técnico',
          style: TextStyle(color: TechnicianDetailScreen.white),
        ),
        iconTheme:
            const IconThemeData(color: TechnicianDetailScreen.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _technicianDetail,
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
                        setState(() => _loadTechnicianDetail()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No hay datos'));
          }

          final tech = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: TechnicianDetailScreen.midGreen,
                    child: const Icon(Icons.person,
                        size: 70,
                        color: TechnicianDetailScreen.white),
                  ),
                ),
                const SizedBox(height: 20),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TechnicianDetailScreen.lightGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        tech['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: TechnicianDetailScreen.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email
                      Row(
                        children: [
                          const Icon(Icons.email,
                              size: 18,
                              color: TechnicianDetailScreen.midGreen),
                          const SizedBox(width: 8),
                          Text(tech['email'] ?? 'Sin email',
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Teléfono
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 18,
                              color: TechnicianDetailScreen.midGreen),
                          const SizedBox(width: 8),
                          Text(tech['telefono'] ?? 'Sin teléfono',
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Tarifa
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tarifa/hora:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '\$${(tech['tarifa_hora'] ?? 0.0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: TechnicianDetailScreen.midGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Experiencia
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Experiencia:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${tech['experiencia_years'] ?? 0} años',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Calificación
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Calificación:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 18, color: Colors.amber),
                              Text(
                                ' ${(tech['calificacion_promedio'] ?? 0.0).toStringAsFixed(1)}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Descripción
                      if (tech['descripcion'] != null &&
                          (tech['descripcion'] as String).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Descripción:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              tech['descripcion'],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Fecha programada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Fecha programada:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: _pickDate,
                      child: Text(_scheduledDate == null
                          ? 'Seleccionar fecha'
                          : '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Descripción de la solicitud
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Describe el trabajo que necesitas:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: TechnicianDetailScreen.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: TechnicianDetailScreen.lightGreen,
                        hintText: 'Describe el trabajo...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botón Solicitar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isRequesting ? null : _requestService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          TechnicianDetailScreen.darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isRequesting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                TechnicianDetailScreen.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Solicitar Servicio',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: TechnicianDetailScreen.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


