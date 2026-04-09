import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../modelos/tecnico_modelo.dart';
import '../modelos/calificacion_modelo.dart';
import '../servicios_red/servicio_contrataciones.dart';
import 'PantallaCrearSolicitud.dart';
import '../utilidades/visor_imagenes_universal.dart';

// ── Design tokens (sistema unificado Servitec) ───────────────────────────────
const Color _verde = Color(0xFF1A5C38);
const Color _verdeClaro = Color(0xFF247A4A);
const Color _verdeOscuro = Color(0xFF0F3B22);
const Color _acento = Color(0xFF4CAF82);
const Color _fondoPage = Color(0xFFF2F6F4);
const Color _fondoCampo = Color(0xFFF4F7F5);
const Color _grisTexto = Color(0xFF8FA89B);
const Color _grisOscuro = Color(0xFF3D4F46);
const Color _ambar = Color(0xFFF5A623);
// ─────────────────────────────────────────────────────────────────────────────

const Map<int, String> _nombreServicios = {
  1: 'Electricista',
  2: 'Plomero',
  3: 'Carpintero',
  4: 'Técnico PC',
  5: 'Jardinería',
  6: 'Línea Blanca',
};

const Map<int, IconData> _iconoServicios = {
  1: Icons.bolt_rounded,
  2: Icons.water_drop_rounded,
  3: Icons.handyman_rounded,
  4: Icons.computer_rounded,
  5: Icons.yard_rounded,
  6: Icons.kitchen_rounded,
};

class PantallaDetalleTecnico extends StatefulWidget {
  final TecnicoModelo tecnico;
  final int? idCliente;
  final int? idServicio;

  const PantallaDetalleTecnico({
    required this.tecnico,
    this.idCliente,
    this.idServicio,
    super.key,
  });

  @override
  State<PantallaDetalleTecnico> createState() => _PantallaDetalleTecnicoState();
}

