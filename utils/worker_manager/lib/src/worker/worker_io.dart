import 'dart:async';
import 'dart:isolate';
import 'package:async/async.dart';
import '../scheduling/task.dart';
import '../worker/worker.dart';

class WorkerImpl implements Worker {
  late Isolate _isolate;
  late ReceivePort _receivePort;
  late SendPort _sendPort;
  late StreamSubscription _portSub;
  late Completer<Object?> _result;

  Function? _onUpdateProgress;
  int? _runnableNumber;

  @override
  int? get runnableNumber => _runnableNumber;

  void _cleanOnNewMessage() {
    _runnableNumber = null;
    _onUpdateProgress = null;
  }

  @override
  Future<void> initialize() async {
    final initCompleter = Completer<bool>();
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_anotherIsolate, _receivePort.sendPort);
    _portSub = _receivePort.listen((message) {
      if (message is ValueResult) {
        _result.complete(message.value);
        _cleanOnNewMessage();
      } else if (message is ErrorResult) {
        _result.completeError(message.error);
        _cleanOnNewMessage();
      } else if (message is SendPort) {
        _sendPort = message;
        initCompleter.complete(true);
      } else {
        _onUpdateProgress?.call(message);
      }
    });
    await initCompleter.future;
  }

  @override
  Future<O> work<A, B, C, D, O>(Task<A, B, C, D, O> task) async {
    _runnableNumber = task.number;
    _result = Completer<Object?>();
    _sendPort.send(Message(_execute, task.runnable));
    final resultValue = await (_result.future as Future<O>);
    return resultValue;
  }

  static FutureOr _execute(runnable) => runnable();

  static void _anotherIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((message) async {
      try {
        final currentMessage = message as Message;
        final function = currentMessage.function;
        final argument = currentMessage.argument;
        final result = await function(argument);
        sendPort.send(Result.value(result));
      } catch (error) {
        try {
          sendPort.send(Result.error(error));
        } catch (error) {
          sendPort.send(Result.error(
              'too big stackTrace, error is : ${error.toString()}'));
        }
      }
    });
  }

  @override
  Future<void> kill() async {
    _cleanOnNewMessage();
    _isolate.kill(priority: Isolate.immediate);
    return _portSub.cancel();
  }
}

class Message {
  final Function function;
  final Object argument;

  Message(this.function, this.argument);

  FutureOr call() async => await function(argument);
}
