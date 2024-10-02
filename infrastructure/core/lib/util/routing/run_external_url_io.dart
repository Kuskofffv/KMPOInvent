import 'package:common/dependencies.dart';
// ignore: implementation_imports
import 'package:url_launcher/src/url_launcher_string.dart';

class RunExternalUrl {
  void runInSameTab(String link) {
    launchUrlString(link);
  }

  String get href => "";

  String get origin => "";
}
