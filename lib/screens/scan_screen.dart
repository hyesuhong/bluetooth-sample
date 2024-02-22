import 'package:bluetooth_sample/widgets/scan_device_widget.dart';
import 'package:flutter/material.dart';

final List<int> dummyList = List.filled(10, 0);

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Find Devices'),
      ),
      body: ListView(
        children: [
          for (var dummy in dummyList) ScanDeviceWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('floating');
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
