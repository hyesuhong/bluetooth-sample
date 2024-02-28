import 'dart:async';

import 'package:bluetooth_sample/utils/wifi.dart';
import 'package:bluetooth_sample/widgets/password_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class CharacteristicWidget extends StatefulWidget {
  final BluetoothCharacteristic characteristic;

  const CharacteristicWidget({super.key, required this.characteristic});

  @override
  State<StatefulWidget> createState() {
    return _CharacteristicWidgetState();
  }
}

class _CharacteristicWidgetState extends State<CharacteristicWidget> {
  List<int> _value = [];

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();

    _lastValueSubscription =
        widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      print('uuid: ${widget.characteristic.uuid}, value: $value');
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();

    super.dispose();
  }

  Future _onReadPressed() async {
    await widget.characteristic.read();
  }

  Future _onWriteUserInfoPressed() async {
    var bandUserInfo = _getPersonalInfo();

    try {
      await widget.characteristic.write(bandUserInfo, withoutResponse: false);
    } catch (error) {
      print(error);
    }
  }

  Future _onWriteWifiPressed() async {
    bool wifiEnabled = await Wifi.isEnabled();

    if (!wifiEnabled) {
      print('Wifi is turned off. Please turn on Wifi.');
      return;
    }

    String ssid = await Wifi.getCurrentWifiSSID();

    if (ssid.isEmpty) {
      print('Cannot get ssid');
      return;
    }

    if (!context.mounted) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PasswordDialog(
        ssid: ssid,
        characteristic: widget.characteristic,
      ),
    );
  }

  List<Widget> _buildWriteButtons() {
    return [
      TextButton(
        onPressed: _onWriteUserInfoPressed,
        child: const Text('Write getting user info'),
      ),
      TextButton(
        onPressed: _onWriteWifiPressed,
        child: const Text('Write wifi'),
      ),
    ];
  }

  Future _onSubscribePressed() async {
    await widget.characteristic.setNotifyValue(true);

    if (mounted) {
      setState(() {});
    }
  }

  Future _onUnsubscribePressed() async {
    await widget.characteristic.setNotifyValue(false);

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildSubscribeButton() {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
      onPressed: isNotifying ? _onUnsubscribePressed : _onSubscribePressed,
      child: Text(isNotifying ? 'Unsubscribe' : 'Subscribe'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Characteristic'),
          Text(widget.characteristic.characteristicUuid.str),
          Row(
            children: [
              if (widget.characteristic.properties.read)
                TextButton(
                  onPressed: _onReadPressed,
                  child: const Text('Read'),
                ),
              if (widget.characteristic.properties.write)
                ..._buildWriteButtons(),
              if (widget.characteristic.properties.notify ||
                  widget.characteristic.properties.indicate)
                _buildSubscribeButton(),
            ],
          ),
          Text(_value.toString()),
        ],
      ),
    );
  }
}

// LNB1: Get User Personal Information
const CMD_GET_USERINFO = 0x42;
List<int> _getPersonalInfo() {
  List<int> value = List.filled(16, 0);
  value[0] = CMD_GET_USERINFO;
  var crc = _crcValue(value);
  value[value.length - 1] = crc;

  return value;
}

int _crcValue(List<int> value) {
  int crc = 0;
  for (var i = 0; i < value.length - 1; i++) {
    crc += value[i];
  }

  return crc & 0xff;
}
