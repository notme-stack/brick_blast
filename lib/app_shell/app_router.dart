import 'package:flutter/material.dart';

import '../modules/brick_blast/module_entry.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/super_home_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String superHome = '/super-home';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    superHome: (context) => const SuperHomeScreen(),
    ...BrickBlastModuleEntry.routes,
  };
}
