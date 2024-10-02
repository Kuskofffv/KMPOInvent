library extensions;

import 'dart:collection';
import 'dart:core';
import 'dart:math' as math;

import 'package:core/util/simple.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util.dart';

export 'extensions.dart';

part 'boolean_methods.dart';
part 'color.dart';
part 'pair.dart';
part 'string_methods.dart';
part 'object.dart';

class Ext {}

extension IterableExtensions<T> on Iterable<T>? {
  T? getOrNull(int index) {
    if (this == null) {
      return null;
    }
    try {
      return SRUtil.cast<T>(this?.elementAt(index));
    } on Object {}
    return null;
  }

  T? get lastOrNull => this.isNullOrEmpty() ? null : this!.last;

  /// Returns first element by given predicate or null otherwise
  T? lastWhereOrNull(bool Function(T element) test) {
    if (this == null) {
      return null;
    }
    T? result;
    for (final item in this!) {
      if (test(item)) {
        result = item;
      }
    }
    return result;
  }

  //

  bool isNullOrEmpty() => this == null || this!.isEmpty;

  /// Returns `false` if this nullable iterable is either `null` or empty.
  bool isNotNullOrEmpty() => this != null && this!.isNotEmpty;

  /// Returns `true` if at least one element matches the given [predicate].
  bool any(bool Function(T element) predicate) {
    if (this.isNullOrEmpty()) {
      return false;
    }
    for (final element in this!) {
      if (predicate(element)) {
        return true;
      }
    }
    return false;
  }

  /// Returns count of elements that matches the given [predicate].
  /// Returns -1 if iterable is null
  int countWhere(bool Function(T element) predicate) {
    if (this == null) {
      return -1;
    }
    var counter = 0;
    for (final item in this!) {
      if (predicate(item)) {
        counter++;
      }
    }
    return counter;
  }

  /// Convert iterable to set
  Set<T> toSet() => Set.from(this!);

  /// Returns a set containing all elements that are contained
  /// by both this set and the specified collection.
  Set<T> intersect(Iterable other) => toSet()..retainAll(other);

  /// Returns a set containing all elements that are contained
  /// by this collection and not contained by the specified collection.
  Set<T> subtract(Iterable<T> other) => toSet()..removeAll(other);

  /// Returns a set containing all distinct elements from both collections.
  Set<T> union(Iterable<T> other) => toSet()..addAll(other);

  /// Performs the given action on each element on iterable,
  /// providing sequential index with the element.
  /// [element!] the element on the current iteration
  /// [index!] the index of the current iteration
  ///
  /// example:
  /// ["ss","tt","xx"].forEachIndexed((it, index) {
  ///    print("it, $index");
  ///  });
  /// result:
  /// ss, 0
  /// tt, 1
  /// xx, 2
  void forEachIndexed(void Function(T element, int index) action) {
    var index = 0;
    for (final element in this!) {
      action(element, index++);
    }
  }

  /// Groups elements of the original collection by the key returned
  /// by the given [keySelector] function
  /// applied to each element and returns a map where each group key
  /// is associated with a list of corresponding elements.
  ///
  /// The returned map preserves the entry iteration order of
  /// the keys produced from the original collection.
  Map<K, List<T>> groupBy<K>(K Function(T e) keySelector) {
    if (this == null) {
      return {};
    }
    final map = <K, List<T>>{};

    for (final element in this!) {
      map.putIfAbsent(keySelector(element), () => []).add(element);
    }
    return map;
  }

  /// Returns a list containing only elements matching the given [predicate!]
  List<T> filter(bool Function(T element) test) {
    if (this == null) {
      return <T>[];
    }
    final result = <T>[];
    for (final e in this!) {
      if (test(e)) {
        result.add(e);
      }
    }
    return result;
  }

  List<T> sortBy<D extends Comparable<D>>(D Function(T element) test) {
    if (this == null) {
      return <T>[];
    }
    return this!.toList()..sort((e1, e2) => test(e1).compareTo(test(e2)));
  }

  List<T> sortDescBy<D extends Comparable<D>>(D Function(T element) test) {
    if (this == null) {
      return <T>[];
    }
    return this!.toList()..sort((e1, e2) => test(e2).compareTo(test(e1)));
  }

  List<T>? notEmpty() {
    if (this == null || this!.isEmpty) {
      return null;
    }
    return SRUtil.cast<List<T>>(this) ?? this?.toList();
  }

  List<K> mapNotNull<K>(K? Function(T element) test) {
    if (this == null) {
      return <K>[];
    }
    final result = <K>[];
    for (final e in this!) {
      final e2 = test(e);
      if (e2 != null) {
        result.add(e2);
      }
    }
    return result;
  }

  List<K> mapIndexed<K>(K Function(T element, int index) test) {
    if (this == null) {
      return <K>[];
    }
    final result = <K>[];

    this!.forEachIndexed((e, index) {
      final e2 = test(e, index);
      result.add(e2);
    });
    return result;
  }

