import 'dart:convert';
import 'dart:io';

import 'package:core/core_dependencies.dart';
import 'package:core/util/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'data_store.dart';

class IODataStore<T> implements DataStore<T> {
  static const _eternalPostfix = '...eternal';
  final String name;
  final bool isEternalCache;
  late final String cacheKey = isEternalCache ? '$name$_eternalPostfix' : name;
  // ignore: avoid_positional_boolean_parameters
  IODataStore(this.name, this.isEternalCache);

  @override
  Future write(T? data) async {
    if (data == null) {
      final file = await _getLocalFile(cacheKey);
      await file.delete();
    } else {
      await WorkerManager.execIsolate2Args<Object, String, void>(
          _encodeToFile, data, await _getLocalFilePath(cacheKey));
    }
  }

  Future<File> _getLocalFile(String name) async {
    final file = File(await _getLocalFilePath(name));
    await file.parent.create(recursive: true);
    return file;
  }

  static final _cacheDirectoryPath = () async {
    return (await getApplicationCacheDirectory()).path;
  }();

  Future<String> _getLocalFilePath(String name) async {
    return '${await _cacheDirectoryPath}/$name';
  }

  Future<void> _encodeToFile(Object data, String path) async {
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
    final jsonStr = json.encode(map);
    await File(path).writeAsString(jsonStr);
  }

  @override
  Future<T?> read(T Function(Map<String, dynamic>) creator) async {
    final content = await WorkerManager.execIsolate(
        _decodeFile, await _getLocalFilePath(name));
    if (content == null) {
      return null;
    }
    return creator(content);
  }

  Map<String, dynamic>? _decodeFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }
    final String content = File(path).readAsStringSync();
    return json.decode(
      content,
    );
  }

  static Future clearAllStorages({bool cleanEternalCache = false}) async {
    try {
      final directory = await getApplicationCacheDirectory();
      await for (final file in directory.list()) {
        try {
          final name = file.path;
          if (cleanEternalCache || !name.contains(_eternalPostfix)) {
            await File(name).delete();
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
    } catch (error, stackTrace) {
      logger.e("IO clearAllStorages error",
          error: error, stackTrace: stackTrace);
    }
  }
}
