import 'package:flutter/material.dart';
import '../modelos/tecnico_modelo.dart';
import '../servicios_red/servicio_tecnicos.dart';

class PantallaListaTecnicos extends StatefulWidget {
  final int? idServicio;

  const PantallaListaTecnicos({Key? key, this.idServicio}) : super(key: key);

  @override
  State<PantallaListaTecnicos> createState() => _PantallaListaTecnicosState();
}

class _PantallaListaTecnicosState extends State<PantallaListaTecnicos> {
  final ServicioTecnicos _servicioTecnicos = ServicioTecnicos();
  late Future<List<TecnicoModelo>> _futuroTecnicos;
  final TextEditingController _controladorBusqueda = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarTecnicos();
  }

  void _cargarTecnicos() {
    setState(() {
      if (widget.idServicio != null) {
        _futuroTecnicos = _servicioTecnicos.obtenerTecnicosPorServicio(widget.idServicio!);
      } else {
        _futuroTecnicos = _servicioTecnicos.obtenerTodosTecnicos();
      }
    });
  }

  void _buscarTecnico(String nombre) {
    if (nombre.isEmpty) {
      _cargarTecnicos();
    } else {
      setState(() {
        _futuroTecnicos = _servicioTecnicos.buscarTecnicosPorNombre(nombre);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final esMovil = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Técnicos Disponibles'),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.all(esMovil ? 12 : 16),
            child: TextField(
              controller: _controladorBusqueda,
              onChanged: _buscarTecnico,
              decoration: InputDecoration(
                hintText: 'Buscar técnico...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Lista de técnicos
          Expanded(
            child: FutureBuilder<List<TecnicoModelo>>(
              future: _futuroTecnicos,
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
                          onPressed: _cargarTecnicos,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final tecnicos = snapshot.data ?? [];
                if (tecnicos.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron técnicos'),
                  );
                }

                return ListView.builder(
                  itemCount: tecnicos.length,
                  itemBuilder: (context, index) {
                    final tecnico = tecnicos[index];
                    return _construirTarjetaTecnico(context, tecnico);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaTecnico(BuildContext context, TecnicoModelo tecnico) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            tecnico.fotoPerfil != null
                ? CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(tecnico.fotoPerfil!),
                    onBackgroundImageError: (error, stackTrace) {},
                  )
                : const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person),
                  ),
            const SizedBox(width: 12),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tecnico.nombreCompleto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${tecnico.calificacionPromedio}/5 (${tecnico.numCalificaciones})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '💰 \$${tecnico.tarifaHora.toStringAsFixed(2)}/hr',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            // Botón ver más
            GestureDetector(
              onTap: () {
                debugPrint('Tap en técnico: ${tecnico.nombreCompleto}');
              },
              child: const Icon(Icons.arrow_forward, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }
}
