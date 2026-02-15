class ServicioModelo {
  final int idServicio;
  final String nombre;
  final String? descripcion;
  final String? categoria;
  final double tarifaBase;
  final int numTecnicosDisponibles;

  ServicioModelo({
    required this.idServicio,
    required this.nombre,
    this.descripcion,
    this.categoria,
    required this.tarifaBase,
    required this.numTecnicosDisponibles,
  });

  factory ServicioModelo.desdeJson(Map<String, dynamic> json) {
    return ServicioModelo(
      idServicio: json['id_servicio'] as int? ?? json['idServicio'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      categoria: json['categoria'] as String?,
      tarifaBase: (json['tarifa_base'] as num? ?? json['tarifaBase'] as num? ?? 0).toDouble(),
      numTecnicosDisponibles: json['num_tecnicos_disponibles'] as int? ?? json['numTecnicosDisponibles'] as int? ?? 0,
    );
  }

  Map<String, dynamic> aJson() {
    return {
      'id_servicio': idServicio,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'tarifa_base': tarifaBase,
      'num_tecnicos_disponibles': numTecnicosDisponibles,
    };
  }

  @override
  String toString() => 'ServicioModelo(id=$idServicio, nombre=$nombre, tarifa=$tarifaBase)';
}
