import 'package:flutter/material.dart';

enum ButtonType {
  floating,
  elevated,
  filled,
  filledTonal,
  outlined,
  text,
}

class Button extends StatelessWidget {
  final ButtonType type;
  final Widget child;
  final VoidCallback? onPressed;

  const Button({
    super.key,
    required this.type,
    required this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ButtonType.floating:
        return FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: onPressed,
          child: child,
        );
      case ButtonType.elevated:
        return ElevatedButton(onPressed: onPressed, child: child);
      case ButtonType.filled:
        return FilledButton(onPressed: onPressed, child: child);
      case ButtonType.filledTonal:
        return FilledButton.tonal(onPressed: onPressed, child: child);
      case ButtonType.outlined:
        return OutlinedButton(onPressed: onPressed, child: child);
      case ButtonType.text:
        return TextButton(onPressed: onPressed, child: child);
    }
  }
}
