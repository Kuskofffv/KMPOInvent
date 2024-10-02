import 'package:flutter/material.dart';

import 'basic_popup.dart';

class MessagePopupButton {
  final String text;
  final VoidCallback? onPressed;

  MessagePopupButton({required this.text, this.onPressed});
}

class MessagePopupWidget extends StatefulWidget {
  final String title;
  final String message;
  final PopupButton? secondaryButton;
  final PopupButton primaryButton;

  const MessagePopupWidget({
    required this.title,
    required this.message,
    required this.primaryButton,
    this.secondaryButton,
  });

  @override
  State<MessagePopupWidget> createState() => _MessagePopupWidgetState();
}

class _MessagePopupWidgetState extends State<MessagePopupWidget> {
  @override
  Widget build(BuildContext context) {
    return BasicPopupWidget(
        title: widget.title,
        primaryButton: widget.primaryButton,
        secondaryButton: widget.secondaryButton,
        body: Text(
          widget.message,
          style: const TextStyle(fontSize: 16),
        ));
  }
}
