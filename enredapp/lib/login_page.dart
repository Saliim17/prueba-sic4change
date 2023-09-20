import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LoginPage({super.key});

  Future<void> _signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      // Aquí puedes navegar a la siguiente pantalla después de iniciar sesión.
    } catch (e) {
      // Maneja el error aquí, por ejemplo, mostrando un mensaje al usuario.
    }
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;
      // Aquí puedes navegar a la siguiente pantalla después de iniciar sesión de forma anónima.
    } catch (e) {
      // Maneja el error aquí, por ejemplo, mostrando un mensaje al usuario.
    }
  }

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
                // Llama a la función de inicio de sesión con correo y contraseña aquí.
                // Debes obtener los valores de correo electrónico y contraseña del formulario.
                _signInWithEmailAndPassword(
                    context, emailController.text, passwordController.text);
                if (_auth.currentUser != null) {
                  GoRouter.of(context).go('/resources');
                }
              },
              child: const Text('Iniciar Sesión con Correo y Contraseña'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                _signInAnonymously(context);
                GoRouter.of(context).go('/resources');
              },
              child: const Text('Iniciar Sesión Anónima'),
            ),
          ],
        ),
      ),
    );
  }
}
