import 'dart:math';

import 'package:core/util/extension/extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

var _emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
// ignore: unused_element
var _emailRegexDroid = RegExp(
    r"^[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+$");
// ignore: unused_element
RegExp _phoneRegex = RegExp(
    r"^(\+[0-9]+[\- \.]*)?(\([0-9]+\)[\- \.]*)?([0-9][0-9\- \.]+[0-9])$");
// ignore: unused_element
RegExp _imeiRegex = RegExp(r"^[0-9]{15,16}$");

class SRUtil {
  SRUtil._();

  /// Safe type casting
  static T? cast<T>(Object? obj) {
    if (obj is T) {
      return obj;
    }
    return null;
  }

  /// Color is dark or light
  static bool isDarkColor(Color color) {
    final darkness = 1 -
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return darkness >= 0.4;
  }

  /// Hide keyboard when it's shown
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static int hash(dynamic data) {
    return _hash(data);
  }

  static int _hash(dynamic data) {
    int result = 0;

    if (data is Map) {
      var hashValue = 121;
      for (final element in data.entries) {
        final keyValueHash = element.key.hashCode + 21 * _hash(element.value);
        hashValue = _Jenkins.finish(hashValue + 21 * keyValueHash);
      }
      result = hashValue;
    } else if (data is Iterable) {
      var hashValue = 21;
      for (final element in data) {
        hashValue = _Jenkins.finish(hashValue + 21 * _hash(element));
      }
      result = hashValue;
    } else if (data == null) {
      result = 21;
    } else {
      result = data.hashCode + 21;
    }

    return _Jenkins.finish(result);
  }

  static int randomInt() {
    const int int64MaxValue = 92233720;
    return Random().nextInt(int64MaxValue);
  }

  static String? validatePassword(String? password1, String? password2,
      {int minLength = 6}) {
    if (password1 == null || password1.isEmpty) {
      return 'Заполните поле';
    } else if (password1 != password2) {
      return 'Пароли не совпадают';
    } else if (password1.length < minLength) {
      return 'Используете более $minLength ${Intl.plural(minLength, one: 'символа', other: 'символов')}';
    } else if (!RegExp('[a-z]').hasMatch(password1.toLowerCase())) {
      return 'Используйте хотя бы одну прописную букву (a-Z)';
    } else if (!RegExp('[0-9]').hasMatch(password1)) {
      return 'Используйте хотя бы одну цифру';
    } else if (!RegExp(r'[!@#$%^&*()\-_=+\[\]{}|;:,.<>?\/`~]')
        .hasMatch(password1)) {
      return 'Используйте хотя бы один спецсимвол';
    }
    return null;
  }

  static String? validateEmail(String? value, {bool required = true}) {
    if (required && value.isNullOrEmptyTrimmed()) {
      return 'Заполните поле';
    }

    if (value.isNotNullOrEmptyTrimmed() &&
        !_emailRegex.hasMatch(value!.trim())) {
      return 'Неправильный формат почты';
    }
    return null;
  }

  static String? validatePhone(String? value, {bool required = true}) {
    if (required && value.isNullOrEmptyTrimmed()) {
      return 'Заполните поле';
    }
    if (value.isNotNullOrEmptyTrimmed() &&
        !RegExp(r'^[+()-\d#]+$').hasMatch(value!.trim())) {
      return 'Неправильный формат номера телефона';
    }
    return null;
  }
}

class _Jenkins {
  _Jenkins._();

  // ignore: unused_element
  static int combine(int hash, int value) {
    int hashLocal = 0x1fffffff & (hash + value);
    hashLocal = 0x1fffffff & (hashLocal + ((0x0007ffff & hashLocal) << 10));
    return hashLocal ^ (hashLocal >> 6);
  }

  static int finish(int hash) {
    int hashLocal = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hashLocal = hashLocal ^ (hashLocal >> 11);
    return 0x1fffffff & (hashLocal + ((0x00003fff & hashLocal) << 15));
  }
}
