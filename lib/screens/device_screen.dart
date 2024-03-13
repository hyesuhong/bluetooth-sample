import 'dart:async';
import 'dart:io';

import 'package:bluetooth_sample/services/wifi.dart';
import 'package:bluetooth_sample/utils/app_l10n.dart';
import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
import 'package:bluetooth_sample/widgets/bluetooth/device_info.dart';
import 'package:bluetooth_sample/widgets/bluetooth/service_widget.dart';
import 'package:bluetooth_sample/widgets/common/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({
    super.key,
    required this.device,
  });

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  bool _isConnecting = false;
  List<BluetoothService> _services = [];
  int? _rssi;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  bool get isConnected =>
      _connectionState == BluetoothConnectionState.connected;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      _connectionState = state;
      _services = [];

      await _updateScreenByBLEConnection(state);

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    if (Platform.isAndroid && isConnected) {
      widget.device.clearGattCache();
    }

    widget.device.disconnect();
    _connectionStateSubscription.cancel();

    super.dispose();
  }

  Future<void> _updateScreenByBLEConnection(
      BluetoothConnectionState state) async {
    switch (state) {
      case BluetoothConnectionState.connected:
        _rssi ??= await widget.device.readRssi();
        break;
      case BluetoothConnectionState.disconnected:
        await _disposeWifiScreen();
        _displayDisconnectionReason(widget.device.disconnectReason);
        break;
      default:
        break;
    }
  }

  Future _disposeWifiScreen() async {
    final isWifiConnected = await Wifi.isConnected();
    if (isWifiConnected) {
      await Wifi.disconnect();
    }

    if (context.mounted) {
      Navigator.popUntil(context, ModalRoute.withName('/DeviceScreen'));
    }
  }

  void _displayDisconnectionReason(DisconnectReason? reason) {
    if (reason == null) {
      return;
    }

    final int? code = reason.code;
    final isSuccess = code != null && code == 0;
    if (!isSuccess) {
      final msg = reason.description;
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: msg ?? AppL10n.getL10n(context).alertDisconnectedDevice,
      );
    }
  }

  Future<void> _onConnectPressed() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await widget.device.connect();

      if (context.mounted) {
        CustomSnackBar.show(
          status: SnackBarStatus.success,
          message: AppL10n.getL10n(context)
              .alertConnectedDevice(widget.device.advName),
        );
      }
    } catch (error) {
      CustomSnackBar.show(
        status: SnackBarStatus.error,
        message: error.toString(),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _onDisconnectPressed() async {
    await widget.device.disconnect();
  }

  Future<void> _onGetServicesPressed() async {
    if (isConnected) {
      List<BluetoothService> services = await widget.device.discoverServices();
      _services = services;

      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildActionButton() {
    final buttonText = _isConnecting
        ? AppL10n.getL10n(context).connecting
        : isConnected
            ? AppL10n.getL10n(context).disconnect
            : AppL10n.getL10n(context).connect;
    return Button(
      type: ButtonType.text,
      onPressed: _isConnecting
          ? null
          : isConnected
              ? _onDisconnectPressed
              : _onConnectPressed,
      child: Text(buttonText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.device.platformName),
        actions: [
          _buildActionButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(widget.device.remoteId.str),
              const SizedBox(height: 8),
              DeviceInfo(
                isConnected: isConnected,
                connectionState: _connectionState.name,
                onGetServicesPressed: _onGetServicesPressed,
                rssi: _rssi,
              ),
              const SizedBox(
                height: 24,
              ),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  BluetoothService service = _services[index];
                  return ServiceWidget(service: service);
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: _services.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
