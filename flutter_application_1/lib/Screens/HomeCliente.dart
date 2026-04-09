import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modelos/usuario_modelo.dart';
import 'PantallaListaTecnicos.dart';
import 'PantallaSolicitudesCliente.dart';
import 'PantallaPerfilCliente.dart';

// ── Design tokens (sistema unificado Servitec) ───────────────────────────────
const Color _verde = Color(0xFF1A5C38);
const Color _verdeClaro = Color(0xFF247A4A);
const Color _verdeOscuro = Color(0xFF0F3B22);
const Color _acento = Color(0xFF4CAF82);
const Color _fondoPage = Color(0xFFF2F6F4);
const Color _fondoCampo = Color(0xFFFFFFFF);
const Color _bordeField = Color(0xFFDDE8E3);
const Color _grisTexto = Color(0xFF8FA89B);
const Color _grisOscuro = Color(0xFF3D4F46);
// ─────────────────────────────────────────────────────────────────────────────

/// Home principal para CLIENTE
/// Contiene: BottomNavBar con 3 tabs (Buscar, Solicitudes, Perfil)
class HomeCliente extends StatefulWidget {
  final int clienteId;
  final UsuarioModelo? usuario;

  const HomeCliente({required this.clienteId, this.usuario, super.key});

  @override
  State<HomeCliente> createState() => _HomeClienteState();
}

