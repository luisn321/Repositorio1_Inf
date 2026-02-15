import 'package:flutter/material.dart';
import '../modelos/tecnico_modelo.dart';
import '../servicios_red/servicio_tecnicos.dart';

class PantallaDetalleTecnico extends StatefulWidget {
  final int idTecnico;

  const PantallaDetalleTecnico({
    Key? key,
    required this.idTecnico,
  }) : super(key: key);

  @override
  State<PantallaDetalleTecnico> createState() => _PantallaDetalleTecnicoState();
}

class _PantallaDetalleTecnicoState extends State<PantallaDetalleTecnico> {
  final ServicioTecnicos _servicioTecnicos = ServicioTecnicos();
  late Future<TecnicoModelo?> _futuroTecnico;

  @override
  void initState() {
    super.initState();
    _futuroTecnico = _servicioTecnicos.obtenerTecnicoPorId(widget.idTecnico);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Técnico'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<TecnicoModelo?>(
        future: _futuroTecnico,
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
                ],
              ),
            );
          }

          final tecnico = snapshot.data;
          if (tecnico == null) {
            return const Center(child: Text('Técnico no encontrado'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Encabezado con foto
                Container(
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      tecnico.fotoPerfil != null
                          ? CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(tecnico.fotoPerfil!),
                              onBackgroundImageError: (error, stackTrace) {},
                            )
                          : const CircleAvatar(
                              radius: 60,
                              child: Icon(Icons.person, size: 48),
                            ),
                      const SizedBox(height: 16),
                      Text(
                        tecnico.nombre,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            '${tecnico.calificacionPromedio}/5 (${tecnico.numCalificaciones} calificaciones)',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Información principal
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _construirSeccion(
                        titulo: 'Información de Contacto',
                        contenido: [
                          _construirFila(
                            icono: Icons.email,
                            label: 'Email',
                            valor: tecnico.email,
                          ),
                          _construirFila(
                            icono: Icons.phone,
                            label: 'Teléfono',
                            valor: tecnico.telefono,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _construirSeccion(
                        titulo: 'Tarifas y Ubicación',
                        contenido: [
                          _construirFila(
                            icono: Icons.attach_money,
                            label: 'Tarifa por Hora',
                            valor: '\$${tecnico.tarifaHora.toStringAsFixed(2)}',
                          ),
                          if (tecnico.latitud != null && tecnico.longitud != null)
                            _construirFila(
                              icono: Icons.location_on,
                              label: 'Ubicación',
                              valor: '${tecnico.latitud}, ${tecnico.longitud}',
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Botiones de acción
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                debugPrint('Llamar a: ${tecnico.telefono}');
                                // TODO: Implementar llamada
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.phone),
                                  SizedBox(width: 8),
                                  Text('Llamar'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                debugPrint('Solicitar servicio de: ${tecnico.nombre}');
                                // TODO: Navegar a pantalla de solicitud
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 8),
                                  Text('Solicitar'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _construirSeccion({
    required String titulo,
    required List<Widget> contenido,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...contenido,
      ],
    );
  }

  Widget _construirFila({
    required IconData icono,
    required String label,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
