import 'package:flutter/material.dart';
import 'package:flutter_application_1/Screens/LoginScreen.dart';
import 'package:flutter_application_1/Screens/RegisterScreen.dart';
import 'package:flutter_application_1/Screens/RegisterTechnicianScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color darkGreen = Color(0xFF0F6B44);
  static const Color midGreen = Color.fromARGB(255, 54, 223, 150);
  static const Color lightGreen = Color(0xFFA8E6CF);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(   //  ESTA LÍNEA evita overflow
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20), // margen extra superior

                  // ILUSTRACIÓN
                  Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: midGreen,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.engineering,
                        size: 110,
                        color: white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    "Servitec",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Encuentra técnicos confiables de forma\nrápida, sencilla y segura.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: white.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BOTÓN INICIAR SESIÓN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () { Navigator.push( context, MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: midGreen,
                        foregroundColor: white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 6,
                      ),
                      child: const Text(
                        "Iniciar sesión",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BOTÓN CREAR CUENTA
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {Navigator.push( context, MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: lightGreen, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Crear cuenta",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BOTÓN SOY TÉCNICO
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {Navigator.push( context, MaterialPageRoute(builder: (context) => const RegisterTechnicianScreen()),
                      );},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        foregroundColor: darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Soy técnico",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
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
