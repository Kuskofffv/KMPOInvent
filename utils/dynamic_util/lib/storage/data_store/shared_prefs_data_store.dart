import 'dart:convert';

import 'package:core/core_dependencies.dart';
import 'package:core/util/extension/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_store.dart';

class SharedPrefsDataStore<T> implements DataStore<T> {
  static const _eternalPostfix = '...eternal';
  final String name;
  final bool isEternalCache;
  late final String cacheKey = isEternalCache ? '$name$_eternalPostfix' : name;
  // ignore: avoid_positional_boolean_parameters
  SharedPrefsDataStore(this.name, this.isEternalCache);

  @override
  Future write(T? data) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (data == null) {
      await sharedPreferences.remove(cacheKey);
    } else {
      await sharedPreferences.setString(cacheKey, _encode(data));
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
    final sharedPreferences = await SharedPreferences.getInstance();
    final String? content = sharedPreferences.getString(cacheKey);
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
    final sharedPreferences = await SharedPreferences.getInstance();
    final keys = sharedPreferences.getKeys().filter(
        (element) => cleanEternalCache || !element.contains(_eternalPostfix));
    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }
}
