part of extensions;

extension StringExtensions on String? {
  /// Returns `true` if this nullable char sequence is either `null` or empty.
  bool isNullOrEmpty() => this == null || this!.isEmpty;

  bool isNullOrEmptyTrimmed() => this == null || this!.trim().isEmpty;

  /// Returns `false` if this nullable char sequence is either `null` or empty.
  bool isNotNullOrEmpty() => this != null && this!.isNotEmpty;

  bool isNotNullOrEmptyTrimmed() => this != null && this!.trim().isNotEmpty;

  /// Returns a progression that goes over the same range
  /// in the opposite direction with the same step.
  String reversed() {
    var res = '';
    for (int i = this!.length; i >= 0; --i) {
      res = this![i];
    }
    return res;
  }

  /// Returns the value of this number as an [int]
  int toInt() => int.parse(this!);

  /// Returns the value of this number as an [int] or null if can not be parsed.
  int? toIntOrNull() {
    if (this == null) {
      return null;
    }
    return int.tryParse(this!);
  }

  /// Returns the value of this number as an [double]
  double toDouble() => double.parse(this!);

  /// Returns the value of this number as an [double]
  /// or null if can not be parsed.
  double? toDoubleOrNull() {
    if (this == null) {
      return null;
    }
    return double.tryParse(this!);
  }

  /// Returns true if 'this' is "true", otherwise - false
  bool toBoolean() => this?.toLowerCase() == 'true';

  ///  Replaces part of string after the first occurrence
  /// of given delimiter with the [replacement] string.
  ///  If the string does not contain the delimiter, returns
  /// [defaultValue] which defaults to the original string.
  String? replaceAfter(String delimiter, String replacement,
      [String? defaultValue]) {
    if (this == null) {
      return null;
    }
    final index = this!.indexOf(delimiter);
    return (index == -1)
        ? defaultValue!.isNullOrEmpty()
            ? this
            : defaultValue
        : this!.replaceRange(index + 1, this!.length, replacement);
  }

  /// Replaces part of string before the first occurrence of given delimiter
  ///  with the [replacement] string.
  ///  If the string does not contain the delimiter,
  /// returns [missingDelimiterValue!] which defaults to the original string.
  String? replaceBefore(String delimiter, String replacement,
      [String? defaultValue]) {
    if (this == null) {
      return null;
    }
    final index = this!.indexOf(delimiter);
    return (index == -1)
        ? defaultValue!.isNullOrEmpty()
            ? this
            : defaultValue
        : this!.replaceRange(0, index, replacement);
  }

  ///Returns `true` if at least one element matches the given [predicate].
  /// the [predicate] should have only one character
  bool anyChar(bool Function(String element) predicate) =>
      this?.split('').any((s) => predicate(s)) ?? false;

  /// Returns last symbol of string or empty string if `this` is null or empty
  String get last {
    if (isNullOrEmpty()) {
      return '';
    }
    return this![this!.length - 1];
  }

  /// Returns `true` if strings are equals without matching case
  bool equalsIgnoreCase(String? other) =>
      (this == null && other == null) ||
      (this != null &&
          other != null &&
          this?.toLowerCase() == other.toLowerCase());

  /// Returns `true` if string contains another without matching case
  bool containsIgnoreCase(String? other) {
    if (other == null) {
      return false;
    }
    return this?.toLowerCase().contains(other.toLowerCase()) ?? false;
  }

  Color? toColorOrNull() {
    if (this == null) {
      return null;
    }
    try {
      return fromHex(this!);
    } on Object {
      return null;
    }
  }

  Color toColor() => toColorOrNull()!;

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  void copyToClipboard({bool notify = false}) {
    if (this == null) {
      return;
    }
    Clipboard.setData(ClipboardData(text: this!));
    if (notify) {
      Simple.toast('Текст скопирован');
    }
  }

  void share() {
    if (this != null) {
      Simple.share(this!);
    }
  }
}
