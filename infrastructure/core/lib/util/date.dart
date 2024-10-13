// ignore_for_file: parameter_assignments, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'exception/app_exception.dart';

class DateFormatUtil {
  DateFormatUtil._();

  static const String defaultDateFormatter = "yyyy-MM-dd'T'HH:mm:ssZ";

  static int _subInt(String text, int startIndex, int endIndex) {
    int i = 0;
    for (var index = 0; index < endIndex - startIndex; index++) {
      i *= 10;
      final code = text.codeUnitAt(startIndex + index) - 48;
      if (code >= 0 && code < 10) {
        i += code;
      } else {
        throw AppException("${text[startIndex + index]} not int");
      }
    }
    return i;
  }

  static DateTime? fastParseIso8601(String text) {
    try {
      if (text.length == 24 && text[23] != "Z") {
        if (text[23] != "Z") {
          //ex. 2002-02-27T14:00:00-0500
          int h = 0;
          int m = 0;

          h = _subInt(text, 20, 22);
          m = _subInt(text, 22, 24);

          if (text[19] == '+') {
            h = -h;
            m = -m;
          }

          return DateTime.utc(
            _subInt(text, 0, 4),
            _subInt(text, 5, 7),
            _subInt(text, 8, 10),
            _subInt(text, 11, 13) + h,
            _subInt(text, 14, 16) + m,
            _subInt(text, 17, 19),
          );
        } else {
          //ex. 2023-07-01 06:00:00.000Z
          return DateTime.utc(
            _subInt(text, 0, 4),
            _subInt(text, 5, 7),
            _subInt(text, 8, 10),
            _subInt(text, 11, 13),
            _subInt(text, 14, 16),
            _subInt(text, 17, 19),
          );
        }
      }
    } on Object {}

    return null;
  }

  static DateTime? dateFromStr(String? text,
      {String? formatter = defaultDateFormatter,
      bool utc = false,
      String locale = "ru"}) {
    if (text == null) {
      return null;
    } else if (formatter == null || formatter == defaultDateFormatter) {
      var date = fastParseIso8601(text) ?? DateTime.tryParse(text);
      if (!utc) {
        date = date?.toLocal();
      }
      return date;
    } else {
      try {
        return DateFormat(formatter, locale).parse(text, utc);
      } on Object {
        return null;
      }
    }
  }

  static String? strFromDate(DateTime? date,
      {String? formatter = defaultDateFormatter, String locale = "ru"}) {
    if (date == null) {
      return null;
    } else if (formatter == null) {
      return date.toIso8601String();
    } else if (formatter == defaultDateFormatter) {
      String timezoneText;
      if (!date.isUtc) {
        final h = (date.timeZoneOffset.inMinutes ~/ 60).abs();
        final m = (date.timeZoneOffset.inMinutes % 60).abs();
        timezoneText =
            "${date.timeZoneOffset.isNegative ? "-" : "+"}${h < 10 ? "0" : ""}$h${m < 10 ? "0" : ""}$m";
      } else {
        timezoneText = "+0000";
      }

      return "${date.year}-${date.month < 10 ? "0" : ""}${date.month}"
          "-${date.day < 10 ? "0" : ""}${date.day}"
          "T${date.hour < 10 ? "0" : ""}${date.hour}"
          ":${date.minute < 10 ? "0" : ""}${date.minute}"
          ":${date.second < 10 ? "0" : ""}${date.second}"
          "$timezoneText";
    } else {
      try {
        if (formatter.contains("Z")) {
          if (!date.isUtc) {
            final h = (date.timeZoneOffset.inMinutes ~/ 60).abs();
            final m = (date.timeZoneOffset.inMinutes % 60).abs();
            formatter = formatter.replaceAll("Z",
                "'${date.timeZoneOffset.isNegative ? "-" : "+"}${strFromDate(DateTime(0, 0, 0, h, m), formatter: "HHmm")}'");
          } else {
            formatter = formatter.replaceAll("Z", "+0000");
          }
        }
        return DateFormat(formatter, locale).format(date);
      } on Object {
        return null;
      }
    }
  }

