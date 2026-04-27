import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../servicios_red/servicio_contrataciones.dart';
import '../servicios_red/servicio_imagenes.dart';
import 'dart:io';
import '../utilidades/visor_imagenes_universal.dart';

// ── Design tokens (sistema unificado Servitec) ───────────────────────────────
const Color _verde = Color(0xFF1A5C38);
const Color _verdeClaro = Color(0xFF247A4A);
const Color _verdeOscuro = Color(0xFF0F3B22);
const Color _acento = Color(0xFF4CAF82);
const Color _fondoPage = Color(0xFFF2F6F4);
const Color _fondoCampo = Color(0xFFF4F7F5);
const Color _bordeField = Color(0xFFDDE8E3);
const Color _grisTexto = Color(0xFF8FA89B);
const Color _grisOscuro = Color(0xFF3D4F46);
const Color _errorColor = Color(0xFFE05252);
const Color _ambar = Color(0xFFF5A623);
// ─────────────────────────────────────────────────────────────────────────────

// Textos y colores por puntuación
const _textosPuntuacion = [
  '',
  'Muy insatisfecho',
  'Insatisfecho',
  'Neutral',
  'Satisfecho',
  'Muy satisfecho',
];
const _coloresPuntuacion = [
  _ambar, // placeholder
  Color(0xFFE05252), // 1 – rojo
  Color(0xFFE07D30), // 2 – naranja
  Color(0xFFF5A623), // 3 – ámbar
  Color(0xFF4CAF82), // 4 – acento
  Color(0xFF1A5C38), // 5 – verde
];

class PantallaCalificaciones extends StatefulWidget {
  final int idContratacion;
  final int idTecnico;
  final String nombreTecnico;
  final String? fotoTecnico;
  final VoidCallback onCalificacionEnviada;

  const PantallaCalificaciones({
    super.key,
    required this.idContratacion,
    required this.idTecnico,
    required this.nombreTecnico,
    this.fotoTecnico,
    required this.onCalificacionEnviada,
  });

  @override
  State<PantallaCalificaciones> createState() => _PantallaCalificacionesState();
}

