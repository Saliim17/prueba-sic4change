import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Si el usuario ya inició sesión, ve directamente a la página de recursos
    if (_auth.currentUser != null) {
      Future.delayed(const Duration(seconds: 3))
          .then((value) => GoRouter.of(context).go('/resources'));
    } else {
      Future.delayed(const Duration(seconds: 3))
          .then((value) => GoRouter.of(context).go('/login'));
    }
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage('assets/logo.jpeg'),
                height: 128.0,
                width: 128.0),
            Text(
              'enREDapp',
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
