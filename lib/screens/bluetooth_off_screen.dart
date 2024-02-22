import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatelessWidget {
  final BluetoothAdapterState? adapterState;
  const BluetoothOffScreen({super.key, this.adapterState});

  Widget buildTitle(BuildContext context) {
    String? state = adapterState?.toString().split('.').last;
    return Text(
      'Bluetooth Adapter is ${state ?? 'not available'}',
      style: Theme.of(context)
          .primaryTextTheme
          .titleSmall
          ?.copyWith(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bluetooth_disabled,
                size: 80.0,
                color: Colors.white54,
              ),
              const SizedBox(
                height: 24,
              ),
              buildTitle(context),
            ],
          ),
        ));
  }
}
