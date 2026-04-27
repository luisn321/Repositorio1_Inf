import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../servicios_red/servicio_contrataciones.dart';

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

class PantallaPago extends StatefulWidget {
  final int idSolicitud;
  final double monto;
  final String nombreTecnico;
  final String descripcion;
  final String nombreServicio;
  final String fechaCita;
  final VoidCallback onPagoCorrecto;

  const PantallaPago({
    super.key,
    required this.idSolicitud,
    required this.monto,
    required this.nombreTecnico,
    required this.descripcion,
    required this.nombreServicio,
    required this.fechaCita,
    required this.onPagoCorrecto,
  });

  @override
  State<PantallaPago> createState() => _PantallaPagoState();
}

class _PantallaPagoState extends State<PantallaPago>
    with SingleTickerProviderStateMixin {
  final _servicio = ServicioContrataciones();
  bool _procesando = false;
  bool _pagado = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Pago con Stripe ────────────────────────────────────────────────────
  Future<void> _procesarPago() async {
    setState(() => _procesando = true);
    try {
      final intentData = await _servicio.crearPaymentIntent(widget.idSolicitud);
      final clientSecret = intentData['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Servitec',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: _verde),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final ok = await ServicioContrataciones().confirmarPago(
        widget.idSolicitud,
      );
      if (!ok) throw Exception('Error al confirmar pago en el backend');

      setState(() => _pagado = true);
      _snack('Pago retenido exitosamente (Escrow)');

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        widget.onPagoCorrecto();
        Navigator.pop(context);
      }
    } on StripeException catch (e) {
      _snack('Error al procesar: ${e.error.localizedMessage}', error: true);
    } catch (e) {
      _snack('Error: $e', error: true);
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
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
        backgroundColor: error ? _errorColor : _verde,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tarjeta resumen del pago
                    _buildResumenPago(),

                    const SizedBox(height: 16),

                    // Tarjeta detalles del servicio
                    _buildDetallesServicio(),

                    const SizedBox(height: 16),

                    // Tarjeta seguridad Escrow
                    _buildBloqueSeguridad(),

                    const SizedBox(height: 24),

                    // CTA o estado pagado
                    _buildBotonOEstado(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
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
            child: _Circle(size: 140, opacity: 0.07),
          ),
          Positioned(
            top: 40,
            right: 55,
            child: _Circle(size: 55, opacity: 0.09),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  // Monto grande centrado en el header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Total a pagar',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${widget.monto.toStringAsFixed(2)}',
                          style: GoogleFonts.sora(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'MXN',
                          style: GoogleFonts.dmMono(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.55),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Técnico
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.22),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.nombreTecnico,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
          ),
        ],
      ),
    );
  }

  // ── Resumen de pago (desglose) ────────────────────────────────────────
  Widget _buildResumenPago() {
    return _Tarjeta(
      titulo: 'Resumen del pago',
      icono: Icons.receipt_outlined,
      child: Column(
        children: [
          _FilaResumen(label: 'Servicio', valor: widget.nombreServicio),
          const SizedBox(height: 10),
          _FilaResumen(label: 'Fecha de cita', valor: widget.fechaCita),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: _bordeField),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _grisOscuro,
                ),
              ),
              Text(
                '\$${widget.monto.toStringAsFixed(2)} MXN',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _verde,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Detalles del servicio ─────────────────────────────────────────────
  Widget _buildDetallesServicio() {
    return _Tarjeta(
      titulo: 'Descripción del trabajo',
      icono: Icons.description_outlined,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _fondoCampo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _bordeField, width: 1),
        ),
        child: Text(
          widget.descripcion,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: _grisOscuro,
            height: 1.6,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ── Bloque de seguridad Escrow ────────────────────────────────────────
  Widget _buildBloqueSeguridad() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _verde.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _verde.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _verde.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: _verde,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Pago seguro con Escrow',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _verde,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tu dinero se retiene de forma segura mediante Stripe y se libera al técnico solo cuando confirmes que el trabajo finalizó satisfactoriamente.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: _verde.withOpacity(0.8),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
          // Badges de garantía
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _BadgeGarantia(
                icono: Icons.verified_user_outlined,
                texto: 'Pago protegido',
              ),
              _BadgeGarantia(
                icono: Icons.replay_rounded,
                texto: 'Reembolso si aplica',
              ),
              _BadgeGarantia(
                icono: Icons.credit_card_outlined,
                texto: 'Stripe Secure',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Botón pagar o estado pagado ───────────────────────────────────────
  Widget _buildBotonOEstado() {
    if (_pagado) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _acento.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _acento.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _acento.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: _acento,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Pago completado!',
                    style: GoogleFonts.sora(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _verde,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tu solicitud está siendo procesada…',
                    style: GoogleFonts.dmSans(fontSize: 12, color: _grisTexto),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: _acento),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _procesando ? null : _procesarPago,
        style: ElevatedButton.styleFrom(
          backgroundColor: _verde,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _grisTexto,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _procesando
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Procesando pago…',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Pagar \$${widget.monto.toStringAsFixed(2)}',
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
// WIDGETS INTERNOS
// ════════════════════════════════════════════════════════════════════════════

/// Tarjeta blanca con sección header (barra acento + icono + título)
class _Tarjeta extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Widget child;

  const _Tarjeta({
    required this.titulo,
    required this.icono,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(
                titulo,
                style: GoogleFonts.sora(
                  fontSize: 13,
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
}

/// Fila de dos columnas para el resumen
class _FilaResumen extends StatelessWidget {
  final String label;
  final String valor;

  const _FilaResumen({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: _grisTexto,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _grisOscuro,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Badge de garantía pequeño
class _BadgeGarantia extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _BadgeGarantia({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _verde.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _verde.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: _verde, size: 12),
          const SizedBox(width: 5),
          Text(
            texto,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _verde,
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo decorativo del header
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
