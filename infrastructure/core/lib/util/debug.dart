class TDebug {
  TDebug._();

  /// Set of keys that have already thrown an error.
  static final _errorKeys = <String>{};

  /// Operation wrapper that will throw an error on the first call.
  static Future<T> Function() firstErrorOperation<T>(
    String key,
    Future<T> Function() operation,
  ) {
    return () async {
      if (_errorKeys.add(key)) {
        await Future.delayed(const Duration(seconds: 2));
        throw Exception('Error $key');
      }
      return operation();
    };
  }
}
