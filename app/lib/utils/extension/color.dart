part of extensions;

extension FlexColorExtensions on Color {
  /// Brightens the color with the given integer percentage amount.
  /// Defaults to 10%.
  Color brighten([final int amount = 10]) {
    if (amount <= 0) {
      return this;
    }
    if (amount > 100) {
      return Colors.white;
    }
    final Color color = Color.fromARGB(
      alpha,
      math.max(0, math.min(255, red - (255 * -(amount / 100)).round())),
      math.max(0, math.min(255, green - (255 * -(amount / 100)).round())),
      math.max(0, math.min(255, blue - (255 * -(amount / 100)).round())),
    );
    return color;
  }

  /// Lightens the color with the given integer percentage amount.
  /// Defaults to 10%.
  Color lighten([final int amount = 10]) {
    if (amount <= 0) {
      return this;
    }
    if (amount > 100) {
      return Colors.white;
    }
    // HSLColor returns saturation 1 for black, we want 0 instead to be able
    // lighten black color up along the grey scale from black.
    final HSLColor hsl = this == const Color(0xFF000000)
        ? HSLColor.fromColor(this).withSaturation(0)
        : HSLColor.fromColor(this);
    return hsl
        .withLightness(math.min(1, math.max(0, hsl.lightness + amount / 100)))
        .toColor();
  }

  /// Darkens the color with the given integer percentage amount.
  /// Defaults to 10%.
  Color darken([final int amount = 10]) {
    if (amount <= 0) {
      return this;
    }
    if (amount > 100) {
      return Colors.black;
    }
    final HSLColor hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness(math.min(1, math.max(0, hsl.lightness - amount / 100)))
        .toColor();
  }

  /// Get the right black or white contrasting onColor for a color.
  ///
  /// The onColor is white if the color has brightness dark and black if
  /// the color has brightness light.
  ///
  /// Use the function to get black/white color typically used for text and
  /// icons when they are placed on a surface/background using `color` as its
  /// background color.
  Color get onColor =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.light
          ? Colors.black
          : Colors.white;

  /// Returns true if the color's brightness is [Brightness.light], else false.
  bool get isLight =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.light;

  /// Returns true if the color's brightness is [Brightness.dark], else false.
  //bool get isDark =>
  //    ThemeData.estimateBrightnessForColor(this) == Brightness.dark;

  /// Blend in the given input Color with a percentage of alpha.
  ///
  /// You typically apply this on a background color, light or dark
  /// to create a background color with a hint of a color used in a theme.
  ///
  /// This is a use case of the alphaBlend static function that exists in
  /// dart:ui Color. It is used to create the branded surface colors in
  /// FlexColorScheme and to calculate dark scheme colors from light ones,
  /// by blending in white color with light scheme color.
  ///
  /// Defaults to 10% alpha blend of the passed in Color value.
  Color blend(final Color input, [final int amount = 10]) {
    // Skip blending for impossible value and return the instance color value.
    if (amount <= 0) {
      return this;
    }
    // Blend amounts >= 100 results in the input Color.
    if (amount >= 100) {
      return input;
    }
    return Color.alphaBlend(input.withAlpha(255 * amount ~/ 100), this);
  }

  /// Blend in the given input Color with an alpha value.
  ///
  /// You typically apply this on a background color, light or dark
  /// to create a background color with a hint of a color used in a theme.
  ///
  /// This is a use case of the alphaBlend static function that exists in
  /// dart:ui Color. It is used to create the branded surface colors in
  /// FlexColorScheme and to calculate dark scheme colors from light ones,
  /// by blending in white color with light scheme color.
  ///
  /// Defaults to alpha 0x0A alpha blend of the passed in Color value,
  /// which is 10% alpha blend.
  Color blendAlpha(final Color input, [final int alpha = 0x0A]) {
    // Skip blending for impossible value and return the instance color value.
    if (alpha <= 0) {
      return this;
    }
    // Blend amounts >= 255 results in the input Color.
    if (alpha >= 255) {
      return input;
    }
    return Color.alphaBlend(input.withAlpha(alpha), this);
  }

  /// The [getShadeColor] extension is used to make a color darker or lighter,
  /// the [shadeValue] defines the amount in % that the shade should be changed.
  ///
  /// It can be used to make a shade of a color to be used in a gradient.
  /// By default it makes a color that is 15% lighter. If lighten is false
  /// it makes a color that is 15% darker by default.
  ///
  /// By default it does not affect black and white colors, but
  /// if [keepWhite] is set to false, it will darken white color when [lighten]
  /// is false and return a grey color.
  ///
  /// Wise versa for black with [keepBlack]
  /// set to false, it will lighten black color, when [lighten] is true and
  /// return a grey shade.
  ///
  /// White cannot be made lighter and black cannot be made
  /// darker, the extension just returns white or black for such attempts, with
  /// a quick exist from the call.
  Color getShadeColor({
    final int shadeValue = 15,
    final bool lighten = true,
    final bool keepBlack = true,
    final bool keepWhite = true,
  }) {
    if (shadeValue <= 0) {
      return this;
    }
    int _shadeValue = shadeValue;
    if (_shadeValue > 100) {
      _shadeValue = 100;
    }

    // Trying to make black darker, just return black
    if (this == Colors.black && !lighten) {
      return this;
    }
    // Black is defined to be kept as black.
    if (this == Colors.black && keepBlack) {
      return this;
    }
    // Make black lighter as lighten was set and we do not keepBlack
    if (this == Colors.black) {
      return this.lighten(_shadeValue);
    }

    // Trying to make white lighter, just return white
    if (this == Colors.white && lighten) {
      return this;
    }
    // White is defined to be kept as white.
    if (this == Colors.white && keepWhite) {
      return this;
    }
    // Make white darker as we do not keep white.
    if (this == Colors.white) {
      return darken(_shadeValue);
    }
    // We are dealing with some other color than white or black, so we
    // make it lighter or darker based on flag and requested shade %
    if (lighten) {
      return this.lighten(_shadeValue);
    } else {
      return darken(_shadeValue);
    }
  }

  /// Return uppercase Flutter style hex code string of the color.
  String get hexCode => value.toRadixString(16).toUpperCase().padLeft(8, '0');

  /// Return uppercase RGB hex code string, with # and no alpha value.
  /// This format is often used in APIs and in CSS color values..
  String get hex =>
      '#${value.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}';

  Color get opposite =>
      ThemeData.estimateBrightnessForColor(this) == Brightness.light
          ? Colors.black
          : Colors.white;
}

extension HexToColor on String {
  Color? hexToColor() {
    try {
      return Color(
          int.parse(toLowerCase().substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return null;
    }
  }

  Color? toHexColor() {
    try {
      return Color(
          int.parse(toLowerCase().substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return null;
    }
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc"
  /// with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign]
  /// is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
