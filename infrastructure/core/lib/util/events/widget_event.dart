import 'dart:async';

import 'package:core/util/globals.dart';
import 'package:flutter/material.dart';

import 'event_bus.dart';

class EventHandlerWidget<T> extends StatefulWidget {
  final void Function(T event) onEvent;
  final Widget? child;

  const EventHandlerWidget({required this.onEvent, Key? key, this.child})
      : super(key: key);

  @override
  State<EventHandlerWidget<T>> createState() => _WidgetEventState<T>();
}

class _WidgetEventState<T> extends State<EventHandlerWidget<T>> {
  late final StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = eventBus.on<T>().listen((event) {
      widget.onEvent.call(event);
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? emptyWidget;
  }
}
