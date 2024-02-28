import 'dart:async';

import 'package:bluetooth_sample/widgets/loading_widget.dart';
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
    setState(() {
      _isConnecting = true;
    });

    try {
      await widget.device.connect();
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

      print(services);

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
          ? 'Connecting..'
          : isConnected
              ? 'Disconnect'
              : 'Connect'),
    );
  }

  Widget _buildGetServicesButton() {
    return FilledButton(
      onPressed: isConnected ? _onGetServicesPressed : null,
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
                    child: Text('Device is ${_connectionState.name}.'),
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
