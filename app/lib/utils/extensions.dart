T let<T, D>(D obj, T Function(D obj) callback) {
  return callback(obj);
}
