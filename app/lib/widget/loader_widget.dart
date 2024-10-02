import 'package:brigantina_invent/widget/page.dart';
import 'package:core/util/exception/exception_parser.dart';
import 'package:core/util/globals.dart';
import 'package:core/util/simple.dart';
import 'package:flutter/material.dart';

import '../utils/worker_manager/worker_manager.dart';

class Snapshot<T> {
  final T data;
  final bool inProgress;
  Snapshot({required this.data, required this.inProgress});
}

class LoaderController {
  _LoaderWidgetState? _state;

  Future<void> loadData(
      {bool cleanCache = false, bool showProgress = false}) async {
    await _state?._loadData(
        cleanCache: cleanCache, showProgressWhenHasData: showProgress);
  }

  void setNewData(Object data) {
    // ignore: invalid_use_of_protected_member
    _state?.setState(() {
      _state?._data = data;
    });
  }
}

class LoaderWidget<T extends Object> extends StatefulWidget {
  final LoaderController? controller;
  final Future<T> Function() operation;
  final Widget Function(BuildContext context, Snapshot<T> snapshot) builder;
  final void Function(Object)? onError;
  final void Function(T)? onResult;
  final bool small;

  const LoaderWidget(
      {required this.operation,
      required this.builder,
      super.key,
      this.controller,
      this.onError,
      this.onResult,
      this.small = false});

  @override
  State<LoaderWidget> createState() => _LoaderWidgetState<T>();
}

class _LoaderWidgetState<T extends Object> extends State<LoaderWidget<T>> {
  final _queue = WorkerManager.queue();
  final _bodyKey = GlobalKey();
  T? _data;
  Object? _exception;
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _loadData();
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) {
      widget.controller?._state = null;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(LoaderWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  Future<void> _loadData(
      {bool cleanCache = false, bool showProgressWhenHasData = false}) async {
    await _queue.add(() async {
      if (!mounted) {
        return;
      }
      if (cleanCache) {
        _data = null;
      }
      if (_data != null && showProgressWhenHasData) {
        _inProgress = true;
      }
      if (_data == null) {
        _exception = null;
      }
      setState(() {});
      try {
        _data = await widget.operation();
        if (_data == null) {
          _exception = Exception('Data is null');
        } else {
          widget.onResult?.call(_data!);
          _exception = null;
        }
      } catch (e, s) {
        widget.onError?.call(e);
        logger.e(e.toString(), error: e, stackTrace: s);
        if (_data == null) {
          _exception = e;
        } else {
          if (mounted) {
            _showErrorToast(e);
          }
        }
      }
      if (mounted) {
        _inProgress = false;
        setState(() {});
      }
    });
  }

  void _showErrorToast(Object e) {
    Simple.toast(ExceptionParser.parseException(e));
  }

  @override
  Widget build(BuildContext context) {
    return buildContent(context);
  }

  Widget buildContent(BuildContext context) {
    if (_data == null && _exception == null) {
      return widget.small
          ? const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            )
          : const TProgressPageWidget();
    } else if (_data == null) {
      if (widget.small) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              Text(
                ExceptionParser.parseException(_exception!),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: _loadData, child: const Text("Повторить")),
            ],
          ),
        );
      }
      return TExceptionPageWidget(
        exception: _exception!,
        onRetry: _loadData,
      );
    } else {
      final body = SizedBox(
        key: _bodyKey,
        child: widget.builder(
            context,
            Snapshot<T>(
              data: _data!,
              inProgress: _inProgress,
            )),
      );
      return _inProgress
          ? Stack(
              children: [
                body,
                if (widget.small)
                  const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  const TProgressPageWidget(),
              ],
            )
          : body;
    }
  }
}
