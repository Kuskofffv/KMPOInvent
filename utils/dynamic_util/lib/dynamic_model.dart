import 'dart:convert';
import 'package:core/util/extension/extensions.dart';
import 'package:core/util/globals.dart';
import 'package:core/util/util.dart';

/// [DynamicModel] is a utility class that provides a flexible way
/// to work with dynamic data structures.
/// It wraps a [Map]<String, Object> and provides methods
/// to safely access and manipulate its data.
class DynamicModel {
  /// The wrapped map.
  final Map<String, Object?> map;

  /// Default constructor, initializes an empty map.
  DynamicModel() : map = <String, Object?>{};

  /// Default constructor, initializes an empty map.
  DynamicModel._(this.map);

  /// Constructor that initializes the map with the given values.
  factory DynamicModel.create(Map? from) {
    if (from is Map<String, Object?>) {
      return DynamicModel._(from);
    } else {
      return DynamicModel._(Map<String, Object?>.from(from ?? {}));
    }
  }

  /// Attempts to parse a JSON string into a DynamicModel.
  /// If parsing fails, returns an empty DynamicModel.
  factory DynamicModel.parseOrEmpty(String text) {
    try {
      final parsed = json.decode(text);
      if (parsed is Map) {
        return DynamicModel.create(parsed);
      }
    } catch (_) {}
    return DynamicModel();
  }

  /// Attempts to parse a JSON string into a DynamicModel.
  /// If parsing fails, returns null.
  static DynamicModel? parseOrNull(String text) {
    try {
      final parsed = json.decode(text);
      return DynamicModel.create(parsed);
    } catch (_) {}
    return null;
  }

  /// Returns a list of DynamicModels from the map's value at the given key,
  /// if it is a list of maps.
  List<DynamicModel>? dynamicListOpt(String listKey) {
    final list = map[listKey];
    if (list is List) {
      try {
        return list.map<DynamicModel>((it) {
          return DynamicModel.create(it);
        }).toList();
      } catch (e) {
        logger.e(e.toString(), error: e);
        return null;
      }
    }
    return null;
  }

  List<List<DynamicModel>>? dynamicMatrixOpt(String listKey) {
    final list = map[listKey];
    if (list is List) {
      try {
        return list.map<List<DynamicModel>>((it) {
          return it.map<DynamicModel>((it) {
            return DynamicModel.create(it);
          }).toList();
        }).toList();
      } catch (e) {
        logger.e(e.toString(), error: e);
        return null;
      }
    }
    return null;
  }

  /// Returns the first DynamicModel from the map's value at the given key,
  /// if it is a list of maps.
  DynamicModel? firstDynamicOpt(String listKey) {
    final list = map[listKey];
    if (list is List && list.isNotEmpty) {
      try {
        return DynamicModel.create(list.first);
      } on Object {
        return null;
      }
    }
    return null;
  }

  DynamicModel? lastDynamicOpt(String listKey) {
    final list = map[listKey];
    if (list is List && list.isNotEmpty) {
      try {
        return DynamicModel.create(list.last);
      } on Object {
        return null;
      }
    }
    return null;
  }

  /// Returns the DynamicModel at the given index from the map's value
  /// at the given key, if it is a list of maps.
  DynamicModel? dynamicByIndexOpt(String listKey, int index) {
    final list = map[listKey];
    if (list is List<Map<String, Object>> && list.length > index) {
      return DynamicModel.create(list[index]);
    }
    return null;
  }

  /// Returns the first DynamicModel from the map's value at the given key
  /// that satisfies the given test, if it is a list of maps.
  DynamicModel? firstDynamicWhereOpt(
      String listKey, bool Function(DynamicModel data) test) {
    final list = map[listKey];
    if (list is List<Map<String, Object>>) {
      for (final item in list) {
        final dynamicItem = DynamicModel.create(item);
        if (test(dynamicItem)) {
          return dynamicItem;
        }
      }
    }
    return null;
  }

  /// Returns the raw list of maps from the map's value at the given key,
  /// if it is a list of maps.
  List<Map<String, Object>>? rawListOpt(String listKey) {
    final list = map[listKey];
    if (list is List<Map<String, Object>>) {
      return list;
    }
    return null;
  }

  /// Returns a list of strings from the map's value at the given key,
  /// if it is a list.
  List<String>? stringListOpt(String listKey) {
    final list = map[listKey];
    if (list is List<dynamic>) {
      return list.map<String>((it) => it.toString()).toList();
    }
    return null;
  }

  /// Returns a list of doubles from the map's value at the given key,
  /// if it is a list of numbers.
  List<double>? doubleListOpt(String listKey) {
    final list = map[listKey];
    if (list is List<num>) {
      return list.map<double>((it) => it.toDouble()).toList();
    }
    return null;
  }

  /// Returns a list of integers from the map's value at the given key,
  /// if it is a list of numbers.
  List<int>? intListOpt(String listKey) {
    final list = map[listKey];
    if (list is List<num>) {
      return list.map<int>((it) => it.toInt()).toList();
    }
    return null;
  }

  /// Returns a DynamicModel from the map's value at the given key,
  /// if it is a map.
  DynamicModel? dynamicOpt(String key) {
    final data = map[key];
    if (data is Map) {
      try {
        return DynamicModel.create(data);
      } on Object {
        return null;
      }
    }
    return null;
  }

  /// Returns a list of the map's keys.
  List<String> keys() {
    return map.keys.toList();
  }

  /// Returns a list of results of applying the given function
  /// to each DynamicModel in the list at the given key,
  /// excluding null results.
  List<T>? mapNoNull<T>(String listKey, T? Function(DynamicModel data) test) {
    return dynamicListOpt(listKey)?.mapNotNull(test);
  }

