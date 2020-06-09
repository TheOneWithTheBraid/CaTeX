import 'package:catex/src/lookup/modes.dart';
import 'package:catex/src/lookup/symbols.dart';
import 'package:meta/meta.dart';

import 'generated/symbols.g.dart';

/// Returns the spacing that should be inserted in logical pixels based
/// on the [previous] and [current] characters in math mode.
///
/// This function also accepts inputs for [previous] and [current] that are not
/// single characters. For example, functions are treated as [_Spacing.ord]s.
double pixelSpacingFromCharacters({
  @required String previous,
  @required String current,
  @required double fontSize,
}) {
  assert(previous != null);
  assert(current != null);
  assert(fontSize != null);

  final previousSpacingType = previous.length != 1
          ? _Spacing.ord
          : symbols[CaTeXMode.math][previous]?.group?.asSpacingType ??
              _Spacing.ord,
      currentSpacingType = current.length != 1
          ? _Spacing.ord
          : symbols[CaTeXMode.math][current]?.group?.asSpacingType ??
              _Spacing.ord;
  return _spacings[previousSpacingType][currentSpacingType]
          ?.inPixels(fontSize) ??
      0;
}

/// Three types of spacing based on https://www.overleaf.com/learn/latex/Spacing_in_math_mode?nocdn=true.
enum Spacing {
  thinSpace,
  mediumSpace,
  thickSpace,
}

extension SpacingMeasurement on Spacing {
  /// Space value in pixels; converted from math units with the help of
  /// https://tex.stackexchange.com/a/41371/192809.
  double inPixels(double fontSize) {
    final inEm = _inMu / 18;
    // Assume that 1em is equal to the font size, i.e. that the
    // character m width is equal to the font size.
    return fontSize * inEm;
  }

  /// Space values in math units.
  double get _inMu {
    switch (this) {
      case Spacing.thinSpace:
        return 3;
      case Spacing.mediumSpace:
        return 4;
      case Spacing.thickSpace:
        return 5;
    }
    throw ArgumentError.value(this);
  }
}

/// Node types for spacing in math mode.
/// Based on https://github.com/KaTeX/KaTeX/blob/f7880acb02447b0e1c0643a3aac6b7f3b8349443/src/spacingData.js.
enum _Spacing {
  ord,
  op,
  bin,
  rel,
  open,
  close,
  punct,
  inner,
}

extension on SymbolGroup {
  _Spacing get asSpacingType {
    switch (this) {
      case SymbolGroup.mathord:
      case SymbolGroup.textord:
        return _Spacing.ord;
      case SymbolGroup.op:
        return _Spacing.op;
      case SymbolGroup.bin:
        return _Spacing.bin;
      case SymbolGroup.rel:
        return _Spacing.rel;
      case SymbolGroup.open:
        return _Spacing.open;
      case SymbolGroup.close:
        return _Spacing.close;
      case SymbolGroup.punct:
        return _Spacing.punct;
      case SymbolGroup.inner:
        return _Spacing.inner;
      case SymbolGroup.accent:
      case SymbolGroup.spacing:
    }
    return null;
  }
}

// The following is also based on https://github.com/KaTeX/KaTeX/blob/f7880acb02447b0e1c0643a3aac6b7f3b8349443/src/spacingData.js.

/// Spacing that should be used based on the previous and current character type.
const _spacings = <_Spacing, Map<_Spacing, Spacing>>{
  _Spacing.ord: {
    _Spacing.op: Spacing.thinSpace,
    _Spacing.bin: Spacing.mediumSpace,
    _Spacing.rel: Spacing.thickSpace,
    _Spacing.inner: Spacing.thinSpace,
  },
  _Spacing.op: {
    _Spacing.ord: Spacing.thinSpace,
    _Spacing.op: Spacing.thinSpace,
    _Spacing.rel: Spacing.thickSpace,
    _Spacing.inner: Spacing.thinSpace,
  },
  _Spacing.bin: {
    _Spacing.ord: Spacing.mediumSpace,
    _Spacing.op: Spacing.mediumSpace,
    _Spacing.open: Spacing.mediumSpace,
    _Spacing.inner: Spacing.mediumSpace,
  },
  _Spacing.rel: {
    _Spacing.ord: Spacing.thickSpace,
    _Spacing.op: Spacing.thickSpace,
    _Spacing.open: Spacing.thickSpace,
    _Spacing.inner: Spacing.thickSpace,
  },
  _Spacing.open: {},
  _Spacing.close: {
    _Spacing.op: Spacing.thinSpace,
    _Spacing.bin: Spacing.mediumSpace,
    _Spacing.rel: Spacing.thickSpace,
    _Spacing.inner: Spacing.thinSpace,
  },
  _Spacing.punct: {
    _Spacing.ord: Spacing.thinSpace,
    _Spacing.op: Spacing.thinSpace,
    _Spacing.rel: Spacing.thickSpace,
    _Spacing.open: Spacing.thinSpace,
    _Spacing.close: Spacing.thinSpace,
    _Spacing.punct: Spacing.thinSpace,
    _Spacing.inner: Spacing.thinSpace,
  },
  _Spacing.inner: {
    _Spacing.ord: Spacing.thinSpace,
    _Spacing.op: Spacing.thinSpace,
    _Spacing.bin: Spacing.mediumSpace,
    _Spacing.rel: Spacing.thickSpace,
    _Spacing.open: Spacing.thinSpace,
    _Spacing.punct: Spacing.thinSpace,
    _Spacing.inner: Spacing.thinSpace,
  },
};

// todo: [_tightSpacings] is unsupported.
// Spacing relationships for script and scriptscript styles.
const _tightSpacings = <_Spacing, Map<_Spacing, Spacing>>{
  _Spacing.ord: {
    _Spacing.op: Spacing.thinSpace,
  },
  _Spacing.op: {
    _Spacing.ord: Spacing.thinSpace,
    _Spacing.op: Spacing.thinSpace,
  },
  _Spacing.bin: {},
  _Spacing.rel: {},
  _Spacing.open: {},
  _Spacing.close: {
    _Spacing.op: Spacing.thinSpace,
  },
  _Spacing.punct: {},
  _Spacing.inner: {
    _Spacing.op: Spacing.thinSpace,
  },
};
