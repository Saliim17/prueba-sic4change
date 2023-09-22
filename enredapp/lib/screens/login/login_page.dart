import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../auth/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final AuthController authController = Get.find<AuthController>();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Oculta el botón de retroceso
        title: const Text("Inicio de Sesión"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
              ),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                authController.signInWithEmailAndPassword(
                    context, emailController.text, passwordController.text);
              },
              child: const Text('Iniciar Sesión con Correo y Contraseña'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                authController.signInAnonymously(context);
              },
              child: const Text('Iniciar Sesión Anónima'),
            ),
          ],
        ),
      ),
    );
  }
}
