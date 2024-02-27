import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class Wifi {
  static getCurrentWifiInformation() async {
    try {
      PermissionStatus? status = await getPermissionWifi();
      if (status == null) {
        throw Exception('Cannot get permission status');
      }

      if (!_canAccess(status)) {
        throw Exception('Location Permission is denied');
      }

      print(await WiFiForIoTPlugin.isEnabled());

      var curWifiSSID = await WiFiForIoTPlugin.getSSID();

      print(curWifiSSID);

      var wifiList = await WiFiForIoTPlugin.loadWifiList();
    } catch (error) {
      print(error);
    }
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
}
