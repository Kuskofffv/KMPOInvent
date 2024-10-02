import 'package:flutter_web_plugins/flutter_web_plugins.dart'
    as flutter_web_plugins;

class UrlStrategyImpl extends flutter_web_plugins.HashUrlStrategy {
  String? lastTHashUrlStrategyUrl;

  @override
  String getPath() {
    final hashUrlStrategyUrl = super.getPath();
    if (hashUrlStrategyUrl.isNotEmpty && hashUrlStrategyUrl != "/") {
      lastTHashUrlStrategyUrl = hashUrlStrategyUrl;
    }
    return hashUrlStrategyUrl;
  }

  void setUrlStrategy() {
    flutter_web_plugins.setUrlStrategy(this);
  }
}