  K? minByOrNull<K extends num>(K Function(T element) test) {
    if (this == null || this.isNullOrEmpty()) {
      return null;
    }

    var minValue = test(this!.first);

    for (final e in this!) {
      minValue = math.min(minValue, test(e));
    }

    return minValue;
  }

  K? maxByOrNull<K extends num>(K Function(T element) test) {
    if (this == null || this.isNullOrEmpty()) {
      return null;
    }

    var maxValue = test(this!.first);

    for (final e in this!) {
      maxValue = math.max(maxValue, test(e));
    }

    return maxValue;
  }

  List<K> mapNotNullIndexed<K>(K? Function(T element, int index) test) {
    if (this == null) {
      return <K>[];
    }
    final result = <K>[];

    this!.forEachIndexed((e, index) {
      final e2 = test(e, index);
      if (e2 != null) {
        result.add(e2);
      }
    });
    return result;
  }

  List<K> expandIndexed<K>(List<K> Function(T element, int index) test) {
    if (this == null) {
      return <K>[];
    }
    final result = <K>[];

    this!.forEachIndexed((e, index) {
      final e2 = test(e, index);
      result.addAll(e2);
    });
    return result;
  }

  List<K> expandNotNullIndexed<K>(
      List<K?> Function(T element, int index) test) {
    if (this == null) {
      return <K>[];
    }
    final result = <K>[];

    this!.forEachIndexed((e, index) {
      final e2 = test(e, index);
      result.addAllOrNot(e2);
    });
    return result;
  }

  /// Returns a list containing all elements not matching the given [predicate!]
  List<T> filterNot(bool Function(T element) test) {
    if (this == null) {
      return <T>[];
    }
    final result = <T>[];
    for (final e in this!) {
      if (!test(e)) {
        result.add(e);
      }
    }
    return result;
  }

  /// Returns a list containing all elements that are not null
  List<T> filterNotNull() {
    if (this == null) {
      return <T>[];
    }
    final result = <T>[];
    for (final e in this!) {
      if (e != null) {
        result.add(e);
      }
    }
    return result;
  }

  /// Returns a list containing first [n] elements.
  List<T> take(int n) {
    if (this == null) {
      return <T>[];
    }
    if (n <= 0) {
      return [];
    }

    final list = <T>[];
    if (this is Iterable) {
      if (n >= this!.length) {
        return this!.toList();
      }

      var count = 0;
      final thisList = this!.toList();
      for (final item in thisList) {
        list.add(item);
        if (++count == n) {
          break;
        }
      }
    }
    return list;
  }

  /// Returns a list containing only elements from the given collection
  // having distinct keys returned by the given [selector] function.
  //
  // The elements in the resulting list are in the same order as they were
  //in the source collection.
  List<T> distinctBy<K>(K Function(T obj) block) {
    if (this == null) {
      return <T>[];
    }
    final set = HashSet<K>();
    final list = <T>[];
    for (final e in this!) {
      final key = block(e);
      if (set.add(key)) {
        list.add(e);
      }
    }
    return list;
  }

  /// Returns first element or null otherwise
  T? get firstOrNull => this.isNullOrEmpty() ? null : this!.first;

  /// Returns first element by given predicate or null otherwise
  T? firstWhereOrNull(bool Function(T element) test) {
    if (this == null) {
      return null;
    }
    for (final item in this!) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }

  /// Returns true if at least one element is in the given list
  bool containsWhere(bool Function(T element) test) {
    return this.firstWhereOrNull(test) != null;
  }
}

extension ListExtensions<T> on List<T?>? {
  void addOrNot(T? data) {
    try {
      this?.add(data);
    } on Object {}
  }

  void addAllOrNot(Iterable<T?>? list) {
    try {
      if (list != null) {
        for (final item in list) {
          addOrNot(item);
        }
      }
    } on Object {}
  }
}

extension SessiaStringExtensions on String {
  bool startWithAnyOf(List<String> array) {
    for (final it in array) {
      if (startWithIgnoreCase(it)) {
        return true;
      }
    }
    return false;
  }

  bool startWithIgnoreCase(String value) =>
      toLowerCase().startsWith(value.toLowerCase());

  String capitalize() =>
      '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String? notEmpty() {
    final value = trim();
    if (value.isEmpty) {
      return null;
    }
    return value;
  }

  String withMaxLength(int max) {
    if (length > max) {
      return substring(0, max);
    }
    return this;
  }

  String plus(String some) => '$this$some';
}

extension SessiaDoubleExtension on double {
  double? noZero() {
    if (this == 0.0) {
      return null;
    }
    return this;
  }
}

extension ColorExtensions on Color {
  bool get isDark => SRUtil.isDarkColor(this);
}

extension DateExtensions on DateTime {
  int _dayComparisonValue(DateTime date) =>
      date.year * (13 * 40) + date.month * 40 + date.day;

  bool isBeforeByDate(DateTime other) =>
      _dayComparisonValue(this) < _dayComparisonValue(other);

  bool isAfterByDate(DateTime other) =>
      _dayComparisonValue(this) > _dayComparisonValue(other);

  bool isSameDay(DateTime other) =>
      _dayComparisonValue(this) == _dayComparisonValue(other);
}
