import 'dart:async';

import 'package:core/util/extension/extensions.dart';
import 'package:core/util/globals.dart';
import 'package:core/util/simple.dart';
import 'package:core/util/theme/colors.dart';
import 'package:core/util/widget/adaptation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:url_launcher/src/url_launcher_string.dart';

//import '../../util/extension/extensions.dart';
import '../../widget/common/basic_popup.dart';
import '../../widget/common/message_operation_popup.dart';
import '../../widget/common/message_popup.dart';
import '../exception/exception_parser.dart';
import '../util.dart';
import 'history_observer.dart';
import 'page_route.dart';
import 'run_external_url_io.dart'
    if (dart.library.html) 'run_external_url_web.dart';

/// TRouter is a utility class that provides methods
/// for navigating between screens.
class SRRouter {
  static GlobalKey<NavigatorState> mainNavigatorKey =
      GlobalKey<NavigatorState>();

  static late HistoryObserver historyObserver = HistoryObserver();

  static final customNextRoutePreparations = <void Function()>[];

  /// Private constructor to prevent instantiation.
  SRRouter._();

  /// Pushes the given screen onto the navigation stack.
  /// Returns a Future that completes to the result
  /// value passed to Navigator.pop when the pushed
  /// screen is popped off the navigation stack.
  ///
  /// [context] is the BuildContext from which navigation will be handled.
  /// [screen] is the Widget that will be pushed onto the navigation stack.
  static Future<T?> push<T extends Object?>(BuildContext context, Widget screen,
      {bool canPop = true}) {
    nextRoutePreparations(context);
    return Navigator.of(context)
        .push(TTPageRoute(screen: screen, canPop: canPop));
  }

  /// Pushes the given screen onto the navigation
  /// stack and removes all previous screens.
  /// Returns a Future that completes to the result
  /// value passed to Navigator.pop when the pushed
  /// screen is popped off the navigation stack.
  ///
  /// [context] is the BuildContext from which navigation will be handled.
  /// [screen] is the Widget that will be pushed onto the navigation stack.
  static Future<T?> pushToRoot<T extends Object?>(
      BuildContext context, Widget screen) {
    nextRoutePreparations(context);
    return Navigator.pushAndRemoveUntil(
        context, TTPageRoute(screen: screen), (r) => false);
  }

  /// Pushes the given screens onto the navigation stack.
  /// [context] is the BuildContext from which navigation will be handled.
  /// [screens] is the List of Widgets that will be pushed
  // ignore: avoid_void_async
  static void pushScreensToRoot(
      BuildContext context, List<Widget> screens) async {
    if (screens.isEmpty) {
      return;
    }
    nextRoutePreparations(context);
    final navigator = Navigator.of(context);
    unawaited(navigator.pushAndRemoveUntil(
        TTPageRoute(screen: screens[0]), (r) => false));

    for (var i = 1; i < screens.length; i++) {
      await Future.delayed(const Duration(milliseconds: 0));
      unawaited(navigator.push(TTPageRoute(screen: screens[i])));
    }
  }

  /// Replaces the current screen with the given screen.
  /// Returns a Future that completes to the result value passed
  /// to Navigator.pop when the pushed screen is
  /// popped off the navigation stack.
  ///
  /// [context] is the BuildContext from which navigation will be handled.
  /// [screen] is the Widget that will replace the current screen
  /// on the navigation stack.
  static Future<T?> pushReplacement<T extends Object?>(
      BuildContext context, Widget screen,
      {bool canPop = true}) {
    nextRoutePreparations(context);
    return Navigator.of(context)
        .pushReplacement(TTPageRoute(screen: screen, canPop: canPop));
  }

