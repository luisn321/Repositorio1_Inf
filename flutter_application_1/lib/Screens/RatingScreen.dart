import 'package:flutter/material.dart';
import '../services/api.dart';

class RatingScreen extends StatefulWidget {
  final int idContratacion;
  final int idTecnico;
  final String technicianName;
  final String serviceName;

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  const RatingScreen({
    super.key,
    required this.idContratacion,
    required this.idTecnico,
    required this.technicianName,
    required this.serviceName,
  });

  @override
  _RatingScreenState createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int selectedStars = 0;
  final TextEditingController commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (selectedStars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona una calificación.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final apiService = ApiService();
      await apiService.createRating(
        idContratacion: widget.idContratacion,
        idTecnico: widget.idTecnico,
        puntuacion: selectedStars,
        comentario: commentController.text.isEmpty
            ? 'Sin comentarios'
            : commentController.text,
      );

      if (mounted) {
        // Mostrar diálogo de éxito
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('✅ Éxito'),
              content: const Text('Gracias por tu reseña. El técnico ha sido calificado.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                    Navigator.of(context).pop(); // Regresa a la pantalla anterior
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RatingScreen.darkGreen,
                  ),
                  child: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar calificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RatingScreen.white,
      appBar: AppBar(
        backgroundColor: RatingScreen.darkGreen,
        title: const Text(
          "Calificar Técnico",
          style: TextStyle(color: RatingScreen.white),
        ),
        iconTheme: const IconThemeData(color: RatingScreen.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Servicio: ${widget.serviceName}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: RatingScreen.darkGreen,
              ),
            ),
            const SizedBox(height: 4),

            Text(
              "Técnico: ${widget.technicianName}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            const Text(
              "Calificación:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: index < selectedStars ? Colors.orange : Colors.grey,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedStars = index + 1;
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            const Text(
              "Comentario:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: commentController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: RatingScreen.lightGreen,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: "Escribe tu opinión...",
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RatingScreen.midGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            RatingScreen.white,
                          ),
                        ),
                      )
                    : const Text(
                        "Enviar Reseña",
                        style: TextStyle(
                          fontSize: 18,
                          color: RatingScreen.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

