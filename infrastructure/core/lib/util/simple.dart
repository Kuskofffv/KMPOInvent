import 'package:core/util/routing/router.dart';
import 'package:flutter/foundation.dart';
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
      {bool bottom = true, Duration? duration}) async {
    await Future.delayed(Duration.zero);
    if (text != null) {
      toastification.show(
        context: SRRouter.mainNavigatorKey
            .currentContext, // optional if you use ToastificationWrapper
        //type: ToastificationType.success,
        //style: ToastificationStyle.flat,
        autoCloseDuration: duration ?? _defaultDuration,
        title: Text(text.toString(),
            style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500)),
        // you can also use RichText widget for title and description parameters
        //description: RichText(
        //    text: const TextSpan(text: 'This is a sample toast message. ')),
        alignment: bottom ? Alignment.bottomCenter : Alignment.topCenter,
        animationDuration: const Duration(milliseconds: 100),
        animationBuilder: (context, animation, alignment, child) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: animation.value,
                child: child,
              );
            },
            child: child,
          );
        },
        // primaryColor: Colors.green,
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        //margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 5,
            blurRadius: 25,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
        closeButtonShowType: CloseButtonShowType.none,
        showProgressBar: false,
        //closeButtonShowType: CloseButtonShowType.onHover,
        closeOnClick: false,
        // pauseOnHover: true,
        // dragToClose: true,
        // applyBlurEffect: true,
        // callbacks: ToastificationCallbacks(
        //   onTap: (toastItem) => print('Toast ${toastItem.id} tapped'),
        //   onCloseButtonTap: (toastItem) =>
        //       print('Toast ${toastItem.id} close button tapped'),
        //   onAutoCompleteCompleted: (toastItem) =>
        //       print('Toast ${toastItem.id} auto complete completed'),
        //   onDismissed: (toastItem) => print('Toast ${toastItem.id} dismissed'),
        // ),
      );

      if (kDebugMode) {
        print("toast: $text");
      }

      // _showToast(text.toString(),
      //     duration: duration,
      //     backgroundColor: Colors.white,
      //     radius: 16,
      //     textStyle: const TextStyle(
      //         fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
      //     textPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      //     dismissOtherToast: true,
      //     animationDuration: const Duration(milliseconds: 100),
      //     animationCurve: Curves.easeInOut,
      //     animationBuilder: (context, child, controller, percent) {
      //   const scale = 0.91;
      //   return Transform.scale(
      //     scale: scale + (1 - scale) * percent,
      //     origin: const Offset(0.5, 1),
      //     alignment: Alignment.bottomCenter,
      //     child: Opacity(opacity: percent, child: child), //Transform.translate(
      //     // offset: Offset(0, 5 * (1 - percent)), child: child),
      //   );
      // }, position: bottom ? ToastPosition.bottom : ToastPosition.top);
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

void toast(Object? text, {bool bottom = true, Duration? duration}) {
  Simple.toast(text, bottom: bottom, duration: duration);
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