  /// Pops the current screen from the navigation stack
  /// and optionally returns a result.
  /// The optional result will be used as the result
  /// of the operation that pushed the popped screen onto the navigation stack.
  ///
  /// [context] is the BuildContext from which navigation will be handled.
  /// [result] is the optional result that will be returned from
  /// the popped screen.
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    nextRoutePreparations(context);
    Navigator.of(context).pop<T>(result);
  }

  /// Pops all screens from the navigation
  /// stack until the first screen is reached.
  ///
  /// [context] is the BuildContext from which navigation will be handled.
  static void popUntilTop(BuildContext context) {
    nextRoutePreparations(context);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  static List<Route<dynamic>> routeHistory(BuildContext context) {
    return Provider.of<HistoryObserver>(context, listen: false).history;
  }

  static List<TTPageRoute<dynamic>> tRouteHistory(BuildContext context) {
    final routes = context.read<HistoryObserver>().history;
    return routes.mapNotNull((e) => SRUtil.cast<TTPageRoute>(e));
  }

  static List<TTPageRoute<dynamic>> tRouteHistoryListened(
      BuildContext context) {
    final routes = context.watch<HistoryObserver>().history;
    return routes.mapNotNull((e) => SRUtil.cast<TTPageRoute>(e));
  }

  static Future<void> pushNamed(BuildContext context, String routeName,
      {bool checkCmdForWeb = false}) async {
    if (kIsWeb && checkCmdForWeb) {
      final keys = HardwareKeyboard.instance.physicalKeysPressed;
      final macosCmdPressed = defaultTargetPlatform == TargetPlatform.macOS &&
          (keys.contains(
                PhysicalKeyboardKey.metaLeft,
              ) ||
              keys.contains(
                PhysicalKeyboardKey.metaRight,
              ));
      final winCmdPressed = defaultTargetPlatform == TargetPlatform.windows &&
          (keys.contains(
                PhysicalKeyboardKey.controlLeft,
              ) ||
              keys.contains(
                PhysicalKeyboardKey.controlRight,
              ));

      if (winCmdPressed || macosCmdPressed) {
        await launchUrlString(
          "${RunExternalUrl().origin}/#$routeName",
        );
        return;
      }
    }
    await Navigator.pushNamed(context, routeName);
  }

  static TRouterDialogResult<T?> showSomeDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
  }) {
    final dialogRouter = DialogRoute<T>(
      context: context,
      builder: builder,
      barrierColor: barrierColor ?? TColors.black.withAlpha(60),
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      settings: routeSettings,
    );
    nextRoutePreparations(context);
    final future = Navigator.of(context, rootNavigator: useRootNavigator)
        .push<T>(dialogRouter);
    return TRouterDialogResult<T>(future, dialogRouter);
  }

  static void nextRoutePreparations(BuildContext context) {
    SRUtil.hideKeyboard();
    for (final preparation in customNextRoutePreparations) {
      preparation();
    }
    ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
  }

  static Future showMessagePopup(BuildContext context,
      {required String title,
      required String message,
      bool barrierDismissible = true,
      PopupButton? primaryButton,
      PopupButton? secondaryButton}) async {
    await showSomeDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => MessagePopupWidget(
        title: title,
        message: message,
        primaryButton:
            primaryButton ?? PopupButton(text: 'OK', onPressed: () {}),
        secondaryButton: secondaryButton,
      ),
    ).future;
  }

  static void showActionPopup(BuildContext context,
      {required Widget body,
      String? title,
      bool barrierDismissible = true,
      PopupButton? primaryButton,
      PopupButton? secondaryButton,
      bool? isMobile}) {
    final isMobileLocal =
        isMobile ?? TAdaptation.of(context, listen: false).isMobile;

    if (isMobileLocal) {
      showModalBottomSheet(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return SafeArea(
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 8),
                  child: body,
                ),
              ),
            );
          });
    } else {
      showSomeDialog(
          context: context,
          barrierDismissible: barrierDismissible,
          builder: (context) {
            return BasicPopupWidget(
              title: title,
              body: body,
              primaryButton: primaryButton,
              secondaryButton: secondaryButton,
            );
          });
    }
  }

  static Future<T?> showCustomPopup<T>(BuildContext context,
      {required Widget body,
      String? title,
      bool barrierDismissible = true,
      PopupButton? primaryButton,
      PopupButton? secondaryButton,
      double? maxWidth}) async {
    return showSomeDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => BasicPopupWidget(
        title: title,
        body: body,
        primaryButton: primaryButton,
        secondaryButton: secondaryButton,
        maxWidth: maxWidth,
      ),
    ).future;
  }

  /// Performs operation. If there is an error, it shows a toast message
  // ignore: avoid_void_async
  static Future<T?> operationWithToast<T extends Object>(
      {required Future<T> Function() operation,
      void Function(T data)? onSuccess}) async {
    final stopwatch = Stopwatch()..start();
    const int minOperationTimeMs = 1000;

    SRRouter.showProgress(visible: true);
    T? result;
    Object? exception;
    try {
      result = await operation();
    } catch (e, s) {
      exception = e;
      logger.e(ExceptionParser.parseException(e), error: e, stackTrace: s);
    }
    // Wait for the minimum operation time to prevent flickering.
    await (stopwatch.elapsedMilliseconds < minOperationTimeMs
        ? Future.delayed(Duration(
            milliseconds: minOperationTimeMs - stopwatch.elapsedMilliseconds))
        : Future.value());
    SRRouter.hideProgress();
    if (result != null) {
      onSuccess?.call(result);
      return result;
    } else if (exception != null) {
      Simple.toast(ExceptionParser.parseException(exception));
    }
    return null;
  }

  /// Asks the user for confirmation before performing an operation.
  static void operationWithConfirmation<T extends Object>(BuildContext context,
      {required String title,
      required String message,
      required String buttonName,
      required Future<T> Function() operation,
      void Function(T data)? onSuccess}) {
    showActionPopup(context,
        body: MessageOperationPopup<T>(
          title: title,
          message: message,
          buttonName: buttonName,
          operation: operation,
          onSuccess: onSuccess,
        ),
        barrierDismissible: false);
  }

  static int _counterProgress = 0;
  static DialogRoute? _progressRoute;
  static final _progressNotifier = ValueNotifier<int?>(null);
  static void progress(int? percent) {
    // ignore: parameter_assignments
    percent = percent?.clamp(0, 100);
    _progressNotifier.value = percent;
  }

  static void showProgress({bool visible = true}) {
    if (_counterProgress++ != 0) {
      return;
    }
    if (mainNavigatorKey.currentContext == null) {
      return;
    }
    _progressNotifier.value = null;
    final theme = Theme.of(mainNavigatorKey.currentContext!);
    const double size = 90;
    final box = DecoratedBox(
      decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 25,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ]),
    );
    final content = Center(
        child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                box,
                const Center(
                  child: CircularProgressIndicator(),
                ),
                ValueListenableBuilder<int?>(
                  valueListenable: _progressNotifier,
                  builder: (context, value, child) {
                    if (value == null) {
                      return emptyWidget;
                    }
                    return Center(
                      child: Text(
                        '$value%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            )));
    final alert = AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: null,
      content: content,
    );
    _progressRoute = SRRouter.showSomeDialog(
      barrierDismissible: false,
      barrierColor: visible ? TColors.black.withAlpha(30) : Colors.transparent,
      context: mainNavigatorKey.currentContext!,
      useRootNavigator: true,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: visible ? alert : emptyWidget,
        );
      },
    ).route;
  }

  static void hideProgress() {
    _counterProgress--;
    if (_counterProgress == 0) {
      if (_progressRoute != null) {
        if (_progressRoute!.isCurrent) {
          Navigator.of(mainNavigatorKey.currentContext!, rootNavigator: true)
              .pop();
        } else {
          Navigator.of(mainNavigatorKey.currentContext!, rootNavigator: true)
              .removeRoute(_progressRoute!);
        }
        _progressRoute = null;
      }
    }
  }

  static void popUntil(BuildContext context, TTPageRoute route) {
    Navigator.of(context).popUntil((r) => r == route);
  }

  static void runExternalUrl(String url, {required bool openInNewBrowserTab}) {
    if (openInNewBrowserTab) {
      launchUrlString(url);
    } else {
      RunExternalUrl().runInSameTab(url);
    }
  }
}

class TRouterDialogResult<T> {
  Future<T?> future;
  DialogRoute<T> route;

  TRouterDialogResult(this.future, this.route);
}
