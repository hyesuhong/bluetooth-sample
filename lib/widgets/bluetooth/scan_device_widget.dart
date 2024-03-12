import 'package:bluetooth_sample/utils/app_l10n.dart';
import 'package:bluetooth_sample/widgets/common/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanDeviceWidget extends StatelessWidget {
  final ScanResult result;
  final VoidCallback? onTap;

  const ScanDeviceWidget({super.key, required this.result, this.onTap});

  List<Widget> _buildTitle() {
    const TextStyle titleStyle = TextStyle(
      fontWeight: FontWeight.w500,
    );
    const TextStyle deviceStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey,
    );

    return result.device.platformName.isNotEmpty
        ? [
            Text(
              result.device.platformName,
              style: titleStyle,
            ),
            Text(
              result.device.remoteId.str,
              style: deviceStyle,
            ),
          ]
        : [
            Text(
              result.device.remoteId.str,
              style: titleStyle,
            ),
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildTitle(),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(result.rssi.toString()),
              Button(
                type: ButtonType.filled,
                onPressed: result.advertisementData.connectable ? onTap : null,
                child: Text(AppL10n.getL10n(context).connect),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
