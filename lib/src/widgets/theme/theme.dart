import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff6f528a),
      surfaceTint: Color(0xff6f528a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xfff0dbff),
      onPrimaryContainer: Color(0xff563b71),
      secondary: Color(0xff665a6f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffedddf6),
      onSecondaryContainer: Color(0xff4d4356),
      tertiary: Color(0xff805157),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffffd9dc),
      onTertiaryContainer: Color(0xff653a40),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff7fe),
      onSurface: Color(0xff1e1a20),
      onSurfaceVariant: Color(0xff4a454e),
      outline: Color(0xff7c757e),
      outlineVariant: Color(0xffccc4ce),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inversePrimary: Color(0xffdbb9f9),
      primaryFixed: Color(0xfff0dbff),
      onPrimaryFixed: Color(0xff280d42),
      primaryFixedDim: Color(0xffdbb9f9),
      onPrimaryFixedVariant: Color(0xff563b71),
      secondaryFixed: Color(0xffedddf6),
      onSecondaryFixed: Color(0xff211829),
      secondaryFixedDim: Color(0xffd0c1d9),
      onSecondaryFixedVariant: Color(0xff4d4356),
      tertiaryFixed: Color(0xffffd9dc),
      onTertiaryFixed: Color(0xff321016),
      tertiaryFixedDim: Color(0xfff3b7bd),
      onTertiaryFixedVariant: Color(0xff653a40),
      surfaceDim: Color(0xffdfd8df),
      surfaceBright: Color(0xfffff7fe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xfff4ebf3),
      surfaceContainerHigh: Color(0xffeee6ee),
      surfaceContainerHighest: Color(0xffe8e0e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff442a5f),
      surfaceTint: Color(0xff6f528a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff7e619a),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3c3245),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff75687e),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff522a30),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff916066),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff7fe),
      onSurface: Color(0xff131015),
      onSurfaceVariant: Color(0xff39343d),
      outline: Color(0xff565059),
      outlineVariant: Color(0xff716b74),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inversePrimary: Color(0xffdbb9f9),
      primaryFixed: Color(0xff7e619a),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff654980),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff75687e),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff5c5065),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff916066),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff75484e),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffccc4cc),
      surfaceBright: Color(0xfffff7fe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff9f1f9),
      surfaceContainer: Color(0xffeee6ee),
      surfaceContainerHigh: Color(0xffe2dae2),
      surfaceContainerHighest: Color(0xffd7cfd7),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff3a1f54),
      surfaceTint: Color(0xff6f528a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff583d73),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff32283b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff504559),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff462126),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff683d43),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff7fe),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2f2a32),
      outlineVariant: Color(0xff4d4750),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff332f35),
      inversePrimary: Color(0xffdbb9f9),
      primaryFixed: Color(0xff583d73),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff41265b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff504559),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff392f42),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff683d43),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff4e272d),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbeb7be),
      surfaceBright: Color(0xfffff7fe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6eef6),
      surfaceContainer: Color(0xffe8e0e8),
      surfaceContainerHigh: Color(0xffdad2da),
      surfaceContainerHighest: Color(0xffccc4cc),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffdbb9f9),
      surfaceTint: Color(0xffdbb9f9),
      onPrimary: Color(0xff3e2458),
      primaryContainer: Color(0xff563b71),
      onPrimaryContainer: Color(0xfff0dbff),
      secondary: Color(0xffd0c1d9),
      onSecondary: Color(0xff362c3f),
      secondaryContainer: Color(0xff4d4356),
      onSecondaryContainer: Color(0xffedddf6),
      tertiary: Color(0xfff3b7bd),
      onTertiary: Color(0xff4b252a),
      tertiaryContainer: Color(0xff653a40),
      onTertiaryContainer: Color(0xffffd9dc),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff151218),
      onSurface: Color(0xffe8e0e8),
      onSurfaceVariant: Color(0xffccc4ce),
      outline: Color(0xff968e98),
      outlineVariant: Color(0xff4a454e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inversePrimary: Color(0xff6f528a),
      primaryFixed: Color(0xfff0dbff),
      onPrimaryFixed: Color(0xff280d42),
      primaryFixedDim: Color(0xffdbb9f9),
      onPrimaryFixedVariant: Color(0xff563b71),
      secondaryFixed: Color(0xffedddf6),
      onSecondaryFixed: Color(0xff211829),
      secondaryFixedDim: Color(0xffd0c1d9),
      onSecondaryFixedVariant: Color(0xff4d4356),
      tertiaryFixed: Color(0xffffd9dc),
      onTertiaryFixed: Color(0xff321016),
      tertiaryFixedDim: Color(0xfff3b7bd),
      onTertiaryFixedVariant: Color(0xff653a40),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff3c383e),
      surfaceContainerLowest: Color(0xff100d12),
      surfaceContainerLow: Color(0xff1e1a20),
      surfaceContainer: Color(0xff221e24),
      surfaceContainerHigh: Color(0xff2c292e),
      surfaceContainerHighest: Color(0xff373339),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffecd3ff),
      surfaceTint: Color(0xffdbb9f9),
      onPrimary: Color(0xff33184d),
      primaryContainer: Color(0xffa384c0),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffe7d7f0),
      onSecondary: Color(0xff2b2234),
      secondaryContainer: Color(0xff998ca3),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffd1d5),
      onTertiary: Color(0xff3f1a20),
      tertiaryContainer: Color(0xffb88389),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff151218),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffe3d9e4),
      outline: Color(0xffb7afba),
      outlineVariant: Color(0xff958e98),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inversePrimary: Color(0xff573c72),
      primaryFixed: Color(0xfff0dbff),
      onPrimaryFixed: Color(0xff1d0137),
      primaryFixedDim: Color(0xffdbb9f9),
      onPrimaryFixedVariant: Color(0xff442a5f),
      secondaryFixed: Color(0xffedddf6),
      onSecondaryFixed: Color(0xff160d1e),
      secondaryFixedDim: Color(0xffd0c1d9),
      onSecondaryFixedVariant: Color(0xff3c3245),
      tertiaryFixed: Color(0xffffd9dc),
      onTertiaryFixed: Color(0xff25060c),
      tertiaryFixedDim: Color(0xfff3b7bd),
      onTertiaryFixedVariant: Color(0xff522a30),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff474349),
      surfaceContainerLowest: Color(0xff09060b),
      surfaceContainerLow: Color(0xff201c22),
      surfaceContainer: Color(0xff2a272c),
      surfaceContainerHigh: Color(0xff353137),
      surfaceContainerHighest: Color(0xff403c42),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff9ebff),
      surfaceTint: Color(0xffdbb9f9),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffd7b5f5),
      onPrimaryContainer: Color(0xff15002b),
      secondary: Color(0xfff9ebff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffccbdd6),
      onSecondaryContainer: Color(0xff100818),
      tertiary: Color(0xffffebec),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffefb3ba),
      onTertiaryContainer: Color(0xff1e0307),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff151218),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff7edf8),
      outlineVariant: Color(0xffc9c0ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe8e0e8),
      inversePrimary: Color(0xff573c72),
      primaryFixed: Color(0xfff0dbff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffdbb9f9),
      onPrimaryFixedVariant: Color(0xff1d0137),
      secondaryFixed: Color(0xffedddf6),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffd0c1d9),
      onSecondaryFixedVariant: Color(0xff160d1e),
      tertiaryFixed: Color(0xffffd9dc),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfff3b7bd),
      onTertiaryFixedVariant: Color(0xff25060c),
      surfaceDim: Color(0xff151218),
      surfaceBright: Color(0xff534e55),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff221e24),
      surfaceContainer: Color(0xff332f35),
      surfaceContainerHigh: Color(0xff3e3a40),
      surfaceContainerHighest: Color(0xff4a454b),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );

  /// Custom Color
  static const customColor = ExtendedColor(
    seed: Color(0xff3f7ec7),
    value: Color(0xff3f7ec7),
    light: ColorFamily(
      color: Color(0xff3a608f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd3e3ff),
      onColorContainer: Color(0xff204876),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff3a608f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd3e3ff),
      onColorContainer: Color(0xff204876),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff3a608f),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffd3e3ff),
      onColorContainer: Color(0xff204876),
    ),
    dark: ColorFamily(
      color: Color(0xffa4c9fe),
      onColor: Color(0xff00315d),
      colorContainer: Color(0xff204876),
      onColorContainer: Color(0xffd3e3ff),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffa4c9fe),
      onColor: Color(0xff00315d),
      colorContainer: Color(0xff204876),
      onColorContainer: Color(0xffd3e3ff),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffa4c9fe),
      onColor: Color(0xff00315d),
      colorContainer: Color(0xff204876),
      onColorContainer: Color(0xffd3e3ff),
    ),
  );

  List<ExtendedColor> get extendedColors => [customColor];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
