import 'dart:async';
import '../scheduling/runnable.dart';
import '../scheduling/task.dart';
import '../worker/worker.dart';

class WorkerImpl implements Worker {
  int? _runnableNumber;

  @override
  int? get runnableNumber => _runnableNumber;
  Completer? _result;

  @override
  Future<void> initialize() async => Future.value();

  @override
  Future<O> work<A, B, C, D, O>(Task<A, B, C, D, O> task) async {
    _runnableNumber = task.number;
    _result = Completer<O>();
    if (!_result!.isCompleted) {
      _result?.complete(await _execute(task.runnable));
    }
    return _result!.future as Future<O>;
  }

  static FutureOr _execute(Runnable runnable) => runnable();

  @override
  Future<void> kill() async {
    _result = null;
  }
}
