import 'package:flutter/material.dart';

import '../app_shell/app_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRouter.login);
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}
