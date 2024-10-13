import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

const Duration _defaultDuration = Duration(milliseconds: 2300);

/// Simple is a utility class that provides simplified access
/// to external core libraries.
class Simple {
  /// Private constructor to prevent instantiation.
  Simple._();

  /// Displays a toast message with the given text.
  /// If 'bottom' is true, the toast will be displayed
  /// at the bottom of the screen, otherwise at the top.
  ///
  /// [text] is the message to be displayed in the toast.
  /// If null, no toast will be displayed.
  ///
  /// [bottom] is a boolean that determines the position of the toast.
  /// If true, the toast will be displayed at the bottom of the screen.
  /// If false, the toast will be displayed at the top of the screen.
  /// The default value is true.
  // ignore: avoid_void_async
  static void toast(Object? text,
      {bool bottom = true,
      Duration? duration,
      Color? textColor,
      Color? backgroundColor}) async {
    await Future.delayed(Duration.zero);
    if (text != null) {
      toastification.showCustom(
        autoCloseDuration: duration ?? _defaultDuration,
        alignment: bottom ? Alignment.bottomCenter : Alignment.topCenter,
        animationDuration: const Duration(milliseconds: 200),
        animationBuilder: (context, animation, alignment, child) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, (1 - animation.value) * 16),
                child: Opacity(
                  opacity: animation.value,
                  child: child,
                ),
              );
            },
            child: child,
          );
        },
        builder: (context, holder) {
          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    spreadRadius: 5,
                    blurRadius: 16,
                    offset: const Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: Text(text.toString(),
                  textAlign: TextAlign.center,
                  maxLines: null,
                  style: TextStyle(
                      fontSize: 17,
                      color: textColor ?? Colors.black,
                      fontWeight: FontWeight.w400)),
            ),
          );
        },
      );
    }
  }

  /// Shares the given object's string representation
  /// using the platform's share dialog.
  ///
  /// [object] is the object to be shared.
  /// The object's string representation will be used as the share content.
  static void share(Object object) {
    Share.share(object.toString());
  }
}

void toast(Object? text,
    {bool bottom = true,
    Duration? duration,
    Color? textColor,
    Color? backgroundColor}) {
  Simple.toast(text,
      bottom: bottom,
      duration: duration,
      textColor: textColor,
      backgroundColor: backgroundColor);
}

void share(Object object) {
  Simple.share(object);
}

Future delayed(int milliseconds) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
}

typedef BuildContextPredicate = BuildContext Function(
  Iterable<BuildContext> list,
);
