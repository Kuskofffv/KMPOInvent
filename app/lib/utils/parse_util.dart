import 'package:core/core_dependencies.dart';
import 'package:core/util/globals.dart';
import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<DynamicModel> parseFunc(String name,
    {Map<String, dynamic>? parameters}) async {
  final function = ParseCloudFunction(name);
  final p = parameters ?? {};
  final functionResult = await function
      .executeObjectFunction(parameters: p)
      .timeout(const Duration(seconds: 30));

  if (functionResult.success) {
    var result = functionResult.result?.get("result");
    if (result is List) {
      result = <String, Object?>{"items": result};
    } else if (result is! Map) {
      result = <String, Object?>{"result": result};
    }
    return DynamicModel.create(Map<String, Object?>.from(result));
  } else {
    if (kDebugMode) {
      logger.e(
          "func $name error:\n${functionResult.error?.message}\n${parameters ?? {}}",
          error: functionResult.error);
    }
    // ignore: only_throw_errors
    throw functionResult.error ?? Exception("Error");
  }
}

final ParseDateFormat parseDateFormat = ParseDateFormat();

/// This is the currently used date format. It is precise to the millisecond.
class ParseDateFormat {
  /// Deserialize an ISO-8601 full-precision extended format representation of date string into [DateTime].
  DateTime? parse(String strDate) {
    try {
      return DateTime.parse(strDate);
    } on FormatException {
      return null;
    }
  }

  /// Serialize [DateTime] into an ISO-8601 full-precision extended format representation.
  String format(DateTime datetime) {
    if (!datetime.isUtc) {
      // ignore: parameter_assignments
      datetime = datetime.toUtc();
    }

    final String y = _fourDigits(datetime.year);
    final String m = _twoDigits(datetime.month);
    final String d = _twoDigits(datetime.day);
    final String h = _twoDigits(datetime.hour);
    final String min = _twoDigits(datetime.minute);
    final String sec = _twoDigits(datetime.second);
    final String ms = _threeDigits(datetime.millisecond);

    return '$y-$m-${d}T$h:$min:$sec.${ms}Z';
  }

  static String _fourDigits(int n) {
    final int absN = n.abs();
    final String sign = n < 0 ? '-' : '';
    if (absN >= 1000) {
      return '$n';
    }
    if (absN >= 100) {
      return '${sign}0$absN';
    }
    if (absN >= 10) {
      return '${sign}00$absN';
    }
    return '${sign}000$absN';
  }

  static String _threeDigits(int n) {
    if (n >= 100) {
      return '$n';
    }
    if (n >= 10) {
      return '0$n';
    }
    return '00$n';
  }

  static String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }
}
