import 'package:flutter/material.dart';

class SubtitleWidget extends StatelessWidget {
  final String title;

  const SubtitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      margin: const EdgeInsets.only(bottom: 4),
      color: Colors.grey[100],
      child: Text(title),
    );
  }
}
