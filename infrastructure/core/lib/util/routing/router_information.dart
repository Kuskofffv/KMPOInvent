import 'package:core/util/extension/extensions.dart';
import 'package:flutter/material.dart';

extension ListOfIRouterInformationItemExt on List<IRouterInformationItem> {
  RouteHandler? findRouteHandler({required String url}) {
    Map<String, String>? urlParameters;
    urlParameters = null;
    if (url.contains("?")) {
      final parts = url.split('?');
      urlParameters = <String, String>{};
      for (final qparam in url.replaceAll("${parts[0]}?", "").split('&')) {
        final parts2 = qparam.split('=');
        qparam.replaceAll("${parts2[0]}=", "").notEmpty()?.also((it) {
          urlParameters?[parts2[0]] = Uri.decodeComponent(it);
        });
      }
      url = parts[0];
    }
    for (final route in this) {
      final builder = route.widgetBuilder(url, urlParameters);
      if (builder != null) {
        return RouteHandler(route: route, builder: builder);
      }
    }
    return null;
  }
}

class RouteHandler {
  final IRouterInformationItem route;
  final WidgetBuilder builder;

  RouteHandler({required this.route, required this.builder});
}

abstract class IRouterInformationItem {
  final String pattern;
  final bool root;

  const IRouterInformationItem({
    required this.pattern,
    required this.root,
  });

  WidgetBuilder? widgetBuilder(String url, Map<String, String>? urlParameters);
}

class RouterInformationItem extends IRouterInformationItem {
  final Widget Function(
      BuildContext context, Map<String, String>? urlParameters) builder;

  const RouterInformationItem({
    required super.pattern,
    required super.root,
    required this.builder,
  });

  @override
  WidgetBuilder? widgetBuilder(String url, Map<String, String>? urlParameters) {
    if (url == pattern) {
      return (context) => builder(context, urlParameters);
    }
    return null;
  }
}

class OneArgRouterInformationItem extends IRouterInformationItem {
  final Widget Function(
          BuildContext context, String arg0, Map<String, String>? urlParameters)
      builder;

  const OneArgRouterInformationItem({
    required super.pattern,
    required super.root,
    required this.builder,
  });

  @override
  WidgetBuilder? widgetBuilder(String url, Map<String, String>? urlParameters) {
    final regex = _PatternUtil.regexByUrlPattern(pattern);
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount == 1) {
      final arg0 = match.group(1);
      if (arg0 != null) {
        return (context) => builder(context, arg0, urlParameters);
      }
    }
    return null;
  }
}

class AnyArgRouterInformationItem extends IRouterInformationItem {
  final Widget Function(
    BuildContext context,
    List<String> args,
    Map<String, String>? urlParameters,
  ) builder;

  const AnyArgRouterInformationItem({
    required super.pattern,
    required super.root,
    required this.builder,
  });

  @override
  WidgetBuilder? widgetBuilder(String url, Map<String, String>? urlParameters) {
    final regex = _PatternUtil.regexByUrlPattern(pattern);
    final match = regex.firstMatch(url);
    if (match != null) {
      final args = <String>[];
      for (var i = 1; i <= match.groupCount; i++) {
        final arg = match.group(i);
        if (arg != null) {
          args.add(arg);
        }
      }
      return (context) => builder(context, args, urlParameters);
    }
    return null;
  }
}

class _PatternUtil {
  _PatternUtil._();

  static final _cacheRegex = <String, RegExp>{};

  static RegExp regexByUrlPattern(String pattern) {
    var cache = _cacheRegex[pattern];
    if (cache == null) {
      String createRegexString(String pattern) {
        // ignore: lines_longer_than_80_chars
        return "^${pattern.replaceAll("|", r"\|").replaceAll("/", r"\/").replaceAll("?", r"\?").replaceAll("%d", r"(\d+)").replaceAll("|%s", "|([^|]+)").replaceAll("%s", r"([^|\/]+)")}\$";
      }

      cache = RegExp(createRegexString(pattern));
      _cacheRegex[pattern] = cache;
    }
    return cache;
  }
}
