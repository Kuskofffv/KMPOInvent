import 'dart:core';

import 'package:core/util/extension/extensions.dart';
import 'package:core/util/globals.dart';
import 'package:flutter/foundation.dart';

import '../dynamic_model.dart';
import 'data_store/data_store.dart';
import 'data_store/io_data_store.dart';
import 'data_store/secure_data_store.dart';
import 'data_store/shared_prefs_data_store.dart';

part 'storage.impl.dart';

bool kDebugPrintStorage = false;
bool _useMemoryCache = true;

/// The `Storage` class provides a way to persistently store and retrieve data.
/// It can be used to store any type of data, including primitive types
/// and complex objects.
class Storage<T> extends IStorage<T> {
  static final _mapStorages = <String, Storage>{};

  T? get memoryCache => _memoryCache;
  bool get hasBeenRead => _hasBeenRead;

  T? _memoryCache;
  bool _hasBeenRead = false;

  Future<T?>? _lastTask;
  final DataStore<T> _dataStore;
  final T Function(Map<String, dynamic>) _creator;
  final bool isEternalCache;

  Storage._(String name, this._creator, this._dataStore, this.isEternalCache)
      : super(name);

  /// Creates a new instance of [Storage] or returns an existing one
  /// if it has already been created.
  static Storage<T> create<T>(
      String name, T Function(Map<String, dynamic>) creator,
      {bool secure = false, bool isEternalCache = false}) {
    var storage = _mapStorages[name].asOrNull<Storage<T>>();
    if (storage == null) {
      final dataStore = secure
          ? SecureDataStore<T>(name, isEternalCache)
          : (kIsWeb
              ? SharedPrefsDataStore<T>(name, isEternalCache)
              : IODataStore<T>(name, isEternalCache));
      storage = Storage._(name, creator, dataStore, isEternalCache);
      _mapStorages[name] = storage;
    }
    return storage;
  }

  /// Clears all storages except those with the specified tags.
  static Future clearAllStorages({bool cleanEternalCache = false}) async {
    final values = _mapStorages.values;
    for (final value in values) {
      if (cleanEternalCache || !value.isEternalCache) {
        await value.write(null);
      }
    }

    if (!kIsWeb) {
      await IODataStore.clearAllStorages(cleanEternalCache: cleanEternalCache);
    }
    await SharedPrefsDataStore.clearAllStorages(
        cleanEternalCache: cleanEternalCache);
    await SecureDataStore.clearAllStorages(
        cleanEternalCache: cleanEternalCache);
  }

  /// Clears the storage by writing null to it.
  @override
  Future clear() async {
    await write(null);
  }

  /// Clears the memory cache of the storage.
  void clearMemory() {
    _memoryCache = null;
    _hasBeenRead = false;
    notifyListeners();
  }

  /// Reads data from the storage. If the data is not in the memory cache,
  /// it is read from the store.
  @override
  Future<T?> read() async {
    while (_lastTask != null) {
      await _lastTask;
    }
    if (memoryCache != null) {
      return memoryCache;
    }
    if (_hasBeenRead) {
      return null;
    }

    _lastTask = () async {
      try {
        if (kDebugMode && kDebugPrintStorage) {
          logger.i('storage read $name');
        }

        final value = await _dataStore.read(_creator);

        if (value is T) {
          if (_useMemoryCache) {
            _memoryCache = value;
            _hasBeenRead = true;
          }

          _lastTask = null;
          return value;
        }
        // ignore: unused_catch_stack
      } catch (e, s) {
        if (kDebugMode) {
          logger.i('storage read error $name');
        }
      }
      if (_useMemoryCache) {
        _hasBeenRead = true;
      }

      _lastTask = null;

      return null;
    }();

    return await _lastTask;
  }

  /// Writes data to the storage. The data can be written
  /// to the memory cache only or also to the store.
  @override
  Future<T?> write(T? data,
      {bool onlyMemory = false, bool withNotify = true}) async {
    if (_useMemoryCache) {
      _memoryCache = data;
    }

    if (onlyMemory) {
      if (withNotify) {
        notifyListeners();
      }
      return data;
    }

    while (_lastTask != null) {
      await _lastTask;
    }

    if (_useMemoryCache) {
      _memoryCache = data;
    }

    _lastTask = () async {
      try {
        if (kDebugMode && kDebugPrintStorage) {
          logger.i('storage write $name');
        }
        await _dataStore.write(data);
        // ignore: unused_catch_stack
      } catch (e, s) {
        if (kDebugMode) {
          logger.e(e);
        }
      }
      if (_useMemoryCache) {
        _hasBeenRead = true;
      }
      _lastTask = null;
      if (withNotify) {
        notifyListeners();
      }
    }();

    await _lastTask;
    return _useMemoryCache ? memoryCache : data;
  }
}

abstract class IStorage<T> extends ChangeNotifier {
  /// The name of the storage.
  String name;
  IStorage(this.name);

  /// Clears the storage. The implementation depends on the specific storage.
  void clear();

  /// Reads data from the storage. The implementation depends
  /// on the specific storage.
  Future<T?> read();

  /// Writes data to the storage. The implementation depends
  /// on the specific storage.
  Future<T?> write(T? data);
}
