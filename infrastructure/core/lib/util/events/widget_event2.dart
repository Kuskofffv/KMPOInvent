import 'dart:async';

import 'package:core/util/globals.dart';
import 'package:flutter/material.dart';

import 'event_bus.dart';

class EventHandlersWidget<T, D> extends StatefulWidget {
  final void Function(T event) onEvent;
  final void Function(D event2) onEvent2;
  final Widget? child;

  const EventHandlersWidget(this.onEvent, this.onEvent2, {Key? key, this.child})
      : super(key: key);

  @override
  State<EventHandlersWidget<T, D>> createState() => _WidgetEventState<T, D>();
}

class _WidgetEventState<T, D> extends State<EventHandlersWidget<T, D>> {
  late final StreamSubscription _subscription;
  late final StreamSubscription _subscription2;

  @override
  void initState() {
    _subscription = eventBus.on<T>().listen(widget.onEvent);
    _subscription2 = eventBus.on<D>().listen(widget.onEvent2);
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _subscription2.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? emptyWidget;
  }
}