  static Duration get timeZoneOffset => DateTime.now().timeZoneOffset;
  static bool _isFirstTimeAgo = true;
  static String? timeAgo(DateTime? date, {String locale = "ru"}) {
    if (date == null) {
      return null;
    }

    if (_isFirstTimeAgo) {
      _isFirstTimeAgo = false;
      //Русский
      timeago.setLocaleMessages('ru', timeago.RuMessages());
      //English
      timeago.setLocaleMessages('en', timeago.EnMessages());
      //香港繁體 (HK)
      timeago.setLocaleMessages('hk', timeago.ZhMessages());
      //繁體中文 - 台灣 (TW)
      timeago.setLocaleMessages('tw', timeago.ZhMessages());
      //简体中文 (CN)
      timeago.setLocaleMessages('cn', timeago.ZhCnMessages());
      //Deutschland (DE)
      timeago.setLocaleMessages('de', timeago.DeMessages());
      //tiếng Việt (VN)
      timeago.setLocaleMessages('vn', timeago.ViMessages());
      //Каза́хский (KZ)
      //timeago.setLocaleMessages('kz', KzMessages());
      //Azərbaycan (AZ)
      timeago.setLocaleMessages('az', timeago.AzMessages());
      //Български (BG)
      //timeago.setLocaleMessages('bg', BgMessages());
      //Polski (PL)
      timeago.setLocaleMessages('pl', timeago.PlMessages());
      //Српски (RS)
      //timeago.setLocaleMessages('rs', RsMessages());
      //Latviešu (LV)
      //timeago.setLocaleMessages('lv', LvMessages());
      //Lithuanian (LT)
      //timeago.setLocaleMessages('lt', LtMessages());
      //한국어 (KO)
      timeago.setLocaleMessages('ko', timeago.KoMessages());
      //Italiano (IT)
      timeago.setLocaleMessages('it', timeago.ItMessages());
      //Монгольский (MN)
      timeago.setLocaleMessages('mn', timeago.MnMessages());
      //Узбекский (UZ)
      //timeago.setLocaleMessages('uz', UzMessages());
      //Português (PT)
      timeago.setLocaleMessages('pt', timeago.PtBrMessages());
    }

    final diff = DateTime.now().difference(date);

    if (diff.inDays > 7) {
      return getYMMMdFormatter(locale: locale).format(date);
    }

    return timeago.format(date, locale: locale);
  }

  static final _mapYMMMdFormatters = <String, DateFormat>{};
  static DateFormat getYMMMdFormatter({String locale = "ru"}) {
    var formatter = _mapYMMMdFormatters[locale];
    if (formatter == null) {
      formatter = DateFormat.yMMMd(locale);
      _mapYMMMdFormatters[locale] = formatter;
    }
    return formatter;
  }

  static final _mapYMMMMdFormatters = <String, DateFormat>{};
  static DateFormat getYMMMMdFormatter({String locale = "ru"}) {
    var formatter = _mapYMMMMdFormatters[locale];
    if (formatter == null) {
      formatter = DateFormat.yMMMMd(locale);
      _mapYMMMMdFormatters[locale] = formatter;
    }
    return formatter;
  }
}

class TDateUtils {
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy');
  static final DateFormat _dayFormat = DateFormat('dd');
  static final DateFormat _firstDayFormat = DateFormat('MMM dd');
  static final DateFormat _fullDayFormat = DateFormat('EEE MMM dd, yyyy');
  static final DateFormat _apiDayFormat = DateFormat('yyyy-MM-dd');

  static String formatMonth(DateTime d) => _monthFormat.format(d);

  static String formatDay(DateTime d) => _dayFormat.format(d);

  static String formatFirstDay(DateTime d) => _firstDayFormat.format(d);

  static String fullDayFormat(DateTime d) => _fullDayFormat.format(d);

  static String apiDayFormat(DateTime d) => _apiDayFormat.format(d);

