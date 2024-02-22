import 'package:flutter/material.dart';

class ScanDeviceWidget extends StatelessWidget {
  const ScanDeviceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device Name'),
          const Text(
            'Address',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('-89'),
              FilledButton(
                onPressed: () {},
                child: const Text('Connect'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
