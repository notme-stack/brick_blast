import 'package:flutter/material.dart';

import 'app_shell/app_router.dart';
import 'theme/app_theme.dart';

class BrickBlastApp extends StatelessWidget {
  const BrickBlastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brick Blast',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
    );
  }
}
