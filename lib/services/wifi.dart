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

  static Future<int?> getFrequency() async {
    final frequency = await WiFiForIoTPlugin.getFrequency();
    return frequency;
  }

  static bool isValidFrequency(double targetGHz, int frequency) {
    final isValidGHz =
        targetGHz.isFinite && !targetGHz.isNegative && !targetGHz.isNaN;
    final isValidValue =
        frequency.isFinite && !frequency.isNegative && !frequency.isNaN;

    if (!isValidGHz || !isValidValue) {
      return false;
    }

    final minHertz = targetGHz * 1000;
    final maxHertz = (targetGHz + 1) * 1000 - 1;
    return minHertz <= frequency && frequency <= maxHertz;
  }

  /// throw Exception
  static Future<String> getCurrentWifiSSID() async {
    final accessible = await hasPermission();
    if (!accessible) {
      throw Exception(
        '앱의 위치 권한이 설정되지 않아 SSID를 받아올 수 없습니다.\n와이파이와 관련된 기능을 사용하기 위해, 설정 > 위치에서 권한을 부여해야 합니다.',
      );
    }

    final isConnected = await WiFiForIoTPlugin.isConnected();
    if (!isConnected) {
      throw Exception('현재 연결된 와이파이가 없습니다.');
    }

    final currentWifiSSID = await WiFiForIoTPlugin.getSSID();
    if (currentWifiSSID == null || currentWifiSSID.isEmpty) {
      throw Exception('와이파이의 ssid를 읽을 수 없습니다.');
    }
    if (currentWifiSSID == '<unknown ssid>') {
      throw Exception('연결된 와이파이의 정보를 받아오는 중입니다. 잠시 후 다시 시도하세요.');
    }

    return currentWifiSSID;
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
