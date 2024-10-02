import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TAdaptationDesktop extends TAdaptation {
  TAdaptationDesktop.create() : super.create();

  @override
  DesignType get designType => DesignType.desktop;

  @override
  void _update(MediaQueryData mediaQuery) {}
}

class TAdaptation extends ChangeNotifier {
  TAdaptation._();
  TAdaptation.create() : this._();

  DesignType designType = DesignType.mobile;

  double _screenWidth = 10;
  double get screenWidth => _screenWidth;

  double get contentWidth => switch (designType) {
        DesignType.mobile => screenWidth,
        DesignType.tablet => screenWidth - mobileSideMenuWidth,
        DesignType.desktop => screenWidth - tabletSideMenuWidth,
      };

  T when<T>({
    required T Function() mobile,
    required T Function() tablet,
    required T Function() desktop,
  }) {
    return switch (designType) {
      DesignType.mobile => mobile(),
      DesignType.tablet => tablet(),
      DesignType.desktop => desktop(),
    };
  }

  T whenValue<T>({
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    return switch (designType) {
      DesignType.mobile => mobile,
      DesignType.tablet => tablet,
      DesignType.desktop => desktop,
    };
  }

  T? whenOpt<T>({
    T Function()? mobile,
    T Function()? table,
    T Function()? desktop,
  }) {
    return switch (designType) {
      DesignType.mobile => mobile?.call(),
      DesignType.tablet => table?.call(),
      DesignType.desktop => desktop?.call(),
    };
  }

  double get horizontalContentPaddingV1 {
    if (designType == DesignType.tablet) {
      final desktopMinContent = desktopFromWidth -
          tabletSideMenuWidth -
          2 * desktopMinBodySidePadding;
      return max(tabletMinBodySidePadding,
          (screenWidth - mobileSideMenuWidth - desktopMinContent) / 2);
    }

    if (designType == DesignType.mobile) {
      if (screenWidth > tabletFromWidth / 2) {
        return mobileMinBodySidePadding +
            (2 * screenWidth / tabletFromWidth - 1) *
                (mobileMaxBodySidePadding - mobileMinBodySidePadding);
      }
      return mobileMinBodySidePadding;
    }

    if (designType == DesignType.desktop) {
      return desktopMinBodySidePadding + (screenWidth - desktopFromWidth) / 6;
    }

    return mobileMinBodySidePadding;
  }

  bool get isDesktop => designType == DesignType.desktop;

  bool get isTableOrDesktop =>
      designType == DesignType.tablet || designType == DesignType.desktop;

  bool get isMobile => !isTableOrDesktop;

  void _update(MediaQueryData mediaQuery) {
    final DesignType designTypeLocal;
    if (mediaQuery.size.width > desktopFromWidth) {
      designTypeLocal = DesignType.desktop;
    } else if (mediaQuery.size.width > tabletFromWidth) {
      designTypeLocal = DesignType.tablet;
    } else {
      designTypeLocal = DesignType.mobile;
    }

    designType = designTypeLocal;
    _screenWidth = mediaQuery.size.width;
    _lastKnownDesignType = designType;

    if (kDebugMode) {
      print('design: $designType screenWidth:$_screenWidth');
    }

    notifyListeners();
  }

  static TAdaptation of(BuildContext context, {bool listen = true}) {
    return Provider.of<TAdaptation>(context, listen: listen);
  }

  static DesignType designTypeOf(BuildContext context) {
    return context
        .select<TAdaptation, DesignType>((adaptation) => adaptation.designType);
  }

  static double get desktopMinBodySidePadding => 40;
  static double get tabletMinBodySidePadding => 20;
  static double get mobileMaxBodySidePadding => 30;
  static double get mobileMinBodySidePadding => 20;
  static double get desktopFromWidth => 900;
  static double get tabletFromWidth => 600;
  static double get tabletSideMenuWidth => 250;
  static double get mobileSideMenuWidth => 80;

  static DesignType _lastKnownDesignType = DesignType.mobile;
  static DesignType get lastKnownDesignType => _lastKnownDesignType;
}

class TAdaptationWrapper extends StatefulWidget {
  final Widget child;
  const TAdaptationWrapper({required this.child, super.key});

  @override
  State<TAdaptationWrapper> createState() => _TAdaptationWrapperState();
}

class _TAdaptationWrapperState extends State<TAdaptationWrapper> {
  final _adaptation = TAdaptation.create();
  final _contentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android)) {
      return _buildScaled(context);
    } else {
      return _buildNormal(context);
    }
  }

  Widget _buildNormal(BuildContext context) {
    return Builder(builder: (context) {
      _adaptation._update(MediaQuery.of(context));
      return ChangeNotifierProvider<TAdaptation>.value(
        key: _contentKey,
        value: _adaptation,
        child: widget.child,
      );
    });
  }

  // scaling feature here
  // ignore: unused_element
  Widget _buildScaled(BuildContext context) {
    return Builder(builder: (context) {
      var mediaQuery = MediaQuery.of(context);
      final isPortrait = mediaQuery.orientation == Orientation.portrait;

      final double width = isPortrait ? 380 : 1200;
      final double height =
          width * mediaQuery.size.height / mediaQuery.size.width;
      final double k = height / mediaQuery.size.height;

      mediaQuery = mediaQuery.copyWith(
          size: Size(width, height),
          viewPadding: mediaQuery.viewPadding * k,
          padding: mediaQuery.padding * k,
          viewInsets: mediaQuery.viewInsets * k);
      _adaptation._update(mediaQuery);

      return MediaQuery(
          data: mediaQuery,
          child: FittedBox(
            child: SizedBox(
                width: width,
                height: height,
                child: ChangeNotifierProvider<TAdaptation>.value(
                  key: _contentKey,
                  value: _adaptation,
                  child: widget.child,
                )),
          ));
    });
  }

  @override
  void dispose() {
    _adaptation.dispose();
    super.dispose();
  }
}

enum DesignType { mobile, tablet, desktop }
