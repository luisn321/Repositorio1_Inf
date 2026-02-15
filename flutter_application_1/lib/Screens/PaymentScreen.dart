import 'package:flutter/material.dart';
import '../services/api.dart';

class PaymentScreen extends StatefulWidget {
  final int idContratacion;
  final String serviceName;
  final String clientName;
  final double monto;

  const PaymentScreen({
    super.key,
    required this.idContratacion,
    required this.serviceName,
    required this.clientName,
    required this.monto,
  });

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _cardNumberController =
      TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _holderController = TextEditingController();

  bool _isProcessing = false;
  String _selectedMethod = 'tarjeta';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    // Validaciones básicas
    if (_selectedMethod == 'tarjeta') {
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty ||
          _holderController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor completa todos los campos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_cardNumberController.text.length < 13 ||
          _cardNumberController.text.length > 19) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Número de tarjeta inválido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isProcessing = true);

    try {
      final apiService = ApiService();

      // Crear registro de pago
      await apiService.createPayment(
        idContratacion: widget.idContratacion,
        monto: widget.monto,
        metodoPago: _selectedMethod,
        transactionRef:
            'TRX_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Actualizar estado de contractación a "En Progreso"
      await apiService.updateContractationStatus(
        widget.idContratacion,
        'En Progreso',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pago procesado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaymentScreen.white,
      appBar: AppBar(
        backgroundColor: PaymentScreen.darkGreen,
        title: const Text(
          'Pago de Servicio',
          style: TextStyle(color: PaymentScreen.white),
        ),
        iconTheme:
            const IconThemeData(color: PaymentScreen.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Resumen del servicio
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: PaymentScreen.lightGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de Pago',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PaymentScreen.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _summaryRow('Servicio:', widget.serviceName),
                  _summaryRow('Cliente:', widget.clientName),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monto Total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: PaymentScreen.darkGreen,
                        ),
                      ),
                      Text(
                        '\$${widget.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: PaymentScreen.midGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Método de pago
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Método de Pago',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PaymentScreen.darkGreen,
                  ),
                ),
                const SizedBox(height: 12),

                // Tarjeta de crédito
                _paymentMethodCard(
                  'tarjeta',
                  Icons.credit_card,
                  'Tarjeta de Crédito/Débito',
                ),
                const SizedBox(height: 8),

                // Billetera digital
                _paymentMethodCard(
                  'billetera',
                  Icons.wallet,
                  'Billetera Digital',
                ),
                const SizedBox(height: 8),

                // Transferencia
                _paymentMethodCard(
                  'transferencia',
                  Icons.account_balance,
                  'Transferencia Bancaria',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Campos de tarjeta (mostrar solo si está seleccionada)
            if (_selectedMethod == 'tarjeta') ...[
              Text(
                'Detalles de la Tarjeta',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: PaymentScreen.darkGreen,
                ),
              ),
              const SizedBox(height: 12),

              // Número de tarjeta
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Número de Tarjeta',
                  hintText: '0000 0000 0000 0000',
                  filled: true,
                  fillColor: PaymentScreen.lightGreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nombre del titular
              TextField(
                controller: _holderController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Titular',
                  filled: true,
                  fillColor: PaymentScreen.lightGreen,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Fecha de vencimiento y CVV
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'MM/AA',
                        filled: true,
                        fillColor: PaymentScreen.lightGreen,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        filled: true,
                        fillColor: PaymentScreen.lightGreen,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ] else if (_selectedMethod == 'billetera') ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PaymentScreen.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Serás redirigido a tu billetera digital para completar el pago.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else if (_selectedMethod == 'transferencia') ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PaymentScreen.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Realiza una transferencia a:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Banco: Banco Central'),
                    Text('Cuenta: 1234567890'),
                    Text('Titular: Servitec'),
                    Text('Concepto: Pago de servicio'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Botón pagar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PaymentScreen.midGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            PaymentScreen.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Procesar Pago',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: PaymentScreen.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Botón cancelar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(
                    color: PaymentScreen.midGreen,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PaymentScreen.darkGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: PaymentScreen.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentMethodCard(
    String value,
    IconData icon,
    String label,
  ) {
    final isSelected = _selectedMethod == value;
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMethod = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? PaymentScreen.darkGreen
                  : Colors.grey[300]!,
              width: isSelected ? 2.5 : 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? PaymentScreen.lightGreen : PaymentScreen.white,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: PaymentScreen.darkGreen.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Radio button mejorado
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? PaymentScreen.darkGreen
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  color: isSelected 
                      ? PaymentScreen.darkGreen.withOpacity(0.1) 
                      : PaymentScreen.white,
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: PaymentScreen.darkGreen,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 14),
              // Icon mejorado
              Icon(
                icon,
                color: isSelected 
                    ? PaymentScreen.darkGreen 
                    : PaymentScreen.midGreen,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: PaymentScreen.darkGreen,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: PaymentScreen.darkGreen,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
