import 'package:core/util/extension/extensions.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';

/// хранит историю переходов по экранам
class HistoryObserver extends RouteObserver<PageRoute> {
  /// A list of all the past routes
  final List<Route<dynamic>?> _history = <Route<dynamic>?>[];

  /// Gets a clone of the navigation history as an immutable list.
  List<Route<dynamic>> get history => _history.mapNotNull((e) => e).toList();

  /// Gets the top route in the navigation stack.
  Route<dynamic>? get top => _history.last;

  /// A list of all routes that were popped to reach the current.
  final List<Route<dynamic>?> _poppedRoutes = <Route<dynamic>?>[];

  /// Gets a clone of the popped routes as an immutable list.
  List<Route<dynamic>> get poppedRoutes =>
      _poppedRoutes.mapNotNull((e) => e).toList();

  /// Gets the next route in the navigation history,
  /// which is the most recently popped route.
  Route<dynamic>? get next => _poppedRoutes.last;

  //static final HistoryObserver _singleton = HistoryObserver._internal();
  HistoryObserver();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    for (final preparation in SRRouter.customNextRoutePreparations) {
      preparation();
    }
    _poppedRoutes.add(_history.last);
    _history.removeLast();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    for (final preparation in SRRouter.customNextRoutePreparations) {
      preparation();
    }
    _history.add(route);
    _poppedRoutes.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _history.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final oldRouteIndex = _history.indexOf(oldRoute);
    _history.replaceRange(oldRouteIndex, oldRouteIndex + 1, [newRoute]);
  }
}
