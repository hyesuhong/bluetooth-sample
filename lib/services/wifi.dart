import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Wifi {
  Wifi._();

  static Future<bool> isEnabled() async {
    bool wifiEnabled = await WiFiForIoTPlugin.isEnabled();

    return wifiEnabled;
  }

  static Future setEnabled(bool state) async {
    await WiFiForIoTPlugin.setEnabled(state, shouldOpenSettings: true);
  }

  static Future<bool> isConnected() async {
    return await WiFiForIoTPlugin.isConnected();
  }

  static bool _isPositiveNum(num value) {
    return value.isFinite && !value.isNegative && !value.isNaN;
  }

  static Future<int?> getFrequency() async {
    final frequency = await WiFiForIoTPlugin.getFrequency();
    return frequency;
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

  static Future<bool> findAndConnect(String ssid, String? password) async {
    await disconnect();

    final response =
        await WiFiForIoTPlugin.findAndConnect(ssid, password: password);

    if (response) {
      await WiFiForIoTPlugin.forceWifiUsage(true);
    }

    return response;
  }

  static Future<void> disconnect() async {
    await WiFiForIoTPlugin.disconnect();

    await WiFiForIoTPlugin.forceWifiUsage(false);
  }
}
