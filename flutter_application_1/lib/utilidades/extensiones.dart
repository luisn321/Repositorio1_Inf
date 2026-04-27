/// Extensiones útiles para tipos nativos de Dart
extension ExtensionesString on String {
  /// Capitaliza la primer letra de la cadena
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Valida que sea un email válido
  bool esEmailValido() {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(this);
  }

  /// Valida que solo contenga números
  bool esSoloNumeros() {
    return RegExp(r'^\d+$').hasMatch(this);
  }

  /// Remueve todos los espacios en blanco
  String sinEspacios() => replaceAll(RegExp(r'\s+'), '');

  /// Formatea como teléfono: +34 600 123 456
  String formatearTelefono() {
    final limpio = sinEspacios();
    if (limpio.length < 9) return this;
    return limpio.replaceAllMapped(
      RegExp(r'(\d{1,3})(\d{3})(\d{3})(\d{2})'),
      (match) => '${match.group(1)} ${match.group(2)} ${match.group(3)} ${match.group(4)}',
    );
  }

  /// Acorta la cadena con puntos suspensivos
  String acortar(int longitud) {
    if (length <= longitud) return this;
    return '${substring(0, longitud)}...';
  }
}

extension ExtensionesDouble on double {
  /// Formatea como dinero: $1,234.56
  String formatearDinero({String simbolo = '\$', int decimales = 2}) {
    final formateado = toStringAsFixed(decimales);
    final partes = formateado.split('.');
    final enteros = partes[0];
    final decimal = partes.length > 1 ? partes[1] : '00';

    // Agregar separadores de miles
    final buffer = StringBuffer();
    for (int i = 0; i < enteros.length; i++) {
      if (i > 0 && (enteros.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(enteros[i]);
    }

    return '$simbolo${buffer.toString()}.$decimal';
  }

  /// Redondea a N decimales
  double redondear(int decimales) {
    final factor = 10.0 * decimales;
    return (this * factor).round() / factor;
  }

  /// Convierte a kiloómetros (desde metros)
  double metrosAKilometros() => this / 1000.0;

  /// Convierte a metros (desde kiloómetros)
  double kilometrosAMetros() => this * 1000.0;
}

extension ExtensionesInt on int {
  /// Formatea como dinero
  String formatearDinero({String simbolo = '\$'}) {
    return toDouble().formatearDinero(simbolo: simbolo, decimales: 0);
  }

  /// Verifica si es positivo
  bool esPositivo() => this > 0;

  /// Verifica si es negativo
  bool esNegativo() => this < 0;

  /// Verifica si es cero
  bool esCero() => this == 0;
}

extension ExtensionesDateTime on DateTime {
  /// Formatea como fecha legible: "14 de febrero de 2026"
  String formatearFecha() {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '$day de ${meses[month - 1]} de $year';
  }

  /// Formatea como hora legible: "14:30"
  String formatearHora() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Formatea como fecha y hora: "14/02/2026 14:30"
  String formatearFechaHora() {
    final fecha = '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
    final hora = formatearHora();
    return '$fecha $hora';
  }

  /// Calcula los días que faltan hasta esta fecha
  int diasHasta() {
    final ahora = DateTime.now();
    final diferencia = difference(ahora);
    return diferencia.inDays;
  }

  /// Verifica si la fecha es hoy
  bool esHoy() {
    final ahora = DateTime.now();
    return year == ahora.year && month == ahora.month && day == ahora.day;
  }

  /// Verifica si la fecha fue ayer
  bool fueAyer() {
    final ayer = DateTime.now().subtract(const Duration(days: 1));
    return year == ayer.year && month == ayer.month && day == ayer.day;
  }

  /// Verifica si la fecha es mañana
  bool esManana() {
    final manana = DateTime.now().add(const Duration(days: 1));
    return year == manana.year && month == manana.month && day == manana.day;
  }
}

extension ExtensionesLista<T> on List<T> {
  /// Verifica si la lista no está vacía
  bool noEstaVacia() => isNotEmpty;

  /// Obtiene un elemento de forma segura
  T? obtenerONull(int indice) {
    try {
      return this[indice];
    } catch (e) {
      return null;
    }
  }
}
