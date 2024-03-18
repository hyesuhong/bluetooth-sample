import 'dart:async';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

abstract class Wifi {
  static const String _unknownSSID = '<unknown ssid>';
  Wifi._();

  static Stream<bool> get enabledState => _enabledState();
  static Stream<WifiConnection> get connectionState => _connectionState();

  static Stream<bool> _enabledState() {
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
        controller.addError(error);
        controller.close();
      }
    }

    void onListen() {
      timer ??= Timer.periodic(duration, getEnabledState);
    }

    void onCancel() {
      timer?.cancel();
      timer = null;

      if (!controller.isClosed) {
        controller.close();
      }
    }

    controller.onListen = onListen;
    controller.onCancel = onCancel;

    return controller.stream;
  }

  static Stream<WifiConnection> _connectionState() {
    final controller = StreamController<WifiConnection>();
    const duration = Duration(seconds: 1);
    Timer? timer;
    WifiConnection lastValue =
        const WifiConnection(state: WifiConnectionState.unknown);

    void getConnectionState(Timer timer) async {
      final isPermitted = await hasPermission();
      if (!isPermitted) {
        const connection =
            WifiConnection(state: WifiConnectionState.unauthorized);

        if (lastValue.state != connection.state) {
          lastValue = connection;
          controller.add(connection);
        }
        return;
      }

      final isConnectedState = await isConnected();
      if (!isConnectedState) {
        const connection =
            WifiConnection(state: WifiConnectionState.disconnected);

        if (lastValue.state != connection.state) {
          lastValue = connection;
          controller.add(connection);
        }
        return;
      }

      final currentSSID = await Wifi.getCurrentWifiSSID();
      if (currentSSID == null) {
        const connection = WifiConnection(state: WifiConnectionState.unknown);

        if (lastValue.state != connection.state) {
          lastValue = connection;
          controller.add(connection);
        }
        return;
      }

      if (currentSSID == _unknownSSID) {
        const connection =
            WifiConnection(state: WifiConnectionState.connecting);

        if (lastValue.state != connection.state) {
          lastValue = connection;
          controller.add(connection);
        }
        return;
      }

      final connection = WifiConnection(
        state: WifiConnectionState.connected,
        ssid: currentSSID,
      );

      if (lastValue.state != connection.state ||
          lastValue.ssid != connection.ssid) {
        lastValue = connection;
        controller.add(connection);
        return;
      }
    }

    void onListen() {
      timer ??= Timer.periodic(duration, getConnectionState);
    }

    void onCancel() {
      timer?.cancel();
      timer = null;

      if (!controller.isClosed) {
        controller.close();
      }
    }

    void onResume() {
      timer ??= Timer.periodic(duration, getConnectionState);
    }

    void onPause() {
      timer?.cancel();
      timer = null;
    }

    controller.onListen = onListen;
    controller.onCancel = onCancel;
    controller.onResume = onResume;
    controller.onPause = onPause;

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

  @override
  String toString() {
    return 'WifiConnection: state - ${state.name} | ssid - $ssid';
  }
}
