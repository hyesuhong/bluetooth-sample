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

  String _convertConnectionStateToKR(
      BuildContext context, WifiConnectionState state) {
    switch (state) {
      case WifiConnectionState.unauthorized:
        return AppL10n.getL10n(context).unauthorized;
      case WifiConnectionState.disconnected:
        return AppL10n.getL10n(context).disconnected;
      case WifiConnectionState.connecting:
        return AppL10n.getL10n(context).connecting;
      case WifiConnectionState.connected:
        return AppL10n.getL10n(context).connected;
      case WifiConnectionState.unknown:
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
          color: warningText == null && state.ssid != null
              ? Colors.green
              : Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          AppL10n.getL10n(context).wifiConnectionState(
            _convertConnectionStateToKR(context, state.state),
          ),
        ),
        if (warningText != null) Text(warningText!),
        if (warningText == null && state.ssid != null) Text(state.ssid!),
        if (children != null) ...children!,
      ],
    );
  }
}
