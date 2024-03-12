import 'package:bluetooth_sample/utils/app_l10n.dart';
import 'package:bluetooth_sample/widgets/common/button.dart';
import 'package:flutter/material.dart';

class DeviceInfo extends StatelessWidget {
  final bool isConnected;
  final String connectionState;
  final int? rssi;
  final VoidCallback onGetServicesPressed;

  const DeviceInfo({
    super.key,
    required this.isConnected,
    required this.connectionState,
    this.rssi,
    required this.onGetServicesPressed,
  });

  String get _rssiStr => rssi == null ? '--' : rssi.toString();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                color: Colors.grey,
              ),
              Text(
                '${_rssiStr}dBm',
                style: const TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
        Expanded(
          child: Text(
            AppL10n.getL10n(context).deviceConnectionStatus(connectionState),
          ),
        ),
        Button(
          type: ButtonType.filled,
          onPressed: isConnected ? onGetServicesPressed : null,
          child: Text(AppL10n.getL10n(context).getServices),
        ),
      ],
    );
  }
}