class _PantallaCalificacionesState extends State<PantallaCalificaciones>
    with SingleTickerProviderStateMixin {
  final _servicio = ServicioContrataciones();
  final _servicioImagenes = ServicioImagenes();
  final _formKey = GlobalKey<FormState>();
  final _ctrlComentario = TextEditingController();

  int _puntuacion = 0;
  bool _enviando = false;
  bool _subiendoFoto = false;
  List<String> _urlsFotos = [];
  List<File> _fotosLocales = [];

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // Iniciales del técnico
  String get _iniciales {
    final p = widget.nombreTecnico.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return p[0].isNotEmpty ? p[0][0].toUpperCase() : '?';
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _ctrlComentario.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Lógica fotos ──────────────────────────────────────────────────────────
  Future<void> _seleccionarFoto() async {
    if (_fotosLocales.length >= 3) {
      _snack('Máximo 3 fotos por reseña', warn: true);
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetFuenteFoto(),
    );
    if (source == null) return;

    try {
      final file = await _servicioImagenes.seleccionarImagen(source);
      if (file == null) return;

      setState(() {
        _fotosLocales.add(file);
        _subiendoFoto = true;
      });

      final url = await _servicioImagenes.subirImagen(file, folder: 'resenas');

      if (url != null) {
        setState(() {
          _urlsFotos.add(url);
          _subiendoFoto = false;
        });
      } else {
        setState(() {
          _fotosLocales.removeLast();
          _subiendoFoto = false;
        });
        _snack('Error al subir la imagen', error: true);
      }
    } catch (e) {
      debugPrint('Error seleccionando foto: $e');
      setState(() => _subiendoFoto = false);
    }
  }

  void _eliminarFoto(int index) {
    if (_subiendoFoto) return;
    setState(() {
      _fotosLocales.removeAt(index);
      if (index < _urlsFotos.length) _urlsFotos.removeAt(index);
    });
  }

  // ── Envío ─────────────────────────────────────────────────────────────────
  Future<void> _enviarCalificacion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_puntuacion == 0) {
      _snack('Selecciona una puntuación para continuar', warn: true);
      return;
    }

    setState(() => _enviando = true);
    try {
      await _servicio.calificarTecnico(
        widget.idContratacion,
        widget.idTecnico,
        _puntuacion,
        _ctrlComentario.text.trim(),
        _urlsFotos.isNotEmpty ? _urlsFotos.join(',') : null,
      );

      if (mounted) {
        _snack('¡Gracias por tu calificación!');
        await Future.delayed(const Duration(milliseconds: 1800));
        if (mounted) {
          widget.onCalificacionEnviada();
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) _snack('Error al enviar: $e', error: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _snack(String msg, {bool error = false, bool warn = false}) {
    final bg = error
        ? _errorColor
        : warn
        ? const Color(0xFFD4A017)
        : _verde;
    final icono = error
        ? Icons.error_outline_rounded
        : warn
        ? Icons.warning_amber_rounded
        : Icons.check_circle_outline;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icono, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondoPage,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // TARJETA: Puntuación con estrellas
                      _buildCard(
                        titulo: 'Tu puntuación',
                        icono: Icons.star_outline_rounded,
                        child: _buildEstrellas(),
                      ),

                      const SizedBox(height: 16),

                      // TARJETA: Fotos
                      _buildCard(
                        titulo: 'Fotos del trabajo (opcional)',
                        icono: Icons.photo_camera_outlined,
                        subtitulo: 'Máximo 3 imágenes',
                        child: _buildGridFotos(),
                      ),

                      const SizedBox(height: 16),

                      // TARJETA: Comentario
                      _buildCard(
                        titulo: 'Comentario (opcional)',
                        icono: Icons.chat_bubble_outline_rounded,
                        child: _buildCampoComentario(),
                      ),

                      const SizedBox(height: 24),

                      _buildBotonEnviar(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
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
          Positioned(
            top: -30,
            right: -20,
            child: _Circle(size: 150, opacity: 0.07),
          ),
          Positioned(
            top: 50,
            right: 55,
            child: _Circle(size: 58, opacity: 0.09),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              child: Column(
                children: [
                  // Barra superior
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
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
                          color: _acento.withOpacity(0.18),
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
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Avatar iniciales + nombre
                  GestureDetector(
                    onTap: () {
                      if (widget.fotoTecnico != null && widget.fotoTecnico!.isNotEmpty) {
                        VisorImagenUniversal.abrir(
                          context,
                          widget.fotoTecnico!,
                          'avatar_calificacion_${widget.idTecnico}',
                        );
                      }
                    },
                    child: Hero(
                      tag: 'avatar_calificacion_${widget.idTecnico}',
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                            width: 2.5,
                          ),
                          image: (widget.fotoTecnico != null && widget.fotoTecnico!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(widget.fotoTecnico!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (widget.fotoTecnico == null || widget.fotoTecnico!.isEmpty)
                            ? Center(
                                child: Text(
                                  _iniciales,
                                  style: GoogleFonts.sora(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.nombreTecnico,
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Cuéntanos cómo fue tu experiencia',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
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

  // ── Tarjeta contenedora ───────────────────────────────────────────────────
  Widget _buildCard({
    required String titulo,
    required IconData icono,
    String? subtitulo,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icono, color: _verde, size: 16),
              const SizedBox(width: 7),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        titulo,
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _verde,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (subtitulo != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '· $subtitulo',
                          style: GoogleFonts.dmSans(fontSize: 11, color: _grisTexto),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  // ── Estrellas interactivas ────────────────────────────────────────────────
  Widget _buildEstrellas() {
    final tieneSeleccion = _puntuacion > 0;
    final colorActual = tieneSeleccion
        ? _coloresPuntuacion[_puntuacion]
        : _grisTexto;

    return Column(
      children: [
        // Fila de estrellas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final val = i + 1;
            final activa = _puntuacion >= val;
            return GestureDetector(
              onTap: () => setState(() => _puntuacion = val),
              child: AnimatedScale(
                scale: activa ? 1.25 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(
                  activa ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 48,
                  color: activa ? _ambar : const Color(0xFFDDE8E3),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 14),

        // Etiqueta animada
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: tieneSeleccion
              ? Container(
                  key: ValueKey(_puntuacion),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: colorActual.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorActual.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: colorActual,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _textosPuntuacion[_puntuacion],
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorActual,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  'Toca una estrella para calificar',
                  key: const ValueKey(0),
                  style: GoogleFonts.dmSans(fontSize: 13, color: _grisTexto),
                ),
        ),
      ],
    );
  }

  // ── Grid de fotos ─────────────────────────────────────────────────────────
  Widget _buildGridFotos() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        // Fotos existentes
        ...List.generate(_fotosLocales.length, (i) {
          final subida = i < _urlsFotos.length;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Miniatura
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: subida ? _acento : _ambar,
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: FileImage(_fotosLocales[i]),
                    fit: BoxFit.cover,
                  ),
                ),
                child: !subida
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: Colors.black38,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : null,
              ),

              // Botón eliminar
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: () => _eliminarFoto(i),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _errorColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _errorColor.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),

              // Badge ✓ subida completa
              if (subida)
                Positioned(
                  bottom: -6,
                  right: -6,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _acento,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                ),
            ],
          );
        }),

        // Botón agregar foto
        if (_fotosLocales.length < 3)
          GestureDetector(
            onTap: (_enviando || _subiendoFoto) ? null : _seleccionarFoto,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: _fondoCampo,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _bordeField,
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: _subiendoFoto ? _grisTexto : _verde,
                    size: 24,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_fotosLocales.length}/3',
                    style: GoogleFonts.dmMono(fontSize: 10, color: _grisTexto),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Campo comentario ──────────────────────────────────────────────────────
  Widget _buildCampoComentario() {
    return TextFormField(
      controller: _ctrlComentario,
      enabled: !_enviando,
      maxLines: 5,
      maxLength: 500,
      style: GoogleFonts.dmSans(fontSize: 14, color: _grisOscuro),
      decoration: InputDecoration(
        hintText: 'Comparte tu experiencia con este técnico…',
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: _grisTexto),
        filled: true,
        fillColor: _fondoCampo,
        contentPadding: const EdgeInsets.all(16),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _bordeField, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _bordeField, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _verde, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: _bordeField.withOpacity(0.5),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ── Botón enviar ──────────────────────────────────────────────────────────
  Widget _buildBotonEnviar() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: (_enviando || _subiendoFoto) ? null : _enviarCalificacion,
        style: ElevatedButton.styleFrom(
          backgroundColor: _verde,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _grisTexto,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _enviando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Enviar calificación',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET: FUENTE DE FOTO
// ════════════════════════════════════════════════════════════════════════════
class _SheetFuenteFoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _bordeField,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Text(
              'Agregar foto',
              style: GoogleFonts.sora(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _verde,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '¿Desde dónde quieres subir la imagen?',
              style: GoogleFonts.dmSans(fontSize: 12, color: _grisTexto),
            ),

            const SizedBox(height: 16),

            _OpcionSheet(
              icono: Icons.photo_library_outlined,
              titulo: 'Galería',
              subtitulo: 'Selecciona desde tus fotos',
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),

            Divider(height: 1, color: _bordeField, indent: 20, endIndent: 20),

            _OpcionSheet(
              icono: Icons.camera_alt_outlined,
              titulo: 'Cámara',
              subtitulo: 'Toma una foto ahora',
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OpcionSheet extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _OpcionSheet({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _verde.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icono, color: _verde, size: 22),
      ),
      title: Text(
        titulo,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _grisOscuro,
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: GoogleFonts.dmSans(fontSize: 12, color: _grisTexto),
      ),
      onTap: onTap,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// WIDGET AUXILIAR
// ════════════════════════════════════════════════════════════════════════════
class _Circle extends StatelessWidget {
  final double size, opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(opacity),
          width: 1.5,
        ),
      ),
    );
  }
}
