import 'package:flutter/material.dart';
import '../modelos/servicio_modelo.dart';
import '../validadores/validadores_servicios.dart';

class PantallaCrearSolicitud extends StatefulWidget {
  final int idCliente;

  const PantallaCrearSolicitud({
    Key? key,
    required this.idCliente,
  }) : super(key: key);

  @override
  State<PantallaCrearSolicitud> createState() => _PantallaCrearSolicitudState();
}

class _PantallaCrearSolicitudState extends State<PantallaCrearSolicitud> {
  final _formKey = GlobalKey<FormState>();
  final _controladorDescripcion = TextEditingController();
  final _controladorFecha = TextEditingController();
  final _controladorUbicacion = TextEditingController();

  int? _servicioSeleccionado;
  DateTime? _fechaSeleccionada;
  bool _enviando = false;

  // Mock lista de servicios - en prod vino del backend
  final List<ServicioModelo> _servicios = [
    ServicioModelo(
      idServicio: 1,
      nombre: 'Reparación de Tuberías',
      descripcion: 'Reparaciones generales de tuberías',
      tarifaBase: 45.0,
      numTecnicosDisponibles: 5,
    ),
    ServicioModelo(
      idServicio: 2,
      nombre: 'Limpieza de Desagüe',
      descripcion: 'Limpieza profunda de sistema de desagüe',
      tarifaBase: 60.0,
      numTecnicosDisponibles: 3,
    ),
  ];

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: ahora.add(const Duration(days: 1)),
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 30)),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _controladorFecha.text = '${fecha.day}/${fecha.month}/${fecha.year}';
      });
    }
  }

  void _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_servicioSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un servicio')),
      );
      return;
    }

    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha')),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      // TODO: Implementar llamada al backend
      debugPrint('Enviando solicitud:');
      debugPrint('  Cliente: ${widget.idCliente}');
      debugPrint('  Servicio: $_servicioSeleccionado');
      debugPrint('  Descripción: ${_controladorDescripcion.text}');
      debugPrint('  Fecha: $_fechaSeleccionada');
      debugPrint('  Ubicación: ${_controladorUbicacion.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Solicitud enviada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Solicitud'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de servicio
              const Text(
                'Selecciona un Servicio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _servicioSeleccionado,
                items: _servicios.map((servicio) {
                  return DropdownMenuItem(
                    value: servicio.idServicio,
                    child: Text(servicio.nombre),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() => _servicioSeleccionado = valor);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Elige un servicio...',
                ),
                validator: ValidadoresServicios.validarSeleccionServicio,
              ),
              const SizedBox(height: 24),

              // Descripción
              const Text(
                'Descripción del Problema',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controladorDescripcion,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText:
                      'Describe el problema o el servicio que necesitas...',
                  counterText: '', // Ocultar contador
                ),
                validator: ValidadoresServicios.validarDescripcion,
              ),
              const SizedBox(height: 24),

              // Fecha
              const Text(
                'Fecha Estimada',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controladorFecha,
                readOnly: true,
                onTap: _seleccionarFecha,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Selecciona una fecha',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: _fechaSeleccionada != null
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
                validator: ValidadoresServicios.validarFechaFutura,
              ),
              const SizedBox(height: 24),

              // Ubicación
              const Text(
                'Ubicación (Opcional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controladorUbicacion,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Dirección o referencia de ubicación',
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: ValidadoresServicios.validarUbicacion,
              ),
              const SizedBox(height: 32),

              // Botón de envío
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _enviando ? null : _enviarSolicitud,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _enviando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Enviar Solicitud',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controladorDescripcion.dispose();
    _controladorFecha.dispose();
    _controladorUbicacion.dispose();
    super.dispose();
  }
}
