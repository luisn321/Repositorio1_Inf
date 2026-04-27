import 'package:flutter/material.dart';

/// Configuración centralizada de iconos y estilos para toda la aplicación
class AppIcons {
  // ============ COLORES GLOBALES ============
  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyMedium = Color(0xFFBDBDBD);
  static const Color greyDark = Color(0xFF757575);

  // ============ ICONOS PARA SERVICIOS ============
  static const Map<String, IconData> serviceIcons = {
    'Electricista': Icons.electrical_services,
    'Plomero': Icons.plumbing,
    'Carpintero': Icons.carpenter,
    'Jardinería': Icons.grass,
    'Línea Blanca': Icons.kitchen,
    'Técnico PC': Icons.computer,
  };

  // ============ ICONOS PARA NAVEGACIÓN ============
  static const Map<String, IconData> navigationIcons = {
    'home': Icons.home_rounded,
    'contratos': Icons.assignment_rounded,
    'perfil': Icons.person_rounded,
    'pagos': Icons.payment_rounded,
    'calificaciones': Icons.star_rounded,
    'buscar': Icons.search_rounded,
    'configuracion': Icons.settings_rounded,
  };

  // ============ ICONOS PARA ACCIONES ============
  static const Map<String, IconData> actionIcons = {
    'agregar': Icons.add_rounded,
    'editar': Icons.edit_rounded,
    'eliminar': Icons.delete_rounded,
    'guardar': Icons.save_rounded,
    'cancelar': Icons.close_rounded,
    'volver': Icons.arrow_back_rounded,
    'aceptar': Icons.check_rounded,
    'rechazar': Icons.close_rounded,
    'llamar': Icons.call_rounded,
    'mensajes': Icons.message_rounded,
    'ubicacion': Icons.location_on_rounded,
    'mapa': Icons.map_rounded,
  };

  // ============ ICONOS PARA ESTADOS ============
  static const Map<String, IconData> statusIcons = {
    'Pendiente': Icons.schedule_rounded,
    'Aceptada': Icons.check_circle_rounded,
    'En Progreso': Icons.hourglass_bottom_rounded,
    'Completada': Icons.task_alt_rounded,
    'Cancelada': Icons.cancel_rounded,
  };

  // ============ MÉTODOS HELPER ============

  /// Obtiene el icono para un servicio
  static IconData getServiceIcon(String serviceName) {
    return serviceIcons[serviceName] ?? Icons.build_rounded;
  }

  /// Obtiene la ruta de imagen PNG para un servicio
  static String getServiceImagePath(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'electricista':
        return 'Iconos/Electricista1.png';
      case 'plomero':
        return 'Iconos/Plomero1.png';
      case 'carpintero':
        return 'Iconos/Carpintero1.png';
      case 'jardinería':
      case 'jardinero':
        return 'Iconos/Jardin1.png';
      case 'Reparación línea blanca':
      case 'Reparacion linea blanca':
        return 'Iconos/LineaBlanca1.png';
      case 'técnico pc':
      case 'tecnico pc':
        return 'Iconos/TecnicoPC.png';
      default:
        return 'Iconos/Tecnico.png';
    }
  }

  /// Obtiene el color para un estado
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.amber;
      case 'aceptada':
        return Colors.blue;
      case 'en progreso':
        return Colors.orange;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return greyMedium;
    }
  }

  /// Obtiene el icono para un estado
  static IconData getStatusIcon(String status) {
    return statusIcons[status] ?? Icons.help_rounded;
  }

  // ============ ESTILOS GLOBALES ============
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkGreen,
    letterSpacing: 0.5,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkGreen,
    letterSpacing: 0.3,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: greyDark,
    letterSpacing: 0.2,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: greyMedium,
    letterSpacing: 0.1,
  );

  // ============ DECORACIONES ============
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration get accentCardDecoration {
    return BoxDecoration(
      color: lightGreen,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: midGreen.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ============ ESTILOS DE BOTONES ============
  static ButtonStyle get primaryButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: midGreen,
      foregroundColor: white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
    );
  }

  static ButtonStyle get outlineButtonStyle {
    return OutlinedButton.styleFrom(
      side: const BorderSide(color: midGreen, width: 2),
      foregroundColor: darkGreen,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // ============ INPUT DECORATIONS ============
  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: greyLight,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: midGreen, size: 22)
          : null,
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: greyMedium, size: 22)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: midGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(
        color: greyMedium,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
