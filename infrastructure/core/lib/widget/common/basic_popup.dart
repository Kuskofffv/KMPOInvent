import 'package:core/util/routing/router.dart';
import 'package:flutter/material.dart';

import '../../widget/common/button.dart';

class PopupButton {
  final String text;
  final VoidCallback? onPressed;

  PopupButton({required this.text, this.onPressed});
}

class BasicPopupWidget extends StatefulWidget {
  final String? title;
  final Widget body;
  final PopupButton? secondaryButton;
  final PopupButton? primaryButton;
  final double? maxWidth;

  const BasicPopupWidget({
    required this.body,
    this.title,
    this.primaryButton,
    this.secondaryButton,
    this.maxWidth,
  });

  @override
  State<BasicPopupWidget> createState() => _BasicPopupWidgetState();
}

class _BasicPopupWidgetState extends State<BasicPopupWidget> {
  @override
  Widget build(BuildContext context) {
    const double sidePadding = 30;
    const double topPadding = 30;
    const double bottomPadding = 24;
    const double buttonsTopPadding = 40;
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 25,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.circular(16))),
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxWidth ?? 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        sidePadding, topPadding, sidePadding, 0),
                    child: Text(
                      widget.title!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      sidePadding, topPadding, sidePadding, 0),
                  child: widget.body,
                ),
                if (widget.primaryButton != null ||
                    widget.secondaryButton != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(sidePadding,
                        buttonsTopPadding, sidePadding, bottomPadding),
                    child: Row(
                      children: [
                        if (widget.secondaryButton != null) ...[
                          Expanded(
                            child: MediumSecondaryButton(
                                child: Text(widget.secondaryButton!.text),
                                onPressed: () {
                                  SRRouter.pop(context);
                                  widget.secondaryButton!.onPressed?.call();
                                }),
                          ),
                          if (widget.primaryButton != null)
                            const SizedBox(width: 12),
                        ],
                        if (widget.primaryButton != null)
                          Expanded(
                            child: MediumPrimaryButton(
                                child: Text(widget.primaryButton!.text),
                                onPressed: () {
                                  SRRouter.pop(context);
                                  widget.primaryButton!.onPressed?.call();
                                }),
                          )
                      ],
                    ),
                  )
                else
                  const SizedBox(
                    height: bottomPadding,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TPopupButtons extends StatelessWidget {
  final String buttonName;
  final void Function() onSubmit;

  const TPopupButtons({
    required this.onSubmit,
    required this.buttonName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MediumSecondaryButton(
              child: const Text("Отменить"),
              onPressed: () {
                SRRouter.pop(context);
              }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MediumPrimaryButton(
            onPressed: () {
              SRRouter.pop(
                context,
              );
              onSubmit();
            },
            child: Text(buttonName),
          ),
        )
      ],
    );
  }
}
