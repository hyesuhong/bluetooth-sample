import 'package:bluetooth_sample/services/wifi.dart';
import 'package:bluetooth_sample/utils/app_l10n.dart';
import 'package:flutter/material.dart';

class WifiInfoWidget extends StatelessWidget {
  final WifiConnection state;
  final bool enabled;
  final String? warningText;
  final List<Widget>? children;

  const WifiInfoWidget({
    super.key,
    required this.state,
    required this.enabled,
    this.warningText,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppL10n.getL10n(context).alertConnectWifi,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        Icon(
          enabled ? Icons.wifi : Icons.wifi_off,
          size: 64,
          color: warningText == null && state.ssid != null
              ? Colors.green
              : Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(state.state.name),
        if (warningText != null) Text(warningText!),
        if (warningText == null && state.ssid != null) Text(state.ssid!),
        if (children != null) ...children!,
      ],
    );
  }
}
