import 'package:flutter/material.dart';

mixin TextControllerMixin<T extends StatefulWidget> on State<T> {
  late final TextEditingController textController;
  @override
  void initState() {
    textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
