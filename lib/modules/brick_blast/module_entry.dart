import 'package:flutter/material.dart';

import 'ui/game_screen.dart';
import 'ui/home_screen.dart';

class BrickBlastModuleEntry {
  static const String homeRoute = '/brick-blast';
  static const String gameRoute = '/brick-blast/game';

  static final Map<String, WidgetBuilder> routes = {
    homeRoute: (context) => const BrickBlastHomeScreen(),
    gameRoute: (context) => const BrickBlastGameScreen(),
  };
}
