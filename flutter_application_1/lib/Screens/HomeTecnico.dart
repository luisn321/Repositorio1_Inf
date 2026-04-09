import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modelos/usuario_modelo.dart';
import '../servicios_red/servicio_contrataciones.dart';
import 'PantallaPerfilTecnico.dart';
import 'PantallaSolicitudesTecnico.dart';

// ── Design tokens (sistema unificado Servitec) ───────────────────────────────
const Color _verde       = Color(0xFF1A5C38);
const Color _verdeClaro  = Color(0xFF247A4A);
const Color _verdeOscuro = Color(0xFF0F3B22);
const Color _acento      = Color(0xFF4CAF82);
const Color _fondoPage   = Color(0xFFF2F6F4);
const Color _bordeField  = Color(0xFFDDE8E3);
const Color _grisTexto   = Color(0xFF8FA89B);
const Color _grisOscuro  = Color(0xFF3D4F46);
const Color _errorColor  = Color(0xFFE05252);
// ─────────────────────────────────────────────────────────────────────────────

const List<Map<String, dynamic>> _catalogoServicios = [
  {'id': 1, 'nombre': 'Electricista', 'icono': Icons.bolt_rounded,       'color': Color(0xFFFFF3CD), 'colorIcon': Color(0xFFD4A017)},
  {'id': 2, 'nombre': 'Plomero',      'icono': Icons.water_drop_rounded, 'color': Color(0xFFCCE5FF), 'colorIcon': Color(0xFF1565C0)},
  {'id': 3, 'nombre': 'Carpintero',   'icono': Icons.handyman_rounded,   'color': Color(0xFFFFE0CC), 'colorIcon': Color(0xFFBF5700)},
  {'id': 4, 'nombre': 'Técnico PC',   'icono': Icons.computer_rounded,   'color': Color(0xFFE8D5F5), 'colorIcon': Color(0xFF6A1B9A)},
  {'id': 5, 'nombre': 'Jardinería',   'icono': Icons.yard_rounded,       'color': Color(0xFFD4F0DC), 'colorIcon': Color(0xFF2E7D32)},
  {'id': 6, 'nombre': 'Línea Blanca', 'icono': Icons.kitchen_rounded,    'color': Color(0xFFE0F2F1), 'colorIcon': Color(0xFF00695C)},
];

// ════════════════════════════════════════════════════════════════════════════
class HomeTecnico extends StatefulWidget {
  final int tecnicoId;
  final UsuarioModelo? usuario;

  const HomeTecnico({required this.tecnicoId, this.usuario, super.key});

  @override
  State<HomeTecnico> createState() => _HomeTecnicoState();
}

class _HomeTecnicoState extends State<HomeTecnico> {
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
      bottomNavigationBar: _BottomNav(
        tabActual: _tabActual,
        onTap: (i) => setState(() => _tabActual = i),
      ),
    );
  }

  Widget _construirPantallaTab(int index) {
    switch (index) {
      case 0:
        return PantallaConfigurarServicios(
          usuario: widget.usuario,
          tecnicoId: widget.tecnicoId,
        );
      case 1: return PantallaSolicitudesTecnico(idTecnico: widget.tecnicoId);
      case 2: return PantallaPerfilTecnico(
          tecnicoId: widget.tecnicoId, usuarioActual: widget.usuario);
      default: return PantallaConfigurarServicios(usuario: widget.usuario);
    }
  }
}