class _PantallaDetalleTecnicoState extends State<PantallaDetalleTecnico> {
  final ServicioContrataciones _servicio = ServicioContrataciones();
  List<CalificacionModelo> _resenas = [];
  bool _cargandoResenas = true;

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    try {
      final res = await _servicio.obtenerResenasTecnico(
        widget.tecnico.idTecnico,
      );
      if (mounted) {
        setState(() {
          _resenas = res;
          _cargandoResenas = false;
        });
      }
    } catch (e) {
      debugPrint('Error cargando reseñas: $e');
      if (mounted) setState(() => _cargandoResenas = false);
    }
  }

  String get _iniciales {
    final p = widget.tecnico.nombreCompleto.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return p[0].isNotEmpty ? p[0][0].toUpperCase() : '?';
  }

  Color get _colorAvatar {
    final c = [
      const Color(0xFF1A5C38),
      const Color(0xFF1565C0),
      const Color(0xFF6A1B9A),
      const Color(0xFFBF5700),
      const Color(0xFF00695C),
      const Color(0xFF2E7D32),
    ];
    return c[widget.tecnico.nombreCompleto.length % c.length];
  }

  void _crearSolicitud(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PantallaCrearSolicitud(
          idCliente: widget.idCliente ?? 0,
          idTecnico: widget.tecnico.idTecnico,
          idServicio: widget.idServicio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPage,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildStatsRow(),
                      const SizedBox(height: 16),

                      if (widget.tecnico.idServicios != null &&
                          widget.tecnico.idServicios!.isNotEmpty) ...[
                        _buildSeccion(
                          titulo: 'Especialidades',
                          child: _buildChipsServicios(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _buildSeccion(
                        titulo: 'Información de contacto',
                        child: Column(
                          children: [
                            _buildItemInfo(
                              icono: Icons.alternate_email_rounded,
                              titulo: 'Correo',
                              valor: widget.tecnico.email,
                            ),
                            _divider(),
                            _buildItemInfo(
                              icono: Icons.phone_outlined,
                              titulo: 'Teléfono',
                              valor: widget.tecnico.telefono,
                            ),
                            if (widget.tecnico.ubicacionText != null &&
                                widget.tecnico.ubicacionText!.isNotEmpty) ...[
                              _divider(),
                              _buildItemInfo(
                                icono: Icons.location_on_outlined,
                                titulo: 'Ubicación',
                                valor: widget.tecnico.ubicacionText!,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildSeccion(
                        titulo: 'Sobre el técnico',
                        child: Text(
                          (widget.tecnico.descripcion?.isNotEmpty ?? false)
                              ? widget.tecnico.descripcion!
                              : 'Este técnico aún no ha agregado una descripción.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color:
                                (widget.tecnico.descripcion?.isNotEmpty ??
                                    false)
                                ? _grisOscuro
                                : _grisTexto,
                            height: 1.65,
                            fontStyle:
                                (widget.tecnico.descripcion?.isNotEmpty ??
                                    false)
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ✨ SECCIÓN DE RESEÑAS (ESTILO ALIEXPRESS/ML)
                      _buildSeccionComentarios(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Botón flotante pegado al bottom
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBoton(context)),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
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
          Positioned(
            top: -30,
            right: -20,
            child: _DecorCircle(size: 160, opacity: 0.07),
          ),
          Positioned(
            top: 60,
            right: 50,
            child: _DecorCircle(size: 60, opacity: 0.09),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                          'PERFIL TÉCNICO',
                          style: GoogleFonts.dmMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _acento,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: () {
                      if (widget.tecnico.fotoPerfil != null &&
                          widget.tecnico.fotoPerfil!.isNotEmpty) {
                        VisorImagenUniversal.abrir(
                          context,
                          widget.tecnico.fotoPerfil!,
                          'avatar_tecnico_detalle',
                        );
                      }
                    },
                    child: Hero(
                      tag: 'avatar_tecnico_detalle',
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 3,
                              ),
                            ),
                          ),
                          ClipOval(
                            child: SizedBox(
                              width: 86,
                              height: 86,
                              child: widget.tecnico.fotoPerfil != null
                                  ? Image.network(
                                      widget.tecnico.fotoPerfil!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            );
                                          },
                                      errorBuilder: (_, __, ___) =>
                                          _avatarIniciales(),
                                    )
                                  : _avatarIniciales(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    widget.tecnico.nombreCompleto,
                    style: GoogleFonts.sora(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < widget.tecnico.calificacionPromedio.round()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: _ambar,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          widget.tecnico.calificacionPromedio.toStringAsFixed(
                            1,
                          ),
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '· ${widget.tecnico.numCalificaciones} reseñas',
                          style: GoogleFonts.dmSans(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
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
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatChip(
          icono: Icons.attach_money_rounded,
          valor: '\$${widget.tecnico.tarifaHora.toStringAsFixed(0)}/hr',
          etiqueta: 'Tarifa',
          color: _acento,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icono: Icons.workspace_premium_outlined,
          valor:
              (widget.tecnico.experienciaYears != null &&
                  widget.tecnico.experienciaYears! > 0)
              ? '${widget.tecnico.experienciaYears} años'
              : '—',
          etiqueta: 'Experiencia',
          color: const Color(0xFF1565C0),
        ),
        const SizedBox(width: 10),
        _StatChip(
          icono: Icons.verified_rounded,
          valor: 'Activo',
          etiqueta: 'Estado',
          color: _verde,
        ),
      ],
    );
  }

  // ── Chips servicios ───────────────────────────────────────────────────────
  Widget _buildChipsServicios() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.tecnico.idServicios!.map((id) {
        final nombre = _nombreServicios[id] ?? 'Servicio';
        final icono = _iconoServicios[id] ?? Icons.build_rounded;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _verde.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _verde.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: _verde, size: 14),
              const SizedBox(width: 6),
              Text(
                nombre,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _verde,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Sección ───────────────────────────────────────────────────────────────
  Widget _buildSeccion({required String titulo, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: _acento,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                titulo,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _verde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ✨ SECCIÓN DE COMENTARIOS (ALIEXPRESS STYLE)
  Widget _buildSeccionComentarios() {
    return _buildSeccion(
      titulo: 'Opiniones de otros clientes',
      child: _cargandoResenas
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: _verde),
              ),
            )
          : _resenas.isEmpty
          ? _buildEmptyReviews()
          : Column(
              children: [
                ..._resenas.map((r) => _ReviewItem(resena: r)).toList(),
                if (_resenas.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: TextButton(
                      onPressed: () {}, // Ver más (opcional)
                      child: Text(
                        'Ver todas las reseñas (${_resenas.length})',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _verdeClaro,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildEmptyReviews() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: _grisTexto.withValues(alpha: 0.3),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no hay opiniones para este técnico.',
              style: GoogleFonts.dmSans(color: _grisTexto, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemInfo({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _fondoCampo,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: _verde, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _grisTexto,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _grisOscuro,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: const Color(0xFFEEF2F0), thickness: 1),
  );

  Widget _buildBoton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () => _crearSolicitud(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _verde,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_turned_in_rounded, size: 20),
              const SizedBox(width: 10),
              Text(
                'Solicitar servicio',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✨ COMPONENTE DE RESEÑA INDIVIDUAL (ESTILO E-COMMERCE PREMIUM)
class _ReviewItem extends StatelessWidget {
  final CalificacionModelo resena;
  const _ReviewItem({required this.resena});

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 365) return 'Hace ${(diff.inDays / 365).floor()} años';
    if (diff.inDays > 30) return 'Hace ${(diff.inDays / 30).floor()} meses';
    if (diff.inDays > 0) return 'Hace ${diff.inDays} días';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} horas';
    return 'Reciente';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar Cliente
            GestureDetector(
              onTap: () {
                if (resena.fotoPerfilCliente != null &&
                    resena.fotoPerfilCliente!.isNotEmpty) {
                  VisorImagenUniversal.abrir(
                    context,
                    resena.fotoPerfilCliente!,
                    'avatar_resena_${resena.idCalificacion}',
                  );
                }
              },
              child: Hero(
                tag: 'avatar_resena_${resena.idCalificacion}',
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: _verde.withValues(alpha: 0.1),
                  backgroundImage: resena.fotoPerfilCliente != null
                      ? NetworkImage(resena.fotoPerfilCliente!)
                      : null,
                  child: resena.fotoPerfilCliente == null
                      ? Text(
                          (resena.nombreCliente?.isNotEmpty ?? false)
                              ? resena.nombreCliente![0].toUpperCase()
                              : '?',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _verde,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resena.nombreCliente ?? 'Cliente Verificado',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: _grisOscuro,
                    ),
                  ),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < resena.puntuacion
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: _ambar,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _timeAgo(resena.fechaCalificacion),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: _grisTexto,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          resena.comentario ?? 'Sin comentario.',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: _grisOscuro.withValues(alpha: 0.85),
            height: 1.5,
          ),
        ),

        // ✨ Galería de fotos (si existen múltiples)
        if (resena.fotosResenaUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: resena.fotosResenaUrls.length,
              itemBuilder: (context, index) {
                final url = resena.fotosResenaUrls[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => VisorImagenUniversal.abrir(
                      context,
                      url,
                      'foto_trabajo_${resena.idCalificacion}_$index',
                    ),
                    child: Hero(
                      tag: 'foto_trabajo_${resena.idCalificacion}_$index',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Divider(
            height: 1,
            color: Colors.grey.withValues(alpha: 0.1),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
class _StatChip extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color color;
  const _StatChip({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(height: 5),
            Text(
              valor,
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _grisOscuro,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: GoogleFonts.dmSans(fontSize: 10, color: _grisTexto),
            ),
          ],
        ),
      ),
    );
  }
}

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
