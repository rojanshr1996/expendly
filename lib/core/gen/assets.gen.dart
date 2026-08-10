/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsGoogleFontsGen {
  const $AssetsGoogleFontsGen();

  /// File path: assets/google_fonts/HankenGrotesk-Bold.ttf
  String get hankenGroteskBold => 'assets/google_fonts/HankenGrotesk-Bold.ttf';

  /// File path: assets/google_fonts/HankenGrotesk-Medium.ttf
  String get hankenGroteskMedium =>
      'assets/google_fonts/HankenGrotesk-Medium.ttf';

  /// File path: assets/google_fonts/HankenGrotesk-Regular.ttf
  String get hankenGroteskRegular =>
      'assets/google_fonts/HankenGrotesk-Regular.ttf';

  /// File path: assets/google_fonts/HankenGrotesk-SemiBold.ttf
  String get hankenGroteskSemiBold =>
      'assets/google_fonts/HankenGrotesk-SemiBold.ttf';

  /// File path: assets/google_fonts/JetBrainsMono-Bold.ttf
  String get jetBrainsMonoBold => 'assets/google_fonts/JetBrainsMono-Bold.ttf';

  /// File path: assets/google_fonts/JetBrainsMono-Medium.ttf
  String get jetBrainsMonoMedium =>
      'assets/google_fonts/JetBrainsMono-Medium.ttf';

  /// File path: assets/google_fonts/JetBrainsMono-Regular.ttf
  String get jetBrainsMonoRegular =>
      'assets/google_fonts/JetBrainsMono-Regular.ttf';

  /// List of all assets
  List<String> get values => [
        hankenGroteskBold,
        hankenGroteskMedium,
        hankenGroteskRegular,
        hankenGroteskSemiBold,
        jetBrainsMonoBold,
        jetBrainsMonoMedium,
        jetBrainsMonoRegular
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/expendly_icon.png
  AssetGenImage get expendlyIcon =>
      const AssetGenImage('assets/images/expendly_icon.png');

  /// File path: assets/images/expendly_logo.png
  AssetGenImage get expendlyLogo =>
      const AssetGenImage('assets/images/expendly_logo.png');

  /// File path: assets/images/expendly_logo_light.png
  AssetGenImage get expendlyLogoLight =>
      const AssetGenImage('assets/images/expendly_logo_light.png');

  /// List of all assets
  List<AssetGenImage> get values =>
      [expendlyIcon, expendlyLogo, expendlyLogoLight];
}

class Assets {
  Assets._();

  static const $AssetsGoogleFontsGen googleFonts = $AssetsGoogleFontsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
