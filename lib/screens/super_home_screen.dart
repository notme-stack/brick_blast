import 'package:flutter/material.dart';

import '../modules/brick_blast/module_entry.dart';

class SuperHomeScreen extends StatelessWidget {
  const SuperHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Super Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, BrickBlastModuleEntry.homeRoute);
          },
          child: const Text('Open Brick Blast'),
        ),
      ),
    );
  }
}
