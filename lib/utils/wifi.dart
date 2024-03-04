import 'dart:io';

import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Wifi {
  static const _MIN_HERTZ = 2400;
  static const _MAX_HERTZ = 2462;

  static Future<bool> isEnabled() async {
    bool wifiEnabled = await WiFiForIoTPlugin.isEnabled();

    return wifiEnabled;
  }

  static setEnabled(bool state) async {
    await WiFiForIoTPlugin.setEnabled(state, shouldOpenSettings: true);
  }

  static _is2_4GHZ(int frequency) {
    return frequency <= _MAX_HERTZ && frequency >= _MIN_HERTZ;
  }

  static Future<String> getCurrentWifiSSID() async {
    String ssid = '';
    try {
      PermissionStatus? status = await getPermissionWifi();
      if (status == null) {
        throw WifiException(message: '앱의 위치 권한 상태를 가져올 수 없습니다.');
      }

      if (!_canAccess(status)) {
        throw WifiException(message: '위치 권한이 거부되었습니다.');
      }

      final isConnected = await WiFiForIoTPlugin.isConnected();
      if (!isConnected) {
        throw WifiException(
          message:
              '연결된 와이파이가 없습니다.\n와이파이가 자동으로 연결될 때까지 기다린 뒤 다시 시도하거나, 설정에서 와이파이를 연결하십시오.',
          shouldOpenSettings: true,
        );
      }

      final frequency = await WiFiForIoTPlugin.getFrequency();
      if (frequency == null || !_is2_4GHZ(frequency)) {
        throw WifiException(
          message:
              'IoT 기기는 2.4GHz의 와이파이만 사용할 수 있습니다.\n이름 뒤에 [2G] 혹은 [2.4G]가 있는 와이파이를 선택하십시오.',
          shouldOpenSettings: true,
        );
      }

      final curWifiSSID = await WiFiForIoTPlugin.getSSID();

      if (curWifiSSID == null) {
        throw WifiException(message: '현재 와이파이의 ssid 값을 가져올 수 없습니다.');
      } else {
        if (curWifiSSID.isEmpty) {
          throw WifiException(message: 'ssid를 가져올 수 없습니다.');
        } else if (curWifiSSID == '<unknown ssid>') {
          throw WifiException(
              message: '연결된 와이파이의 정보를 정확히 가져오지 못했습니다. 잠시 후 다시 시도해주십시오.');
        }
      }

      ssid = curWifiSSID;
    } on WifiException catch (error) {
      SnackBarAction action = SnackBarAction(
        label: '설정',
        textColor: Colors.white,
        onPressed: () {
          WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
        },
      );

      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
        duration: const Duration(seconds: 5),
        action: error.shouldOpenSettings ? action : null,
      );
    } catch (error) {
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
    }

    return ssid;
  }

  static Future<PermissionStatus?> getPermissionWifi() async {
    PermissionStatus? status;

    if (Platform.isAndroid) {
      status = await Permission.location.status;

      if (status.isPermanentlyDenied) {
        CustomSnackBar.show(
          status: SnackBarStatus.error,
          message:
              '위치 권한이 영구적으로 거부되었습니다. 와이파이와 관련된 기능을 사용하고 싶다면, 설정 > 위치에서 권한을 부여하십시오.',
        );
      } else if (status.isProvisional || !_canAccess(status)) {
        PermissionStatus requestStatus = await Permission.location.request();

        if (!_canAccess(requestStatus)) {
          CustomSnackBar.show(
            status: SnackBarStatus.error,
            message: '위치 권한을 얻지 못했습니다.',
          );
        } else {
          status = requestStatus;
        }
      }
    }

    return status;
  }

  static bool _canAccess(PermissionStatus status) {
    return status.isGranted || status.isLimited || status.isProvisional;
  }

  static Future<bool> connectWithResponse(String ssid, String? password) async {
    bool isSuccess = false;

    try {
      await disconnect();

      final response = await WiFiForIoTPlugin.connect(ssid,
          password: password, security: NetworkSecurity.WPA);

      if (!response) {
        throw Exception('$ssid 에 연결할 수 없습니다. 입력한 비밀번호를 확인하십시오.');
      }

      isSuccess = response;

      await WiFiForIoTPlugin.forceWifiUsage(true);
    } catch (error) {
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
    }

    return isSuccess;
  }

  static Future<void> disconnect() async {
    await WiFiForIoTPlugin.disconnect();

    await WiFiForIoTPlugin.forceWifiUsage(false);
  }
}

class WifiException implements Exception {
  final String message;
  final bool shouldOpenSettings;

  WifiException({required this.message, this.shouldOpenSettings = false});

  @override
  String toString() => 'Wifi Exception: $message';
}
