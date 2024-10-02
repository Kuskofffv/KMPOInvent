// ignore: avoid_web_libraries_in_flutter
//import 'dart:html';
import 'package:web/web.dart';

/// Run external url in same tab
class RunExternalUrl {
  // ignore: use_setters_to_change_properties
  void runInSameTab(String link) {
    window.location.href = link;
  }

  String get href => window.location.href;

  String get origin => window.location.origin;
}
