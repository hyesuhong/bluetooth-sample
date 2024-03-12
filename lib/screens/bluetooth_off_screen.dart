import 'dart:io';

import 'package:bluetooth_sample/utils/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatelessWidget {
  final BluetoothAdapterState? adapterState;
  const BluetoothOffScreen({super.key, this.adapterState});

  String _convertAdapterStateToKR(
    BuildContext context,
    BluetoothAdapterState? state,
  ) {
    switch (state) {
      case BluetoothAdapterState.unknown:
        return AppL10n.getL10n(context).unknown;
      case BluetoothAdapterState.unavailable:
        return AppL10n.getL10n(context).unavailable;
      case BluetoothAdapterState.unauthorized:
        return AppL10n.getL10n(context).unauthorized;
      case BluetoothAdapterState.turningOn:
        return AppL10n.getL10n(context).turningOn;
      case BluetoothAdapterState.on:
        return AppL10n.getL10n(context).on;
      case BluetoothAdapterState.turningOff:
        return AppL10n.getL10n(context).turningOff;
      case BluetoothAdapterState.off:
        return AppL10n.getL10n(context).off;
      default:
        return AppL10n.getL10n(context).unknown;
    }
  }

  Widget _buildTitle(BuildContext context) {
    final status = _convertAdapterStateToKR(context, adapterState);
    return Text(
      AppL10n.getL10n(context).statusBLE(status),
      style: Theme.of(context)
          .primaryTextTheme
          .titleSmall
          ?.copyWith(color: Colors.white),
    );
  }

  Widget _buildTurnOnButton(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 24,
        ),
        FilledButton.tonal(
          onPressed: () async {
            await FlutterBluePlus.turnOn();
          },
          child: Text(AppL10n.getL10n(context).turnOnBLE),
        ),
      ],
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
              _buildTitle(context),
              if (Platform.isAndroid) _buildTurnOnButton(context),
            ],
          ),
        ));
  }
}
