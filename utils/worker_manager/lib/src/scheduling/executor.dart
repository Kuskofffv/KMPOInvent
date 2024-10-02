import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../cancelable/cancelable.dart';
import '../scheduling/runnable.dart';
import '../scheduling/task.dart';
import '../worker/worker.dart';

abstract class Executor {
  factory Executor() => _Executor();

  Future<void> warmUp({bool log = false, int isolatesCount});

  Cancelable<O> execute<A, B, C, D, O>({
    A arg1,
    B arg2,
    C arg3,
    D arg4,
    Fun1<A, O> fun1,
    Fun2<A, B, O> fun2,
    Fun3<A, B, C, O> fun3,
    Fun4<A, B, C, D, O> fun4,
    WorkPriority priority = WorkPriority.high,
    bool fake = false,
  });

  Future<void> dispose();
}

class _Executor implements Executor {
  final _queue = PriorityQueue<Task>();
  final _pool = <Worker>[];

  var _taskNumber = pow(-2, 53);
  var _log = false;

  factory _Executor() => _instance;

  _Executor._internal();

  static final _instance = _Executor._internal();

  @override
  Future<void> warmUp({
    bool log = false,
    int? isolatesCount,
  }) async {
    _log = log;
    if (_pool.isEmpty) {
      const processors = kIsWeb ? 1 : 2; // numberOfProcessors;
      isolatesCount ??= processors;
      var processorsNumber =
          isolatesCount < processors ? isolatesCount : processors;
      if (processorsNumber == 1) {
        processorsNumber = 2;
      }
      for (var i = 0; i < processorsNumber - 1; i++) {
        _pool.add(Worker());
      }
      _logInfo('${_pool.length} has been spawned');
      await Future.wait(_pool.map((iw) => iw.initialize()));
      _logInfo('initialized');
    } else {
      _logInfo('all workers already initialized');
    }
  }

  @override
  Cancelable<O> execute<A, B, C, D, O>({
    A? arg1,
    B? arg2,
    C? arg3,
    D? arg4,
    Fun1<A, O>? fun1,
    Fun2<A, B, O>? fun2,
    Fun3<A, B, C, O>? fun3,
    Fun4<A, B, C, D, O>? fun4,
    WorkPriority priority = WorkPriority.high,
    bool fake = false,
  }) {
    //fake = true;
    Cancelable<O> executing() {
      final task = Task(
        _taskNumber.toInt(),
        runnable: Runnable(
          arg1: arg1,
          arg2: arg2,
          arg3: arg3,
          arg4: arg4,
          fun1: fun1,
          fun2: fun2,
          fun3: fun3,
          fun4: fun4,
        ),
        workPriority: priority,
      );
      _logInfo('added task with number $_taskNumber');
      if (kIsWeb || fake) {
        try {
          final runnable = task.runnable();
          if (runnable is Future<O>) {
            runnable
                .then(task.resultCompleter.complete)
                .onError(task.resultCompleter.completeError);
          } else {
            task.resultCompleter.complete(runnable);
          }
        } catch (error) {
          task.resultCompleter.completeError(error);
        }
        return Cancelable(task.resultCompleter);
      } else {
        _taskNumber++;
        _queue.add(task);
        _schedule();
        return Cancelable(task.resultCompleter, onCancel: () => _cancel(task));
      }
    }

    if (_pool.isEmpty) {
      _logInfo("Executor: cold start");
      return Cancelable.fromFuture(warmUp(log: _log))
          .next(onValue: (_) => executing());
    }
    return executing();
  }

  @override
  Future<void> dispose() async {
    _queue.clear();
    await Future.wait(_pool.map((e) => e.kill()));
    _pool.clear();
    _taskNumber = pow(-2, 53);
  }

  void _scheduleNext() {
    if (_queue.isNotEmpty) {
      _schedule();
    }
  }

  void _schedule() {
    final availableIsolate =
        _pool.firstWhereOrNull((iw) => iw.runnableNumber == null);
    if (availableIsolate == null) {
      return;
    }
    final task = _queue.removeFirst();
    _logInfo('isolate with task number ${task.number} begins work');
    availableIsolate.work(task).then((result) {
      if (_log) {
        if (kDebugMode) {
          print('isolate with task number ${task.number} ends work');
        }
      }
      task.resultCompleter.complete(result);
      _scheduleNext();
    }).catchError((error) {
      task.resultCompleter.completeError(error);
      _scheduleNext();
    });
  }

  void _cancel<A, B, C, D, O>(Task<A, B, C, D, O> task) {
    if (!task.resultCompleter.isCompleted) {
      task.resultCompleter.completeError(CanceledError());
    }
    if (_queue.contains(task)) {
      _logInfo('task with number ${task.number} removed from queue');
      _queue.remove(task);
    } else {
      final targetWorker =
          _pool.firstWhereOrNull((iw) => iw.runnableNumber == task.number);
      if (targetWorker != null) {
        _logInfo('isolate with number ${targetWorker.runnableNumber} killed');
        targetWorker.kill().then(
            (_) => targetWorker.initialize().then((_) => _scheduleNext()));
      }
    }
  }

  void _logInfo(String info) {
    if (_log) {
      if (kDebugMode) {
        print(info);
      }
    }
  }
}
