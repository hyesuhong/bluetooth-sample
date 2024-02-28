import 'dart:async';

import 'package:bluetooth_sample/screens/device_screen.dart';
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
  bool _isScanning = false;

  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (error) {
      print(error);
    });

    FlutterBluePlus.cancelWhenScanComplete(_scanResultsSubscription);

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
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
    _isScanningSubscription.cancel();

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

  Future onStopPressed() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (error) {
      print(error);
    }
  }

  Widget _buildFloatingButton() {
    return FlutterBluePlus.isScanningNow
        ? FloatingActionButton(
            onPressed: onStopPressed,
            child: const Icon(Icons.stop),
          )
        : FloatingActionButton(
            onPressed: onScanPressed,
            child: const Icon(Icons.search),
          );
  }

  void onConnectPressed(BluetoothDevice device) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => DeviceScreen(device: device),
      settings: const RouteSettings(name: '/DeviceScreen'),
    );
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('기기 검색'),
      ),
      body: ListView.separated(
        itemCount: _scanResults.length,
        separatorBuilder: (context, index) {
          return const Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          final res = _scanResults[index];
          return ScanDeviceWidget(
            result: res,
            onTap: () => onConnectPressed(res.device),
          );
        },
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }
}
