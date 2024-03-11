import 'dart:async';

import 'package:bluetooth_sample/screens/device_screen.dart';
import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
import 'package:bluetooth_sample/widgets/scan_device_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
      if (mounted) {
        setState(() {});
      }
    }, onError: (error) {
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
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
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
    }
  }

  Future onStopPressed() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (error) {
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
    }
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: FlutterBluePlus.isScanningNow ? onStopPressed : onScanPressed,
      child: Icon(FlutterBluePlus.isScanningNow ? Icons.stop : Icons.search),
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
