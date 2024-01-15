import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  const PrimaryButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onPressed,
      style: onPressed == null
          ? null
          : ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(theme.colorScheme.primary),
              foregroundColor:
                  MaterialStateProperty.all(theme.colorScheme.onPrimary),
            ),
      child: Text(text),
    );
  }
}

class SecondaryButton extends PrimaryButton {
  const SecondaryButton({super.key, required super.text, super.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
