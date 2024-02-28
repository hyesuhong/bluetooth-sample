import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothOffScreen extends StatelessWidget {
  final BluetoothAdapterState? adapterState;
  const BluetoothOffScreen({super.key, this.adapterState});

  String _convertAdapterStateToKR(BluetoothAdapterState? state) {
    switch (state) {
      case BluetoothAdapterState.unknown:
        return '알 수 없음';
      case BluetoothAdapterState.unavailable:
        return '사용 불가능';
      case BluetoothAdapterState.unauthorized:
        return '권한 없음';
      case BluetoothAdapterState.turningOn:
        return '켜는중';
      case BluetoothAdapterState.on:
        return '켜짐';
      case BluetoothAdapterState.turningOff:
        return '끄는중';
      case BluetoothAdapterState.off:
        return '꺼짐';
      default:
        return '사용할 수 없음';
    }
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      '블루투스 어댑터 상태: ${_convertAdapterStateToKR(adapterState)}',
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
          // style: ButtonStyle(
          //   backgroundColor: Colors.white54,
          // ),
          child: const Text('블루투스 켜기'),
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
