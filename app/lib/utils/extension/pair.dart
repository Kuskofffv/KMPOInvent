part of extensions;

/// Represents a generic pair of two values.
class Pair<T, U> {
  Pair(this.left, this.right);

  final T? left;
  final U? right;

  @override
  String toString() => '($left, $right)';
}

extension PairExtensions<T> on Pair<T, T> {
  List<T?> toList() => [left, right];
}
