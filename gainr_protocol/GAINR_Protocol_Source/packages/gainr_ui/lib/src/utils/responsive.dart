/// Unified breakpoint constants matching Back.bet's proven values.
class GainrBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1100;
}

/// Returns responsive horizontal padding based on width.
/// Usage: `padding: EdgeInsets.symmetric(horizontal: gainrPadding(constraints.maxWidth))`
double gainrPadding(double width) {
  if (width < 600) return 16;
  if (width < 900) return 24;
  if (width < 1100) return 32;
  return 48;
}

/// Returns responsive hero font size based on width.
double gainrHeroFontSize(double width) {
  if (width < 600) return 28;
  if (width < 900) return 40;
  return 56;
}
