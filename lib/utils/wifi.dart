import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Wifi {
  static Future<bool> isEnabled() async {
    bool wifiEnabled = await WiFiForIoTPlugin.isEnabled();

    return wifiEnabled;
  }

  static Future<String> getCurrentWifiSSID() async {
    String ssid = '';
    try {
      PermissionStatus? status = await getPermissionWifi();
      if (status == null) {
        throw Exception('Cannot get permission status');
      }

      if (!_canAccess(status)) {
        throw Exception('Location Permission is denied');
      }

      var curWifiSSID = await WiFiForIoTPlugin.getSSID();

      if (curWifiSSID == null) {
        throw Exception('Cannot get current wifi ssid');
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
            'Location permission is permanently denied. If you want to use wifi feature, change location setting.');
      } else if (status.isProvisional || !_canAccess(status)) {
        PermissionStatus requestStatus = await Permission.location.request();

        if (!_canAccess(requestStatus)) {
          print('Location permission is not granted.');
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
        throw Exception('Cannot connect to $ssid. Please check password.');
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
    print('wifi disconnection request result: $response');

    await WiFiForIoTPlugin.forceWifiUsage(false);
  }
}
