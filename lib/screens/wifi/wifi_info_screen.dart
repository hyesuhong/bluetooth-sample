import 'package:bluetooth_sample/screens/wifi/wifi_connection_screen.dart';
import 'package:bluetooth_sample/services/wifi.dart';
import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class WifiInfoScreen extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  const WifiInfoScreen({
    super.key,
    required this.characteristic,
  });

  @override
  State<WifiInfoScreen> createState() => _WifiInfoScreenState();
}

class _WifiInfoScreenState extends State<WifiInfoScreen> {
  bool _wifiEnabled = false;
  bool _hasPassword = false;
  String _password = '';
  String? _wifiSSID;

  FocusNode focusInputNode = FocusNode();

  bool get _canPush =>
      _wifiSSID != null &&
      (!_hasPassword || (_hasPassword && _password.isNotEmpty));

  @override
  void initState() {
    super.initState();

    if (mounted) {
      _checkCurrentWifi();
    }
  }

  @override
  void dispose() {
    focusInputNode.dispose();
    super.dispose();
  }

  Future _checkCurrentWifi() async {
    bool isEnabled = await Wifi.isEnabled();
    String? ssid;
    bool hasPassword = _hasPassword;
    bool mustReset = false;

    try {
      if (isEnabled) {
        final frequency = await Wifi.getFrequency();
        final is2_4GHz =
            frequency != null && Wifi.isValidFrequency(2.4, frequency);

        if (!is2_4GHz) {
          throw Exception(
            'IoT 기기는 2.4GHz의 와이파이만 사용할 수 있습니다.\n이름 뒤에 [2G] 혹은 [2.4G]가 있는 와이파이를 선택하십시오.',
          );
        }

        ssid = await Wifi.getCurrentWifiSSID();
      } else {
        ssid = null;
        hasPassword = false;
        mustReset = true;
      }
    } catch (exception) {
      SnackBarAction action = SnackBarAction(
        label: '설정',
        textColor: Colors.white,
        onPressed: () {
          Wifi.setEnabled(true);
        },
      );

      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: exception.toString(),
        duration: const Duration(seconds: 5),
        action: action,
      );

      hasPassword = false;
      mustReset = true;
    } finally {
      if (mounted) {
        setState(() {
          _wifiEnabled = isEnabled;
          _wifiSSID = ssid;
          _hasPassword = hasPassword;

          if (mustReset) {
            _password = '';
          }
        });
      }
    }
  }

  Widget _buildCheckPassword() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: CheckboxListTile(
        value: _hasPassword,
        onChanged: (value) {
          if (value == null) {
            return;
          }

          setState(() {
            _hasPassword = value;
            if (!value) {
              _password = '';
            }
          });
        },
        title: const Text('비밀번호 사용 여부'),
      ),
    );
  }

  Widget _buildWifiSetting() {
    return Column(
      children: [
        const Text('와이파이 전원이 꺼져있습니다. 설정에서 와이파이를 활성화하십시오.'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                _checkCurrentWifi();
              },
              child: const Text('연결 확인'),
            ),
            TextButton(
              onPressed: () {
                Wifi.setEnabled(true);
              },
              child: const Text('설정'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextField(
        focusNode: focusInputNode,
        obscureText: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '비밀번호',
        ),
        onChanged: (String value) {
          setState(() {
            _password = value;
          });
        },
      ),
    );
  }

  Future _onPushPressed() async {
    if (_wifiSSID == null) {
      return;
    }

    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => WifiConnectionScreen(
        ssid: _wifiSSID!,
        password: _password,
        characteristic: widget.characteristic,
      ),
      settings: const RouteSettings(name: '/wifi/connection'),
    );
    Navigator.of(context).push(route);

    if (focusInputNode.hasFocus) {
      focusInputNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('와이파이 정보'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '와이파이 정보를 전달하기 위해 현재 연결된 와이파이를 확인합니다.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Icon(
                      _wifiEnabled ? Icons.wifi : Icons.wifi_off,
                      size: 64,
                      color: _wifiEnabled ? Colors.green : Colors.red[800],
                    ),
                    const SizedBox(height: 16),
                    if (_wifiSSID != null) Text(_wifiSSID!),
                    const SizedBox(height: 40),
                    _wifiEnabled ? _buildCheckPassword() : _buildWifiSetting(),
                    if (_hasPassword) _buildPasswordInput(),
                  ],
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _canPush ? _onPushPressed : null,
                child: const Text('다음'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          _checkCurrentWifi();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
