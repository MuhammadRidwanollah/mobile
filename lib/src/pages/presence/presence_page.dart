import 'package:flutter/material.dart';

class PresencePage extends StatelessWidget {
  const PresencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presence'),
      ),
      body: const Center(
        child: Text('Presence Page'),
      ),
    );
  }
}