import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart';

class UrlTrimmer {
  UrlTrimmer._();
  static void trimWith() {
    if (kIsWeb) {
      final url = window.location.href;
      final parts = url.split("#");
      parts[0] = parts[0].split("?")[0];
      final newUrl = parts.join("#");
      if (url != newUrl) {
        window.location.href = newUrl;
      }
    }
  }
}
