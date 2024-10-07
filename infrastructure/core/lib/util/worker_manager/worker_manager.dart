library worker_manager;

import 'src/cancelable/cancelable.dart';
import 'src/dart_queue_base.dart';
import 'src/scheduling/executor.dart';
import 'src/scheduling/runnable.dart';
import 'src/scheduling/task.dart';

export 'src/cancelable/cancel_token.dart';
export 'src/cancelable/cancelable.dart';
export 'src/dart_queue_base.dart';
export 'src/scheduling/executor.dart';
export 'src/scheduling/task.dart' show WorkPriority;

class WorkerManager {
  WorkerManager._();

  static bool _warmUpped = false;
  static final Executor _executor = Executor();

  /// Warms up the executor by initializing it
  /// and getting it ready to execute tasks.
  static Future warmUpExecutor() async {
    if (!_warmUpped) {
      await _executor.warmUp();
      _warmUpped = true;
    }
  }

  /// Executes a task in an isolate with one argument.
  static Cancelable<O> execIsolate<A, O>(Fun1<A, O> fun1, A arg1,
      {WorkPriority priority = WorkPriority.high, bool fake = false}) {
    return _executor.execute(
        arg1: arg1, fun1: fun1, priority: priority, fake: fake);
  }

  /// Executes a task in an isolate with two arguments.
  static Cancelable<O> execIsolate2Args<A, B, O>(
      Fun2<A, B, O> fun2, A arg1, B arg2,
      {WorkPriority priority = WorkPriority.high, bool fake = false}) {
    return _executor.execute(
        arg1: arg1, arg2: arg2, fun2: fun2, priority: priority, fake: fake);
  }

  /// Executes a task in an isolate with three arguments.
  static Cancelable<O> execIsolate3Args<A, B, C, O>(
      Fun3<A, B, C, O> fun3, A arg1, B arg2, C arg3,
      {WorkPriority priority = WorkPriority.high, bool fake = false}) {
    return _executor.execute(
        arg1: arg1,
        arg2: arg2,
        arg3: arg3,
        fun3: fun3,
        priority: priority,
        fake: fake);
  }

  /// Executes a task in an isolate with four arguments.
  static Cancelable<O> execIsolate4Args<A, B, C, D, O>(
      Fun4<A, B, C, D, O> fun4, A arg1, B arg2, C arg3, D arg4,
      {WorkPriority priority = WorkPriority.high, bool fake = false}) {
    return _executor.execute(
        arg1: arg1,
        arg2: arg2,
        arg3: arg3,
        arg4: arg4,
        fun4: fun4,
        priority: priority,
        fake: fake);
  }

  /// Help to split a future into parts to prevent UI freezing.
  static Future<T> smartAsyncOperation<T>(
      Future<T> Function(OperationContoller controller) operation) {
    return operation(OperationContoller());
  }

  /// Creates a new queue to execute futures in order.
  static FuturesQueue queue() => FuturesQueue();
}

/// A controller for an asynchronous operation.
class OperationContoller {
  final _stopwatch = Stopwatch()..start();

  /// Checks if a task is taking too long to complete.
  /// Not more than 8ms per frame.
  Future checkMaybeWait() async {
    if (_stopwatch.elapsedMilliseconds > 8) {
      await Future.delayed(Duration.zero);
      _stopwatch.reset();
    }
  }
}
