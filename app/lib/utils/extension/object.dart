part of extensions;

extension AsExtension on Object? {
  /// Casts `this` value to the specified type [X].
  X as<X>() => this as X;

  /// Casts `this` value to the specified type [X] or [Null].
  X? asOrNull<X>() => (this != null && this is X) ? this as X : null;
}

extension ScopeFunctionsForObject<T extends Object> on T {
  /// Calls the specified function [operation] with `this` value
  /// as its argument and returns its result.
  ReturnType let<ReturnType>(ReturnType Function(T self) operation) =>
      operation(this);

  /// Calls the specified function [operation] with `this` value
  /// as its argument and returns `this` value.
  T also(void Function(T self) operation) {
    operation(this);
    return this;
  }
}
