import 'package:enredapp/screens/splash/splash_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../screens/resources/resources_page.dart';

class RoutesClass {

  static String splashPage = '/';
  static String getSplashPage() => splashPage;

  static String resourcesPage = '/resources';
  static String getResourcesPage() => resourcesPage;

  static List<GetPage> routes = [
    GetPage(page: ()=> const SplashPage(), name: splashPage),
    GetPage(page: ()=> const ResourcesPage(), name: resourcesPage),
  ];

}