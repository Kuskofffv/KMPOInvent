import 'package:flutter/material.dart';

class ClearTextSuffixButton extends StatelessWidget {
  const ClearTextSuffixButton({
    required this.text,
    required this.onTap,
    super.key,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox();
    }

    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: onTap,
    );
  }
}
