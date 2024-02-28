import 'dart:convert';

import 'package:bluetooth_sample/utils/wifi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class PasswordDialog extends StatefulWidget {
  final String ssid;
  final BluetoothCharacteristic characteristic;

  const PasswordDialog({
    super.key,
    required this.ssid,
    required this.characteristic,
  });

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  String password = '';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('와이파이 비밀번호 입력'),
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('와이파이에 대한 정보를 전달하기 위해, 현재 와이파이의 비밀번호를 입력해주세요.'),
            const SizedBox(height: 16),
            Text(
              widget.ssid,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '비밀번호',
              ),
              onChanged: (String value) {
                password = value;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            bool isSuccessConnect =
                await Wifi.connectWithResponse(widget.ssid, password);

            if (isSuccessConnect) {
              final wifiInfo = {'ssid': widget.ssid, 'pwd': password};
              final encodedWifiInfo = jsonEncode(wifiInfo);
              final utf16WifiInfo = encodedWifiInfo.codeUnits;

              await widget.characteristic.write(utf16WifiInfo);
            }

            if (!context.mounted) {
              return;
            }

            Navigator.of(context).pop();
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}
