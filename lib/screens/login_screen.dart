import 'package:flutter/material.dart';

import '../modules/brick_blast/module_entry.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              BrickBlastModuleEntry.homeRoute,
            );
          },
          child: const Text('Continue as Guest'),
        ),
      ),
    );
  }
}
