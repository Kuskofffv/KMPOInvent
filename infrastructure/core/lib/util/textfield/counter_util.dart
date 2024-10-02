import 'package:core/util/theme/colors.dart';
import 'package:flutter/material.dart';

abstract final class CounterUtil {
  static const int maxLength = 32;

  static const int maxLengthEmail = 50;

  static InputCounterWidgetBuilder? buildCounter = (
    context, {
    required currentLength,
    required maxLength,
    required isFocused,
  }) {
    if (currentLength == maxLength) {
      return Text(
        '$currentLength/$currentLength',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TColors.grey90,
            ),
      );
    }

    return null;
  };
}
