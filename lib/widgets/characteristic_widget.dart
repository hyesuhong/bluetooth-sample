import 'dart:async';

import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
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

  Future _onWriteWifiPressed() async {
    bool wifiEnabled = await Wifi.isEnabled();

    if (!wifiEnabled) {
      if (!context.mounted) {
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('와이파이 활성화'),
            content: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '와이파이가 현재 꺼져있습니다. 설정에서 와이파이 전원을 켜십시오.',
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
                  await Wifi.setEnabled(true);
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('설정 열기'),
              ),
            ],
          );
        },
      );
      return;
    }

    String ssid = await Wifi.getCurrentWifiSSID();

    if (ssid.isEmpty || !context.mounted) {
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

  Widget _buildWriteButton() {
    return TextButton(
      onPressed: _onWriteWifiPressed,
      child: const Text('Write(wifi)'),
    );
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
              if (widget.characteristic.properties.write) _buildWriteButton(),
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
