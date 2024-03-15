import 'dart:async';

import 'package:bluetooth_sample/screens/wifi/wifi_connection_screen.dart';
import 'package:bluetooth_sample/services/wifi.dart';
import 'package:bluetooth_sample/utils/app_l10n.dart';
import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
import 'package:bluetooth_sample/widgets/common/button.dart';
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

  late StreamSubscription<bool> _wifiEnabledStateSubscription;

  bool get _canPush =>
      _wifiSSID != null &&
      (!_hasPassword || (_hasPassword && _password.isNotEmpty));

  @override
  void initState() {
    super.initState();

    _wifiEnabledStateSubscription = Wifi.enabledState().listen((state) {
      if (mounted) {
        setState(() {
          _wifiEnabled = state;
        });
      }

      if (state) {
        _checkCurrentWifi();
        return;
      }
      _resetWifiInfo();
    }, onError: (error) {
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
    });
  }

  @override
  void dispose() {
    focusInputNode.dispose();
    _wifiEnabledStateSubscription.cancel();

    super.dispose();
  }

  void _resetWifiInfo() {
    setState(() {
      _wifiSSID = null;
      _hasPassword = false;
      _password = '';
    });
  }

  Future _checkCurrentWifi() async {
    String? ssid;
    bool hasPassword = _hasPassword;
    bool mustReset = false;

    try {
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
      if (context.mounted) {
        CustomSnackBar.show(
          status: SnackBarStatus.error,
          message: exception.toString(),
          duration: const Duration(seconds: 5),
          action: CustomSnackBarAction(
            label: AppL10n.getL10n(context).setting,
            onPressed: () {
              Wifi.setEnabled(true);
            },
          ),
        );
      }

      hasPassword = false;
      mustReset = true;
    } finally {
      if (mounted) {
        setState(() {
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
                    if (_wifiSSID != null) _buildCheckPassword(),
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
              child: Button(
                type: ButtonType.filled,
                onPressed: _canPush ? _onPushPressed : null,
                child: Text(AppL10n.getL10n(context).next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
