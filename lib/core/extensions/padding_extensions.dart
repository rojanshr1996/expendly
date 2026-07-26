import 'package:expendly/core/constants/padding_constants.dart';
import 'package:flutter/material.dart';

extension PaddingExtension on Widget {
  Padding px(double padding) => Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: this,
      );

  Padding py(double padding) => Padding(padding: EdgeInsets.symmetric(vertical: padding), child: this);

  Padding defaultCanvasPadding() => Padding(padding: symmetricPaddingLarge, child: this);

  Padding defaultMediumPadding() => Padding(padding: symmetricPaddingMedium, child: this);

  Padding defaultSmallPadding() => Padding(padding: symmetricPaddingSmall, child: this);

  Padding defaultHorizontalPadding() => Padding(padding: horizontalPaddingLarge, child: this);

  Padding defaultVerticalPadding() => Padding(padding: verticalPaddingLarge, child: this);

  Padding defaultSmallVerticalPadding() => Padding(padding: verticalPaddingSmall, child: this);

  Padding defaultSmallHorizontalPadding() => Padding(padding: horizontalPaddingSmall, child: this);

  Padding defaultMediumVerticalPadding() => Padding(padding: verticalPaddingMedium, child: this);

  Padding defaultMediumHorizontalPadding() => Padding(padding: horizontalPaddingMedium, child: this);

  Padding padSymmetric({
    required double horizontalPad,
    required double verticalPad,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPad,
          vertical: verticalPad,
        ),
        child: this,
      );

  Padding pOnly({double left = 0, double top = 0, double right = 0, double bottom = 0}) => Padding(
        padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
        child: this,
      );

  Padding padAll(double value) => Padding(padding: EdgeInsets.all(value), child: this);
}

extension Numx on num {
  EdgeInsets get all => EdgeInsets.all(toDouble());
  EdgeInsets get padY => EdgeInsets.symmetric(vertical: toDouble());
  EdgeInsets get padX => EdgeInsets.symmetric(vertical: toDouble());
}

extension PaddingSym on (num, num) {
  //$1 refers to the first element (horizontal)
//$2 refers to the second element (vertical)
  EdgeInsets get padSym => EdgeInsets.symmetric(
        horizontal: $1.toDouble(),
        vertical: $2.toDouble(),
      );
}
