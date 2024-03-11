import 'dart:async';

import 'package:bluetooth_sample/screens/bluetooth_off_screen.dart';
import 'package:bluetooth_sample/screens/scan_screen.dart';
import 'package:bluetooth_sample/services/wifi.dart';
import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  @override
  void initState() {
    super.initState();

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: screen,
      navigatorObservers: [BluetoothAdapterStateObserver()],
      scaffoldMessengerKey: CustomSnackBar.getSnackBarKey(),
    );
  }
}

class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      _adapterStateSubscription ??=
          FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          navigator?.pop();
        }
      });
    }

    if (route.settings.name != null && route.settings.name!.contains('/wifi')) {
      final devices = FlutterBluePlus.connectedDevices;

      if (devices.isNotEmpty) {
        _connectionStateSubscription ??=
            devices[0].connectionState.listen((state) {
          if (state == BluetoothConnectionState.disconnected) {
            Wifi.disconnect();
            navigator?.popUntil(ModalRoute.withName('/DeviceScreen'));
          }
        });
      }
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;

    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
