import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BluetoothOffScreen extends StatelessWidget {
  final BluetoothAdapterState? adapterState;
  const BluetoothOffScreen({super.key, this.adapterState});

  String _convertAdapterStateToKR(
    BuildContext context,
    BluetoothAdapterState? state,
  ) {
    switch (state) {
      case BluetoothAdapterState.unknown:
        return AppLocalizations.of(context)?.unknown ?? state.toString();
      case BluetoothAdapterState.unavailable:
        return AppLocalizations.of(context)?.unavailable ?? state.toString();
      case BluetoothAdapterState.unauthorized:
        return AppLocalizations.of(context)?.unauthorized ?? state.toString();
      case BluetoothAdapterState.turningOn:
        return AppLocalizations.of(context)?.turningOn ?? state.toString();
      case BluetoothAdapterState.on:
        return AppLocalizations.of(context)?.on ?? state.toString();
      case BluetoothAdapterState.turningOff:
        return AppLocalizations.of(context)?.turningOff ?? state.toString();
      case BluetoothAdapterState.off:
        return AppLocalizations.of(context)?.off ?? state.toString();
      default:
        return AppLocalizations.of(context)?.unknown ?? state.toString();
    }
  }

  Widget _buildTitle(BuildContext context) {
    final status = _convertAdapterStateToKR(context, adapterState);
    return Text(
      AppLocalizations.of(context)?.statusBLE(status) ?? '',
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
          child: Text(AppLocalizations.of(context)?.turnOnBLE ?? ''),
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
