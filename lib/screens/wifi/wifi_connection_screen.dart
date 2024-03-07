import 'dart:convert';

import 'package:bluetooth_sample/services/wifi.dart';
import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
import 'package:bluetooth_sample/widgets/wifi_result_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class WifiConnectionScreen extends StatefulWidget {
  final String ssid;
  final String password;
  final BluetoothCharacteristic characteristic;
  const WifiConnectionScreen({
    super.key,
    required this.ssid,
    required this.password,
    required this.characteristic,
  });

  @override
  State<WifiConnectionScreen> createState() => _WifiConnectionScreenState();
}

class _WifiConnectionScreenState extends State<WifiConnectionScreen> {
  bool _isLoading = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();

    _findAndConnect();
  }

  Future _findAndConnect() async {
    try {
      bool result = await Wifi.findAndConnect(widget.ssid, widget.password);

      if (mounted) {
        setState(() {
          _isSuccess = result;
        });
      }
    } catch (error) {
      print(error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future _onSendPressed() async {
    final wifiInfo = {'ssid': widget.ssid, 'pwd': widget.password};
    final encodedWifiInfo = jsonEncode(wifiInfo);
    final utf16WifiInfo = encodedWifiInfo.codeUnits;

    try {
      await widget.characteristic.write(utf16WifiInfo);

      if (context.mounted) {
        Navigator.popUntil(context, ModalRoute.withName('/DeviceScreen'));
      }
    } catch (error) {
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
    }
  }

  void _onPopPressed() {
    Navigator.of(context).pop();
  }

  Widget _buildIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(),
        ),
        const SizedBox(height: 16),
        Text('${widget.ssid} 정보 확인중'),
      ],
    );
  }

  Widget _buildResultWidget(bool isSuccess) {
    final message = isSuccess
        ? '${widget.ssid} 확인이 완료되었습니다. 기기에 와이파이 정보를 전송하겠습니까?'
        : '입력하신 ${widget.ssid} 정보가 정확하지 않습니다. 입력 화면으로 돌아갑니다.';

    return Column(
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: WifiResultWidget(
              isSuccess: isSuccess,
              message: message,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 400),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: isSuccess ? _onSendPressed : _onPopPressed,
            child: Text(isSuccess ? '전송' : '뒤로'),
          ),
        )
      ],
    );
  }

  Widget _buildBody() {
    return _isLoading ? _buildIndicator() : _buildResultWidget(_isSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: _buildBody(),
        ),
      ),
    );
  }
}