class _HomeClienteState extends State<HomeCliente> {
  int _tabActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPage,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(_tabActual),
          child: _construirPantallaTab(_tabActual),
        ),
      ),
      bottomNavigationBar: _BottomNavServitec(
        tabActual: _tabActual,
        onTap: (i) => setState(() => _tabActual = i),
      ),
    );
  }

  Widget _construirPantallaTab(int index) {
    switch (index) {
      case 0:
        return BuscadorServicios(
          clienteId: widget.clienteId,
          usuario: widget.usuario,
        );
      case 1:
        return PantallaSolicitudesCliente(idCliente: widget.clienteId);
      case 2:
        return PantallaPerfilCliente(
          clienteId: widget.clienteId,
          usuarioActual: widget.usuario,
        );
      default:
        return BuscadorServicios(clienteId: widget.clienteId);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// BOTTOM NAV BAR PERSONALIZADO
// ════════════════════════════════════════════════════════════════════════════
class _BottomNavServitec extends StatelessWidget {
  final int tabActual;
  final ValueChanged<int> onTap;

  const _BottomNavServitec({required this.tabActual, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.search_rounded, label: 'Buscar'),
    _NavItem(icon: Icons.receipt_long_rounded, label: 'Solicitudes'),
    _NavItem(icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final activo = tabActual == i;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: activo
                        ? _verde.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: activo ? _verde : _grisTexto,
                        size: 24,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: activo
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: activo ? _verde : _grisTexto,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ════════════════════════════════════════════════════════════════════════════
// BUSCADOR DE SERVICIOS
// ════════════════════════════════════════════════════════════════════════════
class BuscadorServicios extends StatefulWidget {
  final int clienteId;
  final UsuarioModelo? usuario;

  const BuscadorServicios({required this.clienteId, this.usuario, super.key});

  @override
  State<BuscadorServicios> createState() => _BuscadorServiciosState();
}

class _BuscadorServiciosState extends State<BuscadorServicios> {
  final TextEditingController _controladorBusqueda = TextEditingController();
  bool _buscando = false;

  final List<Map<String, dynamic>> _servicios = [
    {
      'id': 1,
      'nombre': 'Electricista',
      'icono': 'Iconos/Electricista1.png',
      'fallback': Icons.bolt_rounded,
      'color': const Color(0xFFFFF3CD),
      'colorIcon': const Color(0xFFD4A017),
    },
    {
      'id': 2,
      'nombre': 'Plomero',
      'icono': 'Iconos/Plomero1.png',
      'fallback': Icons.water_drop_rounded,
      'color': const Color(0xFFCCE5FF),
      'colorIcon': const Color(0xFF1565C0),
    },
    {
      'id': 3,
      'nombre': 'Carpintero',
      'icono': 'Iconos/Carpintero1.png',
      'fallback': Icons.handyman_rounded,
      'color': const Color(0xFFFFE0CC),
      'colorIcon': const Color(0xFFBF5700),
    },
    {
      'id': 4,
      'nombre': 'Técnico PC',
      'icono': 'Iconos/TecnicoPC.png',
      'fallback': Icons.computer_rounded,
      'color': const Color(0xFFE8D5F5),
      'colorIcon': const Color(0xFF6A1B9A),
    },
    {
      'id': 5,
      'nombre': 'Jardinería',
      'icono': 'Iconos/Jardin1.png',
      'fallback': Icons.yard_rounded,
      'color': const Color(0xFFD4F0DC),
      'colorIcon': const Color(0xFF2E7D32),
    },
    {
      'id': 6,
      'nombre': 'Línea Blanca',
      'icono': 'Iconos/LineaBlanca1.png',
      'fallback': Icons.kitchen_rounded,
      'color': const Color(0xFFE0F2F1),
      'colorIcon': const Color(0xFF00695C),
    },
  ];

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  void _buscarPorNombre() {
    final nombre = _controladorBusqueda.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Ingresa un nombre para buscar',
                style: GoogleFonts.dmSans(color: Colors.white),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _verdeOscuro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaListaTecnicos(
          nombreBusqueda: nombre,
          idCliente: widget.clienteId,
        ),
      ),
    );
  }

  String get _nombreUsuario {
    if (widget.usuario?.nombre != null) {
      return widget.usuario!.nombre.split(' ').first;
    }
    return 'Cliente';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPage,
      body: CustomScrollView(
        slivers: [
          // ── HEADER + BUSCADOR ───────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader()),

          // ── SECCIÓN: Servicios disponibles ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: _buildSectionHeader(
                'Servicios disponibles',
                'Toca una categoría para ver técnicos',
              ),
            ),
          ),

          // ── GRID SERVICIOS ───────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final s = _servicios[index];
                return _TarjetaServicio(
                  nombre: s['nombre'] as String,
                  iconoPath: s['icono'] as String,
                  fallback: s['fallback'] as IconData,
                  colorFondo: s['color'] as Color,
                  colorIcon: s['colorIcon'] as Color,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaListaTecnicos(
                        idServicio: s['id'] as int,
                        idCliente: widget.clienteId,
                      ),
                    ),
                  ),
                );
              }, childCount: _servicios.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets internos ─────────────────────────────────────────────────────

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
          // Círculos decorativos
          Positioned(
            top: -30,
            right: -20,
            child: _DecorCircle(size: 130, opacity: 0.07),
          ),
          Positioned(
            top: 30,
            right: 60,
            child: _DecorCircle(size: 50, opacity: 0.1),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _acento.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'SERVITEC',
                      style: GoogleFonts.dmMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _acento,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Saludo
                  Text(
                    'Hola, $_nombreUsuario 👋',
                    style: GoogleFonts.sora(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '¿Qué servicio necesitas hoy?',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── BUSCADOR dentro del header ──────────────────────────
                  _buildBuscador(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuscador() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controladorBusqueda,
              style: GoogleFonts.dmSans(color: _grisOscuro, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar técnico por nombre…',
                hintStyle: GoogleFonts.dmSans(color: _grisTexto, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _grisTexto,
                  size: 20,
                ),
                suffixIcon: _controladorBusqueda.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: _grisTexto,
                          size: 18,
                        ),
                        onPressed: () {
                          _controladorBusqueda.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 14,
                ),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _buscarPorNombre(),
            ),
          ),
          // Botón buscar
          GestureDetector(
            onTap: _buscarPorNombre,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _verde,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Buscar',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String titulo, String subtitulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: _acento,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              titulo,
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _verde,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            subtitulo,
            style: GoogleFonts.dmSans(fontSize: 12, color: _grisTexto),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TARJETA DE SERVICIO
// ════════════════════════════════════════════════════════════════════════════
class _TarjetaServicio extends StatelessWidget {
  final String nombre;
  final String iconoPath;
  final IconData fallback;
  final Color colorFondo;
  final Color colorIcon;
  final VoidCallback onTap;

  const _TarjetaServicio({
    required this.nombre,
    required this.iconoPath,
    required this.fallback,
    required this.colorFondo,
    required this.colorIcon,
    required this.onTap,
  });

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
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Círculo de color con imagen/icono
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorFondo,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(14),
              child: Image.asset(
                iconoPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(fallback, color: colorIcon, size: 30),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              nombre,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _grisOscuro,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ver técnicos',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: _acento,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _acento,
                  size: 9,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ════════════════════════════════════════════════════════════════════════════
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
    );
  }
}
