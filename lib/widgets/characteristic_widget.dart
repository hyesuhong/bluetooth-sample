import 'dart:async';

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

  Future _onWritePressed() async {
    var bandUserInfo = _getPersonalInfo();

    try {
      await widget.characteristic.write(bandUserInfo, withoutResponse: false);
      print(_value);
    } catch (error) {
      print(error);
    }
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
                TextButton(
                  onPressed: _onWritePressed,
                  child: const Text('Write'),
                ),
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
