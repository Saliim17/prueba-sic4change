import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool get isLoggedIn => _prefs.getBool('isLoggedIn') ?? false;

  static set isLoggedIn(bool value) {
    _prefs.setBool('isLoggedIn', value);
  }
}
