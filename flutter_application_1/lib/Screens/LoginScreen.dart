import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api.dart';
import 'RegisterScreen.dart';
import 'ClientHomeScreen.dart';
import 'TechnicianHomeScreen.dart';
import '../config/app_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor completa todos los campos.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final apiService = ApiService();
      final result = await apiService.login(email, password);

      if (!mounted) return;

      final userType = result['user_type']; // 'client' o 'technician'
      final userId = result['id_user'] as int?; // ID del usuario

      print('🔵 Usuario logueado - Tipo: $userType, ID: $userId');

      // Navega según el tipo de usuario, limpiando el stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => userType == 'client'
              ? ClientHomeScreen(clientId: userId)
              : TechnicianHomeScreen(technicianId: userId),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 3),
        backgroundColor: AppIcons.darkGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppIcons.darkGreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // TÍTULO
                  Text(
                    "Iniciar sesión",
                    style: AppIcons.headingStyle.copyWith(
                      color: AppIcons.white,
                      fontSize: 32,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Bienvenido a Servitec",
                    style: AppIcons.bodyStyle.copyWith(
                      color: AppIcons.lightGreen,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CARD con inputs
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppIcons.lightGreen,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // INPUT EMAIL
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: AppIcons.getInputDecoration(
                            labelText: "Correo electrónico",
                            hintText: "tu@email.com",
                            prefixIcon: Icons.email_outlined,
                          ).copyWith(
                            fillColor: AppIcons.white,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // INPUT PASSWORD
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: AppIcons.getInputDecoration(
                            labelText: "Contraseña",
                            hintText: "••••••••",
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ).copyWith(
                            fillColor: AppIcons.white,
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppIcons.midGreen,
                                size: 22,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Recuperar contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Implementar recuperación de contraseña
                            },
                            child: Text(
                              "¿Olvidaste tu contraseña?",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppIcons.darkGreen,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // BOTÓN INICIAR SESIÓN
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: AppIcons.primaryButtonStyle.copyWith(
                              backgroundColor: MaterialStateProperty.all(
                                AppIcons.midGreen,
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: AppIcons.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Entrar",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // CREAR CUENTA
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "¿No tienes cuenta? ",
                        style: AppIcons.bodyStyle.copyWith(
                          color: AppIcons.white,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: "Regístrate aquí",
                            style: AppIcons.bodyStyle.copyWith(
                              color: AppIcons.lightGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
