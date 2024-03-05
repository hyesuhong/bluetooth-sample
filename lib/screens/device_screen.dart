import 'dart:async';
import 'dart:io';

import 'package:bluetooth_sample/utils/custom_snack_bar.dart';
import 'package:bluetooth_sample/widgets/service_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceScreen({super.key, required this.device});

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

      if (state == BluetoothConnectionState.connected) {
        _services = [];

        _rssi ??= await widget.device.readRssi();
      } else if (state == BluetoothConnectionState.disconnected) {
        if (widget.device.disconnectReason != null) {
          final int? code = widget.device.disconnectReason!.code;
          final isSuccess = code != null && code == 0;
          if (!isSuccess) {
            final msg = widget.device.disconnectReason!.description;
            CustomSnackBar.show(
              status: SnackBarStatus.error,
              message: msg ?? '기기와 연결이 끊어졌습니다.',
            );
          }
        }
      }

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

  Future _onConnectPressed() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      await widget.device.connect();

      CustomSnackBar.show(
        status: SnackBarStatus.success,
        message: '${widget.device.advName} 에 연결되었습니다.',
      );
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

  Future _onDisconnectPressed() async {
    await widget.device.disconnect();
  }

  Future _onGetServicesPressed() async {
    if (isConnected) {
      List<BluetoothService> services = await widget.device.discoverServices();
      _services = services;

      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildActionButton() {
    return TextButton(
      onPressed: _isConnecting
          ? null
          : isConnected
              ? _onDisconnectPressed
              : _onConnectPressed,
      child: Text(_isConnecting
          ? '연결중..'
          : isConnected
              ? '연결 끊기'
              : '연결'),
    );
  }

  Widget _buildGetServicesButton() {
    return FilledButton(
      onPressed: isConnected ? _onGetServicesPressed : null,
      child: const Text('Services 가져오기'),
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
              Row(
                children: [
                  Container(
                    width: 64,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          isConnected
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth,
                          color: Colors.grey,
                        ),
                        if (_rssi != null)
                          Text(
                            '${_rssi.toString()}dBm',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text('기기 연결 상태: ${_connectionState.name}.'),
                  ),
                  _buildGetServicesButton(),
                ],
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
