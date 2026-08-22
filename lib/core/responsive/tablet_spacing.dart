/// Defines consistent spacing values for tablet and larger layouts.
/// These values are in raw dp and should not be scaled using ScreenUtil.
abstract class TabletSpacing {
  TabletSpacing._();

  static const double canvasPadding = 32.0;
  static const double sectionGap = 24.0;
  static const double cardPadding = 20.0;
  static const double gridGutter = 16.0;
  static const double railWidthExpanded = 220.0;
  static const double railWidthCollapsed = 72.0;
  static const double masterDetailGutter = 20.0;
  static const double contentMaxWidth = 1200.0;
}
