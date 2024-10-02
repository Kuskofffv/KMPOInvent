import 'package:core/util/util.dart';
import 'package:flutter/material.dart';

/// ThemeUtil is a utility class that provides methods
/// to create custom themes for buttons.
class ThemeUtil {
  /// Private constructor to prevent instantiation.
  ThemeUtil._();

  /// Creates a theme for an ElevatedButton with the given parameters.
  ///
  /// [color] is the background color of the button.
  /// [foregroundColor] is the text color of the button.
  /// [round] is the border radius of the button.
  /// [height] is the height of the button.
  /// [textSize] is the font size of the button text.
  /// [elevation] is the elevation of the button.
  /// [paddingSide] is the horizontal padding of the button.
  /// [tapTargetSize] is the tap target size of the button.
  /// [fontWeight] is the font weight of the button text.
  static ElevatedButtonThemeData createElevatedButtonThemeDataWith(
      {Color? color,
      Color? foregroundColor,
      double? round,
      double? height,
      double? textSize,
      double? elevation,
      double? paddingSide,
      MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded,
      FontWeight fontWeight = FontWeight.w500}) {
    final colorLocal = color ?? Colors.black;
    final isDarkColorLocal = SRUtil.isDarkColor(colorLocal);
    return ElevatedButtonThemeData(
        style: ButtonStyle(
      // Sets the background color of the button.
      backgroundColor: MaterialStateProperty.all(colorLocal),
      // Sets the foreground color of the button.
      foregroundColor: MaterialStateProperty.all(
          foregroundColor ?? (isDarkColorLocal ? Colors.white : Colors.black)),
      // Sets the padding of the button.
      padding: MaterialStateProperty.all(
          EdgeInsets.fromLTRB(paddingSide ?? 16, 0, paddingSide ?? 16, 0)),
      // Sets the text style of the button.
      textStyle: MaterialStateProperty.all(
          TextStyle(fontSize: textSize ?? 18, fontWeight: fontWeight)),
      // Sets the shape of the button.
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(round ?? 12.0),
      )),
      // Sets the overlay color of the button.
      overlayColor: MaterialStateProperty.all(
          isDarkColorLocal ? Colors.white24 : Colors.black12),
      // Sets the minimum size of the button.
      minimumSize: MaterialStateProperty.all(Size(0, height ?? 56)),
      // Sets the tap target size of the button.
      tapTargetSize: tapTargetSize,
      // Sets the elevation of the button.
      elevation: MaterialStateProperty.all(elevation),
    ));
  }

  /// Creates a theme for an OutlinedButton with the given parameters.
  ///
  /// [color] is the border color of the button.
  /// [foregroundColor] is the text color of the button.
  /// [round] is the border radius of the button.
  /// [height] is the height of the button.
  /// [textSize] is the font size of the button text.
  /// [paddingSide] is the horizontal padding of the button.
  /// [tapTargetSize] is the tap target size of the button.
  /// [borderWidth] is the width of the button border.
  /// [fontWeight] is the font weight of the button text.
  static OutlinedButtonThemeData createOutlinedButtonThemeDataWith(
      {Color? color,
      Color? foregroundColor,
      double? round,
      double? height,
      double? textSize,
      double? paddingSide,
      MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.padded,
      double borderWidth = 1,
      FontWeight fontWeight = FontWeight.w500}) {
    final colorLocal = color ?? Colors.black;
    final foregroundColorLocal = foregroundColor ?? Colors.white;
    return OutlinedButtonThemeData(
        style: ButtonStyle(
      // Sets the foreground color of the button.
      foregroundColor: MaterialStateProperty.all(foregroundColorLocal),
      // Sets the padding of the button.
      padding: MaterialStateProperty.all(
          EdgeInsets.fromLTRB(paddingSide ?? 16, 0, paddingSide ?? 16, 0)),
      // Sets the text style of the button.
      textStyle: MaterialStateProperty.all(
          TextStyle(fontSize: textSize ?? 18, fontWeight: fontWeight)),
      // Sets the shape of the button.
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(round ?? 12.0),
      )),
      // Sets the border side of the button.
      side: MaterialStateProperty.all(BorderSide(
          color: colorLocal, width: borderWidth, style: BorderStyle.solid)),
      // Sets the overlay color of the button.
      overlayColor: MaterialStateProperty.all(Colors.black12),
      // Sets the minimum size of the button.
      minimumSize: MaterialStateProperty.all(Size(0, height ?? 56)),
      // Sets the tap target size of the button.
      tapTargetSize: tapTargetSize,
    ));
  }
}
