import 'package:flutter/material.dart';
import 'ClientProfileScreen.dart';
import 'ServiceDetailScreen.dart';
import 'PaymentScreen.dart';
import 'RatingScreen.dart';
import 'TechnicianDetailScreen.dart';
import '../services/api.dart';
import '../config/app_icons.dart';

class ClientHomeScreen extends StatefulWidget {
  final int? clientId;

  const ClientHomeScreen({
    super.key,
    this.clientId,
  });

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int currentIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    // Inicializar las páginas con el clientId
    pages = [
      _HomeView(clientId: widget.clientId ?? 0),         // ← Inicio
      _ClientContractationsView(clientId: widget.clientId ?? 0), // ← Mis contractaciones
      ClientProfileScreen(clientId: widget.clientId ?? 0), // ← Perfil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppIcons.white,
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: AppIcons.white,
          selectedItemColor: AppIcons.darkGreen,
          unselectedItemColor: AppIcons.greyMedium,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(AppIcons.navigationIcons['home']!),
              label: "Inicio",
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.navigationIcons['contratos']!),
              label: "Contratos",
            ),
            BottomNavigationBarItem(
              icon: Icon(AppIcons.navigationIcons['perfil']!),
              label: "Perfil",
            ),
          ],
        ),
      ),
    );
  }
}

// ------- VISTA DE INICIO DEL CLIENTE -------

class _HomeView extends StatefulWidget {
  final int clientId;

  const _HomeView({required this.clientId});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final apiService = ApiService();
      final results = await apiService.searchTechnicians(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error buscando técnicos: $e');
      setState(() => _isSearching = false);
    }
  }

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,

      appBar: AppBar(
        backgroundColor: darkGreen,
        elevation: 0,
        title: const Text(
          "Bienvenido",
          style: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: white,
              child: Icon(Icons.person, color: darkGreen),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Buscador
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: "Buscar técnico por nombre",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: lightGreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Mostrar resultados de búsqueda si existen
            if (_searchResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Resultados de búsqueda",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._searchResults.map((tech) {
                      return _buildTechnicianSearchResult(tech);
                    }).toList(),
                  ],
                ),
              )
            else if (_searchController.text.isNotEmpty && !_isSearching)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No se encontraron técnicos con "${_searchController.text}"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título categorías
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Categorías",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Grid de categorías - Cargar desde API
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: ApiService().getServices(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: darkGreen),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final services = snapshot.data ?? [];
                      
                      if (services.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No hay categorías disponibles'),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: services.map((service) {
                            final serviceId = service['id_servicio'] ?? service['id'] ?? 0;
                            final serviceName = service['nombre'] ?? service['name'] ?? 'Sin nombre';
                            return _categoryCard(context, Icons.build, serviceName, serviceId);
                          }).toList(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Técnicos recomendados",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkGreen,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Técnicos recomendados - Cargar desde API
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: ApiService().getTechnicians(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 190,
                          child: Center(
                            child: CircularProgressIndicator(color: darkGreen),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return SizedBox(
                          height: 190,
                          child: Center(
                            child: Text('Error: ${snapshot.error}'),
                          ),
                        );
                      }

                      final technicians = snapshot.data ?? [];

                      if (technicians.isEmpty) {
                        return const SizedBox(
                          height: 190,
                          child: Center(
                            child: Text('No hay técnicos disponibles'),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 190,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 16),
                          itemCount: technicians.length,
                          itemBuilder: (context, index) {
                            final tech = technicians[index];
                            final nombre = tech['nombre'] ?? tech['name'] ?? 'Sin nombre';
                            final descripcion = tech['descripcion'] ?? tech['description'] ?? 'Técnico';
                            final calificacion = (tech['calificacion_promedio'] ?? tech['rating'] ?? 0).toString();
                            return _techCard(nombre, descripcion, calificacion);
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              )
          ],
        ),
      ),
    );
  }

  // TARJETA DE CATEGORÍAS
  Widget _categoryCard(BuildContext context, IconData icon, String title, int serviceId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(
              serviceName: title,
              serviceIcon: icon,
              serviceId: serviceId,
              clientId: widget.clientId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: midGreen, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar imagen PNG en lugar de icono
            Image.asset(
              AppIcons.getServiceImagePath(title),
              width: 55,
              height: 55,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: darkGreen,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // TARJETA DE TÉCNICOS
  Widget _techCard(String name, String job, String rating) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: midGreen,
            child: const Icon(Icons.person, size: 32, color: white),
          ),

          const SizedBox(height: 12),

          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: darkGreen,
            ),
          ),

          Text(job, style: const TextStyle(fontSize: 14, color: Colors.black54)),

          const Spacer(),

          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 20),
              Text(rating),
            ],
          )
        ],
      ),
    );
  }

  // RESULTADO DE BÚSQUEDA DE TÉCNICO
  Widget _buildTechnicianSearchResult(Map<String, dynamic> tech) {
    final nombre = tech['nombre'] ?? 'Sin nombre';
    final rating = (tech['calificacion_promedio'] ?? 0.0) as num;
    final tarifa = (tech['tarifa_hora'] ?? 0.0) as num;
    final idTecnico = tech['id_tecnico'] as int;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TechnicianDetailScreen(
              technicianId: idTecnico,
              clientId: widget.clientId,
              serviceId: 0, // Desde búsqueda, no hay servicio específico
              serviceName: 'Búsqueda',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: midGreen,
              child: const Icon(Icons.person, color: white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: darkGreen,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      Text(' ${rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 12),
                      Text('\$${tarifa.toStringAsFixed(2)}/hora', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: midGreen, size: 18),
          ],
        ),
      ),
    );
  }
}

