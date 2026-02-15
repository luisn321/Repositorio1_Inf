import 'package:flutter/material.dart';
import '../validadores/validadores_servicios.dart';
import '../servicios_red/servicio_calificaciones.dart';

class PantallaCalificaciones extends StatefulWidget {
  final int idContratacion;
  final int idTecnico;
  final String nombreTecnico;

  const PantallaCalificaciones({
    Key? key,
    required this.idContratacion,
    required this.idTecnico,
    required this.nombreTecnico,
  }) : super(key: key);

  @override
  State<PantallaCalificaciones> createState() => _PantallaCalificacionesState();
}

class _PantallaCalificacionesState extends State<PantallaCalificaciones> {
  final _formKey = GlobalKey<FormState>();
  final _controladorComentario = TextEditingController();
  final ServicioCalificaciones _servicioCalificaciones = ServicioCalificaciones();

  int _puntuacionSeleccionada = 0;
  bool _enviando = false;

  void _enviarCalificacion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_puntuacionSeleccionada == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una puntuación')),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      // TODO: Implementar llamada al backend
      debugPrint('Enviando calificación:');
      debugPrint('  Contratación: ${widget.idContratacion}');
      debugPrint('  Técnico: ${widget.idTecnico}');
      debugPrint('  Puntuación: $_puntuacionSeleccionada');
      debugPrint('  Comentario: ${_controladorComentario.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Calificación registrada'),
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
        title: const Text('Calificar Servicio'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Técnico',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.nombreTecnico,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Contratación #${widget.idContratacion}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Puntuación
              const Text(
                '¿Cómo fue el servicio?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Estrellas interactivas
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final puntuacion = index + 1;
                    final estaSeleccionada = puntuacion <= _puntuacionSeleccionada;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _puntuacionSeleccionada = puntuacion;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          estaSeleccionada ? Icons.star : Icons.star_outline,
                          color: Colors.orange,
                          size: 48,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Etiqueta de puntuación
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _obtenerEtiquetaPuntuacion(_puntuacionSeleccionada),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _obtenerColorPuntuacion(_puntuacionSeleccionada),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Comentario
              const Text(
                'Comentario (Opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controladorComentario,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Comparte tu experiencia con este técnico...',
                  counterText: '',
                ),
                validator: ValidadoresServicios.validarComentario,
              ),

              const SizedBox(height: 32),

              // Botón de envío
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _enviando ? null : _enviarCalificacion,
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
                          'Enviar Calificación',
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

  String _obtenerEtiquetaPuntuacion(int puntuacion) {
    switch (puntuacion) {
      case 0:
        return 'Selecciona una puntuación';
      case 1:
        return 'Muy Mal 😞';
      case 2:
        return 'Mal 😕';
      case 3:
        return 'Regular 😐';
      case 4:
        return 'Bien 😊';
      case 5:
        return '¡Excelente! 😍';
      default:
        return '';
    }
  }

  Color _obtenerColorPuntuacion(int puntuacion) {
    switch (puntuacion) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _controladorComentario.dispose();
    super.dispose();
  }
}
