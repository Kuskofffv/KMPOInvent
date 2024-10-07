part of 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// A class that provides a mechanism for showing system notifications in the app.
class ParseNotification {
  ParseNotification({required this.onShowNotification});

  final void Function(String value) onShowNotification;

  /// Show notification
  // ignore: type_annotate_public_apis
  void showNotification(title) {
    onShowNotification.call(title);
  }
}
