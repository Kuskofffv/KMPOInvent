part of 'storage.dart';

/// `StorageBool` is a specialized version of `Storage`
/// for persisting `bool` values.
class StorageBool {
  static Storage<bool> create(String name,
      {bool secure = false, bool isEternalCache = false}) {
    return Storage.create(name, _simpleTypefromJson,
        secure: secure, isEternalCache: isEternalCache);
  }
}

/// `StorageString` is a specialized version of `Storage`
/// for persisting `String` values.
class StorageString {
  static Storage<String> create(String name,
      {bool secure = false, bool isEternalCache = false}) {
    return Storage.create(name, _simpleTypefromJson,
        secure: secure, isEternalCache: isEternalCache);
  }
}

/// `StorageInt` is a specialized version of `Storage`
/// for persisting `int` values.
class StorageInt {
  static Storage<int> create(String name,
      {bool secure = false, bool isEternalCache = false}) {
    return Storage.create(name, _simpleTypefromJson,
        secure: secure, isEternalCache: isEternalCache);
  }
}

/// `StorageDynamic` is a specialized version of `Storage`
/// for persisting `DynamicModel` values.
class StorageDynamic {
  static Storage<DynamicModel> create(String name,
      {bool secure = false, bool isEternalCache = false}) {
    return Storage.create(name, DynamicModel.fromJson,
        secure: secure, isEternalCache: isEternalCache);
  }
}

/// `StorageList` is a specialized version of `Storage`
/// for persisting lists of a specific type.
/// The type of items in the list is defined by the generic parameter `T`.

class StorageList {
  StorageList._();
  static Storage<List<T>> create<T>(
      String name, T Function(Map<String, dynamic>) itemCreator,
      {bool secure = false, bool isEternalCache = false}) {
    return Storage.create(name, (d) {
      final rawList = d['items']! as List<dynamic>;
      // ignore: unnecessary_lambdas
      final list = rawList.map<T>((e) => itemCreator(e)).toList();
      return list;
    }, secure: secure, isEternalCache: isEternalCache);
  }
}

/// `StorageIntList` is a specialized version of `Storage`
/// for persisting lists of `int` values.
class StorageIntList {
  static Storage<List<int>> create(String name,
      {bool secure = false, bool isEternalCache = false}) {
    return Storage.create(name, (d) {
      final rawList = d['items']! as List<dynamic>;
      final list = rawList.map<int>((e) => e as int).toList();
      return list;
    }, secure: secure, isEternalCache: isEternalCache);
  }
}

/// `StorageStringList` is a specialized version of `Storage`
/// for persisting lists of `String` values.
class StorageStringList {
  static Storage<List<String>> create(String name,
      {bool secure = false, bool isEternalCache = false}) {
    return Storage.create(name, (d) {
      final rawList = d['items']! as List<dynamic>;
      final list = rawList.map<String>((e) => e as String).toList();
      return list;
    }, secure: secure, isEternalCache: isEternalCache);
  }
}

/// `StorageListDynamic` is a specialized version of `StorageList`
/// for persisting lists of `DynamicModel` values.
abstract class StorageListDynamic {
  static Storage<List<DynamicModel>> create(String name,
      {bool secure = false, bool isEternalCache = false}) {
    return StorageList.create(name, DynamicModel.fromJson,
        secure: secure, isEternalCache: isEternalCache);
  }
}

T _simpleTypefromJson<T>(Map<String, dynamic> json) {
  return json['value'] as T;
}
