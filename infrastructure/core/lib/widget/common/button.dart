import 'package:core/util/theme/colors.dart';
import 'package:flutter/material.dart';

Color get _accentColor => TColors.accent;
Color get _lightBlueColor => TColors.accent10;

ButtonStyle _createPrimaryButtonTheme(BuildContext context,
    {required double height,
    required double fontSize,
    required Color textColor,
    required Color backgroundColor}) {
  return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      minimumSize: Size(100, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      elevation: 0,
      textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: "Inter"));
}

ButtonStyle _createSecondaryButtonTheme(BuildContext context,
    {required double height,
    required double fontSize,
    required Color textColor,
    required Color backgroundColor}) {
  return TextButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      minimumSize: Size(100, height),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      elevation: 0,
      textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: "Inter"));
}

ButtonStyle _createTextButtonTheme(BuildContext context,
    {required double height,
    required double fontSize,
    required Color textColor}) {
  return TextButton.styleFrom(
      foregroundColor: textColor,
      minimumSize: Size(100, height),
      elevation: 0,
      textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: "Inter"));
}

ButtonStyle _createOutlineButtonTheme(BuildContext context,
    {required double height,
    required double fontSize,
    required Color textColor,
    required Color strokeColor}) {
  return OutlinedButton.styleFrom(
      foregroundColor: textColor,
      minimumSize: Size(100, height),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide(width: 2, color: strokeColor),
      textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Inter'));
}

ButtonStyle _createFloatingButtonTheme(BuildContext context,
    {required double fontSize,
    required Color textColor,
    required Color backgroundColor}) {
  return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      textStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: "Inter"));
}

class LargePrimaryButton extends TPrimaryButton {
  const LargePrimaryButton({
    required Widget child,
    required VoidCallback? onPressed,
    Color? color,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
  }) : super(
          size: ButtonSize.large,
          child: child,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
        );
}

class MediumPrimaryButton extends TPrimaryButton {
  const MediumPrimaryButton({
    required Widget child,
    required VoidCallback? onPressed,
    Color? color,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
  }) : super(
          size: ButtonSize.medium,
          child: child,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
        );
}

class LargeSecondaryButton extends TSecondaryButton {
  const LargeSecondaryButton({
    required Widget child,
    required VoidCallback? onPressed,
    Color? color,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
  }) : super(
          size: ButtonSize.large,
          child: child,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
        );
}

class MediumSecondaryButton extends TSecondaryButton {
  const MediumSecondaryButton({
    required Widget child,
    required VoidCallback? onPressed,
    Color? color,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
  }) : super(
          size: ButtonSize.medium,
          child: child,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
        );
}

class LargeTextButton extends TTextButton {
  const LargeTextButton({
    required Widget child,
    required VoidCallback? onPressed,
    Color? color,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
  }) : super(
          size: ButtonSize.large,
          child: child,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
        );
}

class MediumTextButton extends TTextButton {
  const MediumTextButton({
    required Widget child,
    required VoidCallback? onPressed,
    Color? color,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
  }) : super(
          size: ButtonSize.medium,
          child: child,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
        );
}

class LargeOutlineButton extends TOutlineButton {
  const LargeOutlineButton({
    required Widget child,
    required VoidCallback? onPressed,
    Color? color,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
  }) : super(
          size: ButtonSize.large,
          child: child,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
        );
}

class MediumOutlineButton extends TOutlineButton {
  const MediumOutlineButton({
    required Widget child,
    required VoidCallback? onPressed,
    Color? color,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
  }) : super(
          size: ButtonSize.medium,
          child: child,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
        );
}

class HoverTextWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final String text;
  final TextStyle? style;
  final bool underlineUnfocusedText;

  const HoverTextWidget(this.text,
      {required this.onTap, this.style, this.underlineUnfocusedText = false})
      : super();

  @override
  _HoverTextWidgetState createState() => _HoverTextWidgetState();
}

