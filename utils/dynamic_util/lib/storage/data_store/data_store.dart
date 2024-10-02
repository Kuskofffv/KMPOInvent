abstract class DataStore<T> {
  Future write(T? data);
  Future<T?> read(T Function(Map<String, dynamic>) creator);
}
