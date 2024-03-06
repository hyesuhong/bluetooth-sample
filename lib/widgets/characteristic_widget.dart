import 'dart:async';

import 'package:bluetooth_sample/screens/wifi/wifi_info_screen.dart';
import 'package:bluetooth_sample/utils/wifi.dart';
import 'package:bluetooth_sample/widgets/password_dialog.dart';
import 'package:bluetooth_sample/widgets/subtitle_widget.dart';
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
  final dialogContextCompleter = Completer<BuildContext>();

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();

    _lastValueSubscription = widget.characteristic.lastValueStream.listen(
      (value) {
        _value = value;
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();

    _lastValueSubscription.cancel();
    _closeDialog();
  }

  Future _closeDialog() async {
    final dialogContext = await dialogContextCompleter.future;

    if (!dialogContext.mounted) {
      return;
    }

    Navigator.of(dialogContext).pop();
  }

  Future _onReadPressed() async {
    await widget.characteristic.read();
  }

  _onWriteWifiPressed() {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => const WifiInfoScreen(),
      settings: const RouteSettings(name: '/wifi'),
    );
    Navigator.of(context).push(route);
  }

  // Future _onWriteWifiPressed() async {
  //   bool wifiEnabled = await Wifi.isEnabled();
  //
  //   if (!wifiEnabled) {
  //     if (!context.mounted) {
  //       return;
  //     }
  //
  //     showDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       builder: (context) {
  //         if (!dialogContextCompleter.isCompleted) {
  //           dialogContextCompleter.complete(context);
  //         }
  //
  //         return AlertDialog(
  //           title: const Text('와이파이 활성화'),
  //           content: const Padding(
  //             padding: EdgeInsets.all(16),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   '와이파이가 현재 꺼져있습니다. 설정에서 와이파이 전원을 켜십시오.',
  //                 ),
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('취소'),
  //             ),
  //             TextButton(
  //               onPressed: () async {
  //                 await Wifi.setEnabled(true);
  //                 if (!context.mounted) {
  //                   return;
  //                 }
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('설정 열기'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //     return;
  //   }
  //
  //   String ssid = await Wifi.getCurrentWifiSSID();
  //
  //   if (ssid.isEmpty || !context.mounted) {
  //     return;
  //   }
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       if (!dialogContextCompleter.isCompleted) {
  //         dialogContextCompleter.complete(context);
  //       }
  //
  //       return PasswordDialog(
  //         ssid: ssid,
  //         characteristic: widget.characteristic,
  //       );
  //     },
  //   );
  // }

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

  Widget _buildValueText(List<int> value) {
    final isJSON = value.isNotEmpty && value.first == 123 && value.last == 125;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const SubtitleWidget(title: 'Characteristic\'s value'),
        Text(value.toString()),
        const SizedBox(height: 8),
        const SubtitleWidget(
            title: 'JSON (displayed if the value format is JSON)'),
        if (isJSON) _buildDecodedValueText(_value),
      ],
    );
  }

  Widget _buildDecodedValueText(List<int> value) {
    final decodedValue = value.map((e) => String.fromCharCode(e)).join('');
    return Text(decodedValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Characteristic',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: ' (${widget.characteristic.characteristicUuid.str})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
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
          _buildValueText(_value),
        ],
      ),
    );
  }
}
