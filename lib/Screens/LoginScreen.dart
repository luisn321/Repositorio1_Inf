import 'package:flutter/material.dart';
import 'RegisterScreen.dart';
import 'ClientHomeScreen.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color(0xFF2DBE7F);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // TÍTULO
                  const Text(
                    "Iniciar sesión",
                    style: TextStyle(
                      fontSize: 32,
                      color: white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CARD con inputs
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // INPUT EMAIL
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: white,
                            hintText: "Correo electrónico",
                            prefixIcon: const Icon(Icons.email_outlined),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // INPUT PASSWORD
                        TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: white,
                            hintText: "Contraseña",
                            prefixIcon: const Icon(Icons.lock_outline),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Recuperar contraseña
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              "¿Olvidaste tu contraseña?",
                              style: TextStyle(
                                fontSize: 15,
                                color: darkGreen.withOpacity(0.9),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // BOTÓN INICIAR SESIÓN
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {Navigator.push( context, MaterialPageRoute(builder: (context) => const ClientHomeScreen()),
                            );},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: midGreen,
                              foregroundColor: white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Entrar",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CREAR CUENTA
                  GestureDetector(
                    onTap: () {Navigator.push( context, MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );},
                    child: const Text(
                      "¿No tienes cuenta? Regístrate",
                      style: TextStyle(
                        color: white,
                        fontSize: 17,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
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
