/// Modelo que representa un usuario (Cliente o Técnico)
/// Utilizado para almacenar datos del usuario autenticado
class UsuarioModelo {
  final int id;
  final String nombre;
  final String apellido;
  final String correo;
  final String tipoUsuario;
  final String telefono;
  final double latitud;
  final double longitud;
  final String? fotoPerfilUrl;
  final String? direccionTexto;
  final String? ubicacionTexto;
  final double? tarifaHora;
  final double? calificacionPromedio;
  final String? descripcion;
  final int? anosExperiencia;

  UsuarioModelo({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.tipoUsuario,
    required this.telefono,
    required this.latitud,
    required this.longitud,
    this.fotoPerfilUrl,
    this.direccionTexto,
    this.ubicacionTexto,
    this.tarifaHora,
    this.calificacionPromedio,
    this.descripcion,
    this.anosExperiencia,
  });

  /// Crea una instancia desde JSON (respuesta del servidor)
  factory UsuarioModelo.desdeJson(Map<String, dynamic> json) {
    print('\n PARSEANDO USUARIO MODELO');

    // Mapeo flexible para diferentes formatos de respuesta del servidor
    int id =
        json['idUsuario'] ??
        json['IdUsuario'] ??
        json['UserId'] ??
        json['IdUser'] ??
        json['id'] ??
        json['id_usuario'] ??
        0;
    String nombre = json['Nombre'] ?? json['Name'] ?? json['nombre'] ?? '';
    String apellido =
        json['Apellido'] ?? json['LastName'] ?? json['apellido'] ?? '';
    String correo = json['Correo'] ?? json['Email'] ?? json['email'] ?? '';

    // Mapeo más robusto del tipoUsuario
    String tipoUsuario =
        (json['TipoUsuario'] ??
                json['UserType'] ??
                json['tipo_usuario'] ??
                json['tipoUsuario'] ??
                'cliente')
            .toString()
            .toLowerCase()
            .trim();

    // Normalizar valores comunes
    if (tipoUsuario.isEmpty || tipoUsuario == 'null') {
      tipoUsuario = 'cliente';
    }

    print("ID: $id");
    print("Nombre: $nombre");
    print("Apellido: $apellido");
    print("Correo: $correo");
    print("TipoUsuario: $tipoUsuario");

    String telefono =
        json['Telefono'] ?? json['Phone'] ?? json['telefono'] ?? '';
    print("Teléfono: $telefono");

    double latitud = 0;
    double longitud = 0;
    try {
      latitud = (json['Latitud'] ?? json['Latitude'] ?? json['latitud'] ?? 0)
          .toDouble();
      longitud =
          (json['Longitud'] ?? json['Longitude'] ?? json['longitud'] ?? 0)
              .toDouble();
    } catch (e) {
      print('Error parsing latitud/longitud: $e');
    }

    print("Latitud: $latitud");
    print("Longitud: $longitud");

    // Tarifa
    double? tarifaHora;
    try {
      if (json['TarifaHora'] != null) {
        tarifaHora = double.tryParse(json['TarifaHora'].toString());
      } else if (json['tarifa_hora'] != null) {
        tarifaHora = double.tryParse(json['tarifa_hora'].toString());
      }
    } catch (e) {
      print('Error parsing tarifaHora: $e');
    }
    print(
      "TarifaHora: $tarifaHora (raw: TarifaHora=${json['TarifaHora']}, tarifa_hora=${json['tarifa_hora']})",
    );

    // CalificacionPromedio
    double? calificacionPromedio;
    try {
      if (json['CalificacionPromedio'] != null) {
        calificacionPromedio = double.tryParse(
          json['CalificacionPromedio'].toString(),
        );
      } else if (json['calificacion_promedio'] != null) {
        calificacionPromedio = double.tryParse(
          json['calificacion_promedio'].toString(),
        );
      }
    } catch (e) {
      print('Error parsing calificacionPromedio: $e');
    }
    print(
      "CalificacionPromedio: $calificacionPromedio (raw: ${json['CalificacionPromedio']} / ${json['calificacion_promedio']})",
    );

    String? descripcion = json['Descripcion'] ?? json['descripcion'];
    print(
      "Descripcion: $descripcion (raw: Descripcion=${json['Descripcion']}, descripcion=${json['descripcion']})",
    );

    int? anosExperiencia;
    try {
      if (json['AnosExperiencia'] != null) {
        anosExperiencia = int.tryParse(json['AnosExperiencia'].toString());
      } else if (json['anos_experiencia'] != null) {
        anosExperiencia = int.tryParse(json['anos_experiencia'].toString());
      }
    } catch (e) {
      print('Error parsing anosExperiencia: $e');
    }
    print(
      "AnosExperiencia: $anosExperiencia (raw: ${json['AnosExperiencia']} / ${json['anos_experiencia']})",
    );

    String? fotoPerfilUrl =
        json['FotoPerfilUrl'] ??
        json['foto_perfil_url'] ??
        json['fotoPerfilUrl'];
    print("FotoPerfilUrl: $fotoPerfilUrl");

    String? direccionTexto =
        json['DireccionTexto'] ??
        json['direccion_text'] ??
        json['direccionTexto'];
    print(" DireccionTexto: $direccionTexto");

    String? ubicacionTexto =
        json['UbicacionTexto'] ??
        json['ubicacion_text'] ??
        json['ubicacionTexto'];
    print(" UbicacionTexto: $ubicacionTexto");

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    return UsuarioModelo(
      id: id,
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      tipoUsuario: tipoUsuario,
      telefono: telefono,
      latitud: latitud,
      longitud: longitud,
      fotoPerfilUrl: fotoPerfilUrl,
      direccionTexto: direccionTexto,
      ubicacionTexto: ubicacionTexto,
      tarifaHora: tarifaHora,
      calificacionPromedio: calificacionPromedio,
      descripcion: descripcion,
      anosExperiencia: anosExperiencia,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> aJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'tipoUsuario': tipoUsuario,
      'telefono': telefono,
      'latitud': latitud,
      'longitud': longitud,
      'fotoPerfilUrl': fotoPerfilUrl,
      'direccionTexto': direccionTexto,
      'ubicacionTexto': ubicacionTexto,
      'tarifaHora': tarifaHora,
      'calificacionPromedio': calificacionPromedio,
      'descripcion': descripcion,
      'anosExperiencia': anosExperiencia,
    };
  }

  String obtenerNombreCompleto() => '$nombre $apellido';

  /// Indica si el usuario es técnico

  bool esTecnico() {
    final tipo = tipoUsuario.toLowerCase();
    return tipo == 'tecnico' || tipo == 'technician';
  }

  /// Indica si el usuario es cliente
  bool esCliente() {
    final tipo = tipoUsuario.toLowerCase();
    return tipo == 'cliente' || tipo == 'client';
  }

  @override
  String toString() =>
      'UsuarioModelo(id: $id, nombre: $nombre, tipoUsuario: $tipoUsuario)';
}