class _HoverTextWidgetState extends State<HoverTextWidget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: widget.onTap != null
          ? GestureDetector(
              onTap: widget.onTap,
              child: Text(widget.text,
                  style: (widget.style ?? const TextStyle()).copyWith(
                    color: _isHovering ? Theme.of(context).primaryColor : null,
                    decoration: (_isHovering || widget.underlineUnfocusedText)
                        ? TextDecoration.underline
                        : null,
                  )),
            )
          : Text(
              widget.text,
              style: widget.style,
            ),
    );
  }
}

class TButton extends StatelessWidget {
  final ButtonType type;
  final ButtonSize size;

  final VoidCallback? onPressed;
  final Color? color;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget child;

  const TButton({
    required this.type,
    required this.size,
    required this.child,
    required this.onPressed,
    Key? key,
    this.color,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return TPrimaryButton(
          size: size,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          child: child,
        );
      case ButtonType.secondary:
        return TSecondaryButton(
          size: size,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          child: child,
        );
      case ButtonType.text:
        return TTextButton(
          size: size,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          child: child,
        );
      case ButtonType.outline:
        return TOutlineButton(
          size: size,
          onPressed: onPressed,
          color: color,
          focusNode: focusNode,
          autofocus: autofocus,
          clipBehavior: clipBehavior,
          child: child,
        );
    }
  }
}

class TPrimaryButton extends StatelessWidget {
  final ButtonSize size;

  final VoidCallback? onPressed;
  final Color? color;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget child;

  const TPrimaryButton({
    required this.size,
    required this.child,
    required this.onPressed,
    Key? key,
    this.color,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _createPrimaryButtonTheme(context,
          height: size.height,
          fontSize: size.fontSize,
          textColor: Colors.white,
          backgroundColor: color ?? _accentColor),
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

class TSecondaryButton extends StatelessWidget {
  final ButtonSize size;
  final VoidCallback? onPressed;
  final Color? color;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget child;

  const TSecondaryButton({
    required this.size,
    required this.child,
    required this.onPressed,
    Key? key,
    this.color,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: _createSecondaryButtonTheme(context,
          height: size.height,
          fontSize: size.fontSize,
          backgroundColor: color ?? _lightBlueColor,
          textColor: _accentColor),
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

class TTextButton extends StatelessWidget {
  final ButtonSize size;
  final VoidCallback? onPressed;
  final Color? color;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget? child;

  const TTextButton({
    required this.size,
    required this.child,
    required this.onPressed,
    Key? key,
    this.color,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: _createTextButtonTheme(context,
          height: size.height,
          fontSize: size.fontSize,
          textColor: color ?? _accentColor),
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: child!,
    );
  }
}

class TOutlineButton extends StatelessWidget {
  final ButtonSize size;
  final VoidCallback? onPressed;
  final Color? color;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget child;

  const TOutlineButton({
    required this.size,
    required this.child,
    required this.onPressed,
    Key? key,
    this.color,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: _createOutlineButtonTheme(context,
          fontSize: size.fontSize,
          height: size.height,
          textColor: _accentColor,
          strokeColor: color ?? _accentColor),
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

class TFloatingButton extends StatelessWidget {
  final double? width;
  final double? height;
  final VoidCallback? onPressed;
  final Color? color;
  final FocusNode? focusNode;
  final bool autofocus;
  final Clip clipBehavior;
  final Widget child;

  const TFloatingButton({
    required this.child,
    required this.onPressed,
    Key? key,
    this.width,
    this.height,
    this.color,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: width ?? 50,
      height: height ?? 50,
      duration: const Duration(milliseconds: 250),
      child: ElevatedButton(
        onPressed: onPressed,
        style: _createFloatingButtonTheme(context,
            fontSize: 14,
            textColor: Colors.white,
            backgroundColor: color ?? _accentColor),
        focusNode: focusNode,
        autofocus: autofocus,
        clipBehavior: clipBehavior,
        child: child,
      ),
    );
  }
}

enum ButtonType { primary, secondary, text, outline }

enum ButtonSize {
  large(16, 50),
  medium(14, 44),
  small(12, 36);

  final double fontSize;
  final double height;

  const ButtonSize(
    this.fontSize,
    this.height,
  );
}
