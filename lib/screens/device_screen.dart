import 'dart:async';
import 'dart:convert';

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
  List<BluetoothService> _services = [];
  int? _rssi;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      print('device is $state');
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();

    super.dispose();
  }

  Future _onConnectPressed() async {
    await widget.device.connect();
  }

  Future _onDisconnectPressed() async {
    await widget.device.disconnect();
  }

  Widget _buildActionButton() {
    return _connectionState == BluetoothConnectionState.connected
        ? TextButton(
            onPressed: _onDisconnectPressed,
            child: const Text('Disconnect'),
          )
        : TextButton(
            onPressed: _onConnectPressed,
            child: const Text('Connect'),
          );
  }

  Widget _buildGetServicesButton() {
    return TextButton(
      onPressed:
          _connectionState == BluetoothConnectionState.connected ? () {} : null,
      child: const Text('Get Services'),
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
              Row(
                children: [
                  Container(
                    width: 64,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.bluetooth,
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
                    child: Text('Device is ${_connectionState.name}.'),
                  ),
                  _buildGetServicesButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
