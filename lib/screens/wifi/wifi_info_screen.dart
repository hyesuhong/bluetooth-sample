import 'package:bluetooth_sample/screens/wifi/wifi_connection_screen.dart';
import 'package:bluetooth_sample/services/wifi.dart';
import 'package:bluetooth_sample/utils/app_l10n.dart';
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
      if (!isEnabled) {
        ssid = null;
        hasPassword = false;
        mustReset = true;
        return;
      }

      final isPermitted = await Wifi.hasPermission();
      if (!isPermitted && context.mounted) {
        throw Exception(AppL10n.getL10n(context).notPermitted);
      }

      final isConnected = await Wifi.isConnected();
      if (!isConnected && context.mounted) {
        throw Exception(AppL10n.getL10n(context).noneConnectedWifi);
      }

      final frequency = await Wifi.getFrequency();
      final is2_4GHz =
          frequency != null && Wifi.isValidFrequency(2.4, frequency);

      if (!is2_4GHz && context.mounted) {
        throw Exception(
          AppL10n.getL10n(context).not2_4GHz,
        );
      }

      final currentSSID = await Wifi.getCurrentWifiSSID();
      if (!context.mounted) {
        return;
      }
      if (currentSSID == null) {
        throw Exception(AppL10n.getL10n(context).cannotReadSsid);
      }
      if (currentSSID == '<unknown ssid>') {
        throw Exception(AppL10n.getL10n(context).unknownSsid);
      }

      ssid = currentSSID;
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
        title: Text(AppL10n.getL10n(context).passwordUsage),
      ),
    );
  }

  Widget _buildWifiSetting() {
    return Column(
      children: [
        Text(AppL10n.getL10n(context).alertTurnOnWifi),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                _checkCurrentWifi();
              },
              child: Text(AppL10n.getL10n(context).checkConnection),
            ),
            TextButton(
              onPressed: () {
                Wifi.setEnabled(true);
              },
              child: Text(AppL10n.getL10n(context).setting),
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
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: AppL10n.getL10n(context).password,
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
        title: Text(AppL10n.getL10n(context).wifiInfo),
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
                    Text(
                      AppL10n.getL10n(context).alertConnectWifi,
                      style: const TextStyle(
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
                child: Text(AppL10n.getL10n(context).next),
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
