import 'package:enredapp/auth/auth_controller.dart';
import 'package:enredapp/screens/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

IconButton getAuthButton(AuthController authController) {
  return authController.isLoggedIn.value
      ? IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            authController.signOut();
          },
        )
      : IconButton(
          icon: const Icon(Icons.login),
          onPressed: () {
            Get.offAll(() => LoginPage());
          },
        );
}
