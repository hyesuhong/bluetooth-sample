import 'dart:async';

import 'package:bluetooth_sample/screens/device_screen.dart';
import 'package:bluetooth_sample/utils/app_l10n.dart';
import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
import 'package:bluetooth_sample/widgets/common/button.dart';
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
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      if (mounted) {
        setState(() {
          _isScanning = state;
        });
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();

    super.dispose();
  }

  Future _onScanPressed() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (error) {
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
    }
  }

  Future _onStopPressed() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (error) {
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
    }
  }

  void _onConnectPressed(BluetoothDevice device) {
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
        title: Text(AppL10n.getL10n(context).searchDevices),
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
            onTap: () => _onConnectPressed(res.device),
          );
        },
      ),
      floatingActionButton: Button(
        type: ButtonType.floating,
        onPressed: _isScanning ? _onStopPressed : _onScanPressed,
        child: Icon(_isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
