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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Técnicos Disponibles'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controladorBusqueda,
              onChanged: _buscarTecnico,
              decoration: InputDecoration(
                hintText: 'Buscar técnico...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
      child: ListTile(
        leading: tecnico.fotoPerfil != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(tecnico.fotoPerfil!),
                errorBuilder: (context, error, stackTrace) {
                  return const CircleAvatar(child: Icon(Icons.person));
                },
              )
            : const CircleAvatar(child: Icon(Icons.person)),
        title: Text(tecnico.nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('⭐ ${tecnico.calificacionPromedio}/5 (${tecnico.numCalificaciones} calificaciones)'),
            Text('💰 \$${tecnico.tarifaHora.toStringAsFixed(2)}/hr'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone, size: 18),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward),
          ],
        ),
        onTap: () {
          // TODO: Navegar a detalle del técnico
          debugPrint('Tap en técnico: ${tecnico.nombre}');
        },
      ),
    );
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }
}
