import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modelos/tecnico_modelo.dart';
import '../servicios_red/servicio_tecnicos.dart';
import 'PantallaDetalleTecnico.dart';

// ── Design tokens (sistema unificado Servitec) ───────────────────────────────
const Color _verde       = Color(0xFF1A5C38);
const Color _verdeClaro  = Color(0xFF247A4A);
const Color _verdeOscuro = Color(0xFF0F3B22);
const Color _acento      = Color(0xFF4CAF82);
const Color _fondoPage   = Color(0xFFF2F6F4);
const Color _fondoCampo  = Color(0xFFFFFFFF);
const Color _bordeField  = Color(0xFFDDE8E3);
const Color _grisTexto   = Color(0xFF8FA89B);
const Color _grisOscuro  = Color(0xFF3D4F46);
const Color _ambar       = Color(0xFFF5A623);
// ─────────────────────────────────────────────────────────────────────────────

// Mapa de servicios
const Map<int, Map<String, dynamic>> _mapaServicios = {
  1: {'nombre': 'Electricistas',  'icono': Icons.bolt_rounded,         'color': Color(0xFFFFF3CD)},
  2: {'nombre': 'Plomeros',       'icono': Icons.water_drop_rounded,   'color': Color(0xFFCCE5FF)},
  3: {'nombre': 'Carpinteros',    'icono': Icons.handyman_rounded,     'color': Color(0xFFFFE0CC)},
  4: {'nombre': 'Técnicos PC',    'icono': Icons.computer_rounded,     'color': Color(0xFFE8D5F5)},
  5: {'nombre': 'Jardinería',     'icono': Icons.yard_rounded,         'color': Color(0xFFD4F0DC)},
  6: {'nombre': 'Línea Blanca',   'icono': Icons.kitchen_rounded,      'color': Color(0xFFE0F2F1)},
};

class PantallaListaTecnicos extends StatefulWidget {
  final int? idServicio;
  final String? nombreBusqueda;
  final int? idCliente;

  const PantallaListaTecnicos({
    Key? key,
    this.idServicio,
    this.nombreBusqueda,
    this.idCliente,
  }) : super(key: key);

  @override
  State<PantallaListaTecnicos> createState() => _PantallaListaTecnicosState();
}

