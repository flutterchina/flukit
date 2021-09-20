import 'package:flutter/widgets.dart';

/// Animates the position of a widget relative to its normal position
/// ignoring the animation direction(always slide along one direction).
/// Typically, is used in combination with [AnimatedSwitcher].
class SlideTransitionX extends AnimatedWidget {
  SlideTransitionX({
    Key? key,
    required Animation<double> position,
    this.transformHitTests = true,
    this.direction = AxisDirection.down,
    required this.child,
  }) : super(key: key, listenable: position) {
    _tween = Tween(begin: Offset(0, 1), end: Offset.zero);
    switch (direction) {
      case AxisDirection.up:
        _tween.begin = Offset(0, 1);
        break;
      case AxisDirection.right:
        _tween.begin = Offset(-1, 0);
        break;
      case AxisDirection.down:
        _tween.begin = Offset(0, -1);
        break;
      case AxisDirection.left:
        _tween.begin = Offset(1, 0);
        break;
    }
  }

  final bool transformHitTests;

  final Widget child;

  final AxisDirection direction;

  late final Tween<Offset> _tween;

  @override
  Widget build(BuildContext context) {
    final position = listenable as Animation<double>;
    Offset offset = _tween.evaluate(position);
    if (position.status == AnimationStatus.reverse) {
      switch (direction) {
        case AxisDirection.up:
          offset = Offset(offset.dx, -offset.dy);
          break;
        case AxisDirection.right:
          offset = Offset(-offset.dx, offset.dy);
          break;
        case AxisDirection.down:
          offset = Offset(offset.dx, -offset.dy);
          break;
        case AxisDirection.left:
          offset = Offset(-offset.dx, offset.dy);
          break;
      }
    }
    return FractionalTranslation(
      translation: offset,
      transformHitTests: transformHitTests,
      child: child,
    );
  }
}
