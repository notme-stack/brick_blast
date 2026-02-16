import 'package:flutter/material.dart';

import '../../../capabilities/storage/local_storage_service.dart';
import '../logic/game_controller.dart';
import '../module_entry.dart';

class BrickBlastHomeScreen extends StatefulWidget {
  const BrickBlastHomeScreen({super.key});

  @override
  State<BrickBlastHomeScreen> createState() => _BrickBlastHomeScreenState();
}

class _BrickBlastHomeScreenState extends State<BrickBlastHomeScreen> {
  final LocalStorageService _storage = LocalStorageService();

  int _totalCoins = 0;
  int _currentLevel = 1;
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _totalCoins = _storage.read<int>(GameController.totalCoinsKey) ?? 0;
      _currentLevel = _storage.read<int>(GameController.highestLevelKey) ?? 1;
      _bestScore = _storage.read<int>(GameController.bestScoreKey) ?? 0;
    });
  }

  Future<void> _openGame() async {
    await Navigator.pushNamed(context, BrickBlastModuleEntry.gameRoute);
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brick Blast')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Drag to aim and release to fire a stream of balls.\n'
              'After each turn, bricks drop down one row.\n'
              'Do not let them reach the bottom.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('Total Coins: $_totalCoins'),
                    Text('Current Level: $_currentLevel'),
                    Text('Best Score: $_bestScore'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _openGame,
              child: const Text('Start Shooter Run'),
            ),
          ],
        ),
      ),
    );
  }
}