  static const List<String> weekdays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  /// The list of days in a given month
  static List<DateTime> daysInMonth(DateTime month) {
    final first = firstDayOfMonth(month);
    final daysBefore = first.weekday;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));
    final last = TDateUtils.lastDayOfMonth(month);

    var daysAfter = 7 - last.weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    final lastToDisplay = last.add(Duration(days: daysAfter));
    return daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  static bool isFirstDayOfMonth(DateTime day) {
    return isSameDay(firstDayOfMonth(day), day);
  }

  static bool isLastDayOfMonth(DateTime day) {
    return isSameDay(lastDayOfMonth(day), day);
  }

  static DateTime firstDayOfMonth(DateTime month) {
    return DateTime(month.year, month.month);
  }

  static DateTime firstDayOfWeek(DateTime day) {
    /// Handle Daylight Savings by setting hour to 12:00 Noon
    /// rather than the default of Midnight
    day = DateTime.utc(day.year, day.month, day.day, 12);

    /// Weekday is on a 1-7 scale Monday - Sunday,
    /// This Calendar works from Sunday - Monday
    final decreaseNum = day.weekday % 7;
    return day.subtract(Duration(days: decreaseNum));
  }

  static DateTime lastDayOfWeek(DateTime day) {
    /// Handle Daylight Savings by setting hour to 12:00 Noon
    /// rather than the default of Midnight
    day = DateTime.utc(day.year, day.month, day.day, 12);

    /// Weekday is on a 1-7 scale Monday - Sunday,
    /// This Calendar's Week starts on Sunday
    final increaseNum = day.weekday % 7;
    return day.add(Duration(days: 7 - increaseNum));
  }

  /// The last day of a given month
  static DateTime lastDayOfMonth(DateTime month) {
    final beginningNextMonth = (month.month < 12)
        ? DateTime(month.year, month.month + 1, 1)
        : DateTime(month.year + 1, 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1));
  }

  /// Returns a [DateTime] for each day the given range.
  ///
  /// [start] inclusive
  /// [end] exclusive
  static Iterable<DateTime> daysInRange(DateTime start, DateTime end) sync* {
    var i = start;
    var offset = start.timeZoneOffset;
    while (i.isBefore(end)) {
      yield i;
      i = i.add(const Duration(days: 1));
      final timeZoneDiff = i.timeZoneOffset - offset;
      if (timeZoneDiff.inSeconds != 0) {
        offset = i.timeZoneOffset;
        i = i.subtract(Duration(seconds: timeZoneDiff.inSeconds));
      }
    }
  }

  /// Whether or not two times are on the same day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameWeek(DateTime a, DateTime b) {
    /// Handle Daylight Savings by setting hour to 12:00 Noon
    /// rather than the default of Midnight
    a = DateTime.utc(a.year, a.month, a.day);
    b = DateTime.utc(b.year, b.month, b.day);

    final diff = a.toUtc().difference(b.toUtc()).inDays;
    if (diff.abs() >= 7) {
      return false;
    }

    final min = a.isBefore(b) ? a : b;
    final max = a.isBefore(b) ? b : a;
    final result = max.weekday % 7 - min.weekday % 7 >= 0;
    return result;
  }

  static DateTime previousMonth(DateTime m) {
    var year = m.year;
    var month = m.month;
    if (month == 1) {
      year--;
      month = 12;
    } else {
      month--;
    }
    return DateTime(year, month);
  }

  static DateTime nextMonth(DateTime m, {int months = 1}) {
    var year = m.year;
    var month = m.month;

    for (int i = 0; i < months; i++) {
      if (month == 12) {
        year++;
        month = 1;
      } else {
        month++;
      }
    }

    int day = m.day;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    if (day >= daysInMonth) {
      day = daysInMonth;
    }

    return DateTime(year, month, day, m.hour, m.minute, m.second);
  }

  static DateTime previousWeek(DateTime w) {
    return w.subtract(const Duration(days: 7));
  }

  static DateTime nextWeek(DateTime w) {
    return w.add(const Duration(days: 7));
  }
}
