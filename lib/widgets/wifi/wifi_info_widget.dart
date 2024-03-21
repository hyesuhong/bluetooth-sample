import 'package:bluetooth_sample/services/wifi.dart';
import 'package:bluetooth_sample/utils/app_l10n.dart';
import 'package:flutter/material.dart';

class WifiInfoWidget extends StatelessWidget {
  final WifiNetwork network;
  final bool enabled;
  final String? warningText;
  final List<Widget>? children;

  const WifiInfoWidget({
    super.key,
    required this.network,
    required this.enabled,
    this.warningText,
    this.children,
  });

  String _convertConnectionStateToKR(
      BuildContext context, WifiNetworkState state) {
    switch (state) {
      case WifiNetworkState.unauthorized:
        return AppL10n.getL10n(context).unauthorized;
      case WifiNetworkState.disconnected:
        return AppL10n.getL10n(context).disconnected;
      case WifiNetworkState.connecting:
        return AppL10n.getL10n(context).connecting;
      case WifiNetworkState.connected:
        return AppL10n.getL10n(context).connected;
      case WifiNetworkState.on:
        return AppL10n.getL10n(context).on;
      case WifiNetworkState.off:
        return AppL10n.getL10n(context).off;
      case WifiNetworkState.unknown:
      default:
        return AppL10n.getL10n(context).unknown;
    }
  }

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
          color: warningText == null && network.ssid != null
              ? Colors.green
              : Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          AppL10n.getL10n(context).wifiConnectionState(
            _convertConnectionStateToKR(context, network.state),
          ),
        ),
        if (warningText != null) Text(warningText!),
        if (warningText == null && network.ssid != null) Text(network.ssid!),
        if (children != null) ...children!,
      ],
    );
  }
}
