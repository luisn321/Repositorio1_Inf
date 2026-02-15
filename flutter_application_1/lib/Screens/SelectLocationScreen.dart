import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  late MapController _mapController;
  LatLng selectedPoint = LatLng(17.6405, -101.5532); // Zihuatanejo, México

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    print(' FlutterMap inicializado correctamente');
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 204, 112),
        title: const Text("Seleccionar ubicación"),
      ),
      body: Column(
        children: [
          // MAPA
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: selectedPoint,
                initialZoom: 14.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onPositionChanged: (MapPosition pos, bool hasGesture) {
                  setState(() {
                    selectedPoint = pos.center ?? selectedPoint;
                    print(' Nueva ubicación: ${selectedPoint.latitude}, ${selectedPoint.longitude}');
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.de/tiles/osmde/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.flutter.app',
                ),
                // PIN
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedPoint,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        size: 50,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botón Confirmar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DBE7F),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                print(' Ubicación confirmada: ${selectedPoint.latitude}, ${selectedPoint.longitude}');
                Navigator.pop(context, selectedPoint);
              },
              child: const Text(
                "Confirmar ubicación",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
