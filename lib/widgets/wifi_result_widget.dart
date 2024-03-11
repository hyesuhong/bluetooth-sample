import 'package:flutter/material.dart';

class WifiResultWidget extends StatelessWidget {
  final bool isSuccess;
  final String message;

  const WifiResultWidget(
      {super.key, required this.isSuccess, required this.message});

  Color? get iconColor => isSuccess ? Colors.green : Colors.red[800];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isSuccess ? Icons.done : Icons.error,
          size: 100,
          color: iconColor,
        ),
        const SizedBox(height: 16),
        Text(message),
      ],
    );
  }
}