class _PantallaListaTecnicosState extends State<PantallaListaTecnicos>
    with SingleTickerProviderStateMixin {
  final ServicioTecnicos _servicioTecnicos = ServicioTecnicos();
  late Future<List<TecnicoModelo>> _futuroTecnicos;
  final TextEditingController _controladorBusqueda = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _cargarTecnicos();
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _cargarTecnicos() {
    setState(() {
      if (widget.nombreBusqueda != null &&
          widget.nombreBusqueda!.isNotEmpty) {
        _futuroTecnicos =
            _servicioTecnicos.buscarTecnicosPorNombre(widget.nombreBusqueda!);
      } else if (widget.idServicio != null) {
        _futuroTecnicos =
            _servicioTecnicos.obtenerTecnicosPorServicio(widget.idServicio!);
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
        _futuroTecnicos =
            _servicioTecnicos.buscarTecnicosPorNombre(nombre);
      });
    }
  }

  String _obtenerMensajeError(String error) {
    if (error.contains('401') || error.contains('Token inválido')) {
      return 'Tu sesión ha expirado.\nPor favor, inicia sesión nuevamente.';
    } else if (error.contains('500')) {
      return 'Hay un problema en nuestros servidores.\nIntentaremos resolver pronto.';
    } else if (error.contains('SocketException') ||
        error.contains('Failed host lookup')) {
      return 'Verifica tu conexión a internet\ne intenta nuevamente.';
    } else if (error.contains('TimeoutException')) {
      return 'La conexión tardó demasiado.\nIntentaremos de nuevo.';
    } else {
      return 'Parece que hay un problema.\nIntenta nuevamente en unos momentos.';
    }
  }

  // ── Títulos dinámicos ────────────────────────────────────────────────────
  String get _titulo {
    if (widget.nombreBusqueda != null &&
        widget.nombreBusqueda!.isNotEmpty) {
      return '"${widget.nombreBusqueda}"';
    }
    if (widget.idServicio != null) {
      return _mapaServicios[widget.idServicio]?['nombre'] as String? ??
          'Técnicos';
    }
    return 'Técnicos disponibles';
  }

  String get _subtitulo {
    if (widget.nombreBusqueda != null &&
        widget.nombreBusqueda!.isNotEmpty) {
      return 'Resultados de búsqueda';
    }
    if (widget.idServicio != null) {
      return 'Profesionales disponibles en esta categoría';
    }
    return 'Todos los técnicos registrados';
  }

  IconData get _iconoCategoria {
    if (widget.idServicio != null) {
      return _mapaServicios[widget.idServicio]?['icono'] as IconData? ??
          Icons.build_rounded;
    }
    return Icons.search_rounded;
  }

  Color get _colorCategoria {
    if (widget.idServicio != null) {
      return (_mapaServicios[widget.idServicio]?['color'] as Color?) ??
          const Color(0xFFD4F0DC);
    }
    return const Color(0xFFD4F0DC);
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPage,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // ── HEADER ────────────────────────────────────────────────────
            _buildHeader(),

            // ── BUSCADOR ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _buildBuscador(),
            ),

            // ── LISTA ─────────────────────────────────────────────────────
            Expanded(
              child: FutureBuilder<List<TecnicoModelo>>(
                future: _futuroTecnicos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildCargando();
                  }
                  if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  }
                  final tecnicos = snapshot.data ?? [];
                  if (tecnicos.isEmpty) return _buildVacio();

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: tecnicos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _TarjetaTecnico(
                          tecnico: tecnicos[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PantallaDetalleTecnico(
                                tecnico: tecnicos[index],
                                idCliente: widget.idCliente,
                                idServicio: widget.idServicio,
                              ),
                            ),
                          ),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_verdeOscuro, _verde, _verdeClaro],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -30, right: -20,
              child: _DecorCircle(size: 140, opacity: 0.07)),
          Positioned(top: 40, right: 55,
              child: _DecorCircle(size: 55, opacity: 0.09)),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila: botón volver + badge
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2), width: 1),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _acento.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('SERVITEC',
                          style: GoogleFonts.dmMono(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: _acento, letterSpacing: 2.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Ícono de categoría + título
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Círculo ícono categoría
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_iconoCategoria,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_titulo,
                              style: GoogleFonts.sora(
                                fontSize: 22, fontWeight: FontWeight.w700,
                                color: Colors.white, height: 1.15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(_subtitulo,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Buscador ─────────────────────────────────────────────────────────────
  Widget _buildBuscador() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controladorBusqueda,
        onChanged: _buscarTecnico,
        style: GoogleFonts.dmSans(color: _grisOscuro, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar técnico por nombre…',
          hintStyle: GoogleFonts.dmSans(color: _grisTexto, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: _grisTexto, size: 20),
          suffixIcon: _controladorBusqueda.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: _grisTexto, size: 18),
                  onPressed: () {
                    _controladorBusqueda.clear();
                    _cargarTecnicos();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  // ── Estados vacío / carga / error ─────────────────────────────────────────
  Widget _buildCargando() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
              color: _verde, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text('Buscando técnicos…',
            style: GoogleFonts.dmSans(
                fontSize: 14, color: _grisTexto),
          ),
        ],
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: _fondoPage,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded,
                  color: _grisTexto, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Sin resultados',
              style: GoogleFonts.sora(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: _grisOscuro,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No encontramos técnicos con ese criterio.\nIntenta con otro nombre o categoría.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: _grisTexto, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_outlined,
                  color: Color(0xFFE05252), size: 36),
            ),
            const SizedBox(height: 16),
            Text('Sin conexión',
              style: GoogleFonts.sora(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: _grisOscuro,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _obtenerMensajeError(error),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: _grisTexto, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _verde,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 13),
              ),
              onPressed: _cargarTecnicos,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Reintentar',
                style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TARJETA DE TÉCNICO
// ════════════════════════════════════════════════════════════════════════════
class _TarjetaTecnico extends StatelessWidget {
  final TecnicoModelo tecnico;
  final VoidCallback onTap;

  const _TarjetaTecnico({
    required this.tecnico,
    required this.onTap,
  });

  // Iniciales del nombre
  String get _iniciales {
    final partes = tecnico.nombreCompleto.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return partes[0].isNotEmpty ? partes[0][0].toUpperCase() : '?';
  }

  // Color de avatar basado en el nombre
  Color get _colorAvatar {
    final colores = [
      const Color(0xFF1A5C38),
      const Color(0xFF1565C0),
      const Color(0xFF6A1B9A),
      const Color(0xFFBF5700),
      const Color(0xFF00695C),
      const Color(0xFF2E7D32),
    ];
    return colores[tecnico.nombreCompleto.length % colores.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14, offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────────────────────
            _buildAvatar(),

            const SizedBox(width: 14),

            // ── Info ──────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre
                  Text(
                    tecnico.nombreCompleto,
                    style: GoogleFonts.sora(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E2D26),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Calificación
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: _ambar, size: 15),
                      const SizedBox(width: 3),
                      Text(
                        '${tecnico.calificacionPromedio.toStringAsFixed(1)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: _grisOscuro,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '(${tecnico.numCalificaciones})',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: _grisTexto),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Fila inferior: tarifa + chip disponible
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _verde.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${tecnico.tarifaHora.toStringAsFixed(0)}/hr',
                          style: GoogleFonts.dmSans(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: _verde,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: _acento, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text('Disponible',
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: _acento,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Flecha ────────────────────────────────────────────────
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: _verde.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: _verde, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 58, height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: tecnico.fotoPerfil != null
            ? Image.network(
                tecnico.fotoPerfil!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarIniciales(),
              )
            : _avatarIniciales(),
      ),
    );
  }

  Widget _avatarIniciales() {
    return Container(
      color: _colorAvatar,
      child: Center(
        child: Text(
          _iniciales,
          style: GoogleFonts.sora(
            fontSize: 20, fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGET AUXILIAR
// ════════════════════════════════════════════════════════════════════════════
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.white.withOpacity(opacity), width: 1.5),
      ),
    );
  }
}
