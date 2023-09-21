import 'package:enredapp/routes/routes.dart';
import 'package:enredapp/services/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth/auth_controller.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SharedPreferencesService.init();
  runApp(const EnREDapp());
}

class EnREDapp extends StatelessWidget {
  const EnREDapp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'enREDapp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      initialRoute: RoutesClass.getSplashPage(),
      getPages: RoutesClass.routes,
    );
  }
}