// ── Bottom Nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int tabActual;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.tabActual, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.build_circle_outlined, label: 'Servicios'),
    _NavItem(icon: Icons.receipt_long_rounded,  label: 'Solicitudes'),
    _NavItem(icon: Icons.person_rounded,        label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final activo = tabActual == i;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: activo ? _verde.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_items[i].icon,
                          color: activo ? _verde : _grisTexto, size: 24),
                      const SizedBox(height: 3),
                      Text(_items[i].label,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: activo ? FontWeight.w700 : FontWeight.w400,
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
// PANTALLA: CONFIGURAR SERVICIOS
// ════════════════════════════════════════════════════════════════════════════
class PantallaConfigurarServicios extends StatefulWidget {
  final UsuarioModelo? usuario;
  final int? tecnicoId; // 👈 Agregado para robustez
  const PantallaConfigurarServicios({this.usuario, this.tecnicoId, super.key});

  @override
  State<PantallaConfigurarServicios> createState() =>
      _PantallaConfigurarServiciosState();
}

class _PantallaConfigurarServiciosState
    extends State<PantallaConfigurarServicios> {

  final _servicioRed = ServicioContrataciones();
  final Map<int, bool> _seleccionados = {};
  List<Map<String, dynamic>> _serviciosGuardados = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    for (final s in _catalogoServicios) {
      _seleccionados[s['id'] as int] = false;
    }
    _cargarServiciosConfigurados();
  }

  Future<void> _cargarServiciosConfigurados() async {
    final id = widget.usuario?.id ?? widget.tecnicoId;
    if (id == null) return;
    
    setState(() => _cargando = true);
    try {
      debugPrint('📡 Cargando servicios para técnico ID: $id');
      final idsConfigurados = await _servicioRed.obtenerServiciosConfigurados(id);
      
      if (mounted) {
        setState(() {
          // 1. Sincronizar el Grid (iconos verdes)
          for (final key in _seleccionados.keys) {
            _seleccionados[key] = idsConfigurados.contains(key);
          }
          
          // 2. Sincronizar la Lista inferior (Mis servicios activos)
          _serviciosGuardados = _catalogoServicios
              .where((s) => idsConfigurados.contains(s['id'] as int))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando servicios: $e');
      _snack('No se pudieron cargar tus servicios actuales', warn: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarServicios() async {
    final id = widget.usuario?.id ?? widget.tecnicoId;
    if (id == null) return;

    final idsSeleccionados = _seleccionados.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    if (idsSeleccionados.isEmpty) {
      _snack('Selecciona al menos un servicio', warn: true);
      return;
    }

    setState(() => _cargando = true);
    try {
      final exito = await _servicioRed.actualizarServiciosConfigurados(
        id, 
        idsSeleccionados
      );

      if (exito) {
        setState(() {
          _serviciosGuardados = _catalogoServicios
              .where((s) => idsSeleccionados.contains(s['id'] as int))
              .toList();
        });
        _snack('Servicios actualizados correctamente');
      }
    } catch (e) {
      _snack('Error al guardar: $e', warn: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarServicio(int idServ) async {
    final idTec = widget.usuario?.id ?? widget.tecnicoId;
    if (idTec == null) return;

    // Si solo queda uno, no permitir eliminar
    if (_serviciosGuardados.length <= 1) {
      _snack('Debes ofrecer al menos un servicio', warn: true);
      return;
    }

    final nuevosIds = _serviciosGuardados
        .where((s) => s['id'] != idServ)
        .map((s) => s['id'] as int)
        .toList();

    setState(() => _cargando = true);
    try {
      final exito = await _servicioRed.actualizarServiciosConfigurados(
        idTec, 
        nuevosIds
      );

      if (exito) {
        setState(() {
          _serviciosGuardados.removeWhere((s) => s['id'] == idServ);
          _seleccionados[idServ] = false;
        });
        _snack('Servicio desactivado');
      }
    } catch (e) {
      _snack('Error al actualizar: $e', warn: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _snack(String msg, {bool warn = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(warn ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg,
            style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white))),
      ]),
      behavior: SnackBarBehavior.floating,
      backgroundColor: warn ? const Color(0xFFD4A017) : _verde,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  String get _primerNombre =>
      widget.usuario?.nombre.split(' ').first ?? 'Técnico';

  @override
  Widget build(BuildContext context) {
    if (_cargando && _serviciosGuardados.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAF9),
        body: Center(
          child: CircularProgressIndicator(color: _verde),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _fondoPage,
      body: CustomScrollView(
        slivers: [
          // HEADER
          SliverToBoxAdapter(child: _buildHeader()),

          // Título sección selección
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: _seccionHeader(
                'Añadir servicios',
                'Selecciona los que deseas ofrecer',
              ),
            ),
          ),

          // Grid selección
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final s = _catalogoServicios[i];
                  final id = s['id'] as int;
                  final sel = _seleccionados[id] ?? false;
                  return _TileSeleccion(
                    nombre:     s['nombre'] as String,
                    icono:      s['icono'] as IconData,
                    colorFondo: s['color'] as Color,
                    colorIcon:  s['colorIcon'] as Color,
                    seleccionado: sel,
                    onTap: () => setState(() => _seleccionados[id] = !sel),
                  );
                },
                childCount: _catalogoServicios.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12, crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
            ),
          ),

          // Botón guardar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardarServicios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _verde, foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _cargando 
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text('Guardar servicios',
                            style: GoogleFonts.sora(
                              fontSize: 15, fontWeight: FontWeight.w600,
                              letterSpacing: 0.2),
                          ),
                        ],
                      ),
                ),
              ),
            ),
          ),

          // Sección servicios activos
          if (_serviciosGuardados.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: _seccionHeader(
                  'Mis servicios activos',
                  'Toca × para desactivar un servicio',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final s = _serviciosGuardados[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TileActivo(
                        nombre:     s['nombre'] as String,
                        icono:      s['icono'] as IconData,
                        colorFondo: s['color'] as Color,
                        colorIcon:  s['colorIcon'] as Color,
                        onEliminar: () => _confirmarEliminar(s),
                      ),
                    );
                  },
                  childCount: _serviciosGuardados.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
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
              child: _Circle(size: 140, opacity: 0.07)),
          Positioned(top: 40, right: 55,
              child: _Circle(size: 55, opacity: 0.09)),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 12),
                  Text('Hola, $_primerNombre 🔧',
                    style: GoogleFonts.sora(
                      fontSize: 26, fontWeight: FontWeight.w700,
                      color: Colors.white, height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Gestiona los servicios que ofreces',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.72),
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

  Widget _seccionHeader(String titulo, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 4, height: 20,
            decoration: BoxDecoration(
              color: _acento, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 10),
          Text(titulo,
            style: GoogleFonts.sora(
              fontSize: 16, fontWeight: FontWeight.w700, color: _verde),
          ),
        ]),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(sub,
            style: GoogleFonts.dmSans(fontSize: 12, color: _grisTexto)),
        ),
      ],
    );
  }

  void _confirmarEliminar(Map<String, dynamic> s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Desactivar servicio',
          style: GoogleFonts.sora(
            fontSize: 17, fontWeight: FontWeight.w700, color: _verde)),
        content: Text(
          '¿Quieres dejar de ofrecer "${s['nombre']}"?',
          style: GoogleFonts.dmSans(fontSize: 14, color: _grisOscuro)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
              style: GoogleFonts.dmSans(
                  color: _grisTexto, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _errorColor, foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _eliminarServicio(s['id'] as int);
            },
            child: Text('Desactivar',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TILE SELECCIÓN (grid superior — sin/con check)
// ════════════════════════════════════════════════════════════════════════════
class _TileSeleccion extends StatelessWidget {
  final String nombre;
  final IconData icono;
  final Color colorFondo;
  final Color colorIcon;
  final bool seleccionado;
  final VoidCallback onTap;

  const _TileSeleccion({
    required this.nombre, required this.icono,
    required this.colorFondo, required this.colorIcon,
    required this.seleccionado, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: seleccionado ? _verde : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: seleccionado ? _verde : _bordeField,
            width: seleccionado ? 2 : 1.5,
          ),
          boxShadow: seleccionado
              ? [BoxShadow(color: _verde.withValues(alpha: 0.28),
                  blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Stack(
          children: [
            if (seleccionado)
              Positioned(top: 10, right: 10,
                child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 13),
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? Colors.white.withValues(alpha: 0.18)
                          : colorFondo,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icono, size: 26,
                        color: seleccionado ? Colors.white : colorIcon),
                  ),
                  const SizedBox(height: 10),
                  Text(nombre,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: seleccionado ? Colors.white : _grisOscuro,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// TILE ACTIVO (lista de guardados)
// ════════════════════════════════════════════════════════════════════════════
class _TileActivo extends StatelessWidget {
  final String nombre;
  final IconData icono;
  final Color colorFondo;
  final Color colorIcon;
  final VoidCallback onEliminar;

  const _TileActivo({
    required this.nombre, required this.icono,
    required this.colorFondo, required this.colorIcon,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: colorFondo, shape: BoxShape.circle),
            child: Icon(icono, color: colorIcon, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre,
                  style: GoogleFonts.dmSans(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: _grisOscuro,
                  ),
                ),
                const SizedBox(height: 3),
                Row(children: [
                  Container(width: 6, height: 6,
                    decoration: const BoxDecoration(
                        color: _acento, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('Activo',
                    style: GoogleFonts.dmSans(
                      fontSize: 11, color: _acento,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEliminar,
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close_rounded,
                  color: _errorColor, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Círculo decorativo ────────────────────────────────────────────────────────
class _Circle extends StatelessWidget {
  final double size, opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.white.withValues(alpha: opacity), width: 1.5),
      ),
    );
  }
}
