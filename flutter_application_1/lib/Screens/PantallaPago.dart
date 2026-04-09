import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../servicios_red/servicio_contrataciones.dart';

// ── Tokens de diseño ─────────────────────────────────────────────────────────
const Color _verde = Color(0xFF1A5C38);
const Color _verdeClaro = Color(0xFF4CAF82);
const Color _naranja = Color(0xFFFF9800);
const Color _rojo = Color(0xFFCC3333);

class PantallaPago extends StatefulWidget {
  final int idSolicitud;
  final double monto;
  final String nombreTecnico;
  final VoidCallback onPagoCorrecto;

  const PantallaPago({
    super.key,
    required this.idSolicitud,
    required this.monto,
    required this.nombreTecnico,
    required this.onPagoCorrecto,
  });

  @override
  State<PantallaPago> createState() => _PantallaPagoState();
}

class _PantallaPagoState extends State<PantallaPago> {
  final _servicio = ServicioContrataciones();
  bool _procesando = false;
  bool _pagado = false;
  String? _numeroTarjeta;
  String? _nombreTarjeta;
  String? _mesExpiracion;
  String? _anioExpiracion;
  String? _cvv;

  Future<void> _procesarPago() async {
    // Validar campos
    if (_numeroTarjeta == null || _numeroTarjeta!.isEmpty ||
        _nombreTarjeta == null || _nombreTarjeta!.isEmpty ||
        _mesExpiracion == null || _anioExpiracion == null ||
        _cvv == null || _cvv!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // ✨ NUEVO: Ventana de confirmación de pago
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Confirmar Pago?', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estás por pagar el servicio de:', style: GoogleFonts.dmSans(fontSize: 14)),
            const SizedBox(height: 8),
            Text(widget.nombreTecnico, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: _verde)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
                Text('\$${widget.monto.toStringAsFixed(2)}', 
                  style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: _naranja)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.dmSans(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: _verde),
            child: const Text('Confirmar y Pagar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _procesando = true);
    try {
      // Llamar servicio para registrar el pago
      await _servicio.registrarPago(
        widget.idSolicitud,
        widget.monto,
        _numeroTarjeta!,
      );

      setState(() => _pagado = true);

      // Mostrar confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pago procesado exitosamente'),
            backgroundColor: _verde,
          ),
        );
      }

      // Esperar 2 segundos y cerrar
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        widget.onPagoCorrecto(); // ✨ Llamar callback ANTES de cerrar
        Navigator.pop(context);  // Cerrar esta pantalla (PantallaPago)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: _rojo,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _verde,
        title: Text('Pago de Servicio', style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── RESUMEN DE PAGO ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: _verde,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de Pago',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Técnico:',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        widget.nombreTecnico,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monto a Pagar:',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '\$${widget.monto.toStringAsFixed(2)}',
                        style: GoogleFonts.sora(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── DATOS DE TARJETA ───────────────────────────────────
                  Text(
                    'Datos de la Tarjeta',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Número de tarjeta
                  TextField(
                    enabled: !_pagado && !_procesando,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    onChanged: (val) => _numeroTarjeta = val,
                    decoration: InputDecoration(
                      hintText: '1234 5678 9012 3456',
                      labelText: 'Número de Tarjeta',
                      prefixIcon: const Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nombre en tarjeta
                  TextField(
                    enabled: !_pagado && !_procesando,
                    onChanged: (val) => _nombreTarjeta = val,
                    decoration: InputDecoration(
                      hintText: 'Nombre del Titular',
                      labelText: 'Nombre en la Tarjeta',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expiración y CVV
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: !_pagado && !_procesando,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          onChanged: (val) => _mesExpiracion = val,
                          decoration: InputDecoration(
                            hintText: 'MM',
                            labelText: 'Mes',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          enabled: !_pagado && !_procesando,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          onChanged: (val) => _anioExpiracion = val,
                          decoration: InputDecoration(
                            hintText: 'YYYY',
                            labelText: 'Año',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          enabled: !_pagado && !_procesando,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          onChanged: (val) => _cvv = val,
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            labelText: 'CVV',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            counterText: '',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── BOTÓN PAGAR ────────────────────────────────────────
                  if (!_pagado)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _procesando ? null : _procesarPago,
                        icon: _procesando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.payment),
                        label: Text(
                          _procesando ? 'Procesando...' : 'Pagar \$${widget.monto.toStringAsFixed(2)}',
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
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _verde.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _verde.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: _verde, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pago Completado',
                                  style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _verde,
                                  ),
                                ),
                                Text(
                                  'Tu solicitud se está procesando...',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
