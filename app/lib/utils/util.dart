import 'dart:math';

import 'package:brigantina_invent/domain/const.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppUtil {
  AppUtil._();

  static final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
// ignore: unused_element
// var _emailRegexDroid = RegExp(
//     r"^[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+$");
// ignore: unused_element
  static final RegExp phoneRegex = RegExp(
      r"^(\+[0-9]+[\- \.]*)?(\([0-9]+\)[\- \.]*)?([0-9][0-9\- \.]+[0-9])$");
// ignore: unused_element
  static final RegExp imeiRegex = RegExp(r"^[0-9]{15,16}$");

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

  static void toast(Object? message, {bool isError = false}) {
    if (message == null) {
      return;
    }
    Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: isError ? Const.red : Const.green,
        textColor: Colors.white,
        fontSize: 16);
  }

  static void areYouSure(BuildContext context,
      {required String title,
      required String message,
      required String button,
      required VoidCallback onPerform}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(button),
              onPressed: () {
                Navigator.of(context).pop();
                onPerform();
              },
            ),
          ],
        );
      },
    );
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

/// Safe type casting
T? cast<T>(Object? obj) {
  if (obj is T) {
    return obj;
  }
  return null;
}
