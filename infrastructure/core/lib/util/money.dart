import 'package:intl/intl.dart';

class PriceUtil {
  PriceUtil._();

  static String formatRubPrice(int pricePence) {
    final oCcy = NumberFormat("#,##0.00", "en_US");
    // ignore: lines_longer_than_80_chars
    return "${oCcy.format(pricePence / 100).replaceAll(".00", "").replaceAll(",", " ")} ₽";
  }
}
