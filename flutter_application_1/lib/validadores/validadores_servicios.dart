/// Clase con validadores para formularios de servicios, contratos y pagos
class ValidadoresServicios {
  /// Valida que la descripción de un servicio sea válida
  static String? validarDescripcion(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La descripción es obligatoria';
    }
    
    if (valor.trim().length < 10) {
      return 'La descripción debe tener mínimo 10 caracteres';
    }
    
    if (valor.trim().length > 500) {
      return 'La descripción no debe exceder 500 caracteres';
    }
    
    return null; // Válido
  }

  /// Valida que la tarifa horaria sea válida
  static String? validarTarifaHoraria(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La tarifa es obligatoria';
    }
    
    final tarifa = double.tryParse(valor);
    if (tarifa == null) {
      return 'Ingresa un número válido';
    }
    
    if (tarifa <= 0) {
      return 'La tarifa debe ser mayor a 0';
    }
    
    if (tarifa > 10000) {
      return 'La tarifa no puede exceder 10,000';
    }
    
    return null; // Válido
  }

  /// Valida que el monto sea válido
  static String? validarMonto(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El monto es obligatorio';
    }
    
    final monto = double.tryParse(valor);
    if (monto == null) {
      return 'Ingresa un número válido';
    }
    
    if (monto <= 0) {
      return 'El monto debe ser mayor a 0';
    }
    
    if (monto > 100000) {
      return 'El monto no puede exceder 100,000';
    }
    
    return null; // Válido
  }

  /// Valida que la fecha sea válida y en el futuro
  static String? validarFechaFutura(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La fecha es obligatoria';
    }
    
    DateTime? fecha;
    
    // Intenta parsear formato DD/MM/YYYY
    if (valor.contains('/')) {
      final partes = valor.split('/');
      if (partes.length == 3) {
        try {
          final dia = int.parse(partes[0]);
          final mes = int.parse(partes[1]);
          final anio = int.parse(partes[2]);
          fecha = DateTime(anio, mes, dia);
        } catch (e) {
          return 'Fecha inválida';
        }
      }
    } else {
      // Intenta parsear formato ISO (YYYY-MM-DD)
      fecha = DateTime.tryParse(valor);
    }
    
    if (fecha == null) {
      return 'Fecha inválida';
    }
    
    // Comparar solo la fecha (sin hora)
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaSolo = DateTime(fecha.year, fecha.month, fecha.day);
    
    if (fechaSolo.isBefore(hoy)) {
      return 'La fecha debe ser en el futuro';
    }
    
    return null; // Válido
  }

  /// Valida que la puntuación (rating) sea válida (1-5)
  static String? validarPuntuacion(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La puntuación es obligatoria';
    }
    
    final puntuacion = int.tryParse(valor);
    if (puntuacion == null) {
      return 'Ingresa un número válido';
    }
    
    if (puntuacion < 1 || puntuacion > 5) {
      return 'La puntuación debe estar entre 1 y 5';
    }
    
    return null; // Válido
  }

  /// Valida que el comentario sea válido
  static String? validarComentario(String? valor) {
    if (valor != null && valor.trim().length > 500) {
      return 'El comentario no debe exceder 500 caracteres';
    }
    
    return null; // Válido
  }

  /// Valida que la ubicación sea válida
  static String? validarUbicacion(String? valor) {
    if (valor != null && valor.trim().isEmpty) {
      return 'La ubicación no puede estar vacía';
    }
    
    if (valor != null && valor.trim().length < 5) {
      return 'Ingresa una ubicación más detallada (mínimo 5 caracteres)';
    }
    
    return null; // Válido
  }

  /// Valida que se haya seleccionado un técnico
  static String? validarSeleccionTecnico(int? idTecnico) {
    if (idTecnico == null || idTecnico <= 0) {
      return 'Debes seleccionar un técnico';
    }
    
    return null; // Válido
  }

  /// Valida que se haya seleccionado un servicio
  static String? validarSeleccionServicio(int? idServicio) {
    if (idServicio == null || idServicio <= 0) {
      return 'Debes seleccionar un servicio';
    }
    
    return null; // Válido
  }
}
