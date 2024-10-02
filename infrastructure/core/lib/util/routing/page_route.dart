import 'package:core/util/util.dart';
import 'package:core/util/widget/adaptation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'router_information.dart';

mixin TPageRouteScreen on Widget {
  String inAppUrl();
}

mixin TPageRouteState<T extends StatefulWidget> on State<T> {
  String inAppUrl();
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    SystemNavigator.routeInformationUpdated(uri: Uri.parse(inAppUrl()));
  }

  void requestInUrlChange() {
    SystemNavigator.routeInformationUpdated(uri: Uri.parse(inAppUrl()));
  }
}

class TTPageRoute<T> extends MaterialPageRoute<T> {
  final Widget screen;
  final String? url;

  bool _canPop;

  TTPageRoute({required this.screen, this.url, bool canPop = true})
      : _canPop = canPop,
        super(
            builder: (context) => screen,
            settings: RouteSettings(
                name: url ??
                    SRUtil.cast<TPageRouteScreen>(screen)?.inAppUrl() ??
                    screen.runtimeType.toString()));

  static List<IRouterInformationItem> Function()? routerInformationGetter;

  void pop(BuildContext context) {
    _canPop = true;
    Navigator.pop(context, this);
  }

  set canPop(bool value) {
    _canPop = value;
  }

  @override
  RoutePopDisposition get popDisposition {
    if (!_canPop) {
      return RoutePopDisposition.doNotPop;
    }
    return super.popDisposition;
  }

  @override
  Widget buildContent(BuildContext context) {
    if (kDebugMode) {
      Future(() {
        final page = SRUtil.cast<TPageRouteScreen>(screen);
        if (page == null) {
          if (kDebugMode) {
            print(
                "Экран ${screen.runtimeType} должен реализовать TPageRouteScreen");
          }
        } else {
          final urlHandler = routerInformationGetter
              ?.call()
              .findRouteHandler(url: page.inAppUrl());

          if (urlHandler == null) {
            if (kDebugMode) {
              print(
                  // ignore: lines_longer_than_80_chars
                  "Нужно добавить обработчик ${page.inAppUrl()} в router_information.dart");
            }
          } else if (urlHandler.builder(context).runtimeType !=
              screen.runtimeType) {
            if (kDebugMode) {
              print(
                  // ignore: lines_longer_than_80_chars
                  "Обработчик ${page.inAppUrl()} должен возвращать ${screen.runtimeType}");
            }
          }
        }
      });
    }
    return super.buildContent(context);
  }

  @override
  Duration get transitionDuration {
    return TAdaptation.lastKnownDesignType == DesignType.mobile
        ? const Duration(milliseconds: 300)
        : Duration.zero;
  }
}

/// MaterialRouteTransitionMixin provides custom transitions for routes.
mixin MaterialRouteTransitionMixin<T> on PageRoute<T> {
  /// Builds the primary contents of the route.
  @protected
  Widget buildContent(BuildContext context);

  /// Returns the duration of the transition.
  @override
  Duration get transitionDuration {
    return TAdaptation.lastKnownDesignType == DesignType.mobile
        ? const Duration(milliseconds: 300)
        : Duration.zero;
  }

  /// Returns the color of the barrier.
  @override
  Color? get barrierColor => null;

  /// Returns the semantic label of the barrier.
  @override
  String? get barrierLabel => null;

  /// Determines whether the current route can transition to the next route.
  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return (nextRoute is MaterialRouteTransitionMixin &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoRouteTransitionMixin &&
            !nextRoute.fullscreenDialog);
  }

  /// Builds the page to be displayed during the transition.
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final Widget result = buildContent(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  /// Builds the transitions that will be used during the navigation.
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final isTable = TAdaptation.of(context).isTableOrDesktop;
    if (isTable) {
      return child;
    }
    final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions<T>(
        this, context, animation, secondaryAnimation, child);
  }
}
