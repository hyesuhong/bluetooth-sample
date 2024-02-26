import 'package:bluetooth_sample/widgets/characteristic_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ServiceWidget extends StatelessWidget {
  final BluetoothDevice device;
  final BluetoothService service;

  const ServiceWidget({super.key, required this.device, required this.service});

  Widget _buildCharacteristicsList(
      List<BluetoothCharacteristic> characteristics) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: characteristics.length,
        itemBuilder: (context, index) {
          BluetoothCharacteristic characteristic =
              service.characteristics[index];
          return CharacteristicWidget(
            device: device,
            characteristic: characteristic,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    service.uuid.str128,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
        if (service.characteristics.isNotEmpty)
          _buildCharacteristicsList(service.characteristics),
      ],
    );
  }
}
