import 'dart:async';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Wifi {
  static const String _unknownSSID = 'unknown ssid';
  static const _timerDuration = Duration(seconds: 1);

  static final StreamController<WifiNetwork> _stateStreamController =
      StreamController.broadcast(
    onListen: _stateStreamOnListen,
    onCancel: _stateStreamOnCancel,
  );
  static Timer? _stateTimer;
  static WifiNetwork _lastWifiNetwork =
      const WifiNetwork(state: WifiNetworkState.unknown);

  static Stream<WifiNetwork> get currentNetwork => _currentNetwork();

  Wifi._();

  static Stream<WifiNetwork> _currentNetwork() {
    return _stateStreamController.stream;
  }

  static void _getWifiNetwork() async {
    try {
      final enableState = await isEnabled();

      if (!enableState && _lastWifiNetwork.state != WifiNetworkState.off) {
        const state = WifiNetwork(state: WifiNetworkState.off);
        _lastWifiNetwork = state;
        _stateStreamController.add(state);

        return;
      }

      if (_lastWifiNetwork.state == WifiNetworkState.off) {
        const state = WifiNetwork(state: WifiNetworkState.on);
        _lastWifiNetwork = state;
        _stateStreamController.add(state);
      }

      final isPermitted = await hasPermission();
      if (!isPermitted &&
          _lastWifiNetwork.state != WifiNetworkState.unauthorized) {
        const state = WifiNetwork(state: WifiNetworkState.unauthorized);
        _lastWifiNetwork = state;
        _stateStreamController.add(state);

        return;
      }

      final isConnectedState = await isConnected();
      if (!isConnectedState &&
          _lastWifiNetwork.state != WifiNetworkState.disconnected) {
        const state = WifiNetwork(state: WifiNetworkState.disconnected);
        _lastWifiNetwork = state;
        _stateStreamController.add(state);

        return;
      }

      final currentSSID = await Wifi.getCurrentWifiSSID();
      if (currentSSID == null &&
          _lastWifiNetwork.state != WifiNetworkState.unknown) {
        const state = WifiNetwork(state: WifiNetworkState.unknown);
        _lastWifiNetwork = state;
        _stateStreamController.add(state);

        return;
      }

      if (currentSSID!.contains(_unknownSSID) &&
          _lastWifiNetwork.state != WifiNetworkState.connecting) {
        const state = WifiNetwork(state: WifiNetworkState.connecting);
        _lastWifiNetwork = state;
        _stateStreamController.add(state);

        return;
      }

      final state =
          WifiNetwork(state: WifiNetworkState.connected, ssid: currentSSID);

      if (_lastWifiNetwork.state != state.state ||
          _lastWifiNetwork.ssid != state.ssid) {
        _lastWifiNetwork = state;
        _stateStreamController.add(state);
      }
    } catch (e) {
      _stateStreamController.addError(e);
      _stateStreamController.close();
    }
  }

  static void _stateStreamOnListen() {
    _stateTimer ??= Timer.periodic(_timerDuration, (timer) {
      _getWifiNetwork();
    });
  }

  static void _stateStreamOnCancel() {
    if (!_stateStreamController.hasListener) {
      _stateTimer?.cancel();
      _stateTimer = null;

      _lastWifiNetwork = const WifiNetwork(state: WifiNetworkState.unknown);
    }
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

enum WifiNetworkState {
  unauthorized,
  connected,
  disconnected,
  connecting,
  unknown,
  on,
  off,
}

class WifiNetwork {
  final WifiNetworkState state;
  final String? ssid;

  const WifiNetwork({required this.state, this.ssid});

  @override
  String toString() {
    return 'WifiNetwork: state - ${state.name} | ssid - $ssid';
  }
}
