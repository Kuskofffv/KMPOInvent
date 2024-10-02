import 'package:flutter/material.dart';

class AdaptationUtil {
  AdaptationUtil._();

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= isTabletWidth;
  }

  static const double isTabletWidth = 800;
  static const double tabletContentWidth = 850;
  static const double tabletMiniContentWidth = 600;

  static final _contentKey = GlobalKey();

  static Widget buildNormal(Widget child) {
    return SizedBox(
      key: _contentKey,
      child: child,
    );
  }

  static Widget buildScaled(Widget child, {bool scaled = true}) {
    if (!scaled) {
      return buildNormal(child);
    }

    return Builder(builder: (context) {
      var mediaQuery = MediaQuery.of(context);
      double width = 0;

      const double mediumLimit = 600;
      const double bigLimit = 900;

      const double smallWidth = 420;
      const double mediumWidth = 1000;
      const double bigWidth = 1500;

      if (mediaQuery.size.width >= bigLimit) {
        width = bigWidth;
      } else if (mediaQuery.size.width >= mediumLimit &&
          mediaQuery.size.width < bigLimit) {
        width = mediumWidth +
            ((bigWidth - mediumWidth) *
                (mediaQuery.size.width - mediumLimit) /
                (bigLimit - mediumLimit));
      } else {
        width = smallWidth;
      }

      final double height =
          width * mediaQuery.size.height / mediaQuery.size.width;
      final double k = height / mediaQuery.size.height;

      mediaQuery = mediaQuery.copyWith(
          textScaler: const TextScaler.linear(1),
          size: Size(width, height),
          viewPadding: mediaQuery.viewPadding * k,
          padding: mediaQuery.padding * k,
          viewInsets: mediaQuery.viewInsets * k);

      return MediaQuery(
          data: mediaQuery,
          child: FittedBox(
            child: SizedBox(
                width: width,
                height: height,
                child: SizedBox(key: _contentKey, child: child)),
          ));
    });
  }
}
