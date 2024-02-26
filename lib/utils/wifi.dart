import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// { “ssid” : “value”, “pwd” : “value” }
class WifiInformation {
  final String name;
  final String bssid;
  final String password;

  WifiInformation(
      {required this.name, required this.bssid, required this.password});
}

class Wifi {
  Wifi();

  /// throw
  static getWifiInformation() async {
    try {
      PermissionStatus? status = await _permissionWifi();
      print(status);

      if (status == null) {
        throw Exception('Cannot get permission status');
      }

      if (status.isPermanentlyDenied ||
          status.isRestricted ||
          status.isDenied) {
        throw Exception('Permission is denied');
      }

      if (status.isGranted || status.isLimited || status.isProvisional) {
        NetworkInfo info = NetworkInfo();
        String? wifiName = await info.getWifiName();
        String? wifiBSSID = await info.getWifiBSSID();

        print(wifiName);
        print(wifiBSSID);
      }
    } catch (error) {
      print(error);
    }

    // return wifi;
  }

  static Future<PermissionStatus?> _permissionWifi() async {
    PermissionStatus? status;

    if (Platform.isAndroid) {
      status = await Permission.location.status;

      if (status.isPermanentlyDenied) {
        print(
            'permission is permanently denied. If you want to use this function, go setting');
      } else if (status.isDenied ||
          status.isRestricted ||
          status.isProvisional) {
        PermissionStatus requestStatus = await Permission.location.request();

        if (requestStatus.isGranted || requestStatus.isLimited) {
          status = requestStatus;
        } else {
          print('permission is not granted');
        }
      }
      print('Android location status: $status');
    } else if (Platform.isIOS) {
      status = await Permission.location.status;

      if (status.isPermanentlyDenied) {
        print(
            'permission is permanently denied. If you want to use this function, go setting');
      } else if (status.isDenied ||
          status.isRestricted ||
          status.isProvisional) {
        PermissionStatus requestStatus = await Permission.location.request();

        if (requestStatus.isGranted || requestStatus.isLimited) {
          status = requestStatus;
        } else {
          print('permission is not granted');
        }
      }

      print('Ios location status: $status');
    }

    return status;
  }
}
