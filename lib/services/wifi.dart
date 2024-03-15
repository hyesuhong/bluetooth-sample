import 'dart:async';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Wifi {
  Wifi._();

  static Stream<bool> enabledState() {
    final controller = StreamController<bool>();
    const duration = Duration(seconds: 1);
    Timer? timer;
    bool? lastValue;

    void getEnabledState(Timer timer) async {
      try {
        final enableState = await isEnabled();

        if (lastValue != enableState) {
          lastValue = enableState;
          controller.add(enableState);
          return;
        }
      } catch (error) {
        controller.close();
      }
    }

    void onListen() {
      timer ??= Timer.periodic(duration, getEnabledState);
    }

    void onResume() {
      // print('resume enabledState stream');
    }

    void onCancel() {
      timer?.cancel();
      timer = null;
    }

    void onPause() {
      timer?.cancel();
    }

    controller.onListen = onListen;
    controller.onCancel = onCancel;
    controller.onResume = onResume;
    controller.onPause = onPause;

    return controller.stream;
  }

  // TODO: connection 체크하는 Stream도 만들기
  // state: notPermitted, connect, disconnect, connecting(<unknown ssid>)
  // return => ConnectionState state & String? ssid

  static Stream<WifiConnection> connectionState() {
    final controller = StreamController<WifiConnection>();
    const duration = Duration(seconds: 1);
    Timer? timer;
    bool? lastValue;

    void getConnectionState(Timer timer) async {
      final isPermitted = await hasPermission();
      if (!isPermitted) {
        const connection =
            WifiConnection(state: WifiConnectionState.unauthorized);
        controller.add(connection);
        return;
      }

      final isConnectedState = await isConnected();
      if (!isConnectedState) {
        const connection =
            WifiConnection(state: WifiConnectionState.disconnected);
        controller.add(connection);
        return;
      }

      final currentSSID = await Wifi.getCurrentWifiSSID();
      if (currentSSID == null) {
        const connection = WifiConnection(state: WifiConnectionState.unknown);
        controller.add(connection);
        return;
      }

      if (currentSSID == '<unknown ssid>') {
        const connection =
            WifiConnection(state: WifiConnectionState.connecting);
        controller.add(connection);
        return;
      }

      controller.add(WifiConnection(
        state: WifiConnectionState.connected,
        ssid: currentSSID,
      ));
      return;
    }

    return controller.stream;
  }

  static Future<bool> isEnabled() {
    return WiFiForIoTPlugin.isEnabled();
  }

  static void setEnabled(bool state) {
    WiFiForIoTPlugin.setEnabled(state, shouldOpenSettings: true);
  }

  static Future<bool> isConnected() {
    return WiFiForIoTPlugin.isConnected();
  }

  static bool _isPositiveNum(num value) {
    return value.isFinite && !value.isNegative && !value.isNaN;
  }

  static Future<int?> getFrequency() {
    return WiFiForIoTPlugin.getFrequency();
  }

  static bool isValidFrequency(double targetGHz, int frequency) {
    final isValidGHz = _isPositiveNum(targetGHz);
    final isValidValue = _isPositiveNum(frequency);

    if (!isValidGHz || !isValidValue) {
      return false;
    }

    final isDecimal = targetGHz % 1 != 0;
    final additionalNum = isDecimal ? 0.1 : 1;

    final minHertz = targetGHz * 1000;
    final maxHertz = (targetGHz + additionalNum) * 1000 - 1;
    return minHertz <= frequency && frequency <= maxHertz;
  }

  static Future<String?> getCurrentWifiSSID() async {
    final currentWifiSSID = await WiFiForIoTPlugin.getSSID();

    return currentWifiSSID == null || currentWifiSSID.isEmpty
        ? null
        : currentWifiSSID;
  }

  static Future<bool> hasPermission() async {
    PermissionStatus? status;

    if (Platform.isAndroid) {
      status = await Permission.location.status;

      if (status.isProvisional || !_canAccess(status)) {
        PermissionStatus requestStatus = await Permission.location.request();
        status = requestStatus;
      }
    }

    return status != null && _canAccess(status);
  }

  static bool _canAccess(PermissionStatus status) {
    return status.isGranted || status.isLimited || status.isProvisional;
  }

  static Future<bool> findAndConnect(String ssid, String? password) {
    return WiFiForIoTPlugin.findAndConnect(ssid, password: password);
  }
}

enum WifiConnectionState {
  unauthorized,
  connected,
  disconnected,
  connecting,
  unknown,
}

class WifiConnection {
  final WifiConnectionState state;
  final String? ssid;

  const WifiConnection({required this.state, this.ssid});
}
