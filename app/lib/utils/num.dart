class NumUtil {
  NumUtil._();

  static String format(num num) {
    return num.toStringAsFixed(2).replaceAll(".00", "");
  }
}