// ------- VISTA DE CONTRACTACIONES DEL CLIENTE -------

class _ClientContractationsView extends StatefulWidget {
  final int clientId;

  const _ClientContractationsView({required this.clientId});

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<_ClientContractationsView> createState() =>
      _ClientContractationsViewState();
}

class _ClientContractationsViewState extends State<_ClientContractationsView> {
  late Future<List<Map<String, dynamic>>> _contractations;

  @override
  void initState() {
    super.initState();
    _loadContractations();
  }

  void _loadContractations() {
    final apiService = ApiService();
    _contractations =
        apiService.getClientContractations(widget.clientId);
  }

  Future<void> _refreshContractations() async {
    setState(() {
      _loadContractations();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.orange;
      case 'Aceptada':
        return Colors.blue;
      case 'En Progreso':
        return Colors.purple;
      case 'Completada':
        return Colors.green;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ClientContractationsView.white,
      appBar: AppBar(
        backgroundColor: _ClientContractationsView.darkGreen,
        elevation: 0,
        title: const Text(
          "Mis Contractaciones",
          style: TextStyle(
            color: _ClientContractationsView.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _contractations,
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
                        setState(() => _loadContractations()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay contractaciones'),
            );
          }

          final contractations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: contractations.length,
            itemBuilder: (context, index) {
              final contract = contractations[index];
              final serviceName = contract['service_name'] ?? 'Sin servicio';
              final technicianName =
                  contract['technician_name'] ?? 'Sin asignar';
              final estado = contract['estado'] ?? 'Desconocido';
              final detalles = contract['detalles'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  serviceName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _ClientContractationsView
                                        .darkGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Técnico: $technicianName',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(estado),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              estado,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Detalles
                      if (detalles.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _ClientContractationsView.lightGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            detalles,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Botones condicionales
                      if (estado == 'Aceptada')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentScreen(
                                    idContratacion:
                                        contract['id_contratacion'],
                                    serviceName: serviceName,
                                    clientName: _ClientContractationsView
                                        .white
                                        .toString(),
                                    monto: 100.0,
                                  ),
                                ),
                              );
                              // Refrescar datos después de volver del pago
                              _refreshContractations();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              '💳 Pagar y Proceder',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else if (estado == 'Completada')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RatingScreen(
                                    idContratacion:
                                        contract['id_contratacion'],
                                    idTecnico:
                                        contract['id_tecnico'] ?? 0,
                                    technicianName:
                                        contract['technician_name'] ??
                                            'Sin nombre',
                                    serviceName: serviceName,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            child: const Text(
                              '⭐ Calificar Técnico',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

