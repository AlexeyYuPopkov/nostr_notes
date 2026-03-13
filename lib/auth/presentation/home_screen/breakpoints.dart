import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart' as asc;
import 'package:flutter/widgets.dart';

const breakpoints = [SmallBreakpoint(), MediumBreakpoint(), LargeBreakpoint()];

sealed class Breakpoint extends asc.Breakpoint {
  const Breakpoint({
    super.beginWidth,
    super.endWidth,
    super.beginHeight,
    super.endHeight,
    super.andUp = false,
    super.platform,
    super.spacing = asc.kMaterialMediumAndUpSpacing,
    super.margin = asc.kMaterialMediumAndUpMargin,
    super.padding = asc.kMaterialPadding,
    super.recommendedPanes = 1,
    super.maxPanes = 1,
  });

  static Breakpoint activeBreakpointOf(BuildContext context) {
    return (asc.Breakpoint.activeBreakpointIn(context, breakpoints)
            as Breakpoint?) ??
        const SmallBreakpoint();
  }

  bool get isSmall => this is SmallBreakpoint;
  bool get isMedium => this is MediumBreakpoint;
  bool get isLarge => this is LargeBreakpoint;
  bool get isMediumOrLarge => isMedium || isLarge;

  @override
  bool operator >(covariant Breakpoint breakpoint);
  @override
  bool operator <(covariant Breakpoint breakpoint);

  @override
  bool operator >=(covariant Breakpoint breakpoint) {
    return this == breakpoint || this > breakpoint;
  }

  @override
  bool operator <=(covariant Breakpoint breakpoint) {
    return this == breakpoint || this < breakpoint;
  }

  @override
  bool between(covariant Breakpoint lower, covariant Breakpoint upper) {
    return this >= lower && this < upper;
  }
}

final class SmallBreakpoint extends Breakpoint {
  const SmallBreakpoint({
    super.andUp = false,
    super.endWidth = 792,
    super.spacing = asc.kMaterialMediumAndUpSpacing,
    super.margin = asc.kMaterialMediumAndUpMargin,
    super.padding = asc.kMaterialPadding * 2.0,
    super.recommendedPanes = 1,
    super.maxPanes = 1,
  });

  @override
  bool operator >(covariant Breakpoint breakpoint) => false;

  @override
  bool operator <(covariant Breakpoint breakpoint) {
    switch (breakpoint) {
      case SmallBreakpoint():
        return false;
      case MediumBreakpoint():
      case LargeBreakpoint():
        return true;
    }
  }
}

final class MediumBreakpoint extends Breakpoint {
  const MediumBreakpoint({
    super.andUp = false,
    super.beginWidth = 792,
    super.endWidth = 1164,
    super.spacing = asc.kMaterialMediumAndUpSpacing,
    super.margin = asc.kMaterialMediumAndUpMargin,
    super.padding = asc.kMaterialPadding * 2.0,
    super.recommendedPanes = 1,
    super.maxPanes = 1,
  });

  @override
  bool operator >(covariant Breakpoint breakpoint) {
    switch (breakpoint) {
      case SmallBreakpoint():
        return true;
      case MediumBreakpoint():
      case LargeBreakpoint():
        return false;
    }
  }

  @override
  bool operator <(covariant Breakpoint breakpoint) {
    switch (breakpoint) {
      case SmallBreakpoint():
        return false;
      case MediumBreakpoint():
        return false;
      case LargeBreakpoint():
        return true;
    }
  }
}

final class LargeBreakpoint extends Breakpoint {
  const LargeBreakpoint({
    super.andUp = false,
    super.beginWidth = 1164,
    super.endWidth,
    super.spacing = asc.kMaterialMediumAndUpSpacing,
    super.margin = asc.kMaterialMediumAndUpMargin,
    super.padding = asc.kMaterialPadding * 2.0,
    super.recommendedPanes = 2,
    super.maxPanes = 2,
  });

  @override
  bool operator >(covariant Breakpoint breakpoint) {
    switch (breakpoint) {
      case SmallBreakpoint():
      case MediumBreakpoint():
        return true;
      case LargeBreakpoint():
        return false;
    }
  }

  @override
  bool operator <(covariant Breakpoint breakpoint) => false;
}
