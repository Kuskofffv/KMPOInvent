import 'package:core/util/theme/colors.dart';
import 'package:flutter/material.dart';

class TBadge extends StatelessWidget {
  final String text;
  final BadgeStyleSet style;
  final BadgeSize size;

  const TBadge(
      {required this.text, required this.style, this.size = BadgeSize.medium});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: size.height,
        decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(size.height / 2))),
        padding: size.padding,
        child: Text(text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: style.textColor,
              fontSize: size.fontSize,
            )));
  }
}

enum BadgeSize {
  small(24, 12, EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
  medium(26, 13, EdgeInsets.symmetric(horizontal: 12, vertical: 5)),
  large(28, 14, EdgeInsets.symmetric(horizontal: 14, vertical: 5));

  final double height;
  final double fontSize;
  final EdgeInsets padding;

  const BadgeSize(this.height, this.fontSize, this.padding);
}

enum BadgeStyleSet {
  greenSecondary(TColors.systemGreen, TColors.systemGreenLight),
  redSecondary(TColors.systemRed, TColors.systemRedLight),
  greySecondary(TColors.black, TColors.grey30),
  yellowSecondary(TColors.systemYellow, TColors.systemYellowLight),
  pinkSecondary(TColors.heliotrope, TColors.heliotrope20),
  easternBlueSecondary(TColors.easternBlue, TColors.easternBlue20),
  blueSecondary(TColors.accent, TColors.accent10);

  final Color textColor;
  final Color backgroundColor;

  const BadgeStyleSet(this.textColor, this.backgroundColor);
}
