import 'package:core/util/globals.dart';
import 'package:flutter/material.dart';

import 'storage.dart';

/// A class that holds the data and a flag indicating whether the data was read.
class StorageBuilderSnapshot<T> {
  /// The data of type T.
  final T? data;

  /// A flag indicating whether the data was read.
  final bool hasBeenRead;

  /// Constructs a DataStorageBuilder with the given data and flag.
  StorageBuilderSnapshot({required this.data, required this.hasBeenRead});
}

/// A function type that takes a BuildContext
/// and a DataStorageBuilder and returns a Widget.
typedef StorageBuilderFunction<T> = Widget? Function(
    BuildContext context, StorageBuilderSnapshot<T> data);

/// A StatefulWidget that builds a widget based
/// on the state of a Storage object.
class StorageBuilder<T> extends StatefulWidget {
  /// The Storage object that this widget is based on.
  final Storage<T> storage;

  /// The function that builds the widget.
  final StorageBuilderFunction<T> builder;

  /// Constructs a StorageBuilder with the given Storage object
  /// and builder function.
  const StorageBuilder({required this.storage, required this.builder, Key? key})
      : super(key: key);

  @override
  _StorageBuilderState<T> createState() => _StorageBuilderState<T>();
}

/// The state for a StorageBuilder widget.
class _StorageBuilderState<T> extends State<StorageBuilder<T>> {
  @override
  void initState() {
    super.initState();
    widget.storage.addListener(onListener);
    _readFirst();
  }

  /// A listener that calls setState when the Storage object changes.
  void onListener() {
    setState(() {});
  }

  /// Reads the data from the Storage object if it hasn't been read yet.
  Future<void> _readFirst() async {
    if (widget.storage.memoryCache == null && !widget.storage.hasBeenRead) {
      await widget.storage.read();
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant StorageBuilder<T> oldWidget) {
    if (widget.storage != oldWidget.storage) {
      oldWidget.storage.removeListener(onListener);
      widget.storage.addListener(onListener);
      _readFirst();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
            context,
            StorageBuilderSnapshot(
                data: widget.storage.memoryCache,
                hasBeenRead: widget.storage.hasBeenRead)) ??
        emptyWidget;
  }

  @override
  void dispose() {
    widget.storage.removeListener(onListener);
    super.dispose();
  }
}

/// An extension on Storage that provides a builder method.
extension StorageExtension<T> on Storage<T> {
  /// Returns a StorageBuilder that uses the given builder function.
  StorageBuilder<T> builder(StorageBuilderFunction<T> builder) {
    return StorageBuilder(storage: this, builder: builder);
  }
}