  /// Combines the DynamicModels in the list at the given key into
  /// a single value using the given combine function.
  T? foldOpt<T>(String listKey, T initialValue,
      T Function(T previousValue, DynamicModel element) combine) {
    return dynamicListOpt(listKey)?.fold<T>(initialValue, combine);
  }

  /// Removes all elements from the list at the given key
  /// that satisfy the given test.
  void removeFromListWhere(String key, bool Function(DynamicModel data) test) {
    final list = map[key];
    if (list is List<Map<String, Object>>) {
      list.removeWhere((element) {
        return test(DynamicModel.create(element));
      });
    }
  }

  /// Adds a DynamicModel to the list at the given key.
  bool addToList(String listKey, DynamicModel data) {
    var list = map[listKey];
    if (list == null) {
      list = <Map<String, Object>>[];
      map[listKey] = list;
    }
    if (list is List<Map<String, Object?>>) {
      list.add(data.map);
      return true;
    }
    return false;
  }

  /// Inserts a DynamicModel at the given index in the list at the given key.
  bool insertToList(String listKey, int index, DynamicModel data) {
    var list = map[listKey];
    if (list == null) {
      list = <Map<String, Object>>[];
      map[listKey] = list;
    }
    if (list is List<Map<String, Object?>>) {
      if (index <= list.length) {
        list.insert(index, data.map);
      } else {
        list.add(data.map);
      }
      return true;
    }
    return false;
  }

  /// Removes the element at the given index from the list at the given key.
  bool removeFromListAt(String listKey, int index) {
    final list = map[listKey];
    if (list == null) {
      return false;
    }
    if (list is List<dynamic>) {
      return list.removeAt(index);
    }
    return false;
  }

  /// Returns the value at the given key if it is of type T,
  /// otherwise returns null.
  T? getOpt<T>(String key) {
    final data = map[key];
    if (data is T) {
      return data;
    }
    return null;
  }

  /// Removes the value at the given key from the map.
  bool remove(String key) {
    if (map[key] != null) {
      map.remove(key);
      return true;
    }
    return false;
  }

  /// Returns the value at the given path of keys if it is of type T,
  /// otherwise returns null.
  T? fromPathOpt<T>(List<Object> keys) {
    try {
      final n = keys.length;
      dynamic mapLocal = map;
      for (int i = 0; i < n; i++) {
        final key = keys[i];
        mapLocal = mapLocal[key];
      }
      if (T is DynamicModel) {
        return DynamicModel.create(mapLocal) as T;
      } else if (T is List<DynamicModel>) {
        if (mapLocal is List<Map<String, Object>>) {
          return mapLocal.map(DynamicModel.create).toList() as T;
        }
      }
      return mapLocal.asOrNull<T>();
    } catch (_) {}

    return null;
  }

  /// Copies the value at the given key from the other DynamicModel to this one.
  void copyValueFrom(DynamicModel? other, String key) {
    set(key, other?.map[key]);
  }

  /// Copies all values from the other DynamicModel to this one.
  void copyAllFrom(DynamicModel? other) {
    if (other != null) {
      for (final key in other.keys()) {
        set(key, other.getOpt(key));
      }
    }
  }

  /// Copies the values at the given keys from
  /// the other DynamicModel to this one.
  void copyValuesFrom(DynamicModel? other, List<String> keys) {
    for (final key in keys) {
      copyValueFrom(other, key);
    }
  }

  /// Sets the value at the given key to the given value.
  void set<T>(String key, T? value) {
    if (value == null) {
      map.remove(key);
    } else if (value is Iterable) {
      if (value is List<DynamicModel> || value is! List) {
        final newList = <Map<String, Object?>>[];
        value.forEach((e) {
          if (e is DynamicModel) {
            newList.add(e.map);
          } else {
            newList.add(e);
          }
        });
        map[key] = newList;
      } else {
        map[key] = value;
      }
    } else if (value is DynamicModel) {
      map[key] = value.map;
    } else {
      map[key] = value;
    }
  }

  /// Returns the string value at the given key, if it exists.
  String? stringOpt(String key) {
    return getOpt<String>(key);
  }

  /// Returns the boolean value at the given key, if it exists.
  bool? boolOpt(String key) {
    return getOpt<bool>(key);
  }

  /// Returns the integer value at the given key, if it exists.
  int? intOpt(String key) {
    return getOpt<int>(key);
  }

  /// Returns the length of the list at the given key, if it exists.
  int? lengthOpt(String key) {
    return getOpt<List>(key)?.length;
  }

  /// Returns the double value at the given key, if it exists.
  double? doubleOpt(String key) {
    return getOpt<num>(key)?.toDouble();
  }

  /// Returns a JSON string representation of the map.
  @override
  String toString() {
    return json.encode(map);
  }

  /// Returns a pretty-printed JSON string representation of the map.
  String toPrettyString() {
    const JsonDecoder decoder = JsonDecoder();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final object = decoder.convert(toString());
    final prettyString = encoder.convert(object);
    return prettyString;
  }

  /// Returns the hash code of the map.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => SRUtil.hash(map);

  /// Checks if the other object has the same hash code.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }

  /// Returns a clone of this DynamicModel.
  DynamicModel clone() {
    return DynamicModel.parseOrEmpty(toString());
  }

  /// Clears all entries from the map.
  void clear() {
    map.clear();
  }

  /// Returns the json representation.
  Map<String, Object?> toJson() {
    return map;
  }

  /// Constructor that initializes DynamicModel with dynamic value.
  // ignore: prefer_constructors_over_static_methods
  static DynamicModel fromJson(dynamic jsonData) {
    return DynamicModel.create(jsonData);
  }
}
