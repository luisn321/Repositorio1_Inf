import 'package:flutter/material.dart';
import '../modelos/index.dart';
import '../servicios_red/index.dart';
import '../validadores/validadores_autenticacion.dart';
import '../config/app_icons.dart';

/// Pantalla de registro de usuario
/// Permite elegir entre registro de cliente o técnico
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppIcons.darkGreen,
      appBar: AppBar(
        backgroundColor: AppIcons.darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TÍTULO
              Text(
                'Crear cuenta',
                style: AppIcons.headingStyle.copyWith(
                  color: AppIcons.white,
                  fontSize: 32,
                ),
              ),

              const SizedBox(height: 16),

              // SUBTÍTULO
              Text(
                '¿Eres cliente o técnico?',
                style: TextStyle(
                  color: AppIcons.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 60),

              // BOTÓN REGISTRO CLIENTE
              _construirBotonOpcion(
                titulo: 'Soy Cliente',
                descripcion: 'Necesito servicios técnicos',
                icono: Icons.person_outline,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PantallaRegistroCliente(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // BOTÓN REGISTRO TÉCNICO
              _construirBotonOpcion(
                titulo: 'Soy Técnico',
                descripcion: 'Ofrezco servicios técnicos',
                icono: Icons.build_outlined,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PantallaRegistroTecnico(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye un botón de opción (cliente o técnico)
  Widget _construirBotonOpcion({
    required String titulo,
    required String descripcion,
    required IconData icono,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icono,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder para pantalla de registro de cliente
class PantallaRegistroCliente extends StatefulWidget {
  const PantallaRegistroCliente({super.key});

  @override
  State<PantallaRegistroCliente> createState() =>
      _PantallaRegistroClienteState();
}

class _PantallaRegistroClienteState extends State<PantallaRegistroCliente> {
  final _formularioKey = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorApellido = TextEditingController();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorConfirmarContrasena = TextEditingController();
  final _controladorTelefono = TextEditingController();
  final _controladorDireccion = TextEditingController();

  late ServicioAutenticacion _servicio;
  bool _esCargando = false;
  bool _ocultarContrasena = true;

  @override
  void initState() {
    super.initState();
    _servicio = ServicioAutenticacion();
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorApellido.dispose();
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    _controladorConfirmarContrasena.dispose();
    _controladorTelefono.dispose();
    _controladorDireccion.dispose();
    super.dispose();
  }

  Future<void> _registrarCliente() async {
    if (!_formularioKey.currentState!.validate()) return;

    setState(() => _esCargando = true);

    try {
      final solicitud = SolicitudRegistroClienteModelo(
        nombre: _controladorNombre.text.trim(),
        apellido: _controladorApellido.text.trim(),
        correo: _controladorCorreo.text.trim(),
        contrasena: _controladorContrasena.text,
        telefono: _controladorTelefono.text.trim(),
        direccion: _controladorDireccion.text.trim(),
        latitud: 0.0, // Se puede mejorar con geolocalización
        longitud: 0.0,
      );

      await _servicio.registrarCliente(solicitud);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Registro exitoso')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _esCargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final esMovil = size.width < 600;

    return Scaffold(
      backgroundColor: AppIcons.darkGreen,
      appBar: AppBar(
        backgroundColor: AppIcons.darkGreen,
        title: const Text('Registro de Cliente'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(esMovil ? 16 : 24),
        child: Form(
          key: _formularioKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TÍTULO DESCRIPTIVO
              Text(
                'Crea tu cuenta de cliente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: esMovil ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accede a servicios técnicos de calidad',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // DATOS PERSONALES - HEADER
              Text(
                'Información Personal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Row responsive para nombre y apellido
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 500) {
                    return Row(
                      children: [
                        Expanded(
                          child: _campoTexto(
                            _controladorNombre,
                            'Nombre',
                            Icons.person_outline,
                            validador: (v) =>
                                ValidadoresAutenticacion.validarNombre(v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _campoTexto(
                            _controladorApellido,
                            'Apellido',
                            Icons.person_outline,
                            validador: (v) =>
                                ValidadoresAutenticacion.validarCampoRequerido(
                              v,
                              'Apellido',
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _campoTexto(
                          _controladorNombre,
                          'Nombre',
                          Icons.person_outline,
                          validador: (v) =>
                              ValidadoresAutenticacion.validarNombre(v),
                        ),
                        const SizedBox(height: 12),
                        _campoTexto(
                          _controladorApellido,
                          'Apellido',
                          Icons.person_outline,
                          validador: (v) =>
                              ValidadoresAutenticacion.validarCampoRequerido(
                            v,
                            'Apellido',
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorCorreo,
                'Correo Electrónico',
                Icons.email_outlined,
                validador: ValidadoresAutenticacion.validarCorreo,
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorTelefono,
                'Teléfono',
                Icons.phone_outlined,
                validador: ValidadoresAutenticacion.validarTelefono,
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorDireccion,
                'Dirección',
                Icons.location_on_outlined,
                validador: (v) => ValidadoresAutenticacion.validarCampoRequerido(
                  v,
                  'Dirección',
                ),
              ),
              const SizedBox(height: 24),

              // SEGURIDAD - HEADER
              Text(
                'Seguridad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorContrasena,
                'Contraseña',
                Icons.lock_outlined,
                esContrasena: true,
                validador: ValidadoresAutenticacion.validarContrasena,
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorConfirmarContrasena,
                'Confirmar Contraseña',
                Icons.lock_outlined,
                esContrasena: true,
                validador: (v) =>
                    ValidadoresAutenticacion.validarConfirmacionContrasena(
                  v,
                  _controladorContrasena.text,
                ),
              ),
              const SizedBox(height: 32),

              // BOTÓN REGISTRARSE
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _esCargando ? null : _registrarCliente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _esCargando
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          'Crear Cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _esCargando
                                ? Colors.grey
                                : AppIcons.darkGreen,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(
    TextEditingController controlador,
    String etiqueta,
    IconData icono, {
    bool esContrasena = false,
    FormFieldValidator<String?>? validador,
  }) {
    return TextFormField(
      controller: controlador,
      obscureText: esContrasena ? _ocultarContrasena : false,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      decoration: InputDecoration(
        labelText: etiqueta,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icono, color: AppIcons.darkGreen, size: 20),
        suffixIcon: esContrasena
            ? IconButton(
                icon: Icon(
                  _ocultarContrasena
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppIcons.darkGreen,
                ),
                onPressed: () {
                  setState(() {
                    _ocultarContrasena = !_ocultarContrasena;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(fontSize: 13),
      ),
      validator: validador,
    );
  }
}

/// Placeholder para pantalla de registro de técnico
class PantallaRegistroTecnico extends StatefulWidget {
  const PantallaRegistroTecnico({super.key});

  @override
  State<PantallaRegistroTecnico> createState() =>
      _PantallaRegistroTecnicoState();
}

class _PantallaRegistroTecnicoState extends State<PantallaRegistroTecnico> {
  final _formularioKey = GlobalKey<FormState>();
  final _controladorNombre = TextEditingController();
  final _controladorApellido = TextEditingController();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorConfirmarContrasena = TextEditingController();
  final _controladorTelefono = TextEditingController();
  final _controladorUbicacion = TextEditingController();
  final _controladorTarifa = TextEditingController();

  late ServicioAutenticacion _servicio;
  bool _esCargando = false;
  bool _ocultarContrasena = true;
  Set<int> _serviciosSeleccionados = {};

  // Servicios disponibles (simulados - en producción vienen del servidor)
  final _servicios = [
    {'id': 1, 'nombre': 'Electricista'},
    {'id': 2, 'nombre': 'Plomero'},
    {'id': 3, 'nombre': 'Carpintero'},
    {'id': 4, 'nombre': 'Técnico PC'},
    {'id': 5, 'nombre': 'Jardinería'},
    {'id': 6, 'nombre': 'Línea Blanca'},
  ];

  @override
  void initState() {
    super.initState();
    _servicio = ServicioAutenticacion();
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorApellido.dispose();
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    _controladorConfirmarContrasena.dispose();
    _controladorTelefono.dispose();
    _controladorUbicacion.dispose();
    _controladorTarifa.dispose();
    super.dispose();
  }

  Future<void> _registrarTecnico() async {
    if (!_formularioKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Por favor completa todos los campos')),
      );
      return;
    }

    if (_serviciosSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Selecciona al menos un servicio')),
      );
      return;
    }

    setState(() => _esCargando = true);

    try {
      final solicitud = SolicitudRegistroTecnicoModelo(
        nombre: _controladorNombre.text.trim(),
        apellido: _controladorApellido.text.trim(),
        correo: _controladorCorreo.text.trim(),
        contrasena: _controladorContrasena.text,
        telefono: _controladorTelefono.text.trim(),
        ubicacion: _controladorUbicacion.text.trim(),
        latitud: 0.0, // Se puede mejorar con geolocalización
        longitud: 0.0,
        tarifaHora: double.parse(_controladorTarifa.text.trim()),
        idsServicios: _serviciosSeleccionados.toList(),
      );

      await _servicio.registrarTecnico(solicitud);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Registro exitoso')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _esCargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final esMovil = size.width < 600;

    return Scaffold(
      backgroundColor: AppIcons.darkGreen,
      appBar: AppBar(
        backgroundColor: AppIcons.darkGreen,
        title: const Text('Registro de Técnico'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(esMovil ? 16 : 24),
        child: Form(
          key: _formularioKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TÍTULO DESCRIPTIVO
              Text(
                'Completa tu perfil profesional',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: esMovil ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Información personal y profesional',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // DATOS PERSONALES - HEADER
              Text(
                'Datos Personales',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Row responsive para nombre y apellido
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 500) {
                    // Desktop/tablet - lado a lado
                    return Row(
                      children: [
                        Expanded(
                          child: _campoTexto(
                            _controladorNombre,
                            'Nombre',
                            Icons.person_outline,
                            validador: (v) =>
                                ValidadoresAutenticacion.validarNombre(v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _campoTexto(
                            _controladorApellido,
                            'Apellido',
                            Icons.person_outline,
                            validador: (v) =>
                                ValidadoresAutenticacion.validarCampoRequerido(
                              v,
                              'Apellido',
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Mobile - apilado
                    return Column(
                      children: [
                        _campoTexto(
                          _controladorNombre,
                          'Nombre',
                          Icons.person_outline,
                          validador: (v) =>
                              ValidadoresAutenticacion.validarNombre(v),
                        ),
                        const SizedBox(height: 12),
                        _campoTexto(
                          _controladorApellido,
                          'Apellido',
                          Icons.person_outline,
                          validador: (v) =>
                              ValidadoresAutenticacion.validarCampoRequerido(
                            v,
                            'Apellido',
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorCorreo,
                'Correo Electrónico',
                Icons.email_outlined,
                validador: ValidadoresAutenticacion.validarCorreo,
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorTelefono,
                'Teléfono',
                Icons.phone_outlined,
                validador: ValidadoresAutenticacion.validarTelefono,
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorUbicacion,
                'Ubicación / Dirección',
                Icons.location_on_outlined,
                validador: (v) => ValidadoresAutenticacion.validarCampoRequerido(
                  v,
                  'Ubicación',
                ),
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorTarifa,
                'Tarifa por Hora (\$)',
                Icons.attach_money,
                teclado: TextInputType.numberWithOptions(decimal: true),
                validador: (v) {
                  if (v == null || v.isEmpty) return 'Campo requerido';
                  if (double.tryParse(v) == null) return 'Ingresa un número válido';
                  if (double.parse(v) <= 0) return 'La tarifa debe ser mayor a 0';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // CONTRASEÑA - HEADER
              Text(
                'Seguridad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorContrasena,
                'Contraseña',
                Icons.lock_outlined,
                esContrasena: true,
                validador: ValidadoresAutenticacion.validarContrasena,
              ),
              const SizedBox(height: 12),

              _campoTexto(
                _controladorConfirmarContrasena,
                'Confirmar Contraseña',
                Icons.lock_outlined,
                esContrasena: true,
                validador: (v) =>
                    ValidadoresAutenticacion.validarConfirmacionContrasena(
                  v,
                  _controladorContrasena.text,
                ),
              ),
              const SizedBox(height: 24),

              // SERVICIOS - HEADER
              Text(
                'Servicios que Ofreces',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // GRID de servicios
              LayoutBuilder(
                builder: (context, constraints) {
                  int colCount = constraints.maxWidth > 500 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: colCount,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _servicios.length,
                    itemBuilder: (context, index) {
                      final servicio = _servicios[index];
                      final isSelected =
                          _serviciosSeleccionados.contains(servicio['id']);

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _serviciosSeleccionados
                                    .remove(servicio['id']);
                              } else {
                                _serviciosSeleccionados.add(
                                  servicio['id'] as int,
                                );
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                servicio['nombre'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppIcons.darkGreen
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // BOTÓN REGISTRARSE
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _esCargando ? null : _registrarTecnico,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _esCargando
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          'Registrar como Técnico',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _esCargando
                                ? Colors.grey
                                : AppIcons.darkGreen,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(
    TextEditingController controlador,
    String etiqueta,
    IconData icono, {
    bool esContrasena = false,
    TextInputType teclado = TextInputType.text,
    FormFieldValidator<String?>? validador,
  }) {
    return TextFormField(
      controller: controlador,
      obscureText: esContrasena ? _ocultarContrasena : false,
      keyboardType: teclado,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      decoration: InputDecoration(
        labelText: etiqueta,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icono, color: AppIcons.darkGreen, size: 20),
        suffixIcon: esContrasena
            ? IconButton(
                icon: Icon(
                  _ocultarContrasena
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppIcons.darkGreen,
                ),
                onPressed: () {
                  setState(() {
                    _ocultarContrasena = !_ocultarContrasena;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(fontSize: 13),
      ),
      validator: validador,
    );
  }
}

/// Placeholder para selector de tipo de usuario
class PantallaSelectorTipoUsuario extends StatelessWidget {
  const PantallaSelectorTipoUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
