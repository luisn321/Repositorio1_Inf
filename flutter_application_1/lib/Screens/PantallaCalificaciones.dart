import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../servicios_red/servicio_contrataciones.dart';
import '../servicios_red/servicio_imagenes.dart';
import 'dart:io';

const Color _verde = Color(0xFF1A5C38);
const Color _verdeClaro = Color(0xFF4CAF82);
const Color _naranja = Color(0xFFFF9800);
const Color _rojo = Color(0xFFCC3333);

class PantallaCalificaciones extends StatefulWidget {
  final int idContratacion;
  final int idTecnico;
  final String nombreTecnico;
  final VoidCallback onCalificacionEnviada;

  const PantallaCalificaciones({
    super.key,
    required this.idContratacion,
    required this.idTecnico,
    required this.nombreTecnico,
    required this.onCalificacionEnviada,
  });

  @override
  State<PantallaCalificaciones> createState() => _PantallaCalificacionesState();
}

class _PantallaCalificacionesState extends State<PantallaCalificaciones> {
  final _servicio = ServicioContrataciones();
  final _servicioImagenes = ServicioImagenes(); // ✨
  final _formKey = GlobalKey<FormState>();
  final _controladorComentario = TextEditingController();

  int _puntuacionSeleccionada = 0;
  bool _enviando = false;
  List<String> _fotosResenaUrls = []; // ✨ Multiples fotos
  List<File> _fotosLocales = []; // ✨ Multiples fotos

  Future<void> _enviarCalificacion() async {
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
      await _servicio.calificarTecnico(
        widget.idContratacion,
        widget.idTecnico,
        _puntuacionSeleccionada,
        _controladorComentario.text.trim(),
        _fotosResenaUrls.isNotEmpty ? _fotosResenaUrls.join(',') : null, // ✨
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Gracias por tu calificación'),
            backgroundColor: _verde,
          ),
        );

        // Esperar 2 segundos y cerrar
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          widget.onCalificacionEnviada(); // ✨ Callback ANTES de cerrar
          Navigator.pop(
            context,
          ); // ✨ Cerrar esta pantalla (PantallaCalificaciones)
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _rojo),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _controladorComentario.dispose();
    super.dispose();
  }

  // ── Lógica de Fotos ──────────────────────────────────────────────────────
  Future<void> _seleccionarFoto() async {
    if (_fotosLocales.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puedes subir hasta 3 fotos máximo.')),
      );
      return;
    }
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: _verde),
                title: const Text('Galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: _verde),
                title: const Text('Cámara'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final file = await _servicioImagenes.seleccionarImagen(source);
      if (file == null) return;

      setState(() {
        _fotosLocales.add(file);
        _enviando = true;
      });

      // Subir de una vez
      final url = await _servicioImagenes.subirImagen(file, folder: 'resenas');

      if (url != null) {
        setState(() {
          _fotosResenaUrls.add(url);
          _enviando = false;
        });
      } else {
        setState(() {
          _fotosLocales.removeLast();
          _enviando = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir imagen'))
          );
        }
      }
    } catch (e) {
      debugPrint('Error selecionando foto: $e');
      setState(() => _enviando = false);
    }
  }

  void _eliminarFoto(int index) {
      if (_enviando) return;
      setState(() {
          _fotosLocales.removeAt(index);
          if (index < _fotosResenaUrls.length) {
              _fotosResenaUrls.removeAt(index);
          }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _verde,
        title: Text(
          'Calificar Técnico',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── HEADER TÉCNICO ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: _verde,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.nombreTecnico,
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cuéntanos tu experiencia',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── PUNTUACIÓN ──────────────────────────────────────
                    Text(
                      'Puntuación',
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          final estrella = index + 1;
                          final seleccionada =
                              _puntuacionSeleccionada >= estrella;

                          return GestureDetector(
                            onTap: () => setState(
                              () => _puntuacionSeleccionada = estrella,
                            ),
                            child: AnimatedScale(
                              scale: seleccionada ? 1.3 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.star_rounded,
                                size: 50,
                                color: seleccionada
                                    ? _naranja
                                    : Colors.grey[300],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    if (_puntuacionSeleccionada > 0) ...[
                      Center(
                        child: Text(
                          _obtenerTextoCalificacion(_puntuacionSeleccionada),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: _naranja,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── FOTOS DEL TRABAJO (NUEVO) ───────────────────────
                    Text(
                      'Fotos del Trabajo Realizado (Opcional - Max 3)',
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ...List.generate(_fotosLocales.length, (index) {
                          bool subidaCompleta = index < _fotosResenaUrls.length;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: subidaCompleta ? _verde : Colors.orange, width: 2),
                                  image: DecorationImage(
                                    image: FileImage(_fotosLocales[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (!subidaCompleta)
                                const Positioned.fill(
                                  child: Center(
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  ),
                                ),
                              Positioned(
                                top: -8,
                                right: -8,
                                child: GestureDetector(
                                  onTap: () => _eliminarFoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: _rojo,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                        if (_fotosLocales.length < 3)
                          GestureDetector(
                            onTap: _enviando ? null : _seleccionarFoto,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              child: const Icon(
                                Icons.add_a_photo_rounded,
                                color: _verde,
                                size: 30,
                              )
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── COMENTARIO ──────────────────────────────────────
                    Text(
                      'Comentario (Opcional)',
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _controladorComentario,
                      enabled: !_enviando,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Comparte tu experiencia con este técnico...',
                        hintStyle: GoogleFonts.dmSans(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        counterText: '',
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── BOTÓN ENVIAR ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _enviando ? null : _enviarCalificacion,
                        icon: _enviando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          _enviando ? 'Enviando...' : 'Enviar Calificación',
                          style: GoogleFonts.sora(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _verde,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _obtenerTextoCalificacion(int puntuacion) {
    switch (puntuacion) {
      case 1:
        return 'Muy insatisfecho';
      case 2:
        return 'Insatisfecho';
      case 3:
        return 'Neutral';
      case 4:
        return 'Satisfecho';
      case 5:
        return 'Muy satisfecho';
      default:
        return '';
    }
  }
}
