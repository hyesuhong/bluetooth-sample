import 'dart:async';

import 'package:bluetooth_sample/screens/wifi/wifi_connection_screen.dart';
import 'package:bluetooth_sample/services/wifi.dart';
import 'package:bluetooth_sample/utils/app_l10n.dart';
import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
import 'package:bluetooth_sample/widgets/common/button.dart';
import 'package:bluetooth_sample/widgets/wifi/wifi_info_widget.dart';
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
  WifiConnection _connectionState = const WifiConnection(
    state: WifiConnectionState.unknown,
  );
  bool _is2_4GHz = false;

  FocusNode focusInputNode = FocusNode();

  late StreamSubscription<bool> _wifiEnabledStateSubscription;
  StreamSubscription<WifiConnection>? _wifiConnectionSubscription;

  bool get _canUsePassword =>
      _connectionState.state == WifiConnectionState.connected && _is2_4GHz;

  bool get _canPush =>
      _canUsePassword &&
      (!_hasPassword || (_hasPassword && _password.isNotEmpty));

  @override
  void initState() {
    super.initState();

    _wifiEnabledStateSubscription = Wifi.enabledState.listen((state) {
      if (mounted) {
        setState(() {
          _wifiEnabled = state;
        });
      }

      if (state) {
        if (_wifiConnectionSubscription == null ||
            !_wifiConnectionSubscription!.isPaused) {
          _wifiConnectionSubscription ??=
              Wifi.connectionState.listen(_checkCurrentWifi);
          return;
        }

        _wifiConnectionSubscription?.resume();
        return;
      }

      _wifiConnectionSubscription?.pause();

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
    _wifiConnectionSubscription?.cancel();

    super.dispose();
  }

  void _resetWifiInfo() {
    setState(() {
      _hasPassword = false;
      _password = '';
      _connectionState = const WifiConnection(
        state: WifiConnectionState.unknown,
      );
      _is2_4GHz = false;
    });
  }

  Future<bool> _checkWifiFrequency() async {
    final frequency = await Wifi.getFrequency();
    final is2_4GHz = frequency != null && Wifi.isValidFrequency(2.4, frequency);

    return is2_4GHz;
  }

  _checkCurrentWifi(WifiConnection state) async {
    bool is2_4GHz = false;

    if (state.state != WifiConnectionState.connected) {
      _resetWifiInfo();
      return;
    }

    is2_4GHz = await _checkWifiFrequency();

    setState(() {
      _connectionState = state;
      _is2_4GHz = is2_4GHz;
    });
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
    if (_connectionState.state != WifiConnectionState.connected) {
      return;
    }

    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => WifiConnectionScreen(
        ssid: _connectionState.ssid!,
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
                child: WifiInfoWidget(
                  enabled: _wifiEnabled,
                  state: _connectionState,
                  warningText:
                      _connectionState.state == WifiConnectionState.connected &&
                              !_is2_4GHz
                          ? AppL10n.getL10n(context).not2_4GHz
                          : null,
                  children: [
                    const SizedBox(height: 40),
                    if (_canUsePassword) _buildCheckPassword(),
                    if (_canUsePassword && _hasPassword) _buildPasswordInput(),
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
