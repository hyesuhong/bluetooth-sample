import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
              FilledButton(
                onPressed: result.advertisementData.connectable ? onTap : null,
                child: Text(AppLocalizations.of(context)?.connect ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
