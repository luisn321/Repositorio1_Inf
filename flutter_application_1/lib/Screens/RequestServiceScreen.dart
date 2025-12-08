import 'package:flutter/material.dart';

class RequestServiceScreen extends StatefulWidget {
  final String serviceName;     // Electricista, Plomero, etc.
  final String clientAddress;   // Dirección prellenada
  final int idCliente;          // Lo pasas desde login
  final int idServicio;         // Lo pasas desde categoría / técnico

  const RequestServiceScreen({
    super.key,
    required this.serviceName,
    required this.clientAddress,
    required this.idCliente,
    required this.idServicio,
  });

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  final TextEditingController detallesController = TextEditingController();

  DateTime? fechaServicio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: darkGreen,
        title: const Text(
          "Solicitar Servicio",
          style: TextStyle(color: white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SERVICIO
            const Text(
              "Servicio seleccionado",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _dataBox(widget.serviceName),

            const SizedBox(height: 20),

            // DIRECCIÓN (PRELLENADA)
            const Text(
              "Dirección",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _dataBox(widget.clientAddress),

            const SizedBox(height: 20),

            // FECHA
            const Text(
              "Fecha del servicio",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                DateTime now = DateTime.now();
                DateTime? fecha = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: now,
                  lastDate: DateTime(now.year + 1),
                );
                if (fecha != null) {
                  setState(() => fechaServicio = fecha);
                }
              },
              child: _dataBox(
                fechaServicio == null
                    ? "Seleccionar fecha"
                    : "${fechaServicio!.day}/${fechaServicio!.month}/${fechaServicio!.year}",
              ),
            ),

            const SizedBox(height: 20),

            // DETALLES
            const Text(
              "Detalles del problema",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: detallesController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: lightGreen.withOpacity(0.4),
                hintText: "Describe brevemente el problema…",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOTÓN ENVIAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: midGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  if (fechaServicio == null) {
                    _showMessage("Selecciona una fecha");
                    return;
                  }
                  if (detallesController.text.isEmpty) {
                    _showMessage("Describe el problema");
                    return;
                  }

                  // Aquí formamos los datos tal como tu BD los requiere
                  final Map<String, dynamic> solicitud = {
                    "fecha_ser": fechaServicio.toString().split(" ")[0],
                    "fecha_sol": DateTime.now().toString().split(" ")[0],
                    "estado": "Pendiente",
                    "id_cliente": widget.idCliente,
                    "id_servicio": widget.idServicio,
                    "detalles":
                        "Dirección: ${widget.clientAddress}\nDescripción: ${detallesController.text}",
                  };

                  print("Solicitud creada:");
                  print(solicitud);

                  _showMessage("Solicitud enviada");

                  Navigator.pop(context);
                },
                child: const Text(
                  "Enviar solicitud",
                  style: TextStyle(fontSize: 18, color: white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Caja visual
  Widget _dataBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightGreen.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
