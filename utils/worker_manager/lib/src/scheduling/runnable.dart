import 'dart:async';

typedef Fun1<A, O> = FutureOr<O> Function(A arg1);
typedef Fun2<A, B, O> = FutureOr<O> Function(A arg1, B arg2);
typedef Fun3<A, B, C, O> = FutureOr<O> Function(A arg1, B arg2, C arg3);
typedef Fun4<A, B, C, D, O> = FutureOr<O> Function(
    A arg1, B arg2, C arg3, D arg4);

class Runnable<A, B, C, D, O> {
  final A? arg1;
  final B? arg2;
  final C? arg3;
  final D? arg4;

  final Fun1<A, O>? fun1;
  final Fun2<A, B, O>? fun2;
  final Fun3<A, B, C, O>? fun3;
  final Fun4<A, B, C, D, O>? fun4;

  Runnable({
    this.arg1,
    this.arg2,
    this.arg3,
    this.arg4,
    this.fun1,
    this.fun2,
    this.fun3,
    this.fun4,
  });

  FutureOr<O> call() {
    if (fun1 != null) {
      final dynamic f = fun1;
      return f(arg1);
    }
    if (fun2 != null) {
      final dynamic f = fun2;
      return f(arg1, arg2);
    }
    if (fun3 != null) {
      final dynamic f = fun3;
      return f(arg1, arg2, arg3);
    }
    if (fun4 != null) {
      final dynamic f = fun4;
      return f(arg1, arg2, arg3, arg4);
    }
    throw ArgumentError("execute method arguments of function miss match");
  }
}
