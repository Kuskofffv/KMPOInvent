import 'package:flutter/material.dart';

class AdaptiveWidget extends StatefulWidget {
  final Widget Function(BuildContext context) builderPhone;
  final Widget Function(BuildContext context) builderTablet;

  const AdaptiveWidget({
    required this.builderPhone,
    required this.builderTablet,
  });

  @override
  State<AdaptiveWidget> createState() => _AdaptiveWidgetState();
}

class _AdaptiveWidgetState extends State<AdaptiveWidget> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > 600
        ? widget.builderTablet(context)
        : widget.builderPhone(context);
  }
}
