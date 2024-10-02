import 'dart:async';
import '../scheduling/runnable.dart';

enum WorkPriority {
  immediately,
  veryHigh,
  high,
  highRegular,
  regular,
  almostLow,
  low
}

class Task<A, B, C, D, O> implements Comparable<Task<A, B, C, D, O>> {
  final Runnable<A, B, C, D, O> runnable;
  final resultCompleter = Completer<O>();
  final int number;
  final WorkPriority workPriority;

  Task(
    this.number, {
    required this.runnable,
    this.workPriority = WorkPriority.high,
  });

  @override
  int compareTo(Task other) {
    final index = WorkPriority.values.indexOf;
    return index(workPriority) - index(other.workPriority);
  }
}
