//some service pages here
import 'package:brigantina_invent/widget/adaptation.dart';
import 'package:core/util/exception/exception_parser.dart';
import 'package:core/util/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TMessagePageWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? image;
  final double? imageSize;
  final String? buttonName;
  final VoidCallback? buttonHandler;

  const TMessagePageWidget(
      {required this.title,
      this.subtitle,
      this.image,
      this.buttonName,
      this.buttonHandler,
      this.imageSize})
      : super();

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 30);
    final adaptation = TAdaptation.of(context);

    // default image
    final String? imageLocal =
        image; //?? di<ICoreModule>().defaults?.emptyImage;
    var imageSizeLocal = imageSize ?? 340;

    imageSizeLocal = adaptation.whenValue(
        mobile: imageSizeLocal * 0.75,
        tablet: imageSizeLocal * 0.88,
        desktop: imageSizeLocal);

    final Widget resultWidget = Center(
        child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (imageLocal != null)
            SvgPicture.asset(
              imageLocal,
              width: imageSizeLocal,
              height: imageSizeLocal,
            ),
          space,
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            space,
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
          if (buttonHandler != null && buttonName != null) ...[
            space,
            ElevatedButton(
              onPressed: buttonHandler,
              child: Text(buttonName!),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    ));
    // if (TScaffold.maybeOf(context) == null &&
    //     TAuthScaffold.maybeOf(context) == null &&
    //     Scaffold.maybeOf(context)?.widget.appBar == null) {
    //   resultWidget = Scaffold(
    //     appBar: AppBar(
    //       leading: const TScaffoldBackButton(),
    //     ),
    //     body: resultWidget,
    //   );
    // }
    return resultWidget;
  }
}

class TMessagePageSliverWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? image;
  final double? imageSize;
  final String? buttonName;
  final VoidCallback? buttonHandler;

  const TMessagePageSliverWidget(
      {required this.title,
      this.subtitle,
      this.image,
      this.buttonName,
      this.buttonHandler,
      this.imageSize})
      : super();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: TMessagePageWidget(
        title: title,
        subtitle: subtitle,
        image: image,
        imageSize: imageSize,
        buttonName: buttonName,
        buttonHandler: buttonHandler,
      ),
    );
  }
}

double get _circleSize => 80;
//final _progressKey = GlobalKey();

class TProgressPageWidget extends StatelessWidget {
  const TProgressPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      //key: _progressKey,
      child: SizedBox(
          width: _circleSize,
          height: _circleSize,
          child: const CircularProgressIndicator()),
    );
  }
}

class TProgressPageWidgetSliverWidget extends StatelessWidget {
  const TProgressPageWidgetSliverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: TProgressPageWidget(),
    );
  }
}

class TExceptionPageWidget extends StatelessWidget {
  final Object exception;
  final VoidCallback? onRetry;

  const TExceptionPageWidget({required this.exception, required this.onRetry})
      : super();

  @override
  Widget build(BuildContext context) {
    return TMessagePageWidget(
      title: "Произошла ошибка",
      subtitle: ExceptionParser.parseException(exception),
      buttonName: "Повторить",
      buttonHandler: onRetry,
    );
  }
}

class TEmptyPageWidget extends StatelessWidget {
  final String emptyPageTitle;

  const TEmptyPageWidget({required this.emptyPageTitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        emptyPageTitle,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: TColors.grey90,
            ),
        textAlign: TextAlign.start,
      ),
    );
  }
}
