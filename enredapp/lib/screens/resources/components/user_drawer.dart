import 'package:enredapp/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    final FirebaseAuth auth = FirebaseAuth.instance;
    String email = '';
    if (auth.currentUser != null && auth.currentUser!.isAnonymous) {
      email = 'Usuario anónimo';
    } else {
      email = auth.currentUser!.email!;
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
           DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/avatar.jpeg'),
                ),
                const SizedBox(height: 8),
                Text(
                  email, // Cambia a tu nombre de usuario
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Cerrar sesión'),
            onTap: () {
              // Agrega aquí la lógica para cerrar sesión
              auth.signOut();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
