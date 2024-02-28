import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Wifi {
  static Future<bool> isEnabled() async {
    bool wifiEnabled = await WiFiForIoTPlugin.isEnabled();

    return wifiEnabled;
  }

  static setEnabled(bool state) async {
    await WiFiForIoTPlugin.setEnabled(state, shouldOpenSettings: true);
  }

  static Future<String> getCurrentWifiSSID() async {
    String ssid = '';
    try {
      PermissionStatus? status = await getPermissionWifi();
      if (status == null) {
        throw Exception('앱의 위치 권한 상태를 가져올 수 없습니다.');
      }

      if (!_canAccess(status)) {
        throw Exception('위치 권한이 거부되었습니다.');
      }

      var curWifiSSID = await WiFiForIoTPlugin.getSSID();

      if (curWifiSSID == null) {
        throw Exception('현재 와이파이의 ssid 값을 가져올 수 없습니다.');
      }

      ssid = curWifiSSID;
    } catch (error) {
      print(error);
    }

    return ssid;
  }

  static Future<PermissionStatus?> getPermissionWifi() async {
    PermissionStatus? status;

    if (Platform.isAndroid) {
      status = await Permission.location.status;

      if (status.isPermanentlyDenied) {
        print(
            '위치 권한이 영구적으로 거부되었습니다. 와이파이와 관련된 기능을 사용하고 싶다면, 설정 > 위치에서 권한을 부여하십시오.');
      } else if (status.isProvisional || !_canAccess(status)) {
        PermissionStatus requestStatus = await Permission.location.request();

        if (!_canAccess(requestStatus)) {
          print('위치 권한을 얻지 못했습니다.');
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
      print('connect error: $error');
    }

    return isSuccess;
  }

  static Future<void> disconnect() async {
    final response = await WiFiForIoTPlugin.disconnect();

    await WiFiForIoTPlugin.forceWifiUsage(false);
  }
}
