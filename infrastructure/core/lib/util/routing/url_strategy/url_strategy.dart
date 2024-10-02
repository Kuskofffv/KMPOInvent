import 'url_strategy_io.dart' if (dart.library.html) 'url_strategy_web.dart';

class UrlStrategy {
  final _strategy = UrlStrategyImpl();

  String? get lastTHashUrlStrategyUrl => _strategy.lastTHashUrlStrategyUrl;

  void setUrlStrategy() {
    _strategy.setUrlStrategy();
  }
}
