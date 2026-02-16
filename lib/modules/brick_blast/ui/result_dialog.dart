import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  const ResultDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPlayAgain,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPlayAgain;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        TextButton(onPressed: onBack, child: const Text('Back')),
        FilledButton(onPressed: onPlayAgain, child: const Text('Play Again')),
      ],
    );
  }
}
