import 'dart:async';

import 'package:bluetooth_sample/widgets/scan_device_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

final List<int> dummyList = List.filled(10, 0);

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) {
      _scanResults = results;
      if (results.isNotEmpty) {
        print(results.last);
      }
      if (mounted) {
        setState(() {});
      }
    }, onError: (error) {
      print(error);
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();

    super.dispose();
  }

  Future onScanPressed() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (error) {
      print(error);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Find Devices'),
      ),
      body: ListView(
        children: [
          for (var result in _scanResults) ScanDeviceWidget(result: result),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onScanPressed,
        child: const Icon(Icons.search),
      ),
    );
  }
}
