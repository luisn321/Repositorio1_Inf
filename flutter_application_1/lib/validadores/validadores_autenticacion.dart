/// Clase con validadores para formularios de autenticación
class ValidadoresAutenticacion {
  /// Valida que el correo tenga formato correcto
  static String? validarCorreo(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El correo es obligatorio';
    }
    
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(valor)) {
      return 'Ingresa un correo válido';
    }
    
    return null; // Válido
  }

  /// Valida que la contraseña cumpla requisitos mínimos
  static String? validarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    
    if (valor.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    
    if (!valor.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }
    
    if (!valor.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    
    return null; // Válido
  }

  /// Valida que la contraseña sea fuerte (con confirmación)
  static String? validarConfirmacionContrasena(String? valor, String? contrasenaPrincipal) {
    if (valor == null || valor.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (valor != contrasenaPrincipal) {
      return 'Las contraseñas no coinciden';
    }
    
    return null; // Válido
  }

  /// Valida campos de texto requeridos
  static String? validarCampoRequerido(String? valor, String nombreCampo) {
    if (valor == null || valor.trim().isEmpty) {
      return '$nombreCampo es obligatorio';
    }
    return null; // Válido
  }

  /// Valida teléfono (mínimo 10 dígitos)
  static String? validarTelefono(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El teléfono es obligatorio';
    }
    
    final soloDigitos = valor.replaceAll(RegExp(r'\D'), '');
    if (soloDigitos.length < 10) {
      return 'Teléfono inválido (mínimo 10 dígitos)';
    }
    
    return null; // Válido
  }

  /// Valida que el nombre tenga al menos 3 caracteres
  static String? validarNombre(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El nombre es obligatorio';
    }
    
    if (valor.trim().length < 3) {
      return 'El nombre debe tener mínimo 3 caracteres';
    }
    
    return null; // Válido
  }

  /// Valida tarifa horaria (debe ser número positivo)
  static String? validarTarifaHoraria(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La tarifa es obligatoria';
    }
    
    final tarifa = double.tryParse(valor);
    if (tarifa == null || tarifa <= 0) {
      return 'Ingresa una tarifa válida (número positivo)';
    }
    
    return null; // Válido
  }
}
