import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../plotter_attribute.dart';

/// The transformer attribute will scale and offset the item or group.
/// This has an effect on all items.
///
/// A translation attribute for setting a special translation on some data.
class TransAttrImpl implements TransAttr {
  /// The transformation to set.
  @override
  final Transformer? transform;

  /// True indicates the transformation should be multiplied with
  /// the current transformation at that time, false to just set
  /// the transformation overriding the current one at that time.
  ///
  /// The multiplier indicator.
  /// True indicates the transformation should be multiplied with
  /// the current transformation at that time, false to just set
  /// the transformation overriding the current one at that time.
  @override
  final bool multiply;

  /// The previous transformation.
  Transformer? _last;

  /// Creates a new transformation attribute.
  TransAttrImpl(
    final this.transform,
  )   : multiply = true,
        _last = null;

  /// Applies this transformation attribute, similar to pushing but while calculating the data bounds.
  @override
  Transformer apply(
    final Transformer trans,
  ) {
    _last = null;
    final _transform = transform;
    if (_transform != null) {
      _last = trans;
      if (multiply) {
        return trans.mul(_transform);
      } else {
        return _transform;
      }
    }
    return trans;
  }

  /// Un-applies this transformation attribute, similar as popping but while calculating the data bounds.
  @override
  Transformer unapply(
    Transformer trans,
  ) {
    final __last = _last;
    if (__last != null) {
      // ignore: parameter_assignments
      trans = __last;
      _last = null;
    }
    return trans;
  }

  /// Pushes the attribute to the renderer.
  @override
  void pushAttr(
    final PlotterRenderer r,
  ) {
    _last = null;
    final _transform = transform;
    if (_transform != null) {
      final rTransform = r.state.transform;
      _last = rTransform;
      if (multiply) {
        r.state.transform = rTransform!.mul(_transform);
      } else {
        r.state.transform = _transform;
      }
    }
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) {
    final __last = _last;
    if (__last != null) {
      r.state.transform = __last;
      _last = null;
    }
  }
}

/// A translation attribute for setting a special translation on some data.
abstract class TransAttr implements PlotterAttribute {
  /// The transformation to set.
  Transformer? get transform;

  /// True indicates the transformation should be multiplied with
  /// the current transformation at that time, false to just set
  /// the transformation overriding the current one at that time.
  ///
  /// The multiplier indicator.
  /// True indicates the transformation should be multiplied with
  /// the current transformation at that time, false to just set
  /// the transformation overriding the current one at that time.
  bool get multiply;

  /// Applies this transformation attribute, similar to pushing but while calculating the data bounds.
  Transformer apply(
    final Transformer trans,
  );

  /// Un-applies this transformation attribute, similar as popping but while calculating the data bounds.
  Transformer unapply(
    Transformer trans,
  );
}
