import 'dart:convert';

import 'package:core/util/extension/extensions.dart';
import 'package:core/util/worker_manager/worker_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'data_store.dart';

class SecureDataStore<T> implements DataStore<T> {
  static const _eternalPostfix = '...eternal';
  final String name;
  final bool isEternalCache;
  late final flutterSecureStorage = const FlutterSecureStorage();
  late final String cacheKey = isEternalCache ? '$name$_eternalPostfix' : name;
  // ignore: avoid_positional_boolean_parameters
  SecureDataStore(this.name, this.isEternalCache);

  @override
  Future write(T? data) async {
    if (data == null) {
      await flutterSecureStorage.delete(key: cacheKey);
    } else {
      await flutterSecureStorage.write(key: cacheKey, value: _encode(data));
    }
  }

  String _encode(Object data) {
    Map<String, dynamic> map;
    try {
      if (data is List) {
        try {
          map = {'items': data.map((e) => e.toJson()).toList()};
        } on Object {
          map = {'items': data};
        }
      } else {
        map = (data as dynamic).toJson();
      }
    } on Object {
      map = {'value': data};
    }
    return json.encode(map);
  }

  @override
  Future<T?> read(T Function(Map<String, dynamic>) creator) async {
    final String? content = await flutterSecureStorage.read(key: cacheKey);
    T? value;
    if (content != null) {
      value = creator(await WorkerManager.execIsolate(_decode, content));
    }
    return value;
  }

  Map<String, dynamic> _decode(String content) {
    return json.decode(
      content,
    );
  }

  static Future clearAllStorages({bool cleanEternalCache = false}) async {
    const flutterSecureStorage = FlutterSecureStorage();
    final allKeys = (await flutterSecureStorage.readAll()).keys;
    final keys = allKeys.filter(
        (element) => cleanEternalCache || !element.contains(_eternalPostfix));
    for (final key in keys) {
      await flutterSecureStorage.delete(key: key);
    }
  }
}
