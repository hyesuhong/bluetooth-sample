import 'package:bluetooth_sample/services/wifi.dart';
import 'package:flutter/material.dart';

class WifiConnectionScreen extends StatefulWidget {
  final String ssid;
  final String password;
  const WifiConnectionScreen({
    super.key,
    required this.ssid,
    required this.password,
  });

  @override
  State<WifiConnectionScreen> createState() => _WifiConnectionScreenState();
}

class _WifiConnectionScreenState extends State<WifiConnectionScreen> {
  bool _isLoading = true;
  bool _isSuccess = false;

  @override
  initState() {
    super.initState();

    _findAndConnect();
  }

  Future _findAndConnect() async {
    try {
      bool result = await Wifi.findAndConnect(widget.ssid, widget.password);

      if (mounted) {
        setState(() {
          _isSuccess = result;
        });
      }
    } catch (error) {
      print(error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(),
        ),
        const SizedBox(height: 16),
        Text('${widget.ssid} 정보 확인중'),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.done, size: 100, color: Colors.green),
        const SizedBox(height: 16),
        Text('${widget.ssid} 확인이 완료되었습니다. 와이파이 전달 화면으로 돌아갑니다.'),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, size: 100, color: Colors.red[800]),
        const SizedBox(height: 16),
        Text('입력하신 ${widget.ssid} 정보가 정확하지 않습니다. 입력 화면으로 돌아갑니다.'),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildIndicator();
    } else {
      return _isSuccess ? _buildSuccess() : _buildError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // title: const Text('와이파이 정보 전달'),
      ),
      body: SafeArea(
        child: Center(
          child: _buildBody(),
        ),
      ),
    );
  }
}
