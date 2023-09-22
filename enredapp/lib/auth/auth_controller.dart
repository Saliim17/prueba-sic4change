import 'package:enredapp/screens/login/login_page.dart';
import 'package:enredapp/services/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/resources/resources_page.dart';

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  RxBool isLoggedIn = false.obs;

  Future<void> signOut() async {
    try {
      auth.signOut();
      isLoggedIn.value = false;
      SharedPreferencesService.isLoggedIn = false;
      Get.snackbar(
        'Sign Out',
        'You have been signed out',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Sign Out Error',
        'Error signing out. Try again later',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      isLoggedIn.value = true;
      SharedPreferencesService.isLoggedIn = true;
      Get.off(() => const ResourcesPage());
      Get.snackbar(
        'Sign in',
        'You have been signed in',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Sign In Error',
        'Error signing in. Try again later',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> signInAnonymously(BuildContext context) async {
    try {
      await auth.signInAnonymously();
      isLoggedIn.value = true;
      SharedPreferencesService.isLoggedIn = true;
      Get.off(() => const ResourcesPage());

      Get.snackbar(
        'Sign in anonymously',
        'You have been signed in as anonymous',
      );
    } catch (e) {
      Get.snackbar(
        'Sign In Anonymously Error',
        'Error signing in anonymously. Try again later',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      );
    }
  }
}

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
