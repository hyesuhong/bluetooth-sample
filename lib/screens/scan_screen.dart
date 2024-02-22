import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Find devices'),
      ),
      body: ListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('floating');
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
