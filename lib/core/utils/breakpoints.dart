import 'package:flutter/widgets.dart';

/// Screen layout categories based on width breakpoints specified in the assignment.
enum ScreenType {
  /// Width < 600 dp: standard phone portrait, 2-column product grid, bottom navigation bar.
  compact,

  /// Width 600 - 1024 dp: tablet portrait / large phone landscape, 3-4 column grid, navigation rail.
  medium,

  /// Width > 1024 dp: tablet landscape / desktop, master-detail layout.
  expanded,
}

/// Breakpoint helper utilities according to Material 3 responsive layout specifications.
class Breakpoints {
  const Breakpoints._();

  static const double compactMaxWidth = 599.9;
  static const double mediumMinWidth = 600.0;
  static const double mediumMaxWidth = 1024.0;
  static const double expandedMinWidth = 1024.1;

  /// Returns the [ScreenType] for the given [width].
  static ScreenType fromWidth(double width) {
    if (width < mediumMinWidth) {
      return ScreenType.compact;
    } else if (width <= mediumMaxWidth) {
      return ScreenType.medium;
    } else {
      return ScreenType.expanded;
    }
  }

  /// Returns the [ScreenType] using the ambient [BuildContext].
  static ScreenType of(BuildContext context) {
    return fromWidth(MediaQuery.sizeOf(context).width);
  }

  /// Returns the responsive product grid cross-axis column count for a given width.
  static int gridColumnCount(double width) {
    if (width < 350) {
      return 1;
    } else if (width < mediumMinWidth) {
      return 2;
    } else if (width < 840) {
      return 3;
    } else if (width <= mediumMaxWidth) {
      return 4;
    } else {
      return 5;
    }
  }
}
